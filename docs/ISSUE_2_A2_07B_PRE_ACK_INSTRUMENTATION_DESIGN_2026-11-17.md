# A2-07B / A2-PRE-ACK — DEBUG instrumentation test plan (Cycle 9)

**Status:** DESIGN REVIEWED AGAINST SOURCE; **NOT IMPLEMENTED / NOT TESTED ON DEVICE**. This is an addition to the existing A2-07A runbook, not a replacement of its video PASS result.

## Cycle 9 implementation and verified CI follow-up (17 Nov 2026)

**CURRENT STATE: IMPLEMENTED and CI TESTED on Android 14 emulator, NOT TESTED on Xiaomi physical Android.** The older design baseline and NOT IMPLEMENTED statements below describe the original planning snapshot and are **superseded for emulator implementation only**.

- Instrumentation source: `android_native/LocationSafetyTokenInstrumentedTest.kt`; bootstrap installed by `tool/bootstrap_android.py`. JUnit execution gate: `tool/verify_android_probe_results.py` (requires all 6 methods PASS in actual Android instrumentation XML) with regression tests in `tool/test_verify_android_probe_results.py`. No UI/test-token hooks added to a production APK.
- Verified code+handoff HEAD **`97d96d6101e6631524235ea629a2b414274b6259`**: [Foundation run 43989450112](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43989450112) **SUCCESS**, jobs `build-test` **SUCCESS** and `Android 14 emulator headless SQLite execution` **SUCCESS**. Emulator log: `Tests 6/6 completed. (0 skipped) (0 failed)`; XML gate reports six Android instrumented tests executed, including two token races. [Zero Cost Source Gate 43989450094](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43989450094) **SUCCESS**, but not a 30-day cloud billing audit.
- **A2-07B emulator PASS, scoped:** replay saved old notification `PendingIntent` after new FGS has received matching ACK; new owner, no stopRequested, no overlapping claim, matching new ACK survive. **Xiaomi/other physical devices NOT TESTED**.
- **Pre-ACK emulator PASS, scoped:** request Stop after lease reservation and before native `onStartCommand`, queued START safely tears down without ACK/fresh, and a stale START does not kill a later active lease. This deterministic case **does not exhaustively test a Stop racing an already-dispatched asynchronous START before first ACK**. Physical device NOT TESTED.
- Remaining test work (without repeating A2-07A PASS video): stale STOP delivered while the new lease is still pending; Stop after dispatch but before ACK under controlled timing; OS-level owner overlap and Android 11–16/OEM matrix. Do not ask user to hit disabled Flutter Stop or recover an obsolete notification manually. Issue #2 stays OPEN; Issue #3 one production GNSS owner + durable SQLite writer not certified.
- Details also in `docs/ISSUE_2_XIAOMI_ANDROID13_PHYSICAL_EVIDENCE_2026-11-16.md` §2I. Protect coordinates, customer data and existing tariffs; no paid API or passenger fare.

## Verified baseline
- Baseline HEAD before this document: `4fe6e28965b8efa9d66a8da5cf2fb9132f920eb5` (17 Nov 2026). PR #1 OPEN/DRAFT, Issues #2/#3 OPEN.
- Exact-SHA Zero Cost Source Gate run [43986056522](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43986056522): SUCCESS (source scan only). Foundation [43986056478](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43986056478): IN_PROGRESS at review; older [43986049284](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43986049284) CANCELLED. Do not attribute SUCCESS until a completed exact-SHA run is observed.
- A2-07A quick Stop **after ACK**: **PASS according to 29.55-second phone video**, see physical evidence §2H and Issue #2 comment 6933424447. Do not rerun.
- A2-03 ordinary current-notification STOP has already passed UI evidence. It is **not** a replay of an old STOP.
- A2-07B notification STOP from a previous lease and cancellation before the first ACK: **NOT TESTED**, currently impossible to exercise with ordinary Flutter buttons. No user phone action requested.

## Source-level trace and test seams
- `android_native/LocationOwnerRegistry.kt`: synchronized claim/matches/requestSafetyStop/release; release occurs after native Service teardown. Old lease IDs fail `requestSafetyStop` once a new generation owns the registry.
- `android_native/LocationSafetyService.kt`: `ACTION_STOP` reads `EXTRA_LEASE_ID`, requests a token-fenced stop; stale intent should not stop an active newer lease. Notification `PendingIntent` uses unique URI `navitaximeter://gps-safety/stop/<leaseId>` so extras cannot silently alias the next notification. `ACTION_START` checks owner and requested lease.
- `android_native/MainActivity.kt`: `start` reserves the lease and dispatches `startForegroundService`; `stop` requests cancellation but retains the lease until `onDestroy`. No dispatch ACK equals a live-service ACK.
- `lib/src/ui/safety_service_page.dart`: Flutter `_busy` disables Stop while awaiting Start/ACK; UI cannot test pre-ACK cancellation.
- `android_native/LocationOwnerRegistryTest.kt` already exercises old lease rejection and pending stop at JVM registry level only. Existing Android instrumentation currently runs disposable headless SQLite probe, not stale native notification/service lifecycle.

## Minimal implementation proposed next (requires code + exact SHA CI)
1. Add **Android instrumentation-only** class `LocationSafetyTokenInstrumentedTest.kt` under `android_native/`, registered via `tool/bootstrap_android.py` `ANDROID_TEST_SOURCES` (no production UI or release manifest changes).
2. **A2-07B first regression:** while no GPS owner is active, claim old native safety lease, construct old `ACTION_STOP` intent with old lease ID and URI; release old lease (test-isolated registry), claim new lease; deliver stale stop via service **only in an instrumented sandbox where Android FGS lifecycle is controlled**. Assert current owner/lease preserved, no stopRequested, and new service continues. A registry-only assertion cannot be reported as notification replay PASS. Prefer actual immutable `PendingIntent` send/replay and service lifecycle instrumentation if Android restrictions permit. Tests must not bypass location runtime permissions or attempt an illegal background FGS start.
3. **Pre-ACK cancellation regression:** claim lease and request STOP before actual native start command, then deliver START for the same lease in a legal foreground test Activity/FGS environment; assert no trusted FIX/ACK published, no GPS subscription after cancellation, and no rival owner before teardown. Test any second stale START against newer lease; require it not interrupt the current one.
4. Ensure teardown in `finally`, no leaks/parallel owner; isolate test permissions and reset only ephemeral test state. **Do not** forcibly release a live location owner from test setup. If CI emulator/permissions cannot legally execute the service scenario, mark device-runtime NOT TESTED instead of manufacturing a pass.
5. Run existing Kotlin JVM regressions, the new Android instrumentation on emulator, Flutter suite, source gate; compare CI run *with the new commit SHA*. Only then consider an optional physical Android DEBUG runbook. Device-only proof remains pending if test cannot execute.

## PASS / FAIL / evidence
- **A2-07B PASS (instrumented Android only):** a saved old lease notification action is actually delivered after the new lease is active, and the new session is still active/owned by its correct token; stale action cannot clear stop state or ACK. **FAIL:** old action stops/releases newer session, leaks FGS, or results in false ACK.
- **Pre-ACK PASS (instrumented Android only):** stop requested between reservation and first ACK; queued START is cancelled without GPS subscription, remains exclusively reserved until teardown, next lease claims normally only after safe teardown. **FAIL:** overlap, stale ACK or orphaned active service.
- **NOT TESTED:** no real replay, only registry-only tests, or Android permission/lifecycle preconditions not met. Keep every evidence type separate.
- No coordinates, PII, raw phone video, fake fare, tariffs, cloud bills, production SQLite or passenger data in test logs.

## User-facing phone rule
Do **not** ask the owner to locate an obsolete notification or press disabled Stop during Start. Only after a suitable DEBUG APK/test UI actually exists may a phone test be requested, with exact artifact SHA, device, permission preparation, named buttons, each step, PASS/FAIL/NOT TESTED and redacted video sent *in chat*. Rules: `docs/QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md` §9 and Cycle 8 handoff Appendix A.

**Release blockers unchanged:** Zero Paid API, schema v3 + confirmed tariffs/receipts/routes preserved, no passenger fare, GNSS/ACK/SQLite uncertainty ⇒ SUSPENDED, recovery PAUSED + manual RESUME; one production owner/writer not implemented (Issue #3). PR #1 stays Draft, Issues #2/#3 OPEN, no main merge or force push.
