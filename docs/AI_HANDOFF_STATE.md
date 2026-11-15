# NaviTaxiMeter · AI handoff · 2026-11-15
AI_REPLY_COUNT = 4 (fourth completed response in this conversation).

Repository: ThanhTaxiXanh/NaviTaxiMeter
Branch: feature/navitaximeter-foundation
PR: #1 Draft; do not merge.
Prior commit: f7aac734041d3c6f0a9999c1218352b5f11c1ed2
This task: new `MeteredTripCoordinator`, SQLite receipt immutability guards and regression tests.
Latest commit SHA should be read from GitHub when this file is used; not specified here because the commit does not exist until this note is added.

Foundation requirements: Flutter/Dart Android (applicationId vn.navitaximeter), Kotlin when required, zero unapproved paid API, no Google Cloud Billing auto-enable, no fake GPS/fares/POIs/turns, strict driver tariff confirmation, local SQLite trip journal, GPS fare separated from map camera, 7 user-supplied mockups, VietQR cash/bank-only, crash-safe recovery, no interference with TTX-AATaximeter or main. Vietnam map content and licenses require independent validation.

Relevant files:
- lib/src/core/metered_trip_coordinator.dart
- lib/src/core/taximeter_engine.dart
- lib/src/core/location_tracking_policy.dart
- lib/src/data/trip_repository.dart
- lib/src/data/trip_session_snapshot.dart
- lib/src/domain/confirmed_tariffs.dart
- lib/src/ui/gps_preview_page.dart
- test/metered_trip_coordinator_test.dart
- test/trip_repository_ffi_test.dart
- docs/PHASE2_METER_SQLITE.md
- tool/check_zero_cost_policy.py

Current feature state: core coordinator is written and should be checked through CI; NOT connected to physical GPS screen yet. GPS preview uses Geolocator plugin-managed FGS and is non-metered. No production passenger trip UI. Tests use synthetic GPS only. No device-level/force-stop proof, Google Billing proof or release signing. Next work: fix any failed CI tests, then integrate real GPS service ownership and supervised test-only trip UI, persist checkpoints and verify on physical Android. Never claim ready to charge fares.

7-reply transfer rule: after 6 ordinary replies, seventh reply must contain full standalone handoff. Current status after this reply: 4/7.
