---
name: navi-speed-data
description: "Kiểm chứng nguồn dữ liệu biển báo và giới hạn tốc độ hợp pháp."
---

# navi-speed-data

## Common mandatory procedure
1. Read repository `AGENTS.md`, current handoff and the relevant `project/NaviTaxiMeter/` dossier. The live repo's hard rules take precedence over older design proposals.
2. Verify repository, authorized branch, HEAD, implementation symbols and test status before any write.
3. Propose the minimal observable behavior change and its regression seam; preserve SQLite, signed APK identity and privacy.
4. Never claim success without run/SHA evidence. Distinguish PROPOSED, IMPLEMENTED, TESTED, and UNVERIFIED.

## Stop conditions
Never merge `main`, force push, clear persistent app data, fabricate trusted GNSS, bypass Android permissions, disclose keys or enable unapproved paid APIs.

## Task-specific protocol
Assess independent data provenance, licensing, update cadence, directionality and road class. Distinguish verified legal signs from OSM guesses; show unknown if confidence inadequate. Never scrape Google map tiles for geodata. Test speed overlay as non-authoritative driver aid before release.

## Required result
Provide changed files and exact commit or a read-only diagnosis, observed tests and CI, data/privacy/API-cost impact, remaining limitations and rollback.
