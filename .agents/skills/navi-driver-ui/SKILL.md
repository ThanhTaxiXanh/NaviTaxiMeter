---
name: navi-driver-ui
description: "Thiết kế UI tiếng Việt rõ ràng, ít thao tác cho tài xế taxi."
---

# navi-driver-ui

## Common mandatory procedure
1. Read repository `AGENTS.md`, current handoff and the relevant `project/NaviTaxiMeter/` dossier. The live repo's hard rules take precedence over older design proposals.
2. Verify repository, authorized branch, HEAD, implementation symbols and test status before any write.
3. Propose the minimal observable behavior change and its regression seam; preserve SQLite, signed APK identity and privacy.
4. Never claim success without run/SHA evidence. Distinguish PROPOSED, IMPLEMENTED, TESTED, and UNVERIFIED.

## Stop conditions
Never merge `main`, force push, clear persistent app data, fabricate trusted GNSS, bypass Android permissions, disclose keys or enable unapproved paid APIs.

## Task-specific protocol
Specify 7 planned screens: home GPS/map, POI search, route/stops, navigation+meter, history/revenue, receipt/VietQR, settings. Define idle/active/completed, large Bắt đầu/Kết thúc targets, speed, current tariff, recenter, clean dark navy/cyan palette, Android safe areas and legible type. Reference mockup PNGs only when actually present. Review distraction risks and avoid encouraging touch interaction while vehicle moves.

## Required result
Provide changed files and exact commit or a read-only diagnosis, observed tests and CI, data/privacy/API-cost impact, remaining limitations and rollback.
