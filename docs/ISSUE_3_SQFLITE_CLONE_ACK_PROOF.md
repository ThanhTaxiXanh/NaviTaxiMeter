# Issue #3 P3B: Flutter sqflite checkpoint proof on an isolated app-v3-shaped clone

**15/11/2026. Experimental test-only code. NOT a production writer and NOT an approved schema migration.**

## Changed files
- test/support/issue3_sqflite_clone_writer.dart: disposable fixture and single serialized Dart sqflite writer for clone-only technical data.
- test/issue3_sqflite_clone_ack_test.dart: sqflite_common_ffi checks. CI must execute and report independently.
- docs/ISSUE_3_SQFLITE_CLONE_ACK_PROOF.md and docs/AI_HANDOFF_STATE.md.

## Exact scope

The fixture recreates the column layout of the actual app SQLite schema v3: trips, active_trip and active_trip_route. It puts a preservation sentinel into trips and a **non-business, zero-fare** marker into active_trip. It then CLOSES the fixture DB and copies it to a distinct disposable file, using sqflite on the copy to DRY-RUN two proposed v4 tables (checkpoint_fence, checkpoint_ack). The main app file navitaximeter_v1.db and live SharedPreferences are never opened. No real GPS coordinates, real customers, or commercial receipts are used. These fake payloads do NOT conform to a complete domain TripSessionSnapshot.

On this clone only, one Dart queue checks generation, contiguous route sequence, monotonic nanoseconds, mock/accuracy/speed metadata, frozen technical tariff hash and durable SQLite row counts. It builds a copy of a zero-fare fixture header and writes route, header, fence and ACK ledger **in one sqflite transaction**. The writer returns an ACK only after the transaction Future resolves. Fail-injection before/after route/header/ledger must roll back all four. Exact replay is checked against the stored row and SHA-256 digest and must not insert another row. Lost-ACK-after-COMMIT simulation suspends writes; recovery reads from the clone and persists PAUSED.

This uses the **Flutter FFI sqflite implementation on CI Linux**, NOT Android plugin integration, and not a live service-owned TripSessionWorker. Even a fully green CI run is no proof of real Android SQLite durability, FGS lifecycle, GNSS physical authenticity, flash fsync, OEM behavior or fare correctness. Tariff hash is a test sentinel only and cannot prove driver confirmation. No staged real TaximeterEngine candidates have been integrated. The previously proven Android14 headless debug service still uses its OWN headless-probe counter DB.

## Tests and evidence requirements
- Schema v3 source remains intact and receipt sentinel survives test migration to v4 copy.
- An injected upgrade error rolls back both new tables and schema version.
- After successful sqflite transaction, ledger/fence/route readback survives closing/reopening the clone.
- Triggered error after route insert and before ledger insertion rolls back all partial changes, including staged header.
- Eight simultaneous ordered requests serialize; eight exact replays produce a single durable route and ACK.
- Conflicting replay, wrong generation, untrusted metadata, GNSS gap, lost ACK and corrupted ledger fail closed.
- No source code changes to app runtime or production database; Android physical issue #2 remains NOT TESTED.

## Next gate
1. Verify GitHub Foundation Flutter Android workflow for THIS commit, especially flutter test including this new test; a canceled emulator run is neither pass nor app-db-failure proof.
2. Review tests against actual TripRepository.saveActiveIncremental and TripSessionSnapshot, then plan a real service-owned Dart worker using staged immutable engine candidate and a DB fence stored durably. Do not allow Preview/Lab UI to create a competing production writer.
3. Run Android instrumentation on an isolated test-app DB with bound-service lifecycle and fail-injection; later complete issue #2 physical Android 11-16 using the full user-approved step-by-step phone-test evidence guide in docs/QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md §9.
4. No app v3→v4 migration until backup/rollback parity and owner review. No main merge, no TTX changes, no Google Billing or passenger fare.

