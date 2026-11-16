---
name: navi-google-map-driving
description: "Đánh giá bản đồ lái xe 2D/3D, camera, tòa nhà và Google Maps."
---

# navi-google-map-driving

## Common mandatory procedure
1. Read repository `AGENTS.md`, current handoff and the relevant `project/NaviTaxiMeter/` dossier. The live repo's hard rules take precedence over older design proposals.
2. Verify repository, authorized branch, HEAD, implementation symbols and test status before any write.
3. Propose the minimal observable behavior change and its regression seam; preserve SQLite, signed APK identity and privacy.
4. Never claim success without run/SHA evidence. Distinguish PROPOSED, IMPLEMENTED, TESTED, and UNVERIFIED.

## Stop conditions
Never merge `main`, force push, clear persistent app data, fabricate trusted GNSS, bypass Android permissions, disclose keys or enable unapproved paid APIs.

## Task-specific protocol
Current repository prohibits adding Google Maps SDK or enabling Cloud Billing absent separate owner approval; read docs/HANDOFF_2026-11-16_CYCLE4_7-7.md and tool/check_zero_cost_policy.py first. The older dossier's standard Maps SDK suggestion is NOT permission to add it. If approved later, separate camera intents from metering GNSS, support follow/recenter/manual-pan, heading smoothing, zoom-dependent tilt and evidence-based 3D building availability. Do not scrape Google tiles or claim immersive 3D is free.

## Required result
Provide changed files and exact commit or a read-only diagnosis, observed tests and CI, data/privacy/API-cost impact, remaining limitations and rollback.
