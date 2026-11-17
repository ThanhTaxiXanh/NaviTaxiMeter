"""Isolated real-SQLite ACK transaction proof. NEVER use as app storage.

Creates the current v3 active_trip and active_trip_route table shapes plus two
experimental fence/ACK tables inside a dedicated temporary test-only DB.
No Android GPS, production fares, or native SQLite integration.
"""
from dataclasses import dataclass
from hashlib import sha256
from pathlib import Path
import json
import math
import sqlite3
import tempfile


class CheckpointConflict(RuntimeError):
    """Stale, contradictory or unsafe checkpoint operation."""


class CheckpointAckLost(RuntimeError):
    """The SQLite transaction committed but its response was lost."""


@dataclass(frozen=True)
class Fence:
    session_id: str
    generation: int

    def __post_init__(self):
        if not 0 < len(self.session_id) <= 128 or self.generation <= 0:
            raise ValueError("Invalid session fence")


@dataclass(frozen=True)
class RouteFix:
    sequence: int
    lat: float
    lon: float
    recorded_at: str
    accuracy: float
    speed: float
    segment: int
    elapsed_nanos: int
    is_mocked: bool = False

    def checked(self):
        values = (self.lat, self.lon, self.accuracy, self.speed)
        if (self.sequence < 0 or not self.recorded_at or self.segment < 0 or
                self.elapsed_nanos <= 0 or self.is_mocked or
                any(not math.isfinite(v) for v in values) or
                abs(self.lat) > 90 or abs(self.lon) > 180 or
                not 0 <= self.accuracy <= 30 or not 0 <= self.speed <= 220):
            raise CheckpointConflict("Untrusted technical GPS fixture")

    def row(self):
        return (self.sequence, self.lat, self.lon, self.recorded_at,
                self.accuracy, self.speed, self.segment)

    def fingerprint(self):
        # Conflict guard, not authentication of real physical GNSS.
        raw = json.dumps((self.row(), self.elapsed_nanos, self.is_mocked),
                         separators=(",", ":"), allow_nan=False)
        return sha256(raw.encode("utf-8")).hexdigest()


@dataclass(frozen=True)
class CommitAck:
    fence: Fence
    sequence: int
    checkpoint_id: str


class IsolatedSqliteCheckpointProof:
    """A real SQLite transaction test, completely disconnected from the app."""

    def __init__(self, database_path: Path):
        self.database_path = Path(database_path)
        parent = self.database_path.parent.resolve()
        if (self.database_path.name != "DISPOSABLE_TEST_ONLY.db" or
                not parent.name.startswith("navitaxi-sqlite-proof-") or
                parent.parent != Path(tempfile.gettempdir()).resolve() or
                self.database_path.is_symlink()):
            raise ValueError("Refuse any non-disposable application DB path")

    def _db(self):
        db = sqlite3.connect(self.database_path, timeout=10, isolation_level=None)
        db.execute("PRAGMA busy_timeout=10000")
        db.execute("PRAGMA foreign_keys=ON")
        return db

    def create_disposable_schema(self):
        db = self._db()
        try:
            db.executescript("""
                CREATE TABLE active_trip (
                    id INTEGER PRIMARY KEY CHECK(id=1),
                    payload TEXT NOT NULL, updated_at TEXT NOT NULL);
                CREATE TABLE active_trip_route (
                    sequence INTEGER PRIMARY KEY,
                    latitude REAL NOT NULL, longitude REAL NOT NULL,
                    recorded_at TEXT NOT NULL, accuracy_meters REAL NOT NULL,
                    speed_kmh REAL NOT NULL, segment INTEGER NOT NULL);
                -- These next TWO tables exist ONLY in this disposable test DB.
                CREATE TABLE checkpoint_fence (
                    id INTEGER PRIMARY KEY CHECK(id=1),
                    session_id TEXT NOT NULL, generation INTEGER NOT NULL,
                    last_sequence INTEGER NOT NULL, last_gnss_nanos INTEGER NOT NULL,
                    phase TEXT NOT NULL);
                CREATE TABLE checkpoint_ack (
                    session_id TEXT NOT NULL, generation INTEGER NOT NULL,
                    sequence INTEGER NOT NULL, sample_digest TEXT NOT NULL,
                    checkpoint_id TEXT NOT NULL,
                    PRIMARY KEY(session_id, generation, sequence));
            """)
        finally:
            db.close()

    def reserve(self, fence: Fence):
        db = self._db()
        try:
            db.execute("BEGIN IMMEDIATE")
            db.execute("INSERT INTO active_trip (id,payload,updated_at) VALUES (1,?,?)",
                       (json.dumps({"routeStorage": "sqlite-v3", "routeCount": 0,
                                    "disposableProofOnly": True}), "test-only"))
            db.execute("INSERT INTO checkpoint_fence VALUES (1,?,?,-1,-1,'TEST_OPEN')",
                       (fence.session_id, fence.generation))
            db.commit()
        except BaseException:
            db.rollback()
            raise
        finally:
            db.close()

    def append_and_ack(self, fence: Fence, fix: RouteFix,
                       *, lose_ack_after_commit: bool = False) -> CommitAck:
        fix.checked()
        db = self._db()
        try:
            db.execute("BEGIN IMMEDIATE")
            owner = db.execute("SELECT session_id,generation,last_sequence,"
                               "last_gnss_nanos,phase FROM checkpoint_fence "
                               "WHERE id=1").fetchone()
            if owner is None or tuple(owner[:2]) != (fence.session_id, fence.generation):
                raise CheckpointConflict("Stale session/generation")
            _, _, last_seq, last_nanos, phase = owner
            if phase != "TEST_OPEN":
                raise CheckpointConflict("Not an active disposable session")
            header = db.execute("SELECT payload FROM active_trip WHERE id=1").fetchone()
            current = db.execute("SELECT COUNT(*),MAX(sequence) FROM "
                                 "active_trip_route").fetchone()
            if (header is None or current[0] != last_seq + 1 or
                    (current[1] if current[1] is not None else -1) != last_seq or
                    json.loads(header[0]).get("routeCount") != last_seq + 1):
                raise CheckpointConflict("Persisted header/route checkpoint differs")
            digest = fix.fingerprint()
            if fix.sequence == last_seq:
                saved = db.execute("SELECT sample_digest,checkpoint_id FROM "
                                   "checkpoint_ack WHERE session_id=? AND generation=? "
                                   "AND sequence=?",
                                   (fence.session_id, fence.generation, fix.sequence)
                                   ).fetchone()
                row = db.execute("SELECT sequence,latitude,longitude,recorded_at,"
                                 "accuracy_meters,speed_kmh,segment FROM "
                                 "active_trip_route WHERE sequence=?",
                                 (fix.sequence,)).fetchone()
                if saved is None or saved[0] != digest or row != fix.row():
                    raise CheckpointConflict("Conflicting retry at committed sequence")
                db.commit()
                return CommitAck(fence, fix.sequence, saved[1])
            if fix.sequence != last_seq + 1:
                raise CheckpointConflict("Out-of-order or missing GPS sequence")
            if last_nanos >= 0 and (fix.elapsed_nanos <= last_nanos or
                                    fix.elapsed_nanos - last_nanos > 12_000_000_000):
                raise CheckpointConflict("GNSS reversal or missing signal interval")
            checkpoint_id = sha256(
                f"{fence.session_id}:{fence.generation}:{fix.sequence}:{digest}".encode()
            ).hexdigest()
            db.execute("INSERT INTO active_trip_route (sequence,latitude,longitude,"
                       "recorded_at,accuracy_meters,speed_kmh,segment) "
                       "VALUES (?,?,?,?,?,?,?)", fix.row())
            db.execute("UPDATE active_trip SET payload=?,updated_at=? WHERE id=1",
                       (json.dumps({"routeStorage": "sqlite-v3",
                                    "routeCount": fix.sequence + 1,
                                    "disposableProofOnly": True}), "test-only"))
            db.execute("UPDATE checkpoint_fence SET last_sequence=?,"
                       "last_gnss_nanos=? WHERE id=1",
                       (fix.sequence, fix.elapsed_nanos))
            db.execute("INSERT INTO checkpoint_ack VALUES (?,?,?,?,?)",
                       (fence.session_id, fence.generation, fix.sequence,
                        digest, checkpoint_id))
            db.commit()
            # A committed result, never a pre-transaction or dispatched ACK.
            if lose_ack_after_commit:
                raise CheckpointAckLost("Simulated lost response AFTER SQLite commit")
            return CommitAck(fence, fix.sequence, checkpoint_id)
        except BaseException:
            db.rollback()
            raise
        finally:
            db.close()

    def recover_paused(self):
        """Recovery writes PAUSED and has no resume operation."""
        db = self._db()
        try:
            db.execute("BEGIN IMMEDIATE")
            owner = db.execute("SELECT session_id,generation,last_sequence "
                               "FROM checkpoint_fence WHERE id=1").fetchone()
            if owner is None:
                raise CheckpointConflict("No durable session")
            count, last = db.execute("SELECT COUNT(*),MAX(sequence) FROM "
                                     "active_trip_route").fetchone()
            if count != owner[2] + 1 or (last if last is not None else -1) != owner[2]:
                raise CheckpointConflict("Route/checkpoint count mismatch")
            header = db.execute("SELECT payload FROM active_trip WHERE id=1").fetchone()
            if header is None or json.loads(header[0]).get("routeCount") != count:
                raise CheckpointConflict("Active header mismatch")
            db.execute("UPDATE checkpoint_fence SET phase='PAUSED' WHERE id=1")
            db.commit()
            return {"session_id": owner[0], "generation": owner[1],
                    "last_sequence": owner[2], "phase": "PAUSED"}
        except BaseException:
            db.rollback()
            raise
        finally:
            db.close()

    def evidence(self):
        """Technical test metrics only, no passenger data."""
        db = self._db()
        try:
            header = db.execute("SELECT payload FROM active_trip WHERE id=1").fetchone()
            route_count = db.execute("SELECT COUNT(*) FROM active_trip_route").fetchone()[0]
            ack_count = db.execute("SELECT COUNT(*) FROM checkpoint_ack").fetchone()[0]
            owner = db.execute("SELECT last_sequence,phase FROM checkpoint_fence "
                               "WHERE id=1").fetchone()
            return {"header": json.loads(header[0]) if header else None,
                    "route_count": route_count, "ack_count": ack_count,
                    "last_sequence": owner[0] if owner else None,
                    "phase": owner[1] if owner else None}
        finally:
            db.close()
