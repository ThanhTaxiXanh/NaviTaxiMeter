# Thiết kế hợp đồng TripLocationService, chưa kích hoạt sản phẩm

**Ngày:** 15/11/2026. **Trạng thái:** bản thiết kế và **giao thức Kotlin JVM thử nghiệm**, không có Android TripLocationService thực, không có kết nối SQLite/GPS/bảng giá, không thu cước. Tham chiếu issue #3 và cổng thử máy thật issue #2.

## 1. Sự thật trong mã hiện tại

- `lib/src/data/trip_repository.dart` mở `navitaximeter_v1.db` **schema 3**.
  `active_trip` có `id=1, payload, updated_at`; `active_trip_route` có
  `sequence INTEGER PRIMARY KEY` (chỉ số bắt đầu từ **0**),
  `latitude, longitude, recorded_at, accuracy_meters, speed_kmh, segment`.
- `saveActiveIncremental()` viết header `active_trip` cùng các điểm mới
  trong một transaction, từ chối khoảng trống số thứ tự/routeCount
  không khớp. **Đã phát hiện và sửa trong chu kỳ 5/7**: trước đây,
  `INSERT OR IGNORE` có thể chấp nhận replay cùng sequence nhưng
  tọa độ/speed khác; nay đối chiếu mọi trường với hàng SQLite đã lưu,
  chỉ replay giống hệt mới hợp lệ. Có Dart SQLite FFI tests lỗi này.
  Vẫn chưa có sessionId/generation fence hay native durable ACK.
- `MeteredTripCoordinator` là tầng thử nghiệm Flutter. Nó dừng khi fix
  kém, watchdog không cộng tiền từ riêng đồng hồ, checkpoint lỗi thì
  khóa tiếp nhận cho tới khi khôi phục; recovery luôn PAUSED và resume
  thủ công. Tầng này không có worker nền bảo đảm hoạt động sau kill.
- `LocationOwnerRegistry` chỉ khóa độc quyền *trong tiến trình* giữa
  các luồng GPS thí nghiệm. `LocationSafetyService` chỉ báo sức khỏe GPS,
  không chuyển vị trí hoặc tính cước. Chưa có TripLocationService.

## 2. Giao thức Kotlin JVM chỉ phục vụ thiết kế

`android_native/TripCheckpointProtocol.kt` là **pure Kotlin**. Nó
**không được gọi từ MainActivity, LocationSafetyService hay Flutter**,
và không có quyền truy cập Android LocationManager, SQLite, VietQR,
hóa đơn, Google SDK hoặc bộ tính tiền.

Trạng thái lý thuyết:

```text
IDLE --requestStart(sessionId,generation)--> START_REQUESTED
     --live service ACK + fresh monotonic heartbeat--> SERVICE_ACKED
     --GNSS acquisition--> GPS_ACQUIRING
     --verified true GNSS fix--> ACTIVE
ACTIVE --validated fix + atomic writer commit--> ACTIVE + checkpoint ACK
any failure, discontinuity, write uncertainty --> SUSPENDED
restart/recover-from-verified-durable-data --> SUSPENDED (PAUSED)
SUSPENDED --(no implicit transition implemented)--> [manual resume TBD]
```

Dữ liệu khóa: `TripSessionFence(sessionId, generation)`. Mỗi mẫu chỉ
mang metadata `sequence` zero-based, `gnssElapsedRealtimeNanos`,
`accuracyMeters`, `speedKmh`, `isMocked`. **Không mang tọa độ**, nên
giao thức chưa và không thể tạo route thực. Nó chặn mock, sai số >30 m,
speed >220 km/h, NaN, thời gian đảo chiều, gap GNSS >12 giây, thiếu
sequence, duplicate khác nội dung và token stale.

`AtomicTripCheckpointWriter.commit(candidate)` là một **interface chưa
có triển khai thật**. `CheckpointCommitReceipt` chỉ được gate chấp
nhận khi writer trả về đúng session/generation/sequence và ID checkpoint
không rỗng. JVM tests sử dụng fake writer. **Một fake có thể trả kết quả
giả; kiểm thử hiện tại KHÔNG chứng nhận commit SQLite, tọa độ thực,
service liveness, bảo toàn dữ liệu hoặc cước.** Giao thức không có API
resume cho chế độ sử dụng thật.

## 3. Hợp đồng bắt buộc cho writer thật, chưa lập trình

Mọi lời gọi ACK phải xuất phát từ **một writer duy nhất** sở hữu kết nối
transaction tới dữ liệu chuyến. Không chạy đồng thời hai bên ghi:
Kotlin `SQLiteDatabase` và Flutter `sqflite` ghi cùng một phiên.

Đề xuất **migration schema tương lai, KHÔNG được áp dụng tự động ở đây**:
bổ sung metadata fence `sessionId, generation, lastCommittedSequence,
lastGnssElapsedNanos, lastPayloadHash, checkpointId` gắn với active trip
trong một transaction cùng header và route. Giữ cơ chế bảo vệ receipt
bất biến; không ghi đè chuyến trước. Cần phát triển migration v3→v4
theo kiểm thử backup, rollback, cập nhật APK và xung đột thật.

Quy trình write/ACK dự kiến:
1. Kiểm tra owner token còn hiệu lực, hoạt động FGS được Android xác
   nhận, GNSS physical thật và tariff đã xác nhận và đóng băng.
2. Đối chiếu generation và **lastSequence từ SQLite**, không dựa vào
   biến RAM; kiểm tra duplicate có cùng hash/cùng payload không. Sai
   nội dung cùng sequence là **xung đột**, không `INSERT OR IGNORE` mù. Phần kiểm tra
   hàng SQLite v3 trong Dart đã được bổ sung, nhưng sessionId/generation
   thật và kiểm soát writer xuyên runtime vẫn chưa có.
3. Ghi `active_trip`, `active_trip_route`, metadata fence và receipt
   checkpoint trong **một** transaction. Rollback mọi phần khi lỗi.
4. Chỉ sau commit thật mới phát ACK gồm sessionId, generation, sequence
   và checkpointId. Nếu commit có thể đã thành công nhưng phản hồi bị
   mất: **PAUSE**, đọc lại checkpoint từ DB để đối chiếu; không tự
   ghi lại dữ liệu hoặc tính thêm tiền.
5. Từ chối event thứ tự cũ, generation cũ và GPS gap. Không suy diễn
   đoạn đường hoặc thời gian chờ bị thiếu.
6. Khi restart, chỉ đọc dữ liệu đã commit, phục hồi PAUSED; phải có
   một bước người lái bấm Resume thủ công với fix mới và segment mới.

## 4. Bằng chứng và giới hạn hiện tại

- `TripCheckpointProtocolTest.kt` có JVM tests cho startup ACK sai token
  hoặc stale, commit ACK sau writer, replay idempotent, duplicate thay
  đổi nội dung, gap/rollback time, mock/bad accuracy/speed, lỗi ghi,
  receipt giả/mismatch, recovered PAUSED, không auto resume, concurrency.
- `tool/bootstrap_android.py` đưa proto + tests vào Flutter Android
  generated skeleton; cùng bước Gradle `:app:testDebugUnitTest`.
- **Chưa đủ điều kiện phát hành:** writer SQLite thật, fail-injection
  DB/instrumented tests, app/service ACK chứng minh Android, 11–16 thiết
  bị thật/OEM Doze, nghiên cứu runtime tính cước nền và parity Dart,
  backup/migration v4, đối chiếu quãng đường, Zero Paid API 30 ngày, phê
  duyệt chủ dự án. Không viết dữ liệu chuyến thương mại từ protocol thử.

## 5. Việc tiếp tục

1. Đợi CI của commit chứa protocol và test. Không lấy PASS của HEAD cũ
   để khẳng định HEAD mới.
2. Tại issue #3 quyết định mô hình một writer an toàn (Dart isolate được
   giữ sống bởi native FGS có test hoặc chuyển backend transaction vào
   Kotlin có parity tests). Không lựa chọn theo cảm tính.
3. Issue #2: thử thiết bị thật và xác nhận không chồng FGS. Sau đó mới
   quyết định triển khai `TripLocationService` duy nhất.
4. Luôn giữ PR #1 Draft, main/TTX nguyên trạng, không Google Billing,
   không bật cước khách.

## 6. Bằng chứng giao dịch SQLite thực trong DB thử riêng (lượt 6/7)

**Tài liệu:** `docs/SQLITE_ACK_TRANSACTION_PROOF.md`.

- `tool/checkpoint_sqlite_contract.py` chạy SQLite thực (Python stdlib) trên
  **DB tạm DISPOSABLE_TEST_ONLY.db**, *không* mở `navitaximeter_v1.db`.
  Hai bảng route/checkpoint mô phỏng **dạng cột** của schema v3; hai
  bảng fence/ACK bổ sung chỉ tồn tại trong **DB thử**.
- `tool/test_checkpoint_sqlite_contract.py` có **12 thử nghiệm**:
  ACK sau commit bền vững, rollback khi lỗi route/header, ACK bị mất dù
  transaction đã commit, duplicate đúng/sai nội dung, generation stale,
  GPS stale/mock/gap, header/route corruption, recovery PAUSED và
  8 kết nối SQLite cạnh tranh. Dùng dữ liệu kỹ thuật, không tạo
  tuyến đường hay phí hành khách.
- Đã chạy cục bộ `python3 -m unittest discover -s tool
  -p 'test_checkpoint_sqlite_contract.py' -v`: **12/12 PASS** trên
  môi trường cách ly. Phải kiểm tra lại kết quả GitHub Actions đúng HEAD
  sau khi commit.
- Các phép thử này minh họa khả năng thực hiện **một giao dịch SQLite**
  ghi route/header/fence/ACK, nhưng **KHÔNG phải ứng dụng chạy SQLite
  native** và **KHÔNG chứng minh** fsync/crash trên Android thật.
  Chưa có migration v3→v4, chưa có single production writer.
- `TripCheckpointProtocol.kt` hiện vẫn dùng injected writer giả trong
  các Kotlin JVM unit tests, hoàn toàn chưa được nối với Python proof.

**Thứ tự tiếp tục:** lựa chọn một writer duy nhất và test tương thích
Dart engine → thiết kế migration backup/rollback → triển khai Android
writer + ACK → instrumented/device tests issue #2 → phê duyệt riêng.
