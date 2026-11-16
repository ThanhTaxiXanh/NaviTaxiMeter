---
name: navi-zero-cost-contract
description: "Chặn SDK/API có nguy cơ phát sinh phí và đánh giá 50/100 người dùng."
---

# navi-zero-cost-contract

## Common mandatory procedure
1. Read repository `AGENTS.md`, current handoff and the relevant `project/NaviTaxiMeter/` dossier. The live repo's hard rules take precedence over older design proposals.
2. Verify repository, authorized branch, HEAD, implementation symbols and test status before any write.
3. Propose the minimal observable behavior change and its regression seam; preserve SQLite, signed APK identity and privacy.
4. Never claim success without run/SHA evidence. Distinguish PROPOSED, IMPLEMENTED, TESTED, and UNVERIFIED.

## Stop conditions
Never merge `main`, force push, clear persistent app data, fabricate trusted GNSS, bypass Android permissions, disclose keys or enable unapproved paid APIs.

## Task-specific protocol
Current active contract forbids new Google Billing/Maps SDK and other metered services absent explicit owner approval. Run tool/check_zero_cost_policy.py and inspect dependencies, SDKs, network endpoints and cloud account usage separately. The source gate alone never proves 0 USD. Compute 50×24×30 and 100×24×30 user-hours with pricing/SKU evidence; treat cloud invoice evidence as NOT VERIFIED unless directly retrieved. Halt if a newly billable API appears.

## Required result
Provide changed files and exact commit or a read-only diagnosis, observed tests and CI, data/privacy/API-cost impact, remaining limitations and rollback.
