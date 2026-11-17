---
name: navi-backup-recovery
description: "Thiết kế sao lưu và khôi phục toàn bộ chuyến đi/cấu hình không mất dữ liệu."
---

# navi-backup-recovery

## Common mandatory procedure
1. Read repository `AGENTS.md`, current handoff and the relevant `project/NaviTaxiMeter/` dossier. The live repo's hard rules take precedence over older design proposals.
2. Verify repository, authorized branch, HEAD, implementation symbols and test status before any write.
3. Propose the minimal observable behavior change and its regression seam; preserve SQLite, signed APK identity and privacy.
4. Never claim success without run/SHA evidence. Distinguish PROPOSED, IMPLEMENTED, TESTED, and UNVERIFIED.

## Stop conditions
Never merge `main`, force push, clear persistent app data, fabricate trusted GNSS, bypass Android permissions, disclose keys or enable unapproved paid APIs.

## Task-specific protocol
Define versioned archive manifest with schema, entry hashes, app version and UTC timestamp. Capture vehicle/profile, confirmed tariffs, trips/routes/receipts, bank data and map settings without secrets. Write atomically, import into staging, verify hashes, migrate only with tests, preview conflicts, preserve rollback. Test truncated/tampered archives, duplicate imports, old schemas. Never reset SQLite or SharedPreferences as an error workaround.

## Required result
Provide changed files and exact commit or a read-only diagnosis, observed tests and CI, data/privacy/API-cost impact, remaining limitations and rollback.
