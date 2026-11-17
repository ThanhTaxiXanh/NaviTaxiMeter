# Phase 2 · confirmed tariffs and GPS preview

Version: 0.1.1+2. Source PR #1, feature/navitaximeter-foundation.

## Working vertical slices
- Driver can add/edit/select/delete locally saved, explicitly confirmed tariff profiles.
- Tariff form supports cumulative tier boundaries, no retroactive rate changes. Confirmation is mandatory for every save/edit. Store rejects broken/missing tariff data rather than filling with sample prices.
- Live GPS preview requests runtime permissions while app is visible and subscribes through Geolocator Android with a foreground notification. UI only exposes positions that pass accuracy, age, motion and mock-location guards. Preview stops when page closes. NO fare or trip is ever recorded by preview.
- No Google Maps SDK, Map ID, API keys, Maps billing, paid routes or Places.

## Safety gaps before enabling fare-earning journeys
- Geolocator's plugin-managed location FGS is *not* yet proven to survive device kills, Force Stop, or all Android OEM power restrictions. A supervised, device-tested metered-trip owner/service still needs implementing.
- Current preview never writes GPS to SQLite; connecting validated GPS to TaximeterEngine, route checkpoints and transactional trip lifecycle is next.
- Tariff catalog currently uses namespaced SharedPreferencesAsync, while completed trips use SQLite. Complete unified backup needs to include the tariff catalog and future migration/snapshot policy.
- No APK stability/signing validation or device long-run tests yet. CI builds test-only Debug APK.
- Android 14+ requires FOREGROUND_SERVICE_LOCATION and app must initiate service while visible. Foreground service is controlled by an active Geolocator position stream and notification.
- Map rendering, local search/routing, VietQR UI, 7 mockup fidelity and 50/100-user tests remain incomplete.

## Exact next step
Run CI and resolve errors. Then implement metered session coordinator: verified real tariff + fresh GPS + foreground service + SQLite beginActive, incremental checkpoint, interruption suspension, manual resume, completeActive, prevent invoice duplication, tests for crash/reboot behavior.
