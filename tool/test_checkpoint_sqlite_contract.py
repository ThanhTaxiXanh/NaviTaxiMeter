"""Actual SQLite transaction tests on a disposable DB, never app data."""
import concurrent.futures
import sqlite3
import tempfile
import threading
import unittest
from pathlib import Path
from checkpoint_sqlite_contract import (
    CheckpointAckLost, CheckpointConflict, Fence,
    IsolatedSqliteCheckpointProof, RouteFix,
)


class IsolatedCheckpointSqliteTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="navitaxi-sqlite-proof-")
        self.path = Path(self.temp.name) / "DISPOSABLE_TEST_ONLY.db"
        self.writer = IsolatedSqliteCheckpointProof(self.path)
        self.writer.create_disposable_schema()
        self.fence = Fence("test-session-A", 7001)
        self.writer.reserve(self.fence)

    def tearDown(self):
        self.temp.cleanup()

    def fix(self, sequence=0, speed=10.0, lat=0.0, nanos=None):
        # Technical-only numbers, not real/simulated driving-route GPS.
        return RouteFix(
            sequence=sequence, lat=lat, lon=0.0,
            recorded_at=f"test-sample-{sequence}", accuracy=4.0,
            speed=speed, segment=0,
            elapsed_nanos=(nanos if nanos is not None else
                           1_000_000_000 + 3_000_000_000 * sequence),
        )

    def test_00_refuses_non_disposable_database_and_symlink(self):
        with self.assertRaises(ValueError):
            IsolatedSqliteCheckpointProof(
                Path(self.temp.name) / "navitaximeter_v1.db")
        with self.assertRaises(ValueError):
            IsolatedSqliteCheckpointProof(Path(self.temp.name) / "renamed.db")
        with self.assertRaises(ValueError):
            IsolatedSqliteCheckpointProof(
                Path(self.temp.name) / "elsewhere" / "DISPOSABLE_TEST_ONLY.db")
        self.path.unlink()
        self.path.symlink_to(Path(self.temp.name) / "renamed.db")
        try:
            with self.assertRaises(ValueError):
                IsolatedSqliteCheckpointProof(self.path)
        finally:
            self.path.unlink()

    def test_real_sqlite_commit_precedes_ack_and_survives_reopen(self):
        ack = self.writer.append_and_ack(self.fence, self.fix())
        self.assertEqual(ack.sequence, 0)
        self.assertEqual(ack.fence, self.fence)
        reopened = IsolatedSqliteCheckpointProof(self.path)
        self.assertEqual(reopened.evidence()["last_sequence"], 0)
        self.assertEqual(reopened.evidence()["header"]["routeCount"], 1)
        self.assertEqual(reopened.append_and_ack(self.fence, self.fix()), ack)
        self.assertEqual(reopened.evidence()["ack_count"], 1)

    def test_route_insert_error_rolls_back_header_owner_and_ack(self):
        with sqlite3.connect(self.path) as db:
            db.execute("""CREATE TRIGGER block_route BEFORE INSERT
                          ON active_trip_route BEGIN
                          SELECT RAISE(ABORT,'injected SQLite route failure'); END""")
        with self.assertRaises(sqlite3.IntegrityError):
            self.writer.append_and_ack(self.fence, self.fix())
        state = self.writer.evidence()
        self.assertEqual(state["route_count"], 0)
        self.assertEqual(state["ack_count"], 0)
        self.assertEqual(state["last_sequence"], -1)
        self.assertEqual(state["header"]["routeCount"], 0)

    def test_header_write_error_rolls_back_route_and_ack(self):
        with sqlite3.connect(self.path) as db:
            db.execute("""CREATE TRIGGER block_header BEFORE UPDATE
                          ON active_trip BEGIN
                          SELECT RAISE(ABORT,'injected SQLite header failure'); END""")
        with self.assertRaises(sqlite3.IntegrityError):
            self.writer.append_and_ack(self.fence, self.fix())
        self.assertEqual(self.writer.evidence()["route_count"], 0)
        self.assertEqual(self.writer.evidence()["ack_count"], 0)
        self.assertEqual(self.writer.evidence()["header"]["routeCount"], 0)

    def test_identical_replay_is_idempotent_but_conflicts_are_rejected(self):
        ack = self.writer.append_and_ack(self.fence, self.fix())
        self.assertEqual(self.writer.append_and_ack(self.fence, self.fix()), ack)
        for altered in (self.fix(lat=0.01), self.fix(speed=27)):
            with self.assertRaises(CheckpointConflict):
                self.writer.append_and_ack(self.fence, altered)
        self.assertEqual(self.writer.evidence()["ack_count"], 1)
        self.assertEqual(self.writer.evidence()["route_count"], 1)

    def test_stale_generation_and_sequence_gap_never_write(self):
        with self.assertRaises(CheckpointConflict):
            self.writer.append_and_ack(Fence("test-session-A", 7002), self.fix())
        with self.assertRaises(CheckpointConflict):
            self.writer.append_and_ack(self.fence, self.fix(sequence=1))
        self.assertEqual(self.writer.evidence()["route_count"], 0)

    def test_mocked_or_discontinuous_gnss_never_acks(self):
        self.writer.append_and_ack(self.fence, self.fix())
        bad = [
            self.fix(1, nanos=999_999_999),
            self.fix(1, nanos=13_000_000_001),
            RouteFix(1, 0.0, 0.0, "technical", 3, 15, 0, 3_000_000_000, True),
        ]
        for candidate in bad:
            with self.assertRaises(CheckpointConflict):
                self.writer.append_and_ack(self.fence, candidate)
        self.assertEqual(self.writer.evidence()["ack_count"], 1)
        self.assertEqual(self.writer.evidence()["route_count"], 1)

    def test_commit_can_succeed_while_ack_transport_fails(self):
        with self.assertRaises(CheckpointAckLost):
            self.writer.append_and_ack(
                self.fence, self.fix(), lose_ack_after_commit=True)
        self.assertEqual(self.writer.evidence()["ack_count"], 1)
        recovered = IsolatedSqliteCheckpointProof(self.path).recover_paused()
        self.assertEqual(recovered["phase"], "PAUSED")
        self.assertEqual(recovered["last_sequence"], 0)
        with self.assertRaises(CheckpointConflict):
            self.writer.append_and_ack(self.fence, self.fix(sequence=1))

    def test_start_without_fix_recovers_only_paused(self):
        state = self.writer.recover_paused()
        self.assertEqual(state["phase"], "PAUSED")
        self.assertEqual(state["last_sequence"], -1)
        with self.assertRaises(CheckpointConflict):
            self.writer.append_and_ack(self.fence, self.fix())

    def test_corrupted_row_blocks_recovery(self):
        self.writer.append_and_ack(self.fence, self.fix())
        with sqlite3.connect(self.path) as db:
            db.execute("DELETE FROM active_trip_route WHERE sequence=0")
        with self.assertRaises(CheckpointConflict):
            self.writer.recover_paused()
        self.assertEqual(self.writer.evidence()["ack_count"], 1)
        self.assertEqual(self.writer.evidence()["phase"], "TEST_OPEN")

    def test_corrupted_header_blocks_duplicate_ack_and_next_sequence(self):
        self.writer.append_and_ack(self.fence, self.fix())
        with sqlite3.connect(self.path) as db:
            db.execute("UPDATE active_trip SET payload=? WHERE id=1",
                       ('{"routeCount":999}',))
        for candidate in (self.fix(), self.fix(sequence=1)):
            with self.assertRaises(CheckpointConflict):
                self.writer.append_and_ack(self.fence, candidate)
        self.assertEqual(self.writer.evidence()["ack_count"], 1)

    def test_eight_concurrent_connections_commit_one_ack(self):
        start = threading.Event()

        def worker():
            start.wait(timeout=10)
            return IsolatedSqliteCheckpointProof(
                self.path).append_and_ack(self.fence, self.fix())

        with concurrent.futures.ThreadPoolExecutor(max_workers=8) as pool:
            futures = [pool.submit(worker) for _ in range(8)]
            start.set()
            acks = [future.result(timeout=15) for future in futures]
        self.assertTrue(all(ack == acks[0] for ack in acks))
        self.assertEqual(self.writer.evidence()["route_count"], 1)
        self.assertEqual(self.writer.evidence()["ack_count"], 1)


if __name__ == "__main__":
    unittest.main()
