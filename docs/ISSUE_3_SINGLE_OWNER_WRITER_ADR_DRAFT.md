# Issue #3 — ADR dự thảo: một GNSS owner, một Dart SQLite writer sau COMMIT

**Ngày:** 2026-11-15 (Việt Nam). **Trạng thái:** DESIGN CANDIDATE / CẦN PROOF, chưa được phê duyệt triển khai cước khách.
**Mốc đọc nguồn:** feature branch HEAD `05fd65f08631bba28d27fdb87ecd7a6d0713493d` (docs-only handoff), code đã CI thành công `c0af5ef6960a6358013b000fb9a947b6b8564a2a`.
**Liên kết:** issue #3, issue #2 (physical-device BLOCKER), Draft PR #1, `docs/TRIP_LOCATION_SERVICE_CONTRACT.md`, `docs/SQLITE_ACK_TRANSACTION_PROOF.md`.

## 1. Khẳng định về hệ thống *hiện hữu*, không nhầm với kiến trúc mục tiêu

- `android_native/LocationSafetyService.kt` chỉ cung cấp health/heartbeat của dịch vụ native, không ghi tọa độ, SQLite hoặc cước. Lease `LocationOwnerRegistry` hiện chỉ là khoá trong tiến trình cho hai cơ chế thí nghiệm.
- `android_native/TripCheckpointProtocol.kt` là pure Kotlin contract và `AtomicTripCheckpointWriter` interface với **fake writer** ở JVM test, không nối FGS/app.
- `tool/checkpoint_sqlite_contract.py` có 12 test giao dịch SQLite **trên DB tạm DISPOSABLE_TEST_ONLY.db**; bảng checkpoint_fence/ACK chỉ tồn tại trong DB thử. Đây **không** phải writer Android hoặc migration schema.
- `TripRepository` thật dùng `navitaximeter_v1.db` schema v3, ghi route/header cùng transaction qua `sqflite`, nhưng chưa có persistent session/generation/ACK. `MeteredTripCoordinator` đang sống trong Flutter UI/lab, không chứng minh tồn tại khi Activity bị huỷ.
- `TripRepository.save(record)` dùng `ConflictAlgorithm.replace` cho legacy; không được phép để đường này ghi đè receipt ở runtime production.
- CI trên docs-only HEAD `05fd65f` có Foundation PR run 43718739681 và Zero Cost PR run 43718739693 SUCCESS; **không** có bằng chứng Android physical GNSS hoặc Android production commit ACK.

## 2. Phương án ưu tiên để làm proof (không tự nâng lên production)

**Một Android `TripLocationService` Kotlin là GNSS/location-FGS owner duy nhất. Một *service-owned* headless `FlutterEngine` với một Dart isolate/serialized TripSessionWorker sở hữu *độc quyền* `TaximeterEngine` và một `TripRepository`/SQLite writer cho toàn bộ trip mutations.** Flutter Activity/screens chỉ là client đọc trạng thái đã ACK, gửi lệnh người lái và camera-map; không tự subscribe GNSS hoặc ghi active trip.

```text
Android Activity (user-initiated START) --> TripLocationService (one GNSS/FGS owner)
  native verified GNSS fix + session/generation/sequence/monotonic time
                       |
                   bounded IPC / timeout / serialized protocol
                       v
    service-owned headless FlutterEngine: Dart TripSessionWorker
       frozen confirmed tariff --> existing TaximeterEngine
       validated checkpoint proposal --> one TripRepository transaction
       active_trip + route + durable fence + ACK ledger [future schema v4]
                       |
          SQLite COMMIT succeeds (transaction Future completes)
                       v
       same-fence ACK + sequence + checkpointId + persisted hash
                       |
          native service and UI read committed snapshot only
```

**Vì sao chọn làm proof trước:** giữ duy nhất thuật toán cước Dart và `sqflite` hiện có; tránh port monetary math sang Kotlin khi chưa có parity/rounding tests; ngăn Kotlin `SQLiteDatabase` cùng Flutter `sqflite` ghi đồng thời. **Điều kiện tiên quyết chưa chứng minh:** tạo/đóng headless FlutterEngine do Android Service quản lý, đăng ký plugin `sqflite`, hành vi Home/lock/Doze/OEM, teardown, timeout và cấp phát tài nguyên. Native service *không* dựa vào Flutter **UI** isolate.

**Quy tắc không thoả hiệp:** nếu worker/headless engine không sống được hoặc không có ACK trong giới hạn, `SUSPENDED`/PAUSED, dừng tính tiền; không chuyển GNSS sang UI, không bù thời gian/km và **không tự động chuyển sang Kotlin fare**. Nếu proof không đạt, xem lại phương án Kotlin native transactional writer và Dart-only calculator *sau* khi có hợp đồng parity/rounding và duyệt thay đổi kiến trúc.

## 3. Bất biến sản xuất cần đạt trước khi viết adapter

1. Duy nhất một đường *ghi* trip SQLite trong production. FGS Kotlin không gọi `SQLiteDatabase` để ghi; UI, Lab, Preview và legacy `save()`/ `saveActive()` bị chặn không ghi khi writer/session production hoạt động. Đọc history qua gateway/snapshot của writer, không tạo writer thứ hai. Lease RAM không phải persistent fence.
2. Native assigns `sessionId`, generation và sequence zero-based, sử dụng Android monotonic `Location.elapsedRealtimeNanos` cùng kiểm tra mock/age/accuracy/provider. Dart cross-check ứng viên; chỉ fix vật lý đủ tin cậy mới được tính tiền. Camera smoothing, health counters, timestamp wall-clock không được làm dữ liệu billing.
3. Không commit nếu thiếu tariff người lái xác nhận/frozen, mismatch fence/generation hoặc checksum, duplicate khác payload, missing sequence, GPS discontinuity, sai số bất thường, liveness/service/permission failure. `TripCheckpointProtocol.kt` hiện **chưa** tự xác minh GNSS thật và không giữ một durable session fence.
4. Một transaction trong app DB tương lai (schema v4 **CHƯA ÁP DỤNG**) ghi route, meter-header frozen tariff, persistent session fence và ACK ledger, với unique `(sessionId,generation,sequence)`; dùng DB `lastCommittedSequence` làm nguồn sự thật, so sánh đầy đủ payload/digest. Bao gồm đếm route và checkpointId/committed hash. Không để partial write, không cho `REPLACE` receipt.
5. Mọi kết quả UI/native 'checkpoint ACK' chỉ được phát **sau** khi `await db.transaction(...)` hoàn tất thành công, xác minh identity tương ứng. Callback service-start/heartbeat là ACK liveness khác hoàn toàn; method dispatch và snapshot Dart chưa commit không được coi ACK. Cần kiểm tra journal/synchronous, crash/power behavior riêng trên Android thật; không khẳng định fsync bằng CI.
6. Nếu COMMIT thành công nhưng callback ACK mất: không coi là rollback và không tính thêm. Tạm ngắt, mở lại DB đọc ledger/row/header để xác minh một checkpoint đã commit; exact replay idempotent, conflict fail-closed; chỉ tài xế RESUME thủ công từ fresh fix, đoạn route mới.
7. Dart calculator đang mutating trước `_checkpoint()` trong coordinator thử nghiệm. Runtime mới cần stage/copy candidate hoặc chỉ công bố state từ checkpoint *đã* commit; lỗi/timeout phải bỏ memory draft, tải lại last-durable snapshot và PAUSED. Không dùng timer riêng để cộng waiting khi thiếu GPS.
8. START chỉ từ Activity hiển thị đủ quyền; FGS location dùng đúng Android policy, notification STOP có lease-specific token. `START_NOT_STICKY`, kill/reboot/force-stop **không** tự mở lại chuyến, recovery luôn PAUSED. Service death phải làm IPC/worker mất hiệu lực, generation mới khi driver resume.
9. Không tự chạy v3→v4 migration trên dữ liệu người dùng. Backup DB+confirmed tariff prefs cùng consistency point (preflight, hash, rollback), parity v2/v3, update APK và receipt immutability tests là gate bắt buộc.
10. Không API trả phí/Google Billing/thu cước khách; không sửa TTX tham chiếu, không merge main, PR #1 vẫn Draft. Giữ issue #2 OPEN đến khi có device evidence.

## 4. Proof/verification matrix trước integration

| Cổng | Bài thử | Tiêu chí |
| --- | --- | --- |
| A. Headless lifecycle | Kotlin service tạo FlutterEngine và Dart worker với sqflite trên debug build; Activity Home/lock/rotate/destroy; worker health/stop ACK; FGS non-overlap | Chứng minh **worker riêng** hoạt động, không dựa UI isolate; fail closed nếu mất |
| B. Single writer | Mọi lệnh ghi vào route/header/receipt qua worker; UI/legacy/Preview/Lab cố ghi bị từ chối; race/parallel submissions | Duy nhất một serialized mutation authority, không double-write |
| C. v3 parity | Clone/snapshot fixtures v2/v3, migrated v4 proposal, tariff frozen, meter/receipt hashes, replay cùng sequence, corrupted count | Không mất trip, km, money, receipts/prefs; không tự sửa DB thật |
| D. Post-COMMIT ACK | Inject lỗi trước route INSERT, sau route, trước COMMIT, sau COMMIT trước callback; duplicate 8 callers; transaction ack ledger | Rollback nhất quán; ACK không sớm; mất ACK recover đúng row, không double fare |
| E. Failure/restart | Kill PID, process recreation, clock reversal, stop-before-ACK, stale notification, provider/GPS off, permission revoked, low storage/SQLite busy | Recovery PAUSED, chỉ manual Resume, GNSS gap không được bù |
| F. Android device issue #2 | Android 11–16 (ghi NOT TESTED cho API/OEM còn thiếu), Home/lock/Doze/OEM, inspect OS actual FGS & redacted logs | Issue #2 có log/case PASS/FAIL; lỗi phải mở follow-up issue |
| G. Domain/approval | Independent distance and fares test, rounding boundaries, 1/50/100 × 30 ngày Zero Paid API audit, owner signoff | Trước thương mại phải đủ bằng chứng và phê duyệt riêng |

## 5. Trình tự triển khai an toàn

1. Dựng **isolated lifecycle spike** service-owned FlutterEngine + worker + sqflite chỉ trong phòng thử, không đổi schema thật và không nhận hành khách. Xác thực registration, Activity independence và teardown trước khi mở feature code.
2. Viết hợp đồng message typed/fenced, staged meter snapshot và adapter ACK theo transaction Future. Dùng DB test fixtures thật của *app implementation* (khác Python disposable proof) và fault injection.
3. Thiết kế backup/migration v3→v4 dựa trên bản sao dữ liệu; thử v2/v3, rollback/kill; mặc định chưa migration thật.
4. Sau khi proofs thành công, cân nhắc một TripLocationService duy nhất, gỡ đường GNSS riêng trên đường production; giữ screen/Lab ở mode thử nghiệm không chồng owner.
5. Hoàn tất issue #2 trên điện thoại Android thật, đánh giá parity/cước, Zero Cost và owner approval. Trước đó tất cả ở **DESIGN / NOT FOR PASSENGER FARE**.

**Kết luận:** đã xác định **candidate một Kotlin GNSS service + một Dart background writer/engine** để kiểm chứng, **không** tuyên bố đã xây dựng production writer hoặc post-COMMIT ACK trên Android. Nếu cổng A thất bại, chưa được phê duyệt phương án dự phòng.
