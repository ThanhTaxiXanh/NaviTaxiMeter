# Issue #3 P4: staged TaximeterEngine fare candidate / post-commit publication (test-only)

**15/11/2026. NOT a production taxi meter, migration, location service, or Android validation.**

## Prerequisite evidence

At commit `0e6e0cc4b064096d914a15bf63978f86567c7748`, GitHub Foundation run [43732807141](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43732807141) completed its `flutter test` step SUCCESS, validating the previous IPC -> disposable sqflite bridge. This does not imply the whole workflow/emulator has passed.

## New isolated staging proof

**Files:**
- `lib/src/core/taximeter_engine.dart`: adds `forkForCheckpoint()`, a full isolated in-memory copy of the existing Dart fare engine, including private last GPS fix, distance anchor, last tick, waiting-grace counters and interruptions. It also freezes a tiered tariff's `fareTiers` list on the clone. This method is additive, and **no app coordinator/UI calls it yet**.
- `test/support/issue3_staged_fare_checkpoint.dart`: explicitly test-only `TestOnlyFareStage`, which accepts **only** newly created `navi-fare-stage-*` temp directories and writes via actual `TripRepository.saveActiveIncremental` into `DISPOSABLE_FARE_STAGE_ONLY.db`. No default production DB is accessed. Uses synthetic, zero-passenger, clearly marked tariff and coordinates at 0°, not a real trip or a legally confirmed tariff.
- `test/issue3_staged_fare_checkpoint_test.dart`: **10** tests of the staged candidate and actual v3 repository.
- `docs/AI_HANDOFF_STATE.md`: preserved continuation count 5/7 and blockers.

## Staged proposal vs. COMMIT and publication

1. The published `TaximeterEngine` remains untouched. A full fork of its transient state creates an isolated candidate. **Do not** use `TaximeterEngine.fromSnapshot` to fork a running meter because that deliberately returns PAUSED and loses live GPS anchoring.
2. Only the fork consumes a synthetic fix/tick and produces a `TripSessionSnapshot` whose meter data map is **unmodifiable**. The candidate does not become visible while the SQL transaction is pending (including a special test hook that holds the operation).
3. Persist `candidateSnapshot` and one new route row through the **existing v3** `TripRepository.saveActiveIncremental` transaction. Publish the candidate engine, elapsed time and distance **only after** this call successfully resolves. A SQL exception discards the candidate and permanently faults the test-only writer.
4. Fail-inject on route INSERT and on the header's actual **INSERT OR REPLACE**; do not mistakenly use an `UPDATE` trigger here. Verify rollback of persisted route, header, count and published fare. This proves a narrow test condition on SQLite FFI, not physical Android durability.
5. Eight concurrent test observations are queued by one Dart serial queue. Recovery uses `TripSessionSnapshot.restore`, which intentionally returns PAUSED with no retroactive interval.
6. The existing source coordinator `lib/src/core/metered_trip_coordinator.dart` **still mutates its live engine before SQLite** in `accept`, `_suspend`, `resume` and `finish`. This proof changes neither that runtime flow nor real trip users.

## Explicitly NOT proven

- No durable `session_id + generation + sequence` ACK ledger in the live app DB; v4 tables remain only in disposable P3 clones. P4 uses actual **v3** `TripRepository` without the P3 IPC gate; combining these requires reviewed design and Android tests.
- No single `TripLocationService` owner of physical GPS or service-owned `TripSessionWorker`; no native Binder/MethodChannel transport, FGS kill/Doze/background, real device Android 11–16 or final hardware ACK safety.
- No change to any actual tariff/prefs, taximeter receipts, passenger data, billing provider, map data or legitimate ride fees.
- No independent proof of native Android `sqflite` behavior, filesystem durability on power loss, exact fare rounding parity across all tariff variants, or app schema migration safety.

## Next gate

1. Check CI of **new SHA** for `flutter analyze` and `flutter test`, repair failures before asserting PASS.
2. Review `forkForCheckpoint` and staging with regression tests for waiting grace, interrupted/resume, flat fare, tiered tariff, and rounding to thousands; then consider applying copy-on-write to the **existing** coordinator behind guards, WITHOUT activating commercial metering.
3. On a separately isolated Android debug database, prove real `sqflite` transaction rollback, service/engine lifecycle, ACK state fencing and physical GNSS issue #2 test plan.
4. Whenever asking user to test Android, comply with `docs/QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md` §9: exact build and device prerequisites, tap-by-tap steps, expected PASS/FAIL, screen evidence/log with privacy, clear return instructions.

**Always:** keep PR #1 Draft, only write `feature/navitaximeter-foundation`, never merge main, never alter `TTX-AATaximeter`, never enable Google Billing/paid API, never collect passenger fares.
