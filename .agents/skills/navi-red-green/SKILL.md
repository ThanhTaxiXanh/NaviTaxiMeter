---
name: navi-red-green
description: "Phát triển theo RED → GREEN → REFACTOR và kiểm thử hợp đồng."
---

# navi-red-green

## Common mandatory procedure
1. Read repository `AGENTS.md`, current handoff and the relevant `project/NaviTaxiMeter/` dossier. The live repo's hard rules take precedence over older design proposals.
2. Verify repository, authorized branch, HEAD, implementation symbols and test status before any write.
3. Propose the minimal observable behavior change and its regression seam; preserve SQLite, signed APK identity and privacy.
4. Never claim success without run/SHA evidence. Distinguish PROPOSED, IMPLEMENTED, TESTED, and UNVERIFIED.

## Stop conditions
Never merge `main`, force push, clear persistent app data, fabricate trusted GNSS, bypass Android permissions, disclose keys or enable unapproved paid APIs.

## Task-specific protocol
Choose public seams in existing repo: TaximeterEngine, MeteredTripCoordinator, TripRepository, IPC checkpoint protocol, confirmed tariff codec. Write a failing behavioral regression with independently computed expected values, make minimal pass, refactor with suite green. Unit mocks may exercise GPS/clock but never stand in for GNSS hardware, real billing or production ACK. Run flutter test/analyze and native tests when possible; otherwise label UNVERIFIED.

## Required result
Provide changed files and exact commit or a read-only diagnosis, observed tests and CI, data/privacy/API-cost impact, remaining limitations and rollback.
