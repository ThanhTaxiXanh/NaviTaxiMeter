---
name: navi-database-evolution
description: "Kiểm tra SQLite v3, migration và hợp đồng lưu dữ liệu bền vững."
---

# navi-database-evolution

## Common mandatory procedure
1. Read repository `AGENTS.md`, current handoff and the relevant `project/NaviTaxiMeter/` dossier. The live repo's hard rules take precedence over older design proposals.
2. Verify repository, authorized branch, HEAD, implementation symbols and test status before any write.
3. Propose the minimal observable behavior change and its regression seam; preserve SQLite, signed APK identity and privacy.
4. Never claim success without run/SHA evidence. Distinguish PROPOSED, IMPLEMENTED, TESTED, and UNVERIFIED.

## Stop conditions
Never merge `main`, force push, clear persistent app data, fabricate trusted GNSS, bypass Android permissions, disclose keys or enable unapproved paid APIs.

## Task-specific protocol
Inventory schema of navitaximeter_v1.db (current schema 3), trip/route/active tables, confirmed prefs key navi_confirmed_tariffs_v1 and recovery contract. All proposed future versions need forward-only migrations, transaction/fence semantics and fixture upgrades from historic versions. Compare trip counts, receipts, tariffs and settings before/after. Never DROP/TRUNCATE/clear prefs to get green tests. Treat ACK/writer experiments in docs as test-only until production wiring is proven.

## Required result
Provide changed files and exact commit or a read-only diagnosis, observed tests and CI, data/privacy/API-cost impact, remaining limitations and rollback.
