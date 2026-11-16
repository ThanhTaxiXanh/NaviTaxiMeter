---
name: navi-code-commander
description: "Điều phối workflow lập trình NaviTaxiMeter, chọn kỹ năng đúng theo nhiệm vụ."
---

# navi-code-commander

## Common mandatory procedure
1. Read repository `AGENTS.md`, current handoff and the relevant `project/NaviTaxiMeter/` dossier. The live repo's hard rules take precedence over older design proposals.
2. Verify repository, authorized branch, HEAD, implementation symbols and test status before any write.
3. Propose the minimal observable behavior change and its regression seam; preserve SQLite, signed APK identity and privacy.
4. Never claim success without run/SHA evidence. Distinguish PROPOSED, IMPLEMENTED, TESTED, and UNVERIFIED.

## Stop conditions
Never merge `main`, force push, clear persistent app data, fabricate trusted GNSS, bypass Android permissions, disclose keys or enable unapproved paid APIs.

## Task-specific protocol
Read repo AGENTS.md and latest handoff. Route investigation→navi-repo-map; feature→navi-scope-to-spec + navi-safe-change + navi-red-green; bug→navi-root-cause; maps→navi-zero-cost-contract + navi-google-map-driving; GPS→navi-location-background; money→navi-fare-engine + navi-database-evolution; delivery→navi-github-actions + navi-review-two-axis. Never treat user-invoked skills, absent tooling, or proposed architecture as guaranteed capabilities. Stop on conflicting hard requirements.

## Required result
Provide changed files and exact commit or a read-only diagnosis, observed tests and CI, data/privacy/API-cost impact, remaining limitations and rollback.
