---
name: navi-trip-recorder
description: "Ghi nhận chuyến, route segment, checkpoint và kết thúc an toàn."
---

# navi-trip-recorder

## Common mandatory procedure
1. Read repository `AGENTS.md`, current handoff and the relevant `project/NaviTaxiMeter/` dossier. The live repo's hard rules take precedence over older design proposals.
2. Verify repository, authorized branch, HEAD, implementation symbols and test status before any write.
3. Propose the minimal observable behavior change and its regression seam; preserve SQLite, signed APK identity and privacy.
4. Never claim success without run/SHA evidence. Distinguish PROPOSED, IMPLEMENTED, TESTED, and UNVERIFIED.

## Stop conditions
Never merge `main`, force push, clear persistent app data, fabricate trusted GNSS, bypass Android permissions, disclose keys or enable unapproved paid APIs.

## Task-specific protocol
Trace idle/active/paused/suspended/finalizing/completed semantics in the actual coordinator. Accept only sequenced trustworthy fix; prevent duplicates; persist route and fare snapshot atomically before ACK. End-trip must be idempotent; corrupt/uncertain DB transitions fail closed. Lab-only native headless probe must not be described as production trip writer. Render polyline only for a verified active/history session.

## Required result
Provide changed files and exact commit or a read-only diagnosis, observed tests and CI, data/privacy/API-cost impact, remaining limitations and rollback.
