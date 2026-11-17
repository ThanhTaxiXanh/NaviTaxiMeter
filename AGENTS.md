# NaviTaxiMeter · AI Engineering Instructions

This file applies to code agents operating on this repository. Canonical app: **NaviTaxiMeter**, package `vn.navitaximeter`. It is **NOT** the TTX DRIVER PRO repository.

## Authority and working scope
- Active development branch: `feature/navitaximeter-foundation`; PR #1 remains **Draft**. Never merge to `main`, force-push, rewrite history, or change signing secrets without explicit authorization.
- Before implementing, read `docs/HANDOFF_2026-11-16_CYCLE4_7-7.md`, `docs/QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md`, `docs/FOUNDATION_STATUS.md`, and the current source. Verify current SHA and GitHub Actions evidence because historical handoffs can be stale.
- Highest-priority in-repo product constraints are the current verified code, explicit owner decisions, and the handoff's hard rules. `project/NaviTaxiMeter/*` contains design proposals originally authored **before live repository inspection**. When they conflict, treat them as proposals only, not permission to change live rules.
- **Zero Paid API:** Do not add Google Maps SDK, Cloud Billing, Maps 3D, Places, Routes, Navigation, paid tiles, etc. while the active zero-cost contract prohibits them. A source-only CI gate is not a Cloud invoice audit. Escalate conflict between Google Maps UX preference and zero-billing rule; do not silently enable billing.
- Preserve `navitaximeter_v1.db` schema v3, `navi_confirmed_tariffs_v1`, immutable receipts, routes, and trip state. Never clear/migrate production user data to bypass tests. No mock GPS or demo tariff used for passenger fare.
- Keep one trustworthy GNSS owner and one durable trip writer as a **target architecture**, not an already deployed guarantee. Fail closed to SUSPENDED on uncertain GPS/SQLite ACK; resume only manually from fresh fix.
- Do not claim the application is ready to collect passenger fares. Android physical GPS/FGS, production SQLite writer/ACK, release signing, license/cost audit and UI acceptance remain gated.
- User can work entirely from iPhone. Use connected GitHub tools, Draft PR, and GitHub Actions; do not require a desktop as the only path.

## Skills
**Mandatory for every source-code development task:** read `AGENTS.md`, inspect the latest handoff (not just a hardcoded historical filename), then read `.agents/skills/navi-code-commander/SKILL.md` to select and read only relevant task-specific `navi-*` skills. Do not load all 29 skills. Every change must preserve data/privacy, authorized GitHub branch and Draft PR, tests and exact-SHA CI evidence, and Zero Paid API. See hard rule §10 in `docs/QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md`.

Start with `.agents/skills/navi-code-commander/SKILL.md`, then load only the needed `navi-*` skill. Refer to `project/NaviTaxiMeter/README-INTEGRATION.md` for the source-of-truth hierarchy and mapping from skills to live code.

## Evidence and handoff
For each code change provide repo, branch, commit, affected files, tests actually executed, CI run link/status, unresolved risks and rollback. Obey `docs/QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md` including scheduled handoffs when counting is verifiable. Never fake PASS or claim a source scan proves a real-device or billing test.
