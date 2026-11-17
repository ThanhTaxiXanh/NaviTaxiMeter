---
name: navi-iphone-github
description: "Làm việc trực tiếp bằng GitHub/Actions cho người dùng chỉ có iPhone."
---

# navi-iphone-github

## Common mandatory procedure
1. Read repository `AGENTS.md`, current handoff and the relevant `project/NaviTaxiMeter/` dossier. The live repo's hard rules take precedence over older design proposals.
2. Verify repository, authorized branch, HEAD, implementation symbols and test status before any write.
3. Propose the minimal observable behavior change and its regression seam; preserve SQLite, signed APK identity and privacy.
4. Never claim success without run/SHA evidence. Distinguish PROPOSED, IMPLEMENTED, TESTED, and UNVERIFIED.

## Stop conditions
Never merge `main`, force push, clear persistent app data, fabricate trusted GNSS, bypass Android permissions, disclose keys or enable unapproved paid APIs.

## Task-specific protocol
Prefer connected GitHub tools and links; do not require local PC, ADB, Android Studio or shell. Identify allowed branch and current draft PR; change small sets of files and verify GitHub content after commit. Provide mobile-accessible PR/Actions URLs, artifact SHA and tested user instructions. Never claim a write when tooling was read-only.

## Required result
Provide changed files and exact commit or a read-only diagnosis, observed tests and CI, data/privacy/API-cost impact, remaining limitations and rollback.
