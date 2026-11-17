# NaviTaxiMeter | Product Requirements

## Planned seven screens (not a claim of implementation)
1. **Bản đồ chính:** live GPS, camera follow before trip, speed, validated speed limit if available, 2D/3D control, recenter.
2. **Tìm kiếm:** Vietnamese address/POI with and without accents, only through lawful independently licensed sources.
3. **Lập lộ trình:** origin, destination, stops, alternatives when validated data exists.
4. **Dẫn đường + đồng hồ:** turn guidance, route, fare, waiting and GPS confidence. Driving camera must never drive billing math.
5. **Lịch sử + doanh thu:** receipts, route replay where verified, daily/monthly reconciliation.
6. **Chi tiết + thanh toán:** itemized fare/toll/waiting, Tiền Mặt and Chuyển Khoản/VietQR.
7. **Cài đặt:** driver/vehicle, confirmed fare table, banks, backup, map/permissions.

## Core domain acceptance
- Bắt đầu only with user-confirmed tariff and trustworthy GPS, checkpointed atomically.
- Bậc giá opening includes threshold D0; subsequent bands only charge remaining distance.
- GPS bad/stale/out-of-order or persistence uncertainty → SUSPENDED; recover PAUSED, manually resume with new fix/segment.
- Kết thúc idempotently finalizes a transaction; invoice not regenerated with overwritten fare rules.
- Waiting grace/threshold and accrued minutes persist under background/lifecycle changes.
- QR must be validated by real bank app, never simulated as successful.
- Backups must include settings + fare + trips + routes + banks and be recoverable, without exporting secrets.

## Acceptance status
Only foundational domain tests and limited technical UI are verified in code. Seven customer screens, navigable live map, real driver trip, signed release, QR acceptance and 50/100 physical endurance are **NOT IMPLEMENTED OR UNVERIFIED** depending on item. Confirm per source before starting a slice.
