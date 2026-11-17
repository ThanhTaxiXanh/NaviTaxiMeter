# NaviTaxiMeter | Maps and Zero-Cost Decision Gate

## Unresolved design conflict
Older dossier v2.0.0 prefers the **standard Google Maps SDK for Android** for tilt and extruded buildings. It also acknowledges that this SDK requires a billing-enabled project even when some usage appears no-charge.

**Current repository hard rule** (see `docs/HANDOFF_2026-11-16_CYCLE4_7-7.md` and `tool/check_zero_cost_policy.py`): do NOT enable Google Billing or integrate `google_maps_flutter`, Android Maps SDK, 3D/Immersive Maps, Places, Routes, Navigation, paid tiles etc. without a new explicit product decision. Therefore Google Maps has status **BLOCKED BY COST POLICY**, not implemented. Do not silently swap to another paid provider.

## Preflight before any map SDK change
1. Cite current vendor pricing, SKUs, key/billing prerequisites, licence and quotas.
2. Inventory code imports, Android Gradle dependencies, enabled Cloud APIs, network endpoints and key restrictions.
3. Simulate 50 and 100 users × 24 hours/day × 30 days (36,000 and 72,000 user-hours). Count actual request types, not invented SDK per-hour charges.
4. Distinguish PASS of `tool/check_zero_cost_policy.py` (static source scan) from real invoice/cost proof (requires owner Cloud evidence). Label absent evidence UNVERIFIED.
5. Get explicit owner approval for any change requiring billing, or keep it blocked. Billing notifications are not hard caps.

## Design constraints
No scraping/caching Google map tiles to bypass licence/cost; no paid immersive 3D as free substitute. Google basemap labels may not be legally editable. Camera tilt/buildings vary with SDK, zoom and geographic coverage. Map data and taximeter GNSS must remain separate.

## Reference URLs (re-verify before use)
- https://developers.google.com/maps/documentation/android-sdk/usage-and-billing
- https://developers.google.com/maps/billing-and-pricing/pricing
- https://developers.google.com/maps/documentation/maps-3d/android-sdk/usage-and-billing
- https://cloud.google.com/maps-platform/terms/maps-service-terms
