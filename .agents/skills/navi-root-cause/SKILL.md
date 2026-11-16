---
name: navi-root-cause
description: "Chẩn đoán lỗi có bằng chứng và test tái hiện."
---

# navi-root-cause

## Common mandatory procedure
1. Read repository `AGENTS.md`, current handoff and the relevant `project/NaviTaxiMeter/` dossier. The live repo's hard rules take precedence over older design proposals.
2. Verify repository, authorized branch, HEAD, implementation symbols and test status before any write.
3. Propose the minimal observable behavior change and its regression seam; preserve SQLite, signed APK identity and privacy.
4. Never claim success without run/SHA evidence. Distinguish PROPOSED, IMPLEMENTED, TESTED, and UNVERIFIED.

## Stop conditions
Never merge `main`, force push, clear persistent app data, fabricate trusted GNSS, bypass Android permissions, disclose keys or enable unapproved paid APIs.

## Task-specific protocol
Collect build SHA, expected/actual behavior, affected device/OS, reproducibility and redacted logs. Build one failing test or reproducible measurement, hypothesize and instrument minimally. Fix smallest causal source; rerun test and CI. Avoid broad edits, fake-pass statements and assuming the last line of Actions log is root failure.

## Required result
Provide changed files and exact commit or a read-only diagnosis, observed tests and CI, data/privacy/API-cost impact, remaining limitations and rollback.
