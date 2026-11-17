"""Issue #3 P3: disposable SQLite v3 clone and dual-source backup DRY RUN.

Never accepts a production database path or actual SharedPreferences data.
This is a Python sqlite3 laboratory proof, NOT Flutter sqflite or app migration.
"""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
import shutil
import sqlite3
import tempfile


class UnsafeFixture(ValueError):
    """Refuse untrusted source or an inconsistent clone."""


DB_NAME = "DISPOSABLE_V3_CLONE_ONLY.db"
PREFS_NAME = "DISPOSABLE_PREFS_ONLY.json"
PREFS_KEY = "navi_confirmed_tariffs_v1"


def fixture_root() -> Path:
    return Path(tempfile.mkdtemp(prefix="navitaxi-v3-clone-"))


def _check(root: Path, location: Path, filename: str) -> None:
    root = Path(root)
    location = Path(location)
    if (root.is_symlink() or not root.is_dir() or
            root.parent.resolve() != Path(tempfile.gettempdir()).resolve() or
            not root.name.startswith("navitaxi-v3-clone-") or
            location.is_symlink() or location.parent.resolve() != root.resolve() or
            location.name != filename):
        raise UnsafeFixture("Only a dedicated disposable fixture is allowed")


def _digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def _inventory(db: sqlite3.Connection) -> dict:
    integrity = db.execute("PRAGMA integrity_check").fetchone()
    if integrity != ("ok",):
        raise UnsafeFixture("Integrity check failed")
    version = db.execute("PRAGMA user_version").fetchone()[0]
    tables = {r[0] for r in db.execute(
        "SELECT name FROM sqlite_master WHERE type='table'")}
    required = {"trips", "active_trip", "active_trip_route"}
    if not required.issubset(tables):
        raise UnsafeFixture("Missing v3 tables")
    receipts = list(db.execute("SELECT id,started_at,total_fare,distance_km,payload "
                               "FROM trips ORDER BY id"))
    header = list(db.execute("SELECT id,payload,updated_at FROM active_trip"))
    route = list(db.execute("SELECT sequence,latitude,longitude,recorded_at,"
                            "accuracy_meters,speed_kmh,segment "
                            "FROM active_trip_route ORDER BY sequence"))
    if len(header) != 1 or header[0][0] != 1:
        raise UnsafeFixture("Expected exactly one test active trip")
    decoded = json.loads(header[0][1])
    if (decoded.get("routeStorage") != "sqlite-v3" or
            decoded.get("routeCount") != len(route) or
            [row[0] for row in route] != list(range(len(route)))):
        raise UnsafeFixture("Route/header drift")
    return {"version": version, "receipts": receipts,
            "active": header, "route": route}


def _snapshot(db_path: Path) -> dict:
    with sqlite3.connect(db_path) as db:
        return _inventory(db)


def _verified_prefs(prefs_path: Path) -> bytes:
    data = prefs_path.read_bytes()
    decoded = json.loads(data)
    if (not isinstance(decoded, dict) or
            set(decoded) != {PREFS_KEY} or
            not isinstance(decoded[PREFS_KEY], str) or
            not decoded[PREFS_KEY]):
        raise UnsafeFixture("Fixture tariff preferences invalid")
    return data


def create_v3_fixture(root: Path) -> tuple[Path, Path]:
    """Fake rows prove preservation only; coordinates/fare are NOT real."""
    root = Path(root)
    dbpath = root / DB_NAME
    prefspath = root / PREFS_NAME
    _check(root, dbpath, DB_NAME)
    _check(root, prefspath, PREFS_NAME)
    if dbpath.exists() or prefspath.exists():
        raise UnsafeFixture("Refuse to overwrite fixture")
    with sqlite3.connect(dbpath) as db:
        db.executescript("""
            PRAGMA user_version = 3;
            CREATE TABLE trips (
              id TEXT PRIMARY KEY, started_at TEXT NOT NULL,
              total_fare REAL NOT NULL, distance_km REAL NOT NULL,
              payload TEXT NOT NULL);
            CREATE INDEX trips_started_at_idx ON trips(started_at DESC);
            CREATE TABLE active_trip (
              id INTEGER PRIMARY KEY CHECK (id = 1),
              payload TEXT NOT NULL, updated_at TEXT NOT NULL);
            CREATE TABLE active_trip_route (
              sequence INTEGER PRIMARY KEY, latitude REAL NOT NULL,
              longitude REAL NOT NULL, recorded_at TEXT NOT NULL,
              accuracy_meters REAL NOT NULL, speed_kmh REAL NOT NULL,
              segment INTEGER NOT NULL);
        """)
        receipt = json.dumps({"fixtureOnly": True, "receipt": "preserve"},
                             sort_keys=True)
        db.execute("INSERT INTO trips VALUES (?,?,?,?,?)",
                   ("fixture-receipt", "2026-01-01T00:00:00Z", 0.0, 0.0, receipt))
        active = json.dumps({"schema": 1, "routeStorage": "sqlite-v3",
                             "routeCount": 2,
                             "meter": {"startedAt": "2026-01-01T00:00:00Z"},
                             "tariff": {"fixtureOnly": True}}, sort_keys=True)
        db.execute("INSERT INTO active_trip VALUES (1,?,?)",
                   (active, "2026-01-01T00:00:00Z"))
        for i in range(2):
            db.execute("INSERT INTO active_trip_route VALUES (?,?,?,?,?,?,?)",
                       (i, 0.0, 0.0, "2026-01-01T00:00:00Z", 1.0, 0.0, 0))
    prefspath.write_text(json.dumps({PREFS_KEY: "FIXTURE_CONFIRMED_TARIFF_ONLY"},
                                    sort_keys=True), encoding="utf-8")
    return dbpath, prefspath


def backup_fixture(root: Path) -> dict:
    """Clone a *frozen fixture* via SQLite backup API and hash prefs.

    This is NOT an atomic real-world snapshot across DB + SharedPreferences.
    Production needs a mutation barrier / consistency point that does not yet exist.
    """
    root = Path(root)
    src = root / DB_NAME
    prefs = root / PREFS_NAME
    _check(root, src, DB_NAME)
    _check(root, prefs, PREFS_NAME)
    before = _snapshot(src)
    if before["version"] != 3:
        raise UnsafeFixture("Expected v3 fixture")
    before_prefs = _verified_prefs(prefs)
    archive = root / "bundle"
    if archive.exists():
        raise UnsafeFixture("Backup bundle already exists")
    archive.mkdir()
    backup_db = archive / "snapshot.db"
    with sqlite3.connect(src) as source, sqlite3.connect(backup_db) as target:
        source.backup(target)  # includes committed WAL pages
    shutil.copyfile(prefs, archive / "preferences.json")
    after = _snapshot(src)
    after_prefs = _verified_prefs(prefs)
    if before != after or before_prefs != after_prefs:
        shutil.rmtree(archive)
        raise UnsafeFixture("Sources changed while copying: no consistent snapshot")
    manifest = {
        "kind": "DISPOSABLE_V3_FIXTURE_BUNDLE_ONLY",
        "schema_version": 3,
        "db_sha256": _digest(backup_db.read_bytes()),
        "prefs_sha256": _digest((archive / "preferences.json").read_bytes()),
        "receipt_count": len(before["receipts"]),
        "route_count": len(before["route"]),
    }
    (archive / "manifest.json").write_text(
        json.dumps(manifest, sort_keys=True), encoding="utf-8")
    inspect_bundle(root)
    return manifest


def inspect_bundle(root: Path) -> dict:
    archive = Path(root) / "bundle"
    root = Path(root)
    _check(root, root / DB_NAME, DB_NAME)
    if archive.is_symlink() or not archive.is_dir():
        raise UnsafeFixture("Missing bundle")
    m = json.loads((archive / "manifest.json").read_text(encoding="utf-8"))
    if m.get("kind") != "DISPOSABLE_V3_FIXTURE_BUNDLE_ONLY":
        raise UnsafeFixture("Wrong bundle kind")
    snapshot = archive / "snapshot.db"
    prefs = archive / "preferences.json"
    if snapshot.is_symlink() or prefs.is_symlink():
        raise UnsafeFixture("Symlink forbidden")
    if (_digest(snapshot.read_bytes()) != m.get("db_sha256") or
            _digest(_verified_prefs(prefs)) != m.get("prefs_sha256")):
        raise UnsafeFixture("Backup hash mismatch")
    with sqlite3.connect(snapshot) as db:
        evidence = _inventory(db)
    if (evidence["version"] != 3 or
            len(evidence["receipts"]) != m.get("receipt_count") or
            len(evidence["route"]) != m.get("route_count")):
        raise UnsafeFixture("Data count/version mismatch")
    return evidence


def restore_to_new_files(root: Path) -> dict:
    """Restores to DIFFERENT fixture-only paths, refuses overwrite."""
    evidence = inspect_bundle(root)
    archive = Path(root) / "bundle"
    dest = Path(root) / "restored"
    if dest.exists():
        raise UnsafeFixture("Refuse to overwrite existing data")
    dest.mkdir()
    shutil.copyfile(archive / "snapshot.db", dest / "restored.db")
    shutil.copyfile(archive / "preferences.json", dest / "restored_prefs.json")
    restored = _snapshot(dest / "restored.db")
    if restored != evidence or _verified_prefs(dest / "restored_prefs.json") != \
            _verified_prefs(archive / "preferences.json"):
        raise UnsafeFixture("Restore parity failure")
    return restored


def dry_run_v4_on_restore(root: Path, *, inject_error: bool = False) -> dict:
    """Only modifies restored.db clone. Does not migrate the real app DB."""
    root = Path(root)
    _check(root, root / DB_NAME, DB_NAME)
    path = root / "restored" / "restored.db"
    if path.is_symlink() or not path.is_file():
        raise UnsafeFixture("Missing restored clone")
    before = _snapshot(path)
    if before["version"] != 3:
        raise UnsafeFixture("Only a v3 copy is supported")
    db = sqlite3.connect(path, isolation_level=None)
    try:
        db.execute("BEGIN IMMEDIATE")
        db.execute("CREATE TABLE checkpoint_fence ("
                   "id INTEGER PRIMARY KEY CHECK(id=1), session_id TEXT NOT NULL,"
                   "generation INTEGER NOT NULL, last_sequence INTEGER NOT NULL,"
                   "last_gnss_nanos INTEGER NOT NULL, phase TEXT NOT NULL)")
        if inject_error:
            raise RuntimeError("Injected migration failure before COMMIT")
        db.execute("CREATE TABLE checkpoint_ack ("
                   "session_id TEXT NOT NULL, generation INTEGER NOT NULL,"
                   "sequence INTEGER NOT NULL, sample_digest TEXT NOT NULL,"
                   "checkpoint_id TEXT NOT NULL,"
                   "PRIMARY KEY(session_id,generation,sequence))")
        db.execute("PRAGMA user_version = 4")
        db.commit()
    except BaseException:
        db.rollback()
        raise
    finally:
        db.close()
    after = _snapshot(path)
    if any(before[field] != after[field] for field in
           ("receipts", "active", "route")) or after["version"] != 4:
        raise UnsafeFixture("Migration lost legacy data")
    return after