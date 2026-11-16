---
name: navi-secret-policy
description: "Phát hiện rò rỉ key, signing, tài khoản ngân hàng và vị trí."
---

# navi-secret-policy

## Common mandatory procedure
1. Read repository `AGENTS.md`, current handoff and the relevant `project/NaviTaxiMeter/` dossier. The live repo's hard rules take precedence over older design proposals.
2. Verify repository, authorized branch, HEAD, implementation symbols and test status before any write.
3. Propose the minimal observable behavior change and its regression seam; preserve SQLite, signed APK identity and privacy.
4. Never claim success without run/SHA evidence. Distinguish PROPOSED, IMPLEMENTED, TESTED, and UNVERIFIED.

## Stop conditions
Never merge `main`, force push, clear persistent app data, fabricate trusted GNSS, bypass Android permissions, disclose keys or enable unapproved paid APIs.

## Task-specific protocol
Inspect secrets in repo/Actions/logs/backup, Android exported components and location permissions. Mask tokens, keystore, bank accounts and customer GPS. Do not output sensitive strings while investigating. Validate API key restrictions only when use has explicit approval. Provide severity and rotation recommendations for confirmed exposure; do not silently generate/rotate keys.

## Required result
Provide changed files and exact commit or a read-only diagnosis, observed tests and CI, data/privacy/API-cost impact, remaining limitations and rollback.
