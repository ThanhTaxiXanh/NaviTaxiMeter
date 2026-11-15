# GPS Laboratory Integration · 2026-11-15

## Status: 0.1.3+4 · Debug laboratory, NOT a passenger meter

Source branch: feature/navitaximeter-foundation, Draft PR #1.
Main and TTX-AATaximeter reference repo are untouched.

### Implemented now
- A separate **Phòng thử GPS · SQLite** tab subscribes to **real Android geolocator** positions with a foreground location notification, while the activity is visible.
- Start a laboratory-only unfinished session ONLY if the driver has a locally confirmed tariff, a recently received trustworthy physical GPS fix, and a subscribed foreground stream. Consent dialog clearly warns no fare collection or customer invoice.
- Accepted GPS samples reach MeteredTripCoordinator and are written to SQLite atomically with the meter checkpoint. App-visible lab shows technical counts and GPS diagnostics, not passenger fare amounts.
- Watchdog detects >12-second GPS gaps; an app lifecycle exit suspends the test session without assuming tracking works when invisible. Restart/reopening only recovers PAUSED and requires explicit driver action to resume.
- A private checkpoint marker distinguishes this lab session from any other active trip. "Xóa checkpoint phiên thử" needs explicit confirmation and verifies the marker again in SQLite before clearing; it never deletes completed receipts or revenue. No made-up trip, POI, receipt or GPS sample is inserted.
- Laboratory start additionally requires GPS sample reception within 7 seconds; stale or mocked fixes cannot unlock the lab.
- CI tests the safety gate, Dart/SQLite/engine suite, and source/compiled-manifest policy. Compiled APK verification requires permissions ACCESS_FINE_LOCATION, ACCESS_COARSE_LOCATION, FOREGROUND_SERVICE and FOREGROUND_SERVICE_LOCATION, and verifies the native GeolocatorLocationService type 'location'. No ACCESS_BACKGROUND_LOCATION or Google Maps API key.
- Entire code stays on a feature branch; no Google Cloud Billing/APIs activated.

### Not implemented / not claimed
- A production Android **trip** foreground-service owner independent of the test screen and activity lifecycle; phone background charging is intentionally disabled.
- Reliable GPS callbacks across Android OEM restrictions, phone sleep, reboot, Force Stop, location permission revocation. Needs physical Android devices and controlled field tests.
- A real passenger-ready taximeter interface, commercial certification, calibrated GPS, physical fare meter verification, final billing UI, receipt, VietQR, map 2D/3D, offline search/routing and 7 supplied mockup screen fidelity.
- Full transactional backup of tariff catalog + trips, long-duration testing for 1/50/100 drivers, legal map/licensing/sovereignty review, signed APK, true Google billing account audit.
- Manifest check alone cannot prove service longevity; no fake "ready" status.

### Next steps
1. Confirm CI results and inspect APK verifier failures if any; fix and retry on this feature branch only.
2. Add lab-driven Android device test protocol covering leave app, return, GPS outage, clock reversal, crash and restore, duplicated GPS callbacks and SQLite corruption.
3. Introduce independently owned Android foreground trip service in Kotlin, service acknowledgement and watchdog; keep fare disabled until device safety gates and operator verification.
4. Implement 7 mockup-faithful UI screens and compliant offline map/search after these service safety gates.

References: Android Developer 'Foreground service types are required' and 'Restrictions on starting a foreground service from the background'. Both require proper runtime GPS permission and visible-activity startup for foreground location services on Android 14+, unless exceptions apply.
