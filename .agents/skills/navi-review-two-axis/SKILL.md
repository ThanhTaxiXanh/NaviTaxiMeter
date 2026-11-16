---
name: navi-review-two-axis
description: "Review diff theo chất lượng kỹ thuật và đặc tả sản phẩm."
---

# navi-review-two-axis

## Common mandatory procedure
1. Read repository `AGENTS.md`, current handoff and the relevant `project/NaviTaxiMeter/` dossier. The live repo's hard rules take precedence over older design proposals.
2. Verify repository, authorized branch, HEAD, implementation symbols and test status before any write.
3. Propose the minimal observable behavior change and its regression seam; preserve SQLite, signed APK identity and privacy.
4. Never claim success without run/SHA evidence. Distinguish PROPOSED, IMPLEMENTED, TESTED, and UNVERIFIED.

## Stop conditions
Never merge `main`, force push, clear persistent app data, fabricate trusted GNSS, bypass Android permissions, disclose keys or enable unapproved paid APIs.

## Task-specific protocol
Pin fixed SHA/merge-base, inspect actual diff and relevant specs. Axis A: data loss/transactions, concurrent GPS/SQLite, Android FGS, secrets, performance, dependency licences. Axis B: feature correctness, NaviTaxiMeter acceptance, source gate, UI reference availability. Rank P0/P1/P2 and include path/line evidence only when read. Preserve active Draft PR; no self-merge.

## Required result
Provide changed files and exact commit or a read-only diagnosis, observed tests and CI, data/privacy/API-cost impact, remaining limitations and rollback.
