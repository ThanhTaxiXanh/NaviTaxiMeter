---
name: navi-github-actions
description: "Debug log GitHub Actions và xác minh bản build theo commit SHA."
---

# navi-github-actions

## Common mandatory procedure
1. Read repository `AGENTS.md`, current handoff and the relevant `project/NaviTaxiMeter/` dossier. The live repo's hard rules take precedence over older design proposals.
2. Verify repository, authorized branch, HEAD, implementation symbols and test status before any write.
3. Propose the minimal observable behavior change and its regression seam; preserve SQLite, signed APK identity and privacy.
4. Never claim success without run/SHA evidence. Distinguish PROPOSED, IMPLEMENTED, TESTED, and UNVERIFIED.

## Stop conditions
Never merge `main`, force push, clear persistent app data, fabricate trusted GNSS, bypass Android permissions, disclose keys or enable unapproved paid APIs.

## Task-specific protocol
Identify workflow, run URL, SHA and failing job. Inspect earliest primary failure before editing. Differentiate Dart analyzer, Flutter tests, Kotlin/JVM, Android emulator, manifest, signing and Python source gates. Fix smallest root cause and rerun. No secret logging, no silent signing key substitution, no claim of device GPS validation from emulator result. Report PASS/FAIL/UNVERIFIED per job and retain Draft PR.

## Required result
Provide changed files and exact commit or a read-only diagnosis, observed tests and CI, data/privacy/API-cost impact, remaining limitations and rollback.
