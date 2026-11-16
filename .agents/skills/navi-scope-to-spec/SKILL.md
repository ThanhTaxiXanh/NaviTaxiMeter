---
name: navi-scope-to-spec
description: "Đặc tả yêu cầu và chia ticket theo lát cắt end-to-end."
---

# navi-scope-to-spec

## Common mandatory procedure
1. Read repository `AGENTS.md`, current handoff and the relevant `project/NaviTaxiMeter/` dossier. The live repo's hard rules take precedence over older design proposals.
2. Verify repository, authorized branch, HEAD, implementation symbols and test status before any write.
3. Propose the minimal observable behavior change and its regression seam; preserve SQLite, signed APK identity and privacy.
4. Never claim success without run/SHA evidence. Distinguish PROPOSED, IMPLEMENTED, TESTED, and UNVERIFIED.

## Stop conditions
Never merge `main`, force push, clear persistent app data, fabricate trusted GNSS, bypass Android permissions, disclose keys or enable unapproved paid APIs.

## Task-specific protocol
Use existing live repo and dossier, classify confirmed/inferred/unverified. Write observable acceptance criteria, dependency edges, cost and migration gate for each ticket. Sequence one slice end-to-end across UI/domain/storage/test. Do not convert all seven screen mockups into completed UI without image assets and device comparison. Capture incompatibilities between proposed Google Maps UX and active zero-billing policy.

## Required result
Provide changed files and exact commit or a read-only diagnosis, observed tests and CI, data/privacy/API-cost impact, remaining limitations and rollback.
