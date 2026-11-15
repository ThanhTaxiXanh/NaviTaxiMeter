# Foundation status · 2026-11-15

**Warning:** this is a functional domain/data foundation, not a passenger-ready app. The UI only shows truthful readiness state; there is no simulated GPS, fake receipt or auto-enabled demo fare.

**Source provenance:** selected files adapted from ThanhTaxiXanh/TTX-AATaximeter branch feature/flutter-taximeter-foundation at a40c246de6fd3799aaddedce3ed0d3b1d9dd524d. Owner's separate repository is not modified.

**Imported/testable:** tiered fare, waiting/BOT, GPS validity and discontinuities, trip snapshot and SQLite journal, trip records/revenue, quote calculation. Namespace changed. DB and legacy-pref keys renamed to isolate Navi. Decode rejects missing fares; no card method exposed.

**Not implemented:** Android foreground location service, local-only driver tariff editing, Google/MapLibre renderers, 7 mockup screens, VietQR UI, local search/routing, unified backup import, stress tests, stable APK signing. No map API key/Billing configured.

Run: flutter create . --platforms=android --org vn --project-name navitaximeter; flutter pub get; flutter test; flutter analyze --no-fatal-infos --no-fatal-warnings; flutter build apk --debug; python3 tool/check_zero_cost_policy.py.

**Next:** verify GitHub CI, fix any port regressions, implement driver-confirmed tariff management and live GPS FGS+checkpoint before unlocking passenger trip controls. Compare real device screenshots with supplied 7 PNGs in subsequent UI phase. Publication needs real-world GPS, billing, license and sovereignty reviews. PR stays Draft; main stays unchanged.
