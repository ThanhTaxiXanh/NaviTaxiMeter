---
name: navi-architecture-gate
description: "Đánh giá kiến trúc Flutter, state machine và ranh giới GPS, cước, SQLite, UI."
---

# navi-architecture-gate

## Common mandatory procedure
1. Read repository `AGENTS.md`, current handoff and the relevant `project/NaviTaxiMeter/` dossier. The live repo's hard rules take precedence over older design proposals.
2. Verify repository, authorized branch, HEAD, implementation symbols and test status before any write.
3. Propose the minimal observable behavior change and its regression seam; preserve SQLite, signed APK identity and privacy.
4. Never claim success without run/SHA evidence. Distinguish PROPOSED, IMPLEMENTED, TESTED, and UNVERIFIED.

## Stop conditions
Never merge `main`, force push, clear persistent app data, fabricate trusted GNSS, bypass Android permissions, disclose keys or enable unapproved paid APIs.

## Task-specific protocol
Trace actual dependency graph and compare only against an explicitly proposed design. Keep pure fare math independent of widgets/map renderer; one trip state owner, a controlled location service lifecycle, transactional persistence. Flag cycles, mutable globals, and untestable modules. Prefer smallest safe refactor. The single-owner GNSS and production SQLite writer remain design targets, not verified deployed components.

## Required result
Provide changed files and exact commit or a read-only diagnosis, observed tests and CI, data/privacy/API-cost impact, remaining limitations and rollback.
