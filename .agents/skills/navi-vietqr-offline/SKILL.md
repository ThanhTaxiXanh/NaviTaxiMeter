---
name: navi-vietqr-offline
description: "Tạo mã VietQR chuyển khoản hợp lệ và kiểm tra bằng app ngân hàng."
---

# navi-vietqr-offline

## Common mandatory procedure
1. Read repository `AGENTS.md`, current handoff and the relevant `project/NaviTaxiMeter/` dossier. The live repo's hard rules take precedence over older design proposals.
2. Verify repository, authorized branch, HEAD, implementation symbols and test status before any write.
3. Propose the minimal observable behavior change and its regression seam; preserve SQLite, signed APK identity and privacy.
4. Never claim success without run/SHA evidence. Distinguish PROPOSED, IMPLEMENTED, TESTED, and UNVERIFIED.

## Stop conditions
Never merge `main`, force push, clear persistent app data, fabricate trusted GNSS, bypass Android permissions, disclose keys or enable unapproved paid APIs.

## Task-specific protocol
Validate bank BIN, account, uppercase account holder, amount and transfer memo; use EMVCo/VietQR spec and verified test vectors. Keep metadata locally where legal and sourced; block unapproved payment gateways/APIs. Show QR only under Chuyển khoản; no fictional bank test PASS. Shield bank data in logs/backup and require actual bank-app acceptance before release.

## Required result
Provide changed files and exact commit or a read-only diagnosis, observed tests and CI, data/privacy/API-cost impact, remaining limitations and rollback.
