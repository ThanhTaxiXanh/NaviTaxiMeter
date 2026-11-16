---
name: navi-location-background
description: "Thiết kế GPS foreground/background an toàn trên Android."
---

# navi-location-background

## Common mandatory procedure
1. Read repository `AGENTS.md`, current handoff and the relevant `project/NaviTaxiMeter/` dossier. The live repo's hard rules take precedence over older design proposals.
2. Verify repository, authorized branch, HEAD, implementation symbols and test status before any write.
3. Propose the minimal observable behavior change and its regression seam; preserve SQLite, signed APK identity and privacy.
4. Never claim success without run/SHA evidence. Distinguish PROPOSED, IMPLEMENTED, TESTED, and UNVERIFIED.

## Stop conditions
Never merge `main`, force push, clear persistent app data, fabricate trusted GNSS, bypass Android permissions, disclose keys or enable unapproved paid APIs.

## Task-specific protocol
Trace current Geolocator preview, GPS lab, Kotlin LocationSafetyService and permissions. Existing safety FGS measures fix liveness, not production trip navigation. Respect user-authorized FGS lifecycle and permissions; fail-closed SUSPENDED on uncertain GNSS/ACK; recovery PAUSED and manual RESUME. Propose one GNSS owner and one durable writer without asserting existing tests prove production. Test screen lock, process kill, revoke, battery saver, out-of-order/stale fixes on real devices separately from emulator.

## Required result
Provide changed files and exact commit or a read-only diagnosis, observed tests and CI, data/privacy/API-cost impact, remaining limitations and rollback.
