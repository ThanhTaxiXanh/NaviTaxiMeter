# NaviTaxiMeter | Architecture: current vs proposed

## Current executable topology (inspect SHA before relying on this)
```text
lib/main.dart (Flutter technical UI)
  → lib/src/ui/{tariff_management_page,gps_preview_page,gps_lab_page,safety_service_page}
  → lib/src/core/{taximeter_engine,metered_trip_coordinator}
  → lib/src/data/{trip_repository,tariff_codec,trip_session_snapshot}
  → sqflite navitaximeter_v1.db (schema 3)
  → Android MainActivity / LocationSafetyService (GPS liveness diagnostics)
```
`android_native/HeadlessSqliteProbeService.kt` and Dart IPC checkpoint/ACK proofs are **test-only**. `LocationSafetyService` is not a complete production trip GNSS owner. UI preview remains separate from a production fare session.

## Proposed target (not implemented)
```text
User-approved trip → Kotlin TripLocationService, single GNSS owner
                  → session/generation/sequence/monotonic-nanos IPC
                  → Dart TripSessionWorker, one TaximeterEngine + one DB writer
                  → atomic {frozen tariff, trip state, route, fence, ACK} commit
                  → UI state stream (read-only visualisation)
```
Acknowledge fixes only after durable SQLite commit; crash/ACK ambiguity fails closed. UI camera smoothing does not modify metered coordinates. Do not materialize new schema until migration/rollback proof exists.

## Current preservation contract
Database `navitaximeter_v1.db`, SQLite `user_version=3`, tables `trips`, `active_trip`, `active_trip_route`, SharedPreferences `navi_confirmed_tariffs_v1`. No live schema v4 ACK migration. Keep existing independent app namespace.
