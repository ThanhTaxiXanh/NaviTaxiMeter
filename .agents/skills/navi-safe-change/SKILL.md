---
name: navi-safe-change
description: "Triển khai chỉnh sửa nhỏ có rollback và kiểm chứng rõ ràng."
---

# navi-safe-change

## Common mandatory procedure
1. Read repository `AGENTS.md`, current handoff and the relevant `project/NaviTaxiMeter/` dossier. The live repo's hard rules take precedence over older design proposals.
2. Verify repository, authorized branch, HEAD, implementation symbols and test status before any write.
3. Propose the minimal observable behavior change and its regression seam; preserve SQLite, signed APK identity and privacy.
4. Never claim success without run/SHA evidence. Distinguish PROPOSED, IMPLEMENTED, TESTED, and UNVERIFIED.

## Stop conditions
Never merge `main`, force push, clear persistent app data, fabricate trusted GNSS, bypass Android permissions, disclose keys or enable unapproved paid APIs.

## Task-specific protocol
Pin branch HEAD, impact files and data/billing risks. Implement one vertical slice on the authorized feature branch. Add regression test, format/analyze/test when available, inspect diff, verify Actions and give rollback path. Never modify main, force push, merge Draft PR, reset SQLite or turn on billable APIs. Distinguish a real commit from a proposed patch.

## Required result
Provide changed files and exact commit or a read-only diagnosis, observed tests and CI, data/privacy/API-cost impact, remaining limitations and rollback.
