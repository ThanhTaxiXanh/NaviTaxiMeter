# Issue #3 P3C: typed IPC -> disposable sqflite clone adapter

**15/11/2026 • isolated Flutter test only • no production wiring**

## Confirmed prerequisite
At SHA `f59a6eee46238774afc34d034451c33856a9c0f9`, GitHub Foundation Flutter Android run [43732189163](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43732189163) completed `flutter analyze` and `flutter test` steps with **success**. This proves the P3B Linux/Flutter unit test suite ran, not physical Android GNSS or a production schema migration.

## This change
- `test/support/issue3_ipc_sqflite_adapter.dart` binds an existing typed `IpcCheckpointGate` (metadata + opaque digest) to the test-only `CloneAckWriter` (real `sqflite_common_ffi` SQLite transaction).
- `test/issue3_ipc_sqflite_bridge_test.dart` adds **seven** cross-layer Dart tests: eight ordered submissions, eight identical replays, digest mismatches, stale generation, conflicting replay, simulated lost ACK after COMMIT with durable PAUSED, and process-like gate restart requiring PAUSED reconciliation.
- The bridge's fixture registry `Map<String, CloneFix>.unmodifiable` only holds zero-fare, synthetic, immutable test candidates. It checks all relevant metadata before a clone transaction. The gate receives a matching `IpcCommitProof` only after `CloneAckWriter.append()` completes its transaction. No actual native IPC, no live GPS coords and no passenger trip payload are transmitted.
- Reboot/process recreation is **simulated only** by constructing a second Dart gate and reopening a disposable SQLite copy; this does not establish FGS or Android process-death reliability.

## Hard limitations / issue #3 remaining blockers
1. **This is not a real bridge.** The production IPC proposal carries only metadata + hash. An authenticated/validated sample with coordinates, monotonic time, session generation, and engine inputs must be transported through a designed secure channel, not reconstituted from an in-memory test registry.
2. `TripLocationService` and a single service-owned `TripSessionWorker` owning the Dart `TaximeterEngine` are not implemented. UI Preview/Lab Geolocator subscriptions are not de-duplicated into a single production owner.
3. The SQLite table `checkpoint_fence` and `checkpoint_ack` exist only inside disposable cloned files. No app `v3→v4` migration is enabled and confirmed tariffs in SharedPreferences are not altered.
4. ACK after a successful sqflite transaction Future on Linux is not proof of physical Android durability, WAL/fsync or process kill/reboot/Doze behavior.
5. The zero-fare fixture header merely stays unmodified; **immutable staged real fare engine state is still an open requirement**. Must model candidate and persist/reconcile state before exposing fare to UI.
6. No connected Android instrumented suite for this code, no physical issue #2 PASS, no signed release or collection of passenger fares.

## Evidence and next actions
- Verify a new GitHub Foundation run **for the new SHA**, not the predecessor. Check `flutter test` step specifically; `emulator-probe` is a separate instrumented debug-only test and can be canceled by a newer commit.
- Once green, implement a staged, immutable **test-only** `TaximeterEngine` snapshot checkpoint and failure-injection tests, then real isolated Android instrumentation. Review single-owner lifecycle ADR before any runtime integration.
- Device testing must follow `docs/QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md` §9 with the precise APK/build, steps, expected PASS/FAIL, evidence capture and sending method; none is requested yet.

**Forbidden:** production DB edits, deployment of v4 migration, paid APIs/Google Billing, TTX repo modifications, merge to main or commercial fares.
