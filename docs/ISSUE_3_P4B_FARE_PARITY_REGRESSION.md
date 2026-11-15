# Issue #3 P4B: pricing/grace/tier/rounding regression coverage on test-only stage

**Date:** 2026-11-15 (Vietnam, ICT). **Scope:** no real rides, no tariffs from preferences, no physical GNSS, no production schema change.

## Verified prerequisite

Commit `3c1111e5985b9563f33b2ca44d80b7552d8880d6` was verified on GitHub Actions:
- [Foundation Flutter Android run 43733816398](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43733816398) **SUCCESS**, both `build-test` and Android 14 *debug-only headless SQLite probe* job SUCCESS. `flutter test` step SUCCESS including the ten staged-fare tests.
- [Zero Cost Source Gate run 43733816387](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43733816387) **SUCCESS**.
- These findings do **not** prove physical Android GPS/FGS safety, authenticated data, durable real trip ACK ledger, or taxi charging accuracy.

## New code in this step

1. `test/issue3_fare_fork_pricing_regression_test.dart` (**10 tests**): `TaximeterEngine.forkForCheckpoint()` preserves live GPS anchor, fractional waiting grace, moving/stationary transitions, low-speed grace around GPS skip, source isolation; flat fare excludes distance/wait and bypasses thousand rounding; cloned fare tier list cannot be mutated by the original list; cumulative three-tier pricing; rounding just below/at the 500-dong threshold; interruption/restart has no retroactive time/distance, large discount does not make negative fare, restore PAUSED.
2. `test/support/issue3_staged_fare_checkpoint.dart` adds ONLY **test helper parameters** `tariff` and `fixedFare` to `TestOnlyFareStage.begin()`. The default `syntheticStageTariff` is unchanged. This helper still refuses all except a fresh `navi-fare-stage-*` temporary directory and only creates `DISPOSABLE_FARE_STAGE_ONLY.db`. It does NOT read `navi_confirmed_tariffs_v1` or application databases.
3. `test/issue3_staged_tariff_parity_test.dart` (**5 tests**): real Flutter `TripRepository`/SQLite v3 checkpoint against disposable DB for waiting grace, fixed fare, progressive tier+1000 rounding, rolled-back route insert with tiered tariff, stale fix/gap refusing publication. This suite uses technical fake GPS coordinates at 0°, not a real route.

**Total:** 15 additional test cases **written**. Their PASS/FAIL status must come from CI for the new commit SHA, not assumptions or previous runs.

## Exact safety and parity assertions

- A staged candidate's money, distance, and elapsed time are NOT published until `TripRepository.saveActiveIncremental` returns after SQLite COMMIT; errors leave the published meter unchanged and mark the test writer faulted.
- End-of-transaction checkpoints store the original confirmed-*shaped* but **synthetic** tariff snapshot; recovery uses `TripSessionSnapshot.restore()` to force PAUSED and prevent charging the unobserved interval.
- `forkForCheckpoint()` preserves private `_lastFix`, `_distanceAnchor`, `_lastTick`, waiting grace, `_waitGraceAnchor`, and pause flags, unlike `fromSnapshot()` (deliberately crash-recovery PAUSED).
- A test gap >12 seconds is **rejected without publishing fare**; the current TEST harness does not implement full persisted PAUSED for that case, so this remains a production safety gate.

## Remaining issue #3 / #2 blockers

- The **live** `MeteredTripCoordinator` continues to mutate `_meter` before DB COMMIT in `accept`, `resume`, `_suspend`, `finish`. The fork primitive is additive and UNUSED there.
- Typed IPC -> test-clone v4 ACK ledger and actual v3 fare staging are **distinct test harnesses**. No combined production `sessionId+generation+sequence` transaction; no approved migration v3→v4. Do not present them as one integrated meter.
- Android real background `TripLocationService` + service-owned Dart worker, one true GNSS owner, Android 11–16 test matrix, notification STOP, permissions, Doze, reboot and failure recovery are **not** implemented/verified.
- No real verified VietQR, offline road/POI map, legal map sourcing, Zero Paid API 30-day real-world audit, signed release or safe commercial taxi billing proof.

## Next gates

1. Check new CI SHA: `flutter analyze`, `flutter test` (both new files), debug APK, and emulator probe. Repair failures on feature branch before reporting new PASS.
2. Extend fail-injection tests and architecture review for full coordinator copy-on-write including `resume`, suspension, finish and safe transaction ACK; keep production traffic disabled.
3. Only after architecturally approved guarded implementation: Android instrumented tests on **disposable app DB** then physical Android devices. When user testing is necessary, follow [mandatory hard rule §9](QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md): identify APK/SHA/device, tap-by-tap sequence, positive/negative expected results, safe screenshots/logs, and precise method for sending results.
4. Next user-facing assistant response in the current chat is **turn 7/7**, requiring complete standalone handoff sections 3.1–3.10.

**DO NOT:** merge main, edit `TTX-AATaximeter`, turn on Google Billing or paid APIs, write passenger DB, import fake GPS as real, collect fares or claim commercial release.
