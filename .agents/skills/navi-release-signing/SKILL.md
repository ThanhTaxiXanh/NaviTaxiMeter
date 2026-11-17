---
name: navi-release-signing
description: "Kiểm định version, Android applicationId, chữ ký APK và phát hành."
---

# navi-release-signing

## Common mandatory procedure
1. Read repository `AGENTS.md`, current handoff and the relevant `project/NaviTaxiMeter/` dossier. The live repo's hard rules take precedence over older design proposals.
2. Verify repository, authorized branch, HEAD, implementation symbols and test status before any write.
3. Propose the minimal observable behavior change and its regression seam; preserve SQLite, signed APK identity and privacy.
4. Never claim success without run/SHA evidence. Distinguish PROPOSED, IMPLEMENTED, TESTED, and UNVERIFIED.

## Stop conditions
Never merge `main`, force push, clear persistent app data, fabricate trusted GNSS, bypass Android permissions, disclose keys or enable unapproved paid APIs.

## Task-specific protocol
Review pubspec.yaml, GitHub workflow and generated Gradle/manifest configuration. Use vn.navitaximeter; do not import keystore from unrelated application. Validate package, versionCode, signer continuity, artifact SHA and install data retention before any release. Secret material must stay in approved GitHub secrets, never logs or source. No production release/merge without owner approval and hardware gates.

## Required result
Provide changed files and exact commit or a read-only diagnosis, observed tests and CI, data/privacy/API-cost impact, remaining limitations and rollback.
