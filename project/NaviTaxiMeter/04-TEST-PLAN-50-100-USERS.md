# NaviTaxiMeter | Functional, Device, Endurance and Cost Test Plan

## Gates before passenger use
1. Dart/SQLite unit and integration: tariff boundaries, wait threshold, rounding, duplicate finalization, route transaction, SQLite v3 recovery, backup round-trip.
2. Android native/JVM and emulator: FGS permissions, IPC/fence tests, headless SQLite proof. **Emulator passing does not prove real GNSS.**
3. Physical Android/OEM: start from visible activity, lock screen, background, force-stop/reboot, degraded GPS, battery saver, network outage, privilege revoke, pause/resume, data durability. Track device model/build and explicit PASS/FAIL evidence.
4. Release: package/signature continuity, install-over-old data, real QR bank scan, 7 screen screenshot acceptance, driver safety review.
5. Costs: static dependency scan plus real provider Cloud usage/billing evidence if any provider account is approved; otherwise service remains blocked.

## 50/100 continuous users
- 50 × 24 × 30 = **36,000 user-hours**.
- 100 × 24 × 30 = **72,000 user-hours**.
- Simulations can stress deterministic fare math, database and requests with controlled clocks; they cannot certify Android physical GPS 24/24 or provider billing invoices.
- Record request counts per API/SKU, quotas, unit rates, worst-case burst, observed cloud invoices (if any), and licence status. No actual field endurance result may be reported until executed.

## Result template
`test-id | device/build | commit | procedure | expected | actual | run/link | PASS/FAIL/NOT TESTED | limitations`
