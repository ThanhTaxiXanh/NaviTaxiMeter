# Issue #3 P3: app-v3-shaped clone, backup/prefs parity and v4 dry run (PYTHON ONLY)

**2026-11-15. STRICTLY A DISPOSABLE TEST / NOT a production migration, Flutter sqflite or Android proof.**

## Scope

`tool/v3_clone_migration_proof.py` creates a disposable SQLite file `DISPOSABLE_V3_CLONE_ONLY.db` under `/tmp/navitaxi-v3-clone-*`. The `trips`, `active_trip`, `active_trip_route` table DDL matches the *shape* in `lib/src/data/trip_repository.dart` at schema v3. It inserts only synthetic, explicitly marked receipt/header and 0,0 fixture coordinates; this is not a measured route or actual fare. It creates `DISPOSABLE_PREFS_ONLY.json` with a technical placeholder under `navi_confirmed_tariffs_v1`, NOT the user's actual SharedPreferences contents or validated `ConfirmedTariff` codec.

The fixture's `sqlite3.Connection.backup()` API copies committed SQLite contents (including WAL), then a technical preference snapshot is copied and hashed. Hashes, SQLite `integrity_check`, `user_version`, exact receipt/header/route and prefs parity are checked. Restore is permitted only to *new disposable files*, never overwrite. A hypothetical `v4` table proposal on the RESTORED CLONE creates `checkpoint_fence` and `checkpoint_ack` inside one transaction; an injected exception before commit rolls back DDL and preserves v3. **No app `navitaximeter_v1.db`, prefs, installed APK or production schema are touched.** 

`tool/test_v3_clone_migration_proof.py` includes **10 Python tests**: exact v3 table shape, backup data/prefs inventory, restore parity/no overwrite, clone-only v4 proposal, transactional migration rollback, modified DB hash rejection, modified tariff prefs hash rejection, routeCount mismatch rejection, unsafe production filename/path rejection, symlink refusal. **Local CPython unittest: 10/10 PASS** on technical fixture only, before commit. Verify new GitHub Actions run and commit SHA before claiming CI PASS.

## Explicit limitations / blockers

- Actual `TripRepository.createVerifiedBackup()` uses `VACUUM INTO` and Flutter `sqflite`, not Python `Connection.backup()`. Their parity is **NOT demonstrated** here.
- Production cross-store DB+SharedPreferences consistency needs an explicit mutation barrier/same logical checkpoint; comparing before/after snapshots of a **frozen fixture** alone cannot prove atomicity under concurrent app writes. A crash between snapshotting prefs and DB is untested.
- The payloads and prefs are *synthetic placeholders*, not real v2/v3 application payloads/tariff codec, migration from v2, or signed-release restore. Independent Dart fixture tests are still required.
- No persistent production generation/session writer, actual ACK-after-COMMIT, staged immutable Dart money candidate, GPS location-FGS, real Android physical test, fsync/power cut, or commercial validation. Protocol tests and Python tests must not be reported as Android app proof.
- New test code must run under `python3 -m unittest discover -s tool -p 'test_*.py' -v` in CI; no custom paid services.

## Next work (Issue #3)

1. CI confirm exact SHA, fix only demonstrable failures.
2. Implement *test-only* actual Dart `sqflite` app-clone tests with structurally faithful v3 app snapshot, prefs/tariff codec, integrity/hash/rollback, and v3→v4 proposal.
3. Stage immutable fare candidate outside the current mutating `MeteredTripCoordinator`; guarantee one service-owned Dart mutation authority and post-sqflite-COMMIT ledger ACK in a clone. Test restart/lost ACK.
4. Only after proof/review, integrate one native TripLocationService; keep issue #2 physical device OPEN.

## User's new HARD RULE about phone testing

`docs/QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md` section 9 now requires detailed **what to test, taps/steps, expected PASS and FAIL, redacted evidence, how to send it back to AI, and explicit test status** every time physical-phone validation is requested. This P3 step requires **NO PHONE TEST** from the owner, as it is isolated Python tests.

Never merge `main`, modify TTX, enable Google Billing/paid API, charge passengers, migrate real user data or release production.