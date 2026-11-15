# BẢN BÀN GIAO DỰ ÁN — NAVITAXIMETER

**Loại:** **BÀN GIAO BẮT BUỘC — LƯỢT 7/7**, chu kỳ tiếp quản mới, tiếp tục từ bản bàn giao chu kỳ trước.
**Thời điểm:** **16/11/2026, giờ Việt Nam (UTC+07:00)**; người dùng gửi “Tiếp tục” lúc 2026-11-15 17:07:02 UTC, tức 00:07:02 ngày 16/11 giờ Việt Nam.
**Trạng thái:** **ĐANG PHÁT TRIỂN VÀ THỬ NGHIỆM, CHƯA ĐƯỢC PHÉP THU CƯỚC KHÁCH**. Các test-only proof IPC, SQLite và staged fare đã có CI, nhưng single owner/writer production + Android vật lý vẫn chưa đạt.
**Bộ đếm:** `AI_REPLY_COUNT = 7` sau lượt bàn giao này. Trong cuộc trò chuyện hiện tại nếu tiếp tục thì đếm 8, 9,... và bàn giao ở lượt 14, 21,...; **cuộc trò chuyện mới đặt lại `AI_REPLY_COUNT=0`** rồi bàn giao ở lượt 7 trong chat mới.
**Nguồn:** bản bàn giao chu kỳ trước do người dùng cung cấp (341 dòng), quy tắc cứng đã cập nhật mục 9, source và GitHub Actions/PR/issues truy cập trực tiếp ở lượt 7, docs/AI_HANDOFF_STATE.md và các commit chu kỳ hiện tại. Bản này độc lập, đủ mục 3.1–3.10 và toàn văn mục 9.

## Thông tin khóa và bằng chứng tại thời điểm chốt

| Hạng mục | Giá trị đã đối chiếu |
| --- | --- |
| Kho dự án | https://github.com/ThanhTaxiXanh/NaviTaxiMeter |
| Nhánh **duy nhất được phép ghi** trong giai đoạn này | `feature/navitaximeter-foundation` |
| **HEAD CODE được CI xác minh trước khi bàn giao hiện tại** | `edee0b7e2651f96983b0e3624243fd3e557d637e` trên feature (sau khi commit tài liệu, HEAD docs có thể đổi) |
| Mốc Android 14 headless debug-probe đã xác minh từ chu kỳ trước | `85cfa50e79f77787e61e10e86a4652d004e7aae3`, run `43725473578` SUCCESS |
| Foundation Flutter Android, có test Android 14 Emulator | Run **43725473578**, **SUCCESS** trên code HEAD `85cfa50`: https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43725473578 |
| Zero Cost Source Gate trên code HEAD `85cfa50` | Run **43725473618 SUCCESS** |
| **Zero Cost Source Gate trên code SHA `edee0b7e`** | Run `43738096483` SUCCESS, kiểm mã nguồn, KHÔNG phải audit chi phí thực tế 30 ngày |
| **Foundation trên code SHA `edee0b7e`** | Run `43738096495` SUCCESS: build-test, `flutter analyze`, `flutter test`, Android 14 emulator **headless DEBUG SQLite probe** SUCCESS |
| Pull request #1 | https://github.com/ThanhTaxiXanh/NaviTaxiMeter/pull/1 — **OPEN / DRAFT / NOT MERGED** |
| `main` | `539ff788b62be69135e5b3ad2c554dca005249a5` — **KHÔNG MERGE** |
| TTX tham chiếu (đọc, không viết) | https://github.com/ThanhTaxiXanh/TTX-AATaximeter, nhánh `feature/flutter-taximeter-foundation`, SHA `a40c246de6fd3799aaddedce3ed0d3b1d9dd524d` |
| Issue #2 (Android thật) | https://github.com/ThanhTaxiXanh/NaviTaxiMeter/issues/2 — **OPEN / NOT TESTED PHYSICAL** |
| Issue #3 (GNSS owner + one writer) | https://github.com/ThanhTaxiXanh/NaviTaxiMeter/issues/3 — **OPEN**, có thiết kế và probe nhưng chưa có writer production |
| Mốc bằng chứng Android emulator | Issue #3 comment https://github.com/ThanhTaxiXanh/NaviTaxiMeter/issues/3#issuecomment-6896375542 |

**Quy tắc chứng cứ:** PASS của `build-test` khác PASS của `emulator-probe`; cả hai đều khác kiểm thử điện thoại Android thật và khác kiểm toán thương mại. Sau khi lưu bản bàn giao mới lên GitHub, **HEAD có thể đổi chỉ vì commit tài liệu**. AI tiếp nhận phải đọc lại SHA và CI của HEAD mới, không tự nhận PASS nếu workflow còn chạy.

---

## 3.1. TỔNG QUAN DỰ ÁN

**Tên sản phẩm:** NaviTaxiMeter; Flutter package `navitaximeter`, Android `applicationId = vn.navitaximeter`, phiên bản hiện tại trong `pubspec.yaml` là `0.1.4+5`.

**Mục tiêu:** Ứng dụng đồng hồ taxi dành cho **tài xế taxi**, tính cước từ vị trí GNSS thật theo **bảng giá do tài xế xác nhận và đóng băng cho từng chuyến**, hoạt động offline, bảo toàn lịch sử và doanh thu, có hỗ trợ bản đồ/định tuyến 2D/3D, hóa đơn và VietQR hợp lệ, quản lý bảng giá, phương tiện, ngân hàng, sao lưu và chẩn đoán GPS. Giao diện yêu cầu bám theo **bảy ảnh mockup** do người dùng đưa.

**Đối tượng:** Tài xế vận hành tại Việt Nam. Người dùng muốn tiếp tục phát triển qua GitHub Actions và thiết bị di động, không được coi việc có một máy tính Android cục bộ là điều kiện duy nhất để tiếp tục lập trình.

**Phạm vi:** Android trước; Flutter/Dart và Kotlin Android native; iOS chỉ sau khi Android ổn định, kiểm chứng an toàn và được phê duyệt. Không được đánh đồng phòng thử GPS với đồng hồ thương mại.

**Hiện trạng:** Đã có lõi tiền/chuyến/SQLite, bảng giá xác nhận, một số màn kỹ thuật và Android GPS safety interlock; đã thêm **thử nghiệm headless FlutterEngine do bound service sở hữu**, dùng `sqflite` trên **cơ sở dữ liệu riêng** và **đã PASS Android 14 Emulator**. Chưa có một `TripLocationService` production duy nhất, chưa có transactional **production** trip writer có **ACK sau COMMIT** (đã có test-only proof), chưa có bộ bảy màn cuối, renderer bản đồ online/offline, POI/routing thật, VietQR sản xuất, thiết bị Android vật lý được kiểm tra, bản phát hành đã ký, hay audit 0 USD 30 ngày.

---

## 3.2. YÊU CẦU CỨNG KHÔNG ĐƯỢC THAY ĐỔI

1. **Zero Paid API / phí thực tế bằng 0:** Mục tiêu **0 USD phí API/tháng** với **1/50/100 người dùng sử dụng liên tục 30 ngày** (tương ứng 720/36.000/72.000 người-giờ). Không tự bật Google Cloud Billing, key/API trả phí, Maps/Navigation/Places/Routes/Directions/Roads/Speed Limits/Map Tiles SKU có rủi ro phí hoặc SDK dịch vụ navigation có phí. Không dùng free quota rồi tự động vượt phí. Zero Cost Source Gate chỉ kiểm tra source, **không phải** xác nhận hóa đơn Cloud hay license hoặc audit tải thực tế.
2. **Nền tảng:** Android-first; Flutter/Dart `>=3.11.0 <4.0.0`, Kotlin native. Giữ hiện trạng domain Dart/SQLite trước khi có quyết định và kiểm thử thay thế được duyệt; iOS sau.
3. **Bản đồ/GIS:** Yêu cầu Việt Nam online/offline, 2D/3D, tòa nhà và công trình 3D, đường và làn, mũi tên hướng xe, biển báo, giới hạn tốc độ, POI/địa chỉ, tìm đường và điểm dừng. Tích hợp dữ liệu GIS/Mapillary **chỉ khi hợp pháp và có nguồn thực**; hiện **CHƯA CÓ RUNTIME** cho các chức năng đó. Ưu tiên Google Maps SDK Android thường chỉ nếu chứng minh **hợp đồng và phí 0**; nếu không, nghiên cứu MapLibre + OpenStreetMap offline có bản quyền/attribution hợp lệ. Không scrape/caching hàng loạt `tile.openstreetmap.org`, không chép imagery Google, không tạo POI/làn/tuyến giả hoặc xóa attribution.
4. **Yêu cầu hiển thị chủ quyền/nội dung bản đồ theo người dùng:** dùng tên **Biển Đông**; thể hiện **Hoàng Sa và Trường Sa thuộc Việt Nam**; không hiển thị ranh giới, nhãn trái yêu cầu đã chốt. Khi có dataset/style/tile phải kiểm tra và sửa pipeline, screenshot và test nhãn/chủ quyền tương ứng. **CHƯA CÓ MAP RENDERER, CHƯA TEST** nên không tuyên bố đạt.
5. **GPS tin cậy:** Chỉ **fix GNSS thực** được xác minh mới đi vào engine cước; không dùng camera smoothing, ước lượng khoảng mất tín hiệu, mock location, timestamp đảo/stale, accuracy/speed quá ngưỡng, jump/drift/multipath. Khi mất quyền/FGS/stream/GPS/SQLite phải **fail closed SUSPENDED**, không cộng bù km hay thời gian thiếu. Khi mở lại/chết process thì **PAUSED**, chỉ tài xế **RESUME thủ công** bằng fix mới với segment mới.
6. **Một nguồn GNSS và một nguồn ghi cước:** Đích production là **một** Android `TripLocationService` sở hữu GNSS/location FGS và **một** SQLite trip mutation authority; ACK của checkpoint chỉ gửi **sau khi SQLite transaction COMMIT thành công** và có session/generation/sequence fence. **Kiến trúc Dart headless writer hiện là ứng viên đang chứng minh**, chưa phải quyết định được phép thu cước. Không tự port thuật toán tiền sang Kotlin.
7. **Bảng giá và độ chính xác cước:** Tài xế phải xác nhận bảng giá, giữ immutable tariff snapshot theo chuyến; không dùng `TariffConfig.demo()` để thu tiền. Phải hiệu chuẩn quãng đường, bậc giá, phí chờ, BOT, phụ thu, giảm giá, sai số và rounding/kiểm thử độc lập; so sánh parity nếu đổi ngôn ngữ tính tiền. Không đưa tốc độ theo bản đồ/camera vào cước.
8. **Dữ liệu/offline/privacy:** SQLite offline cho chuyến, route, doanh thu, hóa đơn; SharedPreferences cho cài đặt và tariff đã xác nhận. Ngăn duplicate/overwrite, lưu nguyên dữ liệu khi ứng dụng cập nhật, backup/restore **đồng bộ DB + SharedPreferences**, hash/preflight/rollback; không tự thay schema nếu chưa có proof migration. Không upload/tung GPS khách/tài xế, địa chỉ, tài khoản ngân hàng, token/key/log cá nhân.
9. **Thanh toán:** **Chỉ Tiền mặt và Chuyển khoản**. VietQR phải tạo thực tại thiết bị từ dữ liệu ngân hàng hợp lệ và kiểm chứng bằng ứng dụng ngân hàng, **không giả QR**. Không thêm online payment gateway tính phí khi chưa duyệt.
10. **Bảy màn UI tiếng Việt đúng mockup:** (1) Home bản đồ/GPS, (2) địa chỉ/POI, (3) tuyến đường kèm điểm dừng, (4) dẫn lái + đồng hồ, (5) lịch sử/doanh thu, (6) chi tiết/hóa đơn/VietQR, (7) cài đặt. Các phần phụ: bảng giá, xe, ngân hàng, backup, GPS diagnostics. Màu dark navy/cyan đã chốt: `#071827`, `#10263C`, `#12334D`, `#00D8F0`, `#28F4FF`, `#FFFFFF`, `#A9C5D3`, `#20DFA5`, `#FFB020`, `#FF5266`. Bảy PNG `IMG_4488.png`–`IMG_4494.png`, mỗi ảnh 863×1822; **đã được cung cấp ở cuộc trò chuyện hiện tại**, không nằm trong Git repo và **không tự có trong chat mới**. Cần đính kèm lại khi dựng UI nếu môi trường chat mới không truy cập.
11. **Camera + hiệu năng:** Các chế độ `FOLLOW_HEADING`, `NORTH`, `FREE_EXPLORE`, `RECENTER`, `TRIP_OVERVIEW`; camera hướng xe mượt, không tác động GNSS tính tiền. Mục tiêu gần **60 FPS** và không ANR/leak, tối ưu pin/RAM; **chưa benchmark thực tế**. Android Auto mới là đề xuất nghiên cứu, không nhận đã tích hợp.
12. **Phát hành/kiểm soát:** Chỉ release Android ARM64 được ký keystore ổn định sau kiểm thử update/backup/migration, phí và license, Android vật lý, xác nhận riêng của chủ dự án. APK hiện có **DEBUG ONLY, KHÔNG PHẢI BẢN SẢN PHẨM**. **Không merge `main`, không sửa repo TTX tham chiếu, không bật Google Billing hoặc thu cước khách** nếu chưa được phê duyệt rõ ràng.


**13. QUY TẮC CỨNG MỚI, NGUYÊN VĂN YÊU CẦU CHỦ DỰ ÁN:** “Nếu muốn tôi kiểm thử hay kiểm chứng trên điện thoại thì phải hướng dẫn chi tiết, kiểm thử cái gì, kiểm chứng cái gì, làm thế nào để cho bạn biết là đã kiểm thử hay kiểm chứng thành công để đưa cho bạn xem.” Mỗi yêu cầu thử phải có mã APK/SHA và nơi lấy đã xác minh, mục tiêu/điều kiện, thao tác từng nút, PASS/FAIL/NOT TESTED, cách chụp bằng chứng không lộ dữ liệu riêng, cách gửi cho AI và tiêu chí AI đối chiếu. Không mặc định người dùng có máy tính/ADB, không hư cấu nút. Toàn văn quy tắc bổ sung nằm ở **PHỤ LỤC A** cuối bản này và tại [`docs/QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md`](https://github.com/ThanhTaxiXanh/NaviTaxiMeter/blob/feature/navitaximeter-foundation/docs/QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md).

---

## 3.3. KIẾN TRÚC HỆ THỐNG, MODULE, SDK VÀ DỮ LIỆU

### 3.3.1. Hệ thống đang thực sự chạy (phòng thử)

```text
Flutter Material 3, hiện là 5 tab kỹ thuật:
   Trạng thái / Bảng giá / GPS thử / Phòng thử / GPS nền
   |
   +-- ConfirmedTariffStore -> SharedPreferencesAsync (confirmed tariff)
   +-- GPS Preview ------- Geolocator stream (không tính tiền)
   +-- GPS Lab ----------- Geolocator stream + MeteredTripCoordinator
   |                                            |
   |                                      TaximeterEngine (Dart)
   |                                            |
   |                                      TripRepository (sqflite)
   |                                            |
   |                                  navitaximeter_v1.db, schema v3
   +-- Kotlin MethodChannel in MainActivity
                  |
         LocationOwnerRegistry (in-process lease/fenced token)
                  |
         LocationSafetyService (native FGS health/liveness ONLY)
```

`LocationOwnerRegistry` và `serialized_gps_stop.dart` quản lý lease trong tiến trình để interlock Preview/Lab/native safety. Kotlin `LocationSafetyService` dùng `LocationManager`, location foreground service non-exported, `START_NOT_STICKY`, monotonic heartbeat, notification Stop token và giữ lease đến `onDestroy` nếu Stop-before-ACK. Đây là **ACK liveness/service**, **KHÔNG** truyền route vào cước hay ghi SQLite; chưa chứng minh OS FGS không overlap trên máy thực.

`MeteredTripCoordinator` là coordinator trong Flutter UI/Lab; kiểm tra trusted GPS fix, tăng trạng thái Dart meter, gọi SQLite và recovery PAUSED. **Rủi ro hiện hữu:** một số meter mutation xảy ra **trước khi await checkpoint**, nên production vẫn phải áp dụng stage immutable/copy candidate; thử nghiệm fork đã viết nhưng chưa nối coordinator và chỉ công bố trạng thái sau transaction COMMIT; trường hợp commit/ACK không chắc phải phục hồi trạng thái durable. Flutter UI isolate không chứng minh sống khi Activity bị hủy. Lab vẫn khởi tạo `TripRepository()` trực tiếp (`lib/src/ui/gps_lab_page.dart`), Preview còn `Geolocator.getPositionStream`; **chưa có one production writer/one native GNSS service**.

`TaximeterEngine` Dart có bảng giá theo bậc km, phí mở cửa, chờ/grace, phí BOT/phụ thu/giảm giá, trạng thái idle/running/paused/finished. Thuật toán đang dùng một số phép tính `double`, cần test rounding và calibration trước thương mại; không được tự đổi Kotlin.

### 3.3.2. SQLite ứng dụng hiện tại (THẬT, schema version 3)

- DB runtime: **`navitaximeter_v1.db`**, không có sẵn trong Git repo.
- `trips(id PRIMARY KEY, started_at, total_fare, distance_km, payload)`.
- `active_trip(id=1, payload, updated_at)`.
- `active_trip_route(sequence INTEGER PRIMARY KEY zero-based, latitude, longitude, recorded_at, accuracy_meters, speed_kmh, segment)`.
- `TripRepository.saveActiveIncremental()` ghi route và header cùng **một transaction sqflite**; kiểm tra route count/sequence và replay cùng sequence phải khớp từng trường; replay khác bị từ chối. `completeActive()` kiểm tra receipt/ID. **Legacy `save(record)` có `ConflictAlgorithm.replace`**, không cho dùng làm đường ghi receipt production.
- Tariff đã xác nhận trong SharedPreferences, key **`navi_confirmed_tariffs_v1`**. Chưa có backup/restore đồng bộ DB+Prefs, chưa có SQL migration v3→v4.

### 3.3.3. Code-spike headless FlutterEngine + SQLite vừa ĐƯỢC KIỂM CHỨNG TRÊN EMULATOR

```text
Android DEBUG manifest only
  HeadlessSqliteProbeService (bound service, NOT FGS, NO GNSS)
     owns one FlutterEngine independent of Flutter Activity
       -> Dart @pragma('vm:entry-point') headlessSqliteProbeMain
       -> DartPluginRegistrant + sqflite via MethodChannel
       -> SerializedHeadlessProbeWriter (single Dart queue)
       -> navitaximeter_HEADLESS_PROBE_ONLY.db (counter table ONLY)
       -> await sqflite transaction; close DB; reopen readOnly; readback
     onDestroy -> HeadlessProbeCallbackFence: pending => SERVICE_DESTROYED
     stale Dart callback => ignored; unbind/destroy/rebind is tested
```

- Source `android_native/HeadlessSqliteProbeService.kt` và `HeadlessProbeCallbackFence.kt` được `tool/bootstrap_android.py` copy **chỉ vào generated `src/debug/kotlin`**, không phải `src/main` production. `HeadlessSqliteProbeInstrumentedTest.kt` vào `src/androidTest`; `HeadlessProbeCallbackFenceTest.kt` vào `src/test`.
- DB spike **chỉ** `navitaximeter_HEADLESS_PROBE_ONLY.db`: không tariff/route/receipt/production ACK. Có test Flutter FFI 8 yêu cầu xếp hàng; test Android emulator 1 + 8 lệnh, `onDestroy`/unbind/rebind và count đọc lại.
- **Bằng chứng:** PR run **43725473578**, `build-test` **SUCCESS**, `Android 14 emulator headless SQLite execution` **SUCCESS**, trong log job `132847796746`: `Starting 1 tests on test(AVD) - 14`, `Finished 1 tests`, `BUILD SUCCESSFUL in 3m 31s`, `PASS: headless FlutterEngine/sqflite instrumentation actually executed once on an Android emulator (NOT a physical device)`. Bước kiểm tra XML tên testcase chạy **SUCCESS**. Không chứng minh GNSS/device thật, fsync khi mất điện, Doze/OEM, fare hay app DB writer.

### 3.3.4. Kiến trúc production ĐỀ XUẤT, CHƯA TRIỂN KHAI

```text
Visible Activity + tài xế xác nhận START/RESUME
          |
    [Kotlin TripLocationService: ONE GNSS/location-FGS OWNER]    FUTURE
          |  physical fix; token/sessionId/generation/seq/monotonic timestamp
          v
    bounded IPC (fenced, timeout, fail-closed)
          |
    [service-owned headless Dart TripSessionWorker: ONE WRITER]  FUTURE
          |  frozen confirmed tariff; staged meter candidate
          |  one sqflite transaction:
          |    route + meter/header + durable session fence + ACK ledger
          v
    COMMIT successful; verify persisted identity
          |
    post-COMMIT ACK (sessionId,generation,seq,checkpointId/hash)
          |
    native/UI read only committed snapshots
```

Đây là **ADR DESIGN CANDIDATE** tại `docs/ISSUE_3_SINGLE_OWNER_WRITER_ADR_DRAFT.md`, **không phải kiến trúc production đã được duyệt**. Chọn làm hướng chứng minh trước vì giữ engine tiền Dart và `sqflite`; không tạo writer Kotlin SQLite song song hay port tiền sang Kotlin chưa parity. Nếu service-owned engine không đáp ứng lifecycle GNSS/OS, phải **dừng/fail closed** rồi đánh giá phương án khác với thiết kế, kiểm thử và chủ dự án phê duyệt, không tự chuyển trong im lặng.

### 3.3.5. Các proof khác, tuyệt đối không nhập làm một

- `android_native/TripCheckpointProtocol.kt`: Kotlin **pure JVM protocol + fake `AtomicTripCheckpointWriter`**. Chưa kết nối Android service, GPS thật, route hay SQLite app.
- `tool/checkpoint_sqlite_contract.py` và tests: **12 SQLite Python sqlite3 tests**, DB tạm **`DISPOSABLE_TEST_ONLY.db`**, bảng fence/ACK chỉ là **bảng test đề xuất**, không trong app DB. Chứng minh giao dịch/rollback/replay/ACK mất trên DB mô phỏng, **không** chứng minh Android SQLite hoặc `fsync`.
- Flutter FFI `test/headless_sqlite_probe_test.dart`: thử DB probe riêng bằng `sqflite_common_ffi`, **không** phải Android runtime.
- Emulator probe: xác minh service-owned FlutterEngine và sqflite debug trên Android 14 AVD, **không** phải production trip writer, GNSS FGS hay Android thật.

**Dependencies (`pubspec.yaml`):** geolocator `^14.1.2`, geolocator_android `^5.2.1`, sqflite `^2.4.2+1`, path `^1.9.1`, shared_preferences `^2.5.6`, crypto `^3.0.8`; dev `flutter_test`, `flutter_lints ^6.0.0`, `sqflite_common_ffi ^2.4.5`, `sqlite3 3.8.0`; Java **17** trong CI.

**Online/offline hiện hữu:** nghiệp vụ core và lịch sử trên SQLite offline; GPS hệ thống là Android provider. **Chưa tích hợp** Google Maps/MapLibre renderer, map tiles offline, GIS/Mapillary runtime, POI FTS5, route engine, lane/speed sign data, bản đồ 3D hoặc style. Mọi nội dung này là **kế hoạch**, không được gán là đã hoàn thành. Không có Google paid API hay Cloud billing được bật trong source; vẫn phải audit thực tế khi tiến đến release.

---

### 3.3.6. Các proof mới ở chu kỳ này, sau khi Android14 debug headless đã PASS

- **Typed IPC:** `lib/src/lab/trip_ipc_contract.dart` + `test/trip_ipc_contract_test.dart` (11 ca). SessionId/generation/seq/GNSS elapsedNanos, digest/tariff hash, mock/accuracy/speed, replays, lost ACK. Đây là contract Dart và fake writer, không truyền GPS thật qua Android IPC.
- **SQLite v3 clone + v4 dry-run Python:** `tool/v3_clone_migration_proof.py` + `tool/test_v3_clone_migration_proof.py` (10 ca), snapshot/hash/restore của fixture cùng prefs sentinel; không thao tác DB/prefs tài xế.
- **sqflite FFI clone/ACK:** `test/support/issue3_sqflite_clone_writer.dart` + `test/issue3_sqflite_clone_ack_test.dart` (14 ca), tạo proposed fence/ACK tables trong **bản sao disposable**, viết route + header + fence + ledger trong một transaction, rollback/duplicate/reopen/PAUSED.
- **IPC nối sqflite test:** `test/support/issue3_ipc_sqflite_adapter.dart` + `test/issue3_ipc_sqflite_bridge_test.dart` (7 ca). Nguồn fix là registry fixture bất biến, KHÔNG có Android native IPC/GNSS thật.
- **Stage tiền từ Dart engine:** `TaximeterEngine.forkForCheckpoint()` được thêm vào `lib/src/core/taximeter_engine.dart`, có đầy đủ trạng thái GPS anchor/tick/wait-grace private. `test/support/issue3_staged_fare_checkpoint.dart` + `test/issue3_staged_fare_checkpoint_test.dart` (10 ca) thử với **TripRepository schema v3 thật, DB tạm**. Tiền mới chỉ được publish sau transaction Future COMMIT. Phương thức fork **chưa có người gọi trong coordinator production**.
- **Giá chờ, giá bao, tier, rounding:** `test/issue3_fare_fork_pricing_regression_test.dart` (10 ca) + `test/issue3_staged_tariff_parity_test.dart` (5 ca) PASS GitHub `flutter test` trên SHA `edee0b7e` (Foundation run `43738096495`). Tất cả tariff/coordinates đều là synthetic fixture.

**Giới hạn không được làm mờ:** Python SQLite, Flutter FFI SQL, IPC fake-writer, Android 14 debug headless probe, staged fare v3 là **các bằng chứng độc lập**. Chưa có transaction **production** đồng thời ghi fare + route + session fence + durable ACK; chưa có single true GNSS service. Không có kiểm thử Android vật lý.

---

## 3.4. CÔNG VIỆC ĐÃ HOÀN THÀNH VÀ MỨC KIỂM CHỨNG

### 3.4.1. Các phần có source và kiểm thử từ các chu kỳ trước

- Flutter app v0.1.4+5 với 5 tab kỹ thuật (trạng thái/bảng giá/GPS thử/phòng thử/GPS nền); `TaximeterEngine` Dart, stored confirmed tariffs, SQLite schema v3 cho trips/active_trip/route, receipt/history/revenue. Không phải 7 màn cuối.
- `MeteredTripCoordinator` + `TripRepository.saveActiveIncremental` bảo vệ dữ liệu route, replay đúng content mới idempotent, replay khác phải lỗi/rollback. Lưu ý coordinator còn mutation trước COMMIT.
- Android `LocationSafetyService` native chỉ hỗ trợ liveness/token/lease, không phải trip GNSS writer. Kotlin JVM/Flutter test và bootstrap/Zero Cost source gates đã có.
- Headless FlutterEngine + `sqflite` debug-only bound service hoạt động trên **Android 14 Emulator**, kể cả unbind/destroy/rebind và callback fence. Run `43725473578` SUCCESS. Service này chỉ ghi counter DB `navitaximeter_HEADLESS_PROBE_ONLY.db`.
- 12 Python sqlite3 checkpoint atomicity tests trên DB tạm, không phải Android production SQLite.
- **Quy tắc cứng §9 mới** đã được đưa nguyên văn vào repo `docs/QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md`, không thể bỏ qua ở các lượt sau.

### 3.4.2. Tiến độ chính xác lượt 1–6 của chu kỳ vừa qua

| Lượt | Commit và thay đổi mã trên nhánh feature | Trạng thái bằng chứng |
| --- | --- | --- |
| **1/7** | `bc5a9cf5f663402e4b7d6433eba9372d0143dd25`: typed IPC contract + 11 Dart tests, doc proof. | CI/chỉ là contract thử, không phải GNSS production. |
| **2/7** | `6dc68cae6e2f4d7b91569a2e9ddaa88c6877ac8b`: full hard-rule §9; `85de6187b0f6a166a8986c75a8f0b87559670c13`: Python v3 clone backup/v4 dry-run + 10 tests. | Foundation `43731059227` SUCCESS (build-test + emulator debug); ZeroCost `43731059286` SUCCESS. |
| **3/7** | `f59a6eee46238774afc34d034451c33856a9c0f9`: Flutter FFI sqflite v3-shaped clone v4 ACK ledger + 14 tests. | `flutter test` của run `43732189163` SUCCESS; toàn workflow sau đó CANCELLED vì commit mới, không gọi full SUCCESS. |
| **4/7** | `0e6e0cc4b064096d914a15bf63978f86567c7748`: test-only typed IPC -> sqflite adapter + 7 tests. | `flutter test`/build-test của run `43732807141` SUCCESS; workflow sau đó CANCELLED khi push mới. |
| **5/7** | `3c1111e5985b9563f33b2ca44d80b7552d8880d6`: `TaximeterEngine.forkForCheckpoint()` + v3 TripRepository staged candidate test-only + 10 tests. | ZeroCost `43733816387` SUCCESS; Foundation `43733816398` **FULL SUCCESS** (build-test và Android14 debug). |
| **6/7** | `299f7aae543db14ffa3caafcef75234555d6c9f5`: +15 tests chờ/flat/tier/rounding; `edee0b7e2651f96983b0e3624243fd3e557d637e`: sửa assertion chống rung GPS đứng yên, không sửa engine. | **ZeroCost `43738096483` SUCCESS**, **Foundation `43738096495` FULL SUCCESS**, `flutter analyze` và `flutter test` SUCCESS, emulator debug SUCCESS. |
| **7/7** | **Lượt hiện tại:** chỉ tổng hợp bàn giao đầy đủ và cập nhật docs, không khởi động task ứng dụng mới. | Sau commit chỉ sửa docs phải đối chiếu CI của SHA docs mới riêng; code PASS đã gắn đúng SHA `edee0b7e`. |

### 3.4.3. Phân biệt đạt/chưa đạt

**ĐÃ KIỂM CHỨNG BẰNG CI** (SHA `edee0b7e`): Kotlin JVM, Python safety, Flutter analyze/test bao gồm 15 tests mới, Flutter debug APK, Android 14 emulator headless SQLite DEBUG probe executed và kết quả XML. Zero Cost **source** gate PASS. Không có lý do làm lại các proof này nếu không xuất hiện lỗi mới.

**ĐÃ VIẾT, MỚI LÀ TEST-ONLY:** IPC typed; ứng viên schema v4 ACK ledger trên clone; bridge IPC -> SQL test; full fork state/staged fare trên repository v3 tạm. **Chưa có** production worker/FGS, schema migration được phép, money state ACK end-to-end.

**CHƯA KIỂM CHỨNG / CHƯA TRIỂN KHAI:** Android 11–16 máy thật, physical GNSS+Doze/FGS ownership, fsync khi mất điện, single trip writer live, bảo đảm tính cước thương mại, 7 màn UI chuẩn, 2D/3D offline online map, POI/routing, VietQR bank-app, backup thống nhất, audit API 0 USD thực tế 30 ngày, signed ARM64 release.

---

## 3.5. CÔNG VIỆC ĐANG TRIỂN KHAI VÀ ĐIỂM TIẾP TỤC CHÍNH XÁC

**Issue #3 OPEN** là ưu tiên hàng đầu: một Kotlin `TripLocationService` làm GNSS FGS owner và một service-owned headless Dart `TripSessionWorker`/`TaximeterEngine`/SQLite writer, fenced `sessionId + generation + sequence`, ACK đúng sau COMMIT. **ADR vẫn là DESIGN CANDIDATE, chưa phê duyệt commercial.**

**Điểm dừng kỹ thuật:** Code test-only `IPC -> clone SQLite proposed v4 ACK` và code test-only `fork -> TripRepository v3 fare checkpoint` đang **tách biệt**. Không có transaction production chung fare + route + header + durable session fence + ACK ledger. Runtime `MeteredTripCoordinator.accept`, `resume`, `_suspend`, `finish` vẫn thay engine trước DB COMMIT (rủi ro phantom fare). Một helper staging mới không tự sửa runtime. Không chạm app DB `navitaximeter_v1.db` hoặc tariff prefs.

**Lần chỉnh mã gần nhất:** SHA `edee0b7e` sửa duy nhất expectation của test flat fare xe đứng yên, từ >60m thành >30m để tôn trọng anti-jitter GPS (vẫn kiểm tốc độ chuyển động trong test khác). GitHub `flutter test` của SHA mới đã SUCCESS và toàn run SUCCESS.

**Khi tiếp quản sau handoff:** (1) đối chiếu latest feature HEAD và CI, có thể đã đổi do docs-only handoff; (2) đọc `docs/ISSUE_3_IPC_SQFLITE_BRIDGE_PROOF.md`, `docs/ISSUE_3_STAGED_FARE_COMMIT_PROOF.md`, `docs/ISSUE_3_P4B_FARE_PARITY_REGRESSION.md`, ADR; (3) xây **test-only tích hợp** IPC + immutable candidate + *một* sqflite transaction trên bản sao DB v3/v4; (4) lỗi/fault injection/recovery; (5) sau đó đánh giá refactor runtime coordinator guarded. Không làm lại test cũ hoặc mở main.

**Issue #2 OPEN/NOT TESTED trên máy Android thật**. Không yêu cầu chủ dự án thao tác điện thoại nếu chưa xác minh đúng APK và nút test; tuân theo Phụ lục A.

---

## 3.6. LỖI ĐÃ SỬA VÀ RỦI RO CÒN TỒN TẠI

### Lỗi đã xử lý có proof

1. `TripRepository.saveActiveIncremental` trước dùng `INSERT OR IGNORE`, che giấu replay route cùng sequence nhưng khác payload; sửa đối chiếu row thực và rollback, Flutter tests PASS.
2. Android bootstrap/Gradle fixture không idempotent hoặc escape debug manifest sai đã sửa và kiểm tra.
3. `emulator-probe` từng FAIL ở verifier XML do tìm `android/app/build/outputs/...` thay vì Flutter `build/app/outputs/...`; sửa workflow, run `43725473578` SUCCESS.
4. Trường hợp service callback sau teardown được bảo vệ qua `HeadlessProbeCallbackFence`, Android14 emulator debug lifecycle và Kotlin tests PASS.
5. Test staging ban đầu dùng giả định header UPDATE trong trigger, nhưng repository thực là `INSERT OR REPLACE`: đổi thành INSERT-trigger; run `43733816398` PASS.
6. Lượt 6 test flat fare stationary kỳ vọng quãng đường >60m mặc dù GPS anti-jitter có thể bỏ segment dưới 15s; chỉnh assertion tại `edee0b7e`, **không sửa thuật toán**, run `43738096495` PASS.

### Blockers chưa giải quyết

- **Native GNSS owner production chưa có**, Preview/Lab có đường Geolocator riêng, `LocationSafetyService` là health only. In-process lease không chứng minh OS FGS single-owner trên thiết bị thật.
- **Production SQLite writer/ACK sau COMMIT chưa có**. Proposed v4 `checkpoint_fence`/`checkpoint_ack` chỉ tồn tại trong clone thử; chưa có durable fence/generation trong app DB và native real IPC; callback timeout/lost ACK phải fail-closed PAUSED chứ không retry gây double-count.
- **Trạng thái tiền trước COMMIT:** production `MeteredTripCoordinator` còn mutate `_meter` trước await checkpoint ở các luồng; chưa áp dụng `forkForCheckpoint` tại production, chưa có verified parity OS real.
- **Backup/migration:** chưa có consistency boundary giữa DB v3 và confirmed Prefs, chưa proof update APK, production v3→v4 migration, restore khi hỏng hoặc WAL/flash/Doze. `save(TripRecord)` legacy còn `ConflictAlgorithm.replace`, không được dùng làm đường ghi receipt production.
- **Thiết bị thật:** chưa GPS Android 11–16 physical, Home/lock, permission approximate/precise/revoke, provider off, Doze/OEM, notification Stop stale, killed process/reboot, pin/RAM/60FPS, NAND fsync.
- **Cước:** demo/technical tariff chưa phải bảng giá tài xế thật; `double`/rounding/độ chính xác GNSS vẫn cần hiệu chuẩn độc lập trước thương mại.
- **Map, UI, thanh toán, kinh phí:** 7 màn mockup chưa hoàn tất, không có 2D/3D/map  offline, POI/routing GIS/Mapillary runtime thật, sovereignty style tests, VietQR bank-app validated, 30-day 0-USD real audit, signed release.
- **CI cancellation:** các workflow `CANCELLED` sau push mới không đồng nghĩa code test FAIL; phải kiểm đúng commit/run/step, không gộp tình trạng của SHA khác.

---

## 3.7. MÃ NGUỒN, TỆP, LỆNH BUILD VÀ DỮ LIỆU

**Repo:** https://github.com/ThanhTaxiXanh/NaviTaxiMeter ; chỉ được ghi `feature/navitaximeter-foundation`. **PR #1:** https://github.com/ThanhTaxiXanh/NaviTaxiMeter/pull/1 ; **issue #3:** https://github.com/ThanhTaxiXanh/NaviTaxiMeter/issues/3 ; **issue #2:** https://github.com/ThanhTaxiXanh/NaviTaxiMeter/issues/2.

**Root/build:** `pubspec.yaml` v0.1.4+5, `lib/main.dart`, `.github/workflows/flutter-foundation.yml`, `zero-cost-gate.yml`, `tool/bootstrap_android.py`, `tool/verify_apk_manifest.py`, `tool/check_zero_cost_policy.py`, `tool/verify_android_probe_results.py`.

**Engine/domain:** `lib/src/core/taximeter_engine.dart`, `metered_trip_coordinator.dart`, `location_tracking_policy.dart`, `location_owner_gate.dart`, `serialized_gps_stop.dart`; `lib/src/domain/confirmed_tariffs.dart`, `trip_record.dart`, `trip_route_point.dart`, `revenue_summary.dart`, `quote_calculator.dart`.

**Data/UI:** `lib/src/data/trip_repository.dart`, `trip_session_snapshot.dart`, `tariff_codec.dart`; `lib/src/ui/gps_lab_page.dart`, `gps_preview_page.dart`, `safety_service_page.dart`, `tariff_management_page.dart`; `lib/src/lab/headless_sqlite_probe.dart`, `trip_ipc_contract.dart`.

**Android Kotlin:** `android_native/MainActivity.kt`, `LocationSafetyService.kt`, `LocationOwnerRegistry.kt`, `TripCheckpointProtocol.kt`, `HeadlessSqliteProbeService.kt`, `HeadlessProbeCallbackFence.kt`, `HeadlessSqliteProbeInstrumentedTest.kt`, Kotlin tests. Android skeleton generated by Flutter/create + bootstrap in CI, not necessarily tracked in Git.

**Tệp tests mới:** `test/trip_ipc_contract_test.dart`; `tool/v3_clone_migration_proof.py`, `tool/test_v3_clone_migration_proof.py`; `test/support/issue3_sqflite_clone_writer.dart`, `test/issue3_sqflite_clone_ack_test.dart`; `test/support/issue3_ipc_sqflite_adapter.dart`, `test/issue3_ipc_sqflite_bridge_test.dart`; `test/support/issue3_staged_fare_checkpoint.dart`, `test/issue3_staged_fare_checkpoint_test.dart`; `test/issue3_fare_fork_pricing_regression_test.dart`, `test/issue3_staged_tariff_parity_test.dart`. Các unit tests cũ ở `test/taximeter_engine_test.dart`, `trip_repository_ffi_test.dart`, `metered_trip_coordinator_test.dart`, `headless_sqlite_probe_test.dart`, v.v.

**Tài liệu quan trọng:** `docs/QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md`, `docs/AI_HANDOFF_STATE.md`, `docs/ISSUE_3_SINGLE_OWNER_WRITER_ADR_DRAFT.md`, `docs/TRIP_LOCATION_SERVICE_CONTRACT.md`, `docs/HEADLESS_SQLITE_PROBE_DEBUG_ONLY.md`, `docs/ISSUE_3_IPC_PROOF_STATUS.md`, `docs/ISSUE_3_V3_CLONE_MIGRATION_PROOF.md`, `docs/ISSUE_3_SQFLITE_CLONE_ACK_PROOF.md`, `docs/ISSUE_3_IPC_SQFLITE_BRIDGE_PROOF.md`, `docs/ISSUE_3_STAGED_FARE_COMMIT_PROOF.md`, `docs/ISSUE_3_P4B_FARE_PARITY_REGRESSION.md` và bản bàn giao này. Docs cũ có mốc lịch sử; không dùng thay HEAD hiện tại.

**Storage:** DB app runtime `navitaximeter_v1.db` schema **v3**, không track repo; Prefs confirmed key `navi_confirmed_tariffs_v1`. DB probe `navitaximeter_HEADLESS_PROBE_ONLY.db`; Python `DISPOSABLE_TEST_ONLY.db`, clone `DISPOSABLE_V3_CLONE_ONLY.db`, Dart fixture `DISPOSABLE_APP_V3_ONLY.db`, `DISPOSABLE_APP_V4_ONLY.db`, `DISPOSABLE_FARE_STAGE_ONLY.db` đều là TEST ONLY, tuyệt đối không chép vào production.

**7 ảnh UI:** `IMG_4488.png` đến `IMG_4494.png`, 863×1822, chỉ ở uploads cuộc trò chuyện, **không** nằm repo; nếu chat mới không thấy, cung cấp lại khi dựng UI. Không có tile data/offline map/GPS hoặc tài khoản ngân hàng thật ở repo.

**Build trên máy có Flutter stable, Java 17, Android SDK, Python 3 (không mặc định user có PC/ADB):**

```sh
git clone https://github.com/ThanhTaxiXanh/NaviTaxiMeter.git
cd NaviTaxiMeter
git checkout feature/navitaximeter-foundation
flutter create . --platforms=android --org vn --project-name navitaximeter
python3 tool/bootstrap_android.py
python3 tool/bootstrap_android.py --check
python3 -m unittest discover -s tool -p 'test_*.py' -v
python3 tool/check_zero_cost_policy.py
flutter pub get
rm -f test/widget_test.dart
(cd android && ./gradlew :app:testDebugUnitTest --no-daemon)
(cd android && ./gradlew :app:assembleDebugAndroidTest --no-daemon)
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
flutter build apk --debug
python3 tool/verify_apk_manifest.py
```

**Chỉ khi Android emulator hoặc Android test device thực sự đã kết nối:** `cd android && ./gradlew :app:connectedDebugAndroidTest --no-daemon`, sau đó `python3 tool/verify_android_probe_results.py build/app/outputs/androidTest-results/connected`. Compile-only không chứng minh executed test. Debug APK không phải signed ARM64 release.

---

## 3.8. QUYẾT ĐỊNH KỸ THUẬT ĐÃ CHỐT / ỨNG VIÊN CHƯA DUYỆT

**Đã xác nhận, không đổi:** Android-first Flutter/Dart+Kotlin; fare engine Dart offline SQLite; driver-confirmed immutable tariff per trip; one genuine physical GNSS owner/one production writer là yêu cầu; ACK chỉ sau SQLite COMMIT và session/generation/seq fencing; PAUSED/manual RESUME fresh fix/new segment/no backfill; privacy; cash/bank-transfer-only; VietQR thật; 7 màn + dark navy/cyan; bản đồ theo nội dung người dùng xác nhận; Zero Paid API; không merge main, không sửa TTX, không Billing và không thu khách.

**Ứng viên kỹ thuật CHƯA được phép commercial:** một Kotlin `TripLocationService` thực sự sở hữu GNSS/location FGS, một FlutterEngine headless do service sở hữu chạy Dart `TripSessionWorker` sở hữu chính `TaximeterEngine` và một SQLite app writer. Lý do: giữ tiền trong Dart, tránh Kotlin writer song song, tránh port tiền chưa parity. Android14 debug probe chỉ chứng minh bound FlutterEngine và sqflite counter DB.

**Không tự thay công nghệ:** port Dart fare sang Kotlin khi chưa có parity/owner approval; chuyển sang paid Google APIs/Billing; scrape Google/OSM tiles trái license; fake map POI/route/QR; migrate production v3→v4; gọi helper fork mới trong app rồi nói sản phẩm đã an toàn. Google Maps SDK thường chỉ xem xét nếu có chứng minh zero-cost license; MapLibre/OSM offline là hướng nghiên cứu phải có attribution hợp pháp.

---

## 3.9. KẾ HOẠCH TIẾP TỤC THEO THỨ TỰ VÀ TIÊU CHÍ

| Cổng | Việc cần làm | Tiêu chí kiểm chứng |
| --- | --- | --- |
| **P0 Repo/CI sau docs commit** | Đọc lại feature HEAD, PR #1, issue #2/#3, ZeroCost/Foundation theo **SHA**, so với mã đã PASS `edee0b7e`. | Không gán CI PASS của SHA code cho docs-only HEAD; main/TTX không đổi. |
| **P1 Unified test-only writer** | Trên **một DB clone**: typed IPC metadata + source fix trusted synthetic -> `forkForCheckpoint()` -> một transaction route + frozen fare/header + durable fence + ACK ledger -> post-COMMIT ACK, cùng callback lifecycle. | 8 parallel/duplicate idempotent, stale gen/conflicting replay/gap/mock reject, SQL injected failure rollback tất cả, ACK lost reopen PAUSED, UI không thấy tiền phantom. |
| **P2 Coordinator copy-on-write** | Review `MeteredTripCoordinator.accept`, `resume`, `_suspend`, `finish` rồi áp dụng staged candidate + one mutation owner sau khi proof/ADR được duyệt; không bật production. | Mọi live fare update chỉ sau COMMIT; storage/IPC unknown => PAUSED; không backfill GPS gap. |
| **P3 Backup + schema clone** | DB v3 cùng confirmed Prefs tại consistency point, hash/preflight/rollback, v2/v3 fixtures, v4 fence/ledger trên CLONE, update APK tests. | Không mất receipt/route/tariff; rollback/restore, không auto-migrate app thật. |
| **P4 Android instrumentation** | Android debug-only app DB clone, real service ownership, native->Dart IPC and crash/fail-injection, executed XML gate. | Rõ APK SHA/API, Kotlin/Dart tests thật, không tự nhận GPS physical. |
| **P5 Issue #2 Android thật** | Android 11–16 thiết bị sẵn có; FGS/GNSS, Stop stale, Home/lock/Doze/OEM, revoke, kill/reboot, GPS gap và battery. **Bắt buộc áp dụng toàn văn Phụ lục A** với từng thao tác, PASS/FAIL/NOT TESTED, ảnh/log che riêng tư, cách gửi AI. | Chỉ đánh dấu PASS sau khi chủ dự án gửi đủ bằng chứng và AI đối chiếu; không có đúng APK/nút test thì CHƯA THỂ TEST. |
| **P6 Feature & parity** | Hiệu chuẩn distance/fare real-world, driver tariffs, 7 mockups, map VN 2D/3D offline/online, POI/routing/sovereignty test theo dataset có license, VietQR test bank-app. | Kết quả pháp lý/giấy phép, screenshots, cước parity, QR hợp lệ, không mock data. |
| **P7 Chi phí/release** | Kiểm 1/50/100 tài xế × 30 ngày 0 USD phí API; signed ARM64 APK, update/backup/migration, FPS/RAM/pin, owner release approval. | Chỉ khi pass mọi cổng + chủ dự án phê duyệt mới xem xét thương mại hay merge main. |

**Không khởi động lại** Python/FFI/emulator proofs đã PASS trừ khi có lý do kỹ thuật đã xác minh. **Tiếp tục issue #3 P1 unified test-only writer**, không mở chức năng sản phẩm mới trước khi an toàn.

---

## 3.10. CHỈ THỊ BẮT BUỘC CHO AI CHAT MỚI

1. **Đọc toàn bộ bàn giao 3.1–3.10 + Phụ lục A và quy tắc cứng**. Không chỉ đọc summary hoặc bắt chủ dự án nhắc lại.
2. **Chat mới đặt `AI_REPLY_COUNT=0`**. Mỗi assistant reply hoàn tất +1, cuối 1–6 ghi `Trạng thái bàn giao: n/7`; lượt 7 lại viết bàn giao ĐẦY ĐỦ 3.1–3.10. Nếu cùng chat hiện tại, lần bàn giao kế tiếp là lượt 14; không reset sai.
3. **GitHub live:** xác minh feature HEAD/CI đúng SHA, PR #1 Draft/unmerged, main SHA, TTX ref SHA, issue #2/#3. Chỉ ghi `feature/navitaximeter-foundation`; **TUYỆT ĐỐI KHÔNG** merge main, sửa TTX, bật Google Billing/API trả phí, tính cước khách hoặc signed release.
4. **Phân biệt proof:** SHA `edee0b7e` full CI SUCCESS, `flutter test` và Android14 headless **debug-only** SQLite probe đã chạy, **KHÔNG** là trip GNSS service production, commercial fare ACK hoặc Android physical.
5. Tiếp tục P1 issue #3 **từ unified test-only typed IPC + immutable Dart candidate + SQLite route/header/fence/ACK COMMIT**, sau đó review coordinator/live service. Không tự viết lại headless probe đã có CI.
6. Issue #2 vẫn **OPEN/NOT TESTED PHYSICAL**. Khi cần người dùng test trên điện thoại, bắt buộc đưa đúng APK/SHA + chuẩn bị, từng nút từng bước, PASS/FAIL/NOT TESTED, ảnh/video/log cần che, cách gửi trong chat và AI đối chiếu, theo **toàn văn Phụ lục A**. Không giả định máy tính/ADB. Không đúng APK/nút -> CHƯA THỂ TEST.
7. Không đưa mật khẩu, token/API key, GPS cá nhân, tài khoản ngân hàng, keystore hoặc ảnh khách vào logs/issue/handoff. Không tạo GPS/POI/route/QR giả để lấp thiếu source.
8. Bảy mockup PNG không nằm trong Git; kiểm attachments hoặc chỉ xin đính kèm lại khi thực sự cần dựng UI.
9. Cập nhật `docs/AI_HANDOFF_STATE.md` với count/SHA/CI/next gate khi có quyền; lưu tài liệu bàn giao full độc lập. Không nhận CI source gate là audit chi phí thực tế.
10. Chốt an toàn: nếu OS physical/SQLite/fare chưa có bằng chứng, đánh dấu **CHƯA XÁC MINH / NOT TESTED**, không được tuyên bố hoàn thành hoặc thu phí.

### Câu lệnh khởi động chat mới (sao chép cùng tài liệu này)

> Hãy tiếp quản NaviTaxiMeter từ **BẢN BÀN GIAO BẮT BUỘC — LƯỢT 7/7 ngày 16/11/2026**. Đọc đủ 3.1–3.10 và Phụ lục A hướng dẫn kiểm thử điện thoại. Đặt `AI_REPLY_COUNT=0`. Chỉ sửa nhánh `feature/navitaximeter-foundation`, không merge main, không sửa TTX, không Google Billing, không thu cước khách. CI code SHA `edee0b7e` SUCCESS (flutter test + Android 14 headless DEBUG SQLite probe), nhưng issue #3 còn thiếu production GNSS owner/one trip writer/durable ACK end-to-end và issue #2 Android thật vẫn OPEN. Kiểm tra HEAD/CI live, sau đó tiếp tục issue #3 P1 **unified TEST-ONLY IPC + staged immutable Dart fare + atomic SQLite route/header/fence/ACK trên DB clone**, không làm lại những proof đã PASS. Nếu muốn tôi test điện thoại phải hướng dẫn chính xác mục tiêu, từng bước, PASS/FAIL, bằng chứng và cách gửi theo Phụ lục A. Sau 6 lượt AI trả lời bình thường, lượt 7 tiếp theo lại bàn giao đầy đủ.

---

## PHỤ LỤC A. TOÀN VĂN QUY TẮC CỨNG MỤC 9: HƯỚNG DẪN KIỂM THỬ/CHỨNG MINH TRÊN ĐIỆN THOẠI

## 9. QUY TẮC CỨNG BỔ SUNG: HƯỚNG DẪN KIỂM THỬ/KIỂM CHỨNG TRÊN ĐIỆN THOẠI
**Ngày bổ sung:** 15/11/2026. **Mức độ ưu tiên:** BẮT BUỘC, áp dụng xuyên suốt NaviTaxiMeter và mọi chu kỳ bàn giao 7 lượt.

**Nguyên văn yêu cầu của chủ dự án:**
> Nếu muốn tôi kiểm thử hay kiểm chứng trên điện thoại thì phải hướng dẫn chi tiết, kiểm thử cái gì, kiểm chứng cái gì, làm thế nào để cho bạn biết là đã kiểm thử hay kiểm chứng thành công để đưa cho bạn xem.

**Quy tắc thực thi cho AI:**
1. Mỗi khi nhờ chủ dự án kiểm thử/kiểm chứng trên điện thoại, **bắt buộc cung cấp một quy trình thao tác cụ thể, theo từng bước**, phù hợp người dùng chủ yếu vận hành qua điện thoại, không mặc nhiên có máy tính hoặc ADB.
2. Trước khi thao tác, ghi rõ **mục tiêu đang kiểm thử**, chức năng/rủi ro cần kiểm chứng, mã commit SHA, loại bản Android APK (DEBUG/RELEASE), link GitHub Actions/artifact khi đã xác minh, điều kiện tiên quyết, Android/OEM và trạng thái quyền GPS cần quan sát. Không đặt link/artifact không tồn tại, không nhận CI PASS thay cho kiểm thử điện thoại thật.
3. Hướng dẫn **cách tải, cài và mở đúng bản APK thử nghiệm**, có cảnh báo về nguồn tải hoặc giới hạn cài đặt; hướng dẫn chính xác nút/màn/tab cần mở, thứ tự bấm, thời gian chờ hoặc dấu hiệu nhìn thấy. Nếu chưa có đúng bản APK hoặc tính năng kiểm chứng thì ghi **CHƯA THỂ TEST**, không yêu cầu bấm nút giả định.
4. Với **mỗi ca test**, trình bày: (a) đang thử điều gì; (b) từng bước thao tác; (c) **kết quả mong đợi (PASS)**; (d) dấu hiệu **FAIL** và lúc nào phải dừng; (e) cách xử lý nếu không thấy nút hoặc màn hình khác tài liệu. Không dùng chỉ dẫn mơ hồ như “thử GPS rồi báo lại”.
5. Ghi rõ **cần thu thập bằng chứng gì**, chụp ảnh màn hình/video/ghi lại biểu hiện ở đúng bước, cách tìm phiên bản Android và model thiết bị, thời gian test, quyền vị trí, tình trạng khóa màn hình, mã APK/run/SHA. Có thể dùng checklist ngắn để người dùng chỉ việc điền **PASS / FAIL / NOT TESTED** và mô tả điều quan sát thực tế.
6. Hướng dẫn **gửi bằng chứng về cho AI** ngay trong cuộc trò chuyện: đính kèm ảnh/video hoặc văn bản, kèm mã ca test, bước số, kết quả quan sát được và thông tin máy/phiên bản Android đã kiểm tra. AI phải nêu tiêu chí để đối chiếu và **chỉ công nhận PASS sau khi bằng chứng đủ rõ**; nếu chưa đủ thì đánh dấu **CHƯA XÁC MINH**, chỉ yêu cầu bổ sung phần thiếu.
7. **Quy tắc riêng về bảo mật:** ảnh/video/log phải che hoặc cắt bỏ tọa độ, địa chỉ nhà, hành trình khách, số tài khoản ngân hàng, thông báo riêng tư, mã token, API key, keystore và dữ liệu cá nhân. Không yêu cầu đăng công khai bằng chứng nhạy cảm lên GitHub; không thu phí khách, không dùng hành khách thật để thử; nếu hành vi GPS/FGS không an toàn thì dừng ngay.
8. Luôn phân biệt **“đã chạy thao tác”**, **“người dùng báo PASS”**, **“AI đã đối chiếu bằng chứng”**, **“CI PASS”** và **“Android vật lý được kiểm chứng”**. Chưa quan sát được không được suy diễn là PASS. Nếu test FAIL, ghi nguyên hiện tượng, bước tái hiện và điều kiện; không đánh dấu issue #2 hoặc #3 hoàn tất trước khi có bằng chứng đầy đủ.
9. Khi có bản bàn giao 7/7, **phải chép nguyên vẹn quy tắc bổ sung này hoặc liên kết kèm đầy đủ văn bản và nhắc bắt buộc** trong mục 3.2, 3.9 và 3.10 để AI tiếp quản áp dụng từ lượt đầu tiên. Bản quy tắc phải lưu trong repository NaviTaxiMeter trên nhánh được phép, không sửa TTX/main.

**Mẫu tối thiểu cho mỗi yêu cầu test điện thoại:** `Mã ca | Mục tiêu | APK/SHA | Chuẩn bị | Bước 1,2,3... | PASS khi | FAIL khi | Bằng chứng cần chụp | Cách gửi AI | Kết quả PASS/FAIL/NOT TESTED`.

**Quy tắc này không cấp phép triển khai production:** vẫn giữ Zero Paid API, single GNSS owner, fail-closed/PAUSED, không Billing, không thương mại và không merge main.

---

**KẾT LUẬN:** NaviTaxiMeter code SHA `edee0b7e` có `flutter test`/Android14 DEBUG headless SQLite CI SUCCESS, nhưng chưa có production service GNSS/single writer/ACK trên DB app, chưa có kiểm thử Android vật lý, chưa được thương mại. Bước tiếp là issue #3 P1 unified test-only writer, sau đó issue #2 theo quy tắc điện thoại; mọi thay đổi chỉ branch feature.

**Trạng thái bàn giao: 7/7. AI_REPLY_COUNT = 7.**
