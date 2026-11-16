# NaviTaxiMeter | Decisions

| Status | Decision | Evidence/owner gate |
|---|---|---|
| ACTIVE | Independent NaviTaxiMeter package `vn.navitaximeter`; do not alter TTX source | README, latest handoff |
| ACTIVE | Work only on `feature/navitaximeter-foundation`, PR #1 remains Draft | Latest handoff |
| ACTIVE | No paid API/Google Billing until explicit decision | `tool/check_zero_cost_policy.py`, latest handoff |
| ACTIVE | SQLite v3 + confirmed tariff prefs and fail-closed metering | Current Dart code/tests |
| PROPOSED | Single Kotlin GNSS owner and single Dart SQLite writer with committed ACK | Issue #3, ADR draft |
| PRODUCT ASPIRATION / BLOCKED | Google Maps standard 2D/3D driving experience | Old dossier vs active cost constraint |
| PLANNED | Seven full customer UX screens, VietQR, full backup | Product requirements |
| UNVERIFIED | Real device 24h × 50/100 cost and stable signed release | Device and billing gates |

Do not silently upgrade PROPOSED/PLANNED to ACTIVE. Every new ADR records date, actual SHA, options, approval, cost/security/data impact and rollback.
