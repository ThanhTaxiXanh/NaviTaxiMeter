---
name: navi-scenario-qa
description: "Lập ma trận test taxi, GPS, SQLite, backup và 50/100 người dùng."
---

# navi-scenario-qa

## Common mandatory procedure
1. Read repository `AGENTS.md`, current handoff and the relevant `project/NaviTaxiMeter/` dossier. The live repo's hard rules take precedence over older design proposals.
2. Verify repository, authorized branch, HEAD, implementation symbols and test status before any write.
3. Propose the minimal observable behavior change and its regression seam; preserve SQLite, signed APK identity and privacy.
4. Never claim success without run/SHA evidence. Distinguish PROPOSED, IMPLEMENTED, TESTED, and UNVERIFIED.

## Stop conditions
Never merge `main`, force push, clear persistent app data, fabricate trusted GNSS, bypass Android permissions, disclose keys or enable unapproved paid APIs.

## Task-specific protocol
Create acceptance matrix with device/environment, input, expected, actual, evidence, result PASS/FAIL/NOT TESTED. Cover idle follow, metering, tier edges, waiting, GPS/FGS gaps, SQLite crash/restart, backup, QR, route, dark map and release signer. For 50/100 users 24/24 calculate 36,000/72,000 user-hours per month (30 days); a simulation is not a cost invoice or a completed endurance test. Hardware and Cloud billing are separate gates.

## Required result
Provide changed files and exact commit or a read-only diagnosis, observed tests and CI, data/privacy/API-cost impact, remaining limitations and rollback.
