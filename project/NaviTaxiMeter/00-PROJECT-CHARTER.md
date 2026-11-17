# NaviTaxiMeter | Project Charter (repo-integrated)

**Product:** NaviTaxiMeter, Flutter/Dart Android-first, package `vn.navitaximeter`. **Audience:** Vietnamese taxi drivers. **State:** technical foundation, not authorized for collecting passenger fares.

## Objective
A reliable taximeter with real trustworthy GNSS, configurable confirmed fare tables, waiting/BOT, immutable receipts, trip history and revenue, cash or VietQR transfer, backup/recovery. Desired later UX: seven modern Vietnamese screens and a smooth navigation-oriented map with 2D/3D buildings and orientation behind vehicle.

## Non-negotiable constraints
- Zero paid API / zero unapproved billing at 1/50/100 active users; no Google Cloud billing enablement. Ads, subscriptions and pay-as-you-go services are not automatic substitutes.
- Git branch `feature/navitaximeter-foundation`; keep PR #1 Draft, do not merge main, do not modify the reference TTX repo.
- Fare is derived only from verified GNSS plus approved tariffs; no demo fare, mock GPS or extrapolated broken segments for actual passenger charges.
- Preserve SQLite schema 3 and preferences; require lossless verified migrations and backup/restore before altering production data.
- Protect private location, bank credentials, signing secrets and ride data. Follow Android location and foreground-service policy.
- iPhone-only GitHub workflow supported; GitHub Actions provides CI evidence, not proof of physical Android field quality.
- Follow mandatory seven-assistant-reply handoff rules in `docs/QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md`.

## Live snapshot
Read the newest handoff and code for precise commit status. As of 16 Nov 2026, the project has Dart meter engine, tariff/SQLite contracts, test-oriented GPS/IPC proof and Android native GPS diagnostics. Production physical GPS→durable fare writer→customer trip UI is not complete. Planned Google Maps display is not enabled.
