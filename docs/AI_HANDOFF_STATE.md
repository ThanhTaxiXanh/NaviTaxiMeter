# NaviTaxiMeter · AI handoff · 2026-11-15
AI_REPLY_COUNT = 3 (after this assistant response; 7-reply handoff required).

Repository: ThanhTaxiXanh/NaviTaxiMeter
Branch: feature/navitaximeter-foundation
Prior known good commit: 17fcb86d3a2acf0249a393ad825bee105af3f1b3
PR #1: Draft, do NOT merge.
TTX reference: ThanhTaxiXanh/TTX-AATaximeter branch feature/flutter-taximeter-foundation at a40c246de6fd3799aaddedce3ed0d3b1d9dd524d. Never mutate reference repository.

Current phase 2 work: driver-confirmed multi-tier tariffs with strict persisted decode and GPS preview powered by geolocator Android native foreground service. GPS preview does NOT run fare collection or persist route, and stops on page disposal. Android permissions injected in CI by tool/bootstrap_android.py. Must check fresh CI result, fix errors if needed. This is not proof of commercial fare, background survival, no billing or real-device battery/GPS testing.

Hard requirements: zero unapproved paid APIs; no Google Billing enabled; separate fare GPS vs smoothed map; 7 mockups; local SQLite completed trip data; VietQR cash/bank only; 1/50/100 users stress plan; Vietnam-facing Hoàng Sa, Trường Sa, Biển Đông content requirements with independent license checks; maintain signed production keystore; do not alter main without owner approval.

Next: CI status and any regressions. Then verified tariff + fresh trusted GPS + Android FGS coordinated session + SQLite checkpoint/restore + manual suspension/resume and no duplicate fare or receipt; only then enable real trips, with extensive device tests. Never overstate readiness.
