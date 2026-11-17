"""Issue #3 P3: fixture-only real SQLite clone/backup/migration tests."""

from pathlib import Path
import shutil
import sqlite3
import tempfile
import unittest

from v3_clone_migration_proof import (
    DB_NAME, UnsafeFixture, backup_fixture, create_v3_fixture,
    dry_run_v4_on_restore, fixture_root, inspect_bundle,
    restore_to_new_files,
)


class TestDisposableV3Clone(unittest.TestCase):
    def setUp(self):
        self.root = fixture_root()
        self.src, self.prefs = create_v3_fixture(self.root)

    def tearDown(self):
        shutil.rmtree(self.root)

    def test_v3_fixture_matches_real_app_table_layout(self):
        with sqlite3.connect(self.src) as db:
            self.assertEqual(db.execute("PRAGMA user_version").fetchone()[0], 3)
            self.assertEqual(len(list(db.execute("SELECT * FROM trips"))), 1)
            self.assertEqual(len(list(db.execute("SELECT * FROM active_trip_route"))), 2)

    def test_bundle_copies_receipts_route_header_and_confirmed_prefs(self):
        manifest = backup_fixture(self.root)
        self.assertEqual(manifest["schema_version"], 3)
        self.assertEqual(manifest["receipt_count"], 1)
        self.assertEqual(manifest["route_count"], 2)
        self.assertEqual(len(inspect_bundle(self.root)["receipts"]), 1)

    def test_restore_matches_backup_and_will_not_overwrite(self):
        backup_fixture(self.root)
        restored = restore_to_new_files(self.root)
        self.assertEqual(restored["version"], 3)
        self.assertEqual(len(restored["route"]), 2)
        with self.assertRaises(UnsafeFixture):
            restore_to_new_files(self.root)

    def test_v4_dry_run_uses_restored_clone_and_preserves_source(self):
        backup_fixture(self.root)
        previous_source = self.src.read_bytes()
        restore_to_new_files(self.root)
        migrated = dry_run_v4_on_restore(self.root)
        self.assertEqual(migrated["version"], 4)
        self.assertEqual(len(migrated["receipts"]), 1)
        self.assertEqual(self.src.read_bytes(), previous_source)
        self.assertEqual(inspect_bundle(self.root)["version"], 3)

    def test_injected_migration_failure_rolls_back_new_tables_and_version(self):
        backup_fixture(self.root)
        restore_to_new_files(self.root)
        with self.assertRaises(RuntimeError):
            dry_run_v4_on_restore(self.root, inject_error=True)
        with sqlite3.connect(self.root / "restored" / "restored.db") as db:
            self.assertEqual(db.execute("PRAGMA user_version").fetchone()[0], 3)
            tables = {r[0] for r in db.execute(
                "SELECT name FROM sqlite_master WHERE type='table'")}
            self.assertNotIn("checkpoint_fence", tables)
            self.assertNotIn("checkpoint_ack", tables)
        self.assertEqual(len(inspect_bundle(self.root)["receipts"]), 1)

    def test_tampered_backup_db_is_rejected_before_restore(self):
        backup_fixture(self.root)
        with open(self.root / "bundle" / "snapshot.db", "ab") as fd:
            fd.write(b"TAMPERED")
        with self.assertRaises(UnsafeFixture):
            inspect_bundle(self.root)

    def test_tampered_tariff_preferences_are_rejected(self):
        backup_fixture(self.root)
        (self.root / "bundle" / "preferences.json").write_text(
            '{"navi_confirmed_tariffs_v1":"CHANGED"}')
        with self.assertRaises(UnsafeFixture):
            restore_to_new_files(self.root)

    def test_bad_route_count_prevents_backup(self):
        with sqlite3.connect(self.src) as db:
            db.execute("DELETE FROM active_trip_route WHERE sequence=1")
        with self.assertRaises(UnsafeFixture):
            backup_fixture(self.root)
        self.assertFalse((self.root / "bundle").exists())

    def test_outside_path_production_filename_is_refused(self):
        other = Path(tempfile.gettempdir()) / "navitaximeter_v1.db"
        with self.assertRaises(UnsafeFixture):
            create_v3_fixture(other)

    def test_symlink_database_is_refused(self):
        self.src.unlink()
        self.src.symlink_to(self.root / "missing.db")
        with self.assertRaises(UnsafeFixture):
            backup_fixture(self.root)


if __name__ == "__main__":
    unittest.main()