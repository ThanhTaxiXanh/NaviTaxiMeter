---
name: navi-vietnam-map-integrity
description: "Kiểm tra dữ liệu, nhãn Biển Đông, Hoàng Sa, Trường Sa."
---

# navi-vietnam-map-integrity

## Common mandatory procedure
1. Read repository `AGENTS.md`, current handoff and the relevant `project/NaviTaxiMeter/` dossier. The live repo's hard rules take precedence over older design proposals.
2. Verify repository, authorized branch, HEAD, implementation symbols and test status before any write.
3. Propose the minimal observable behavior change and its regression seam; preserve SQLite, signed APK identity and privacy.
4. Never claim success without run/SHA evidence. Distinguish PROPOSED, IMPLEMENTED, TESTED, and UNVERIFIED.

## Stop conditions
Never merge `main`, force push, clear persistent app data, fabricate trusted GNSS, bypass Android permissions, disclose keys or enable unapproved paid APIs.

## Task-specific protocol
Treat map presentation requirements as product criteria; verify actual provider dataset/style and screenshots. Do not assume Google basemap labels/borders can be overridden. Identify independently licensed datasets where overlays are allowed, preserve attribution and record unresolved map conflicts. Mark renderer-less stage NOT TESTED; never fake geographic compliance or tamper with copyrighted map tiles.

## Required result
Provide changed files and exact commit or a read-only diagnosis, observed tests and CI, data/privacy/API-cost impact, remaining limitations and rollback.
