---
name: navi-fare-engine
description: "Kiểm định công thức cước theo bậc, cước chờ, BOT và chốt giá."
---

# navi-fare-engine

## Common mandatory procedure
1. Read repository `AGENTS.md`, current handoff and the relevant `project/NaviTaxiMeter/` dossier. The live repo's hard rules take precedence over older design proposals.
2. Verify repository, authorized branch, HEAD, implementation symbols and test status before any write.
3. Propose the minimal observable behavior change and its regression seam; preserve SQLite, signed APK identity and privacy.
4. Never claim success without run/SHA evidence. Distinguish PROPOSED, IMPLEMENTED, TESTED, and UNVERIFIED.

## Stop conditions
Never merge `main`, force push, clear persistent app data, fabricate trusted GNSS, bypass Android permissions, disclose keys or enable unapproved paid APIs.

## Task-specific protocol
Verify existing Dart TaximeterEngine, ConfirmedTariffs and MeteredTripCoordinator. Opening price covers included distance D0; next band applies only to max(0,distance-D0). Snapshot driver-confirmed tariff for each trip; do not apply demo fixtures to passenger charges. Test exact tier boundaries, negative/large input, GPS gaps, waiting threshold, BOT, discounts, rounding and replay parity. Calculate independent numeric expected values rather than deriving expected from the implementation.

## Required result
Provide changed files and exact commit or a read-only diagnosis, observed tests and CI, data/privacy/API-cost impact, remaining limitations and rollback.
