---
name: navi-performance-profile
description: "Đo và tối ưu khởi động, FPS, pin, RAM, APK của Flutter Android."
---

# navi-performance-profile

## Common mandatory procedure
1. Read repository `AGENTS.md`, current handoff and the relevant `project/NaviTaxiMeter/` dossier. The live repo's hard rules take precedence over older design proposals.
2. Verify repository, authorized branch, HEAD, implementation symbols and test status before any write.
3. Propose the minimal observable behavior change and its regression seam; preserve SQLite, signed APK identity and privacy.
4. Never claim success without run/SHA evidence. Distinguish PROPOSED, IMPLEMENTED, TESTED, and UNVERIFIED.

## Stop conditions
Never merge `main`, force push, clear persistent app data, fabricate trusted GNSS, bypass Android permissions, disclose keys or enable unapproved paid APIs.

## Task-specific protocol
Capture before metrics for cold start, CPU/frame, RAM, battery, APK bytes and DB writes. Separate GPS metering from camera redraw and throttle render-only updates without modifying monetary sampling. Test long runs/Doze on a physical Android device; distinguish profiling from guesswork. Report before/after data and Android build fingerprints.

## Required result
Provide changed files and exact commit or a read-only diagnosis, observed tests and CI, data/privacy/API-cost impact, remaining limitations and rollback.
