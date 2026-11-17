# NaviTaxiMeter project dossier: integration and precedence

This directory integrates the earlier **NaviTaxiMeter Project Dossier v2.0.0** into the *actual* GitHub repository. The text has been reconciled with live code/hand-offs as of 2026-11-16 rather than copied as a frozen design ZIP. Files here are **specifications and engineering context**, NOT evidence that all features exist.

## Authority, in descending priority
1. User-approved hard constraints, active repo `AGENTS.md`, `docs/QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md`, and most recent verified project handoff.
2. Actual GitHub commit/source/tests/CI evidence.
3. Approved technical decisions and current implementation contracts.
4. These project dossier documents as **requirements and proposals**.
5. Older standalone ZIP references or experimental/mock/test-only code.

## Material differences from old v2.0 dossier
- Repository and working branch are now known: `ThanhTaxiXanh/NaviTaxiMeter`, `feature/navitaximeter-foundation`, Draft PR #1.
- Standard Google Maps SDK is **not integrated** and is blocked by the current no-Google-Billing/no-paid-API rule. An older document's Google Maps preference is a product aspiration, not a permission to activate SDK/billing. See `03-GOOGLE-MAPS-COST-AND-LICENSE.md`.
- Android physical GNSS, production one-owner/one-writer, final seven screens, signed release and real customer metering are NOT VERIFIED.
- `docs/HANDOFF_2026-11-16_CYCLE4_7-7.md` and code are the current operational reference. Never overwrite these from a skills pack.
- The original ZIP's 29 procedural skill topics have been integrated as repo-adjusted `.agents/skills/navi-*/SKILL.md` plus Codex metadata.

## Usage
Read `AGENTS.md` then `.agents/skills/navi-code-commander/SKILL.md` and one or two relevant skills. Consult this dossier only for requirements. Before any patch inspect actual source, SHA, tests and CI. Never classify old planned requirements as completed features.
