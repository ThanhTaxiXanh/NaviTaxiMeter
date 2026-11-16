# Issue #3 P1 — Android DEBUG Kotlin→Dart typed IPC checkpoint (NOT production)

Date: 2026-11-16. This document describes an *experimental Android emulator* transport proof.
Do not use for passengers, GNSS metering, tariffs, billing or issuing receipts.

## Exact runtime boundary now exercised

```text
Android instrumented test (Android API 34 emulator)
  -> HeadlessSqliteProbeService.ProbeBinder.debugCheckpoint(...)
  -> main-thread MethodChannel.invokeMethod("debugCheckpoint", typed map)
  -> service-owned FlutterEngine / headlessSqliteProbeMain
  -> DebugCheckpointTransport (single serialized Dart queue)
  -> sqflite transaction: debug_fence + debug_checkpoint (one COMMIT)
  -> close DB, reopen read-only, verify exact fence + sequence + hash + checkpointId
  -> typed debug.checkpoint.ack.v1 on Kotlin callback (only after readback)
```

- Android service is **bound and debug-manifest-only**, not a location FGS.
- No GNSS stream, location fix or coordinates exist on this path. The hash is a
  synthetic opaque test token, **not** physical GNSS or tariff evidence.
- Database per test session is named `navitaximeter_DEBUG_IPC_DBG_*.db`.
  It is separate from production `navitaximeter_v1.db` (schema 3), from
  `navitaximeter_HEADLESS_PROBE_ONLY.db`, and from any customer data.
- Kotlin validates bounded `DBG_` session, positive generation, nonnegative
  contiguous sequence and 64-digit lowercase digest. No money calculation.
- First DEBUG worker invocation refuses to reopen a pre-existing session DB
  (`PAUSED_RESTART_EXISTING_DEBUG_DB`). No auto-resume after service recreation.
- Kotlin rejects a foreign generation before dispatch. In-Dart byte-identical
  last-sequence replay returns the original committed ACK; changed digest,
  missing sequence, storage uncertainty or callback error pauses the writer.
- Callback fence rejects late responses after teardown. A 20s native ACK
  timeout faults the bound session: a successful SQL COMMIT without its callback
  must **never** be interpreted as a successful native ACK.

## Evidence the updated CI must produce

The `Foundation Flutter Android` workflow must PASS at the *new exact SHA*.
`build-test` compiles the instrumentation tests. Only the PR-triggered
`emulator-probe` job runs `connectedDebugAndroidTest` on Android 14 (API 34).

`tool/verify_android_probe_results.py` now requires **both** instrumented
methods exactly once, with neither skipped nor failed:

1. `boundHeadlessEngineCanOpenSqfliteAndReadCommittedProbe`
2. `realKotlinToHeadlessDartDebugIpcAcksOnlyAfterSqliteReadback`

The second performs eight concurrent Kotlin→Dart calls, asserts typed ACKs,
unique checkpoint identities, idempotent duplicate, stale generation rejection,
conflicting replay → PAUSED, and rejection after worker rebind. The Dart writer
performs a fresh read-only database open before each ACK; the native callback
also validates the exact fence/sequence/digest/marker.

## Explicit outstanding release gates

**NOT TESTED / NOT IMPLEMENTED**: one production `TripLocationService` GNSS
owner, physical source verification, lifecycle-safe location FGS, a single
production SQLite writer for route+fare+fence+ACK, real Android 11–16 devices,
OEM/Doze/process/power-loss resilience, physical distance/rounding parity,
DB v3→v4 migration, backup+Prefs atomicity and commercial use.

Issue #2 stays OPEN/NOT TESTED on physical devices. A DEBUG APK or emulator PASS
is not authorization for phone testing or passenger fares; every phone test
needs verified SHA/APK+digest, UI buttons and Appendix A instructions. Zero Cost
Source Gate is a static source check, not a 30-day cost audit. No main merge,
TTX modifications, Google Billing, paid APIs, or passenger charges.
