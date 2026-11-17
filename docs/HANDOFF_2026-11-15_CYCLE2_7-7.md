# BẢN BÀN GIAO DỰ ÁN — NAVITAXIMETER

**Loại:** **BÀN GIAO BẮT BUỘC — LƯỢT 7/7** (chu kỳ tiếp quản thứ hai trong cuộc trò chuyện hiện tại; các lượt thường 1–6 đã hoàn thành).  
**Ngày:** Chủ nhật, **15/11/2026, giờ Việt Nam UTC+07:00**; người dùng yêu cầu tiếp tục lúc **21:54:32**.  
**Trạng thái:** **ĐANG TRIỂN KHAI / THỬ NGHIỆM**, đã chứng minh được *headless FlutterEngine + sqflite* trên **Android 14 Emulator**, nhưng **CHƯA ĐỦ ĐIỀU KIỆN THU CƯỚC KHÁCH**.  
**Đếm lượt:** `AI_REPLY_COUNT = 7` sau khi hoàn tất câu trả lời bàn giao này. **Cuộc trò chuyện mới khởi tạo `AI_REPLY_COUNT = 0`**. Nếu tiếp tục **trong cùng cuộc trò chuyện** thì đếm lượt 8, 9,... và bàn giao lại ở lượt 14, 21, 28,..., không reset giữa chừng.  
**Nguồn:** Tệp người dùng cung cấp `QUY TẮC CỨNG — BÀN GIAO DỰ ÁN SAU MỖI 7 LƯỢT TRẢ LỜI AI.md`; bản bàn giao trước `HANDOFF_2026-11-15_CYCLE_7-7.md`; GitHub trực tiếp; mã nguồn và log GitHub Actions được đối chiếu ngày 15/11/2026. Bản này **đủ thông tin để sao chép độc lập sang chat mới**.

## Thông tin khóa và bằng chứng tại thời điểm chốt

| Hạng mục | Giá trị đã đối chiếu |
| --- | --- |
| Kho dự án | https://github.com/ThanhTaxiXanh/NaviTaxiMeter |
| Nhánh **duy nhất được phép ghi** trong giai đoạn này | `feature/navitaximeter-foundation` |
| HEAD khi bắt đầu bàn giao lượt 7 | `a8a09433ead50014b61301e0b8aafeca35f2eb74` (**docs-only** so với code đã PASS) |
| HEAD **code/debug test đã được CI đầy đủ xác minh** | `85cfa50e79f77787e61e10e86a4652d004e7aae3` |
| Foundation Flutter Android, có test Android 14 Emulator | Run **43725473578**, **SUCCESS** trên code HEAD `85cfa50`: https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43725473578 |
| Zero Cost Source Gate trên code HEAD `85cfa50` | Run **43725473618 SUCCESS** |
| Zero Cost Source Gate trên docs HEAD `a8a09433` | Run **43726611616 SUCCESS** |
| Foundation trên docs HEAD `a8a09433` | Run **43726611613** vẫn **IN PROGRESS** lúc kiểm tra đầu lượt 7. Không gán SUCCESS của SHA cũ cho SHA này. |
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

**Hiện trạng:** Đã có lõi tiền/chuyến/SQLite, bảng giá xác nhận, một số màn kỹ thuật và Android GPS safety interlock; đã thêm **thử nghiệm headless FlutterEngine do bound service sở hữu**, dùng `sqflite` trên **cơ sở dữ liệu riêng** và **đã PASS Android 14 Emulator**. Chưa có một `TripLocationService` production duy nhất, chưa có transactional trip writer có **ACK sau COMMIT**, chưa có bộ bảy màn cuối, renderer bản đồ online/offline, POI/routing thật, VietQR sản xuất, thiết bị Android vật lý được kiểm tra, bản phát hành đã ký, hay audit 0 USD 30 ngày.

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

`MeteredTripCoordinator` là coordinator trong Flutter UI/Lab; kiểm tra trusted GPS fix, tăng trạng thái Dart meter, gọi SQLite và recovery PAUSED. **Rủi ro hiện hữu:** một số meter mutation xảy ra **trước khi await checkpoint**, nên production phải stage immutable/copy candidate và chỉ công bố trạng thái sau transaction COMMIT; trường hợp commit/ACK không chắc phải phục hồi trạng thái durable. Flutter UI isolate không chứng minh sống khi Activity bị hủy. Lab vẫn khởi tạo `TripRepository()` trực tiếp (`lib/src/ui/gps_lab_page.dart`), Preview còn `Geolocator.getPositionStream`; **chưa có one production writer/one native GNSS service**.

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

## 3.4. CÔNG VIỆC ĐÃ HOÀN THÀNH, MÃ ĐÃ VIẾT VÀ MỨC KIỂM CHỨNG

### 3.4.1. Nền tảng từ các chu kỳ trước (đã có source/test CI)

- Flutter app core/5 engineering tabs, taximeter Dart, domain quote/revenue, SQLite schema v3 và route checkpoint, history/receipt representation, confirmed tariff store và preview/lab GPS.
- Android Kotlin `MainActivity`, `LocationOwnerRegistry`, `LocationSafetyService` health-only, MethodChannel, lease token/fenced Stop, monotonic heartbeat; Kotlin/JVM và Dart tests. `TripCheckpointProtocol` thiết kế thuần Kotlin với fake writer.
- Replay route từ SQLite: sửa lỗi `INSERT OR IGNORE` chấp nhận cùng sequence có payload sai; nay so sánh hàng persisted, lỗi phải rollback. 12 Python SQLite contract tests minh họa atomicity/recovery trên DB tạm.
- `tool/bootstrap_android.py` tạo native generated Android source sau `flutter create`, idempotency, permission và compiled manifest checks; workflow Flutter Foundation và Zero Cost Source Gate.
- Các mốc lịch sử trước: `c0af5ef6960a6358013b000fb9a947b6b8564a2a` có Foundation run `43717172307 SUCCESS` và Zero Cost run `43717172335 SUCCESS`, tất cả chỉ xác minh source/CI.

### 3.4.2. Chu kỳ vừa tiếp quản, các lượt 1–6

| Lượt | Công việc có commit thực trên feature branch | Trạng thái bằng chứng |
| --- | --- | --- |
| **1/7** | ADR một GNSS owner + một service-owned Dart writer: `docs/ISSUE_3_SINGLE_OWNER_WRITER_ADR_DRAFT.md`, cập nhật `docs/AI_HANDOFF_STATE.md`, bình luận issue #3. HEAD cuối lượt `192160ffe7735012ba5113b398ae0549fde6d67b`. | **DESIGN CANDIDATE**, chưa code writer; PR Draft. |
| **2/7** | `HeadlessSqliteProbeService.kt`, `lib/src/lab/headless_sqlite_probe.dart`, entrypoint `lib/main.dart`, Dart FFI/Android instrumentation tests, bootstrap debug-only, Gradle wiring; docs `HEADLESS_SQLITE_PROBE_DEBUG_ONLY.md`. Code test HEAD `a2b072bdc8ac126016e6f134a3697d8995c93417`, handoff HEAD `bf99438ab434fbaee73b446714fb2858d13e88a8`. | Đã sửa Python Gradle fixture thiếu `defaultConfig` và lỗi escape newline debug manifest; lúc bàn giao chưa chạy emulator. |
| **3/7** | `SerializedHeadlessProbeWriter` (queue 1 writer cho **DB probe**, không phải trip), Flutter FFI tests 8 concurrent writes/conflicting DB path, Android instrumentation test 8 calls; code commit `2ecc412e46206841c2ced76b187a35f23e2713b7`, docs HEAD `86607bdc0c52dc1053925314e810d036fa0f00b3`. | Foundation run **43722503940 SUCCESS**: Python/JVM/Flutter, instrumentation **compile only**, Debug APK + manifest. |
| **4/7** | Workflow PR `emulator-probe` Android API 34 x86_64, `connectedDebugAndroidTest`, tool `verify_android_probe_results.py` và 7 Python tests phải có executed testcase XML; code commit `7a2a18aa1e4b24745cc70991b29ac24db42008fe`, docs HEAD `e116b97cee65deea2353cb9050bacaa4d4c87dbf`. | Zero Cost PASS, emulator chạy sau Foundation; chưa có PASS ở thời điểm lượt 4. |
| **5/7** | Log emulator đầu tiên run `43724015757`: Gradle `connectedDebugAndroidTest BUILD SUCCESSFUL`, test 1 đã chạy, nhưng **gate XML FAIL vì sai path**. Sửa path thành `build/app/...`; thêm `HeadlessProbeCallbackFence.kt`/Kotlin JVM tests; service callback at-most-once, pending requests fail `SERVICE_DESTROYED`, stale ignored; instrumentation unbind/destroy/rebind+persisted count. Code HEAD `58fc25441dad91acc7566ee6ef25a9666b9be5b2`, docs/head state cuối `85cfa50e79f77787e61e10e86a4652d004e7aae3`. | Đây là **lỗi CI thật** đã được sửa, nhưng cần run xác minh. |
| **6/7** | Đối chiếu run `43725473578` đúng `85cfa50`: **Foundation build-test + Android 14 Emulator + XML executed test gate cùng SUCCESS**. Cập nhật issue #3/#2 và `docs/AI_HANDOFF_STATE.md`. HEAD docs `a8a09433ead50014b61301e0b8aafeca35f2eb74`. | **ĐÃ KIỂM CHỨNG Android 14 EMULATOR DEBUG PROBE**, **KHÔNG** phải Android physical/production writer. |
| **7/7** | **LƯỢT HIỆN TẠI: chỉ thực hiện bàn giao**; đọc quy tắc, nguồn và repo, tạo tài liệu độc lập 3.1–3.10; không mở tính năng hoặc merge. | Kết quả CI mới của commit tài liệu phải kiểm tra lại theo HEAD mới. |

### 3.4.3. Danh mục PASS/NOT TESTED rõ ràng

**ĐÃ HOÀN THÀNH VÀ CÓ BẰNG CHỨNG KIỂM THỬ TỰ ĐỘNG:** build Flutter debug, Dart fare/domain/SQLite-FFI tests, Kotlin JVM source and callback fence tests, `:app:assembleDebugAndroidTest`, `flutter analyze`, `flutter test`, `flutter build apk --debug`, compiled manifest safety checks, Python unit tests và 12 SQLite temporary proof tests. **Android 14 Emulator AVD chạy thật 1 instrumented testcase, kiểm tra XML PASS** trên HEAD `85cfa50` tại run `43725473578`; code đó còn được giữ nguyên trong docs-only HEAD `a8a09433`.

**ĐÃ VIẾT NHƯNG CHƯA ĐƯỢC KIỂM THỬ TRÊN ĐIỆN THOẠI THẬT:** GPS accuracy/multipath, FGS overlap thực tế, stale notification, Stop-before-ACK OS, precise/approx permission/revoke, Home/lock, Doze/OEM, force-stop/reboot, storage failure, pin/RAM/FPS, SQLite flash durability. Android emulator test **không** chứng minh toàn bộ các trường hợp này.

**CHƯA TRIỂN KHAI PRODUCTION:** một native TripLocationService GNSS/trip owner, single app SQLite writer và durable fence/ACK ledger, staged immutable money candidate, v3→v4 migration và backup thống nhất, signed ARM64 release, 7 final screens, online/offline map renderer + GIS/POI/routing, VietQR đã kiểm app ngân hàng và zero-paid-API audit thực tế 30 ngày.

---

## 3.5. CÔNG VIỆC ĐANG TRIỂN KHAI, ĐIỂM DỪNG, TỆP VỪA SỬA

**Công việc chủ đạo:** **issue #3**: sau khi kiểm chứng khả năng headless FlutterEngine+sqflite trên Android 14 AVD, bước kế là thiết kế và thử **một SQLite trip writer runtime duy nhất** với giao thức typed IPC, session/generation/sequence fencing và ACK sau COMMIT, không chạm dữ liệu khách. **Issue #2** kiểm thử GNSS/FGS Android vật lý vẫn là blocker song song.

**Trạng thái tại lúc bắt đầu lượt 7:** HEAD `a8a09433ead50014b61301e0b8aafeca35f2eb74`, chỉ khác code PASS `85cfa50e79f77787e61e10e86a4652d004e7aae3` ở `docs/AI_HANDOFF_STATE.md` (12 dòng thêm). Foundation trên HEAD docs `43726611613` lúc đầu **IN PROGRESS**, Zero Cost `43726611616 SUCCESS`. Lượt này không sửa mã ứng dụng. Chỉ ghi thêm tài liệu bàn giao và trạng thái lượt 7 nếu có quyền, **không được nâng CI trạng thái từ SHA khác**.

**Đường dây nối việc cụ thể:**

1. Mở issue #3 và `docs/ISSUE_3_SINGLE_OWNER_WRITER_ADR_DRAFT.md`, `docs/HEADLESS_SQLITE_PROBE_DEBUG_ONLY.md`, `docs/TRIP_LOCATION_SERVICE_CONTRACT.md`.
2. Xem source `android_native/HeadlessSqliteProbeService.kt`, `HeadlessProbeCallbackFence.kt`, `lib/src/lab/headless_sqlite_probe.dart`, `lib/src/data/trip_repository.dart`, `lib/src/core/metered_trip_coordinator.dart`, `android_native/TripCheckpointProtocol.kt`.
3. Phân định riêng *một service GNSS owner*, *một Dart worker owner*, *một DB connection/writer authority*, *một ACK protocol*. Không đưa Flutter UI/Lab thành production writer; `GpsLabPage` hiện vẫn tự mở `TripRepository`, `GpsPreviewPage` vẫn dùng Geolocator stream.
4. Thiết kế typed message `sessionId`, `generation`, `sequence`, `gnssElapsedRealtimeNanos`, GNSS physical trust, immutable confirmed tariff hash, checkpointId/payload digest. Chỉ chấp nhận exact replay giống nhau và monotonic sequence; timeout/unknown ACK phải PAUSED/SUSPENDED.
5. Chuẩn bị fixture **bản sao app DB v3 + prefs**, chưa migrate production. Thử v3→v4 trên copy cùng backup/rollback, bảo toàn route/receipt/tariff, không có double-count. Định nghĩa transaction thực: route, header, durable fence và ACK ledger cùng COMMIT, emit ACK sau Future transaction thành công.
6. Chạy CI và Android instrumentation cho **app DB copy/probe test**, không dùng địa chỉ GPS thật hay thu cước. Sau đó kiểm chứng issue #2 trên điện thoại Android 11–16, OEM/Doze/FGS.

**Tệp vừa sửa gần nhất trong chu kỳ 5–6:** `.github/workflows/flutter-foundation.yml`; `android_native/HeadlessProbeCallbackFence.kt`, `HeadlessProbeCallbackFenceTest.kt`, `HeadlessSqliteProbeService.kt`, `HeadlessSqliteProbeInstrumentedTest.kt`; `tool/bootstrap_android.py`, `tool/test_bootstrap_android.py`; `docs/HEADLESS_SQLITE_PROBE_DEBUG_ONLY.md`, `docs/AI_HANDOFF_STATE.md`. **Điểm dừng code:** đã có emulator lifecycle proof; **chưa** viết adapter trip writer production hay schema v4.

---

## 3.6. LỖI, BẤT ĐỊNH VÀ VẤN ĐỀ CHƯA GIẢI QUYẾT

### Lỗi đã tìm và có bằng chứng sửa

1. Lịch sử: `aapt dump xmltree` argument order sai → sửa và CI manifest PASS; bootstrap Android không idempotent → sửa và CI PASS.
2. Lịch sử: `TripRepository.saveActiveIncremental()` dùng `INSERT OR IGNORE` có nguy cơ chấp nhận replay cùng sequence nhưng khác tọa độ/speed → đã so sánh persisted route row và thêm Dart SQLite FFI regression tests PASS.
3. Chu kỳ mới lượt 2: Python Gradle fixture thiếu `defaultConfig` khiến `test_gradle_unit_test_patch_idempotent` FAIL; sửa tại `ee00a41250b46d36593139767384bcb2bc7f595a`, sau đó Python safety PASS.
4. Chu kỳ mới lượt 2: escape newline trong generator debug manifest chưa đúng → sửa tại `abf99990257c30152d580d4b0ff9f2b1cc3a03a2`.
5. Chu kỳ mới lượt 5: `emulator-probe` run `43724015757` **FAIL** vì verifier tìm `android/app/build/outputs/androidTest-results/connected`, trong khi Flutter output thực là `build/app/outputs/androidTest-results/connected`; log test ghi một test đã chạy và Gradle BUILD SUCCESSFUL. Đã sửa workflow tại `4efe8f6542731833e08b5cafed10ec010f6de14b`; **run xác minh `43725473578` PASS** cả instrumented test và XML gate.
6. Rủi ro callback sau destroy → thêm `HeadlessProbeCallbackFence` với at-most-once callback, fail `SERVICE_DESTROYED` trên pending và ignore stale; Kotlin JVM PASS, Android debug lifecycle unbind/rebind instrumented testcase PASS trên emulator.

### Chưa giải quyết / còn thiếu bằng chứng (KHÔNG TỰ TỔNG KẾT LÀ PASS)

1. **Production GNSS owner chưa có:** `LocationSafetyService` chỉ health, `Preview/Lab` vẫn là hai Geolocator paths và process-local lease. Chưa có `TripLocationService` service duy nhất và hệ thống OS thực chưa chứng minh không chồng FGS. Pending Start/Stop chưa nhận OS ACK có thể giữ lease fail closed cho đến reset; không giải khóa bằng timeout mù.
2. **Production writer/ACK chưa có:** `TripCheckpointProtocol` fake writer, Python proof DB tạm, Flutter probe DB riêng; **không** app DB v4, durable generation/seq/ACK ledger, staged money state, crash/power-loss durability hay native GNSS transaction. Không đánh đồng `ready`, service heartbeat hoặc probe counter với ACK cước.
3. **Rủi ro Dart coordinator:** `MeteredTripCoordinator.accept()` thay meter trước khi `await _checkpoint`; lỗi/unknown COMMIT cần staged candidate và tải lại SQLite durable PAUSED, không lộ tiền/kilomet chưa commit. UI Lab vẫn mở `TripRepository` và có đường `save(record)` `REPLACE` trong legacy, nguy cơ song writer và ghi đè receipt.
4. **Phiên bản/backup:** App SQLite v3; không có session fence/schema v4, chưa có backup SQLite + SharedPreferences consistency point, chưa kiểm migration v2/v3, restore, rollback khi storage đầy/corrupt hoặc update APK.
5. **Giới hạn emulator:** Run `43725473578` đã PASS API34 AVD cho headless SQLite debug và service teardown/rebind. Không chứng minh permission/GNSS thực trên Android 11–16, các OEM/Doze, process kill/power loss, crash đúng giao dịch, fsync; issue #2 vẫn **OPEN**.
6. **Giá cước:** Dart `double`/rounding chưa được kiểm độc lập; chưa có tariff thương mại chuẩn/hiệu chuẩn km và chưa có parity nếu muốn Kotlin fare.
7. **Tính năng chưa có:** bảy màn mockup, online/offline map/3D, map style/sovereignty test, POI/FTS5, dẫn đường, lane/speed signs/Mapillary data, VietQR thực, đồng bộ backup, hiệu năng 60 FPS, Android Auto, chi phí API thực tế, release signed ARM64.
8. **CI concurrency:** workflow push `Foundation` thường `CANCELLED` khi cùng nhánh có PR run vì `cancel-in-progress`; không tự kết luận đó là build failure. Khi commit docs sẽ phát sinh HEAD khác và run PR đang chạy có thể bị hủy; phải luôn dùng **SHA + run ID** cụ thể.
9. **Tài liệu cũ:** `README.md`, `docs/FOUNDATION_STATUS.md` và đoạn lịch sử trong `docs/AI_HANDOFF_STATE.md` có thể phản ánh mốc trước; lấy bản bàn giao này + tài liệu issue #3 + source/Actions chính xác HEAD làm nguồn hiện tại, không xóa lịch sử đã có.

**Không phát hiện sự cố thương mại thực địa** vì ứng dụng chưa được phép dùng chở khách. Không bịa kết quả FGS hoặc GPS physical.

---

## 3.7. MÃ NGUỒN, TỆP, DỮ LIỆU, LỆNH BUILD VÀ TÀI NGUYÊN

**GitHub code:** https://github.com/ThanhTaxiXanh/NaviTaxiMeter ; checkout nhánh `feature/navitaximeter-foundation`. Android skeleton không được commit; sinh bằng `flutter create` trong CI rồi `tool/bootstrap_android.py`. Git tree tại SHA `a8a09433` đã đối chiếu, **89 entries** tổng cộng. Không tưởng tượng thư mục tiles/POI được track nếu chưa thấy.

**Root/config:** `pubspec.yaml` (`0.1.4+5`), `lib/main.dart` (5 tab + headless entrypoint), `README.md`, `.github/workflows/flutter-foundation.yml`, `.github/workflows/zero-cost-gate.yml`.

**Core/domain:** `lib/src/core/taximeter_engine.dart`, `metered_trip_coordinator.dart`, `location_tracking_policy.dart`, `lab_session_safety.dart`, `location_owner_gate.dart`, `serialized_gps_stop.dart`; `lib/src/domain/confirmed_tariffs.dart`, `quote_calculator.dart`, `revenue_summary.dart`, `trip_record.dart`, `trip_route_point.dart`.

**Data & UI:** `lib/src/data/trip_repository.dart`, `trip_session_snapshot.dart`, `tariff_codec.dart`; `lib/src/ui/gps_preview_page.dart`, `gps_lab_page.dart`, `safety_service_page.dart`, `tariff_management_page.dart`; `lib/src/lab/headless_sqlite_probe.dart`.

**Kotlin native/TEST:** `android_native/MainActivity.kt`, `LocationSafetyService.kt`, `LocationOwnerRegistry.kt`, `LocationOwnerRegistryTest.kt`, `TripCheckpointProtocol.kt`, `TripCheckpointProtocolTest.kt`; mới thêm `HeadlessSqliteProbeService.kt`, `HeadlessSqliteProbeInstrumentedTest.kt`, `HeadlessProbeCallbackFence.kt`, `HeadlessProbeCallbackFenceTest.kt`.

**Build/check tools:** `tool/bootstrap_android.py`, `verify_apk_manifest.py`, `check_zero_cost_policy.py`, `checkpoint_sqlite_contract.py`, `test_checkpoint_sqlite_contract.py`, `test_bootstrap_android.py`, `test_verify_apk_manifest.py`, `test_zero_cost_policy.py`, `verify_android_probe_results.py`, `test_verify_android_probe_results.py`.

**Flutter tests trong Git:** `test/app_shell_test.dart`, `confirmed_tariffs_test.dart`, `gps_gap_recovery_test.dart`, `gps_preview_quality_test.dart`, `headless_sqlite_probe_test.dart`, `lab_session_safety_test.dart`, `location_owner_gate_test.dart`, `location_tracking_policy_test.dart`, `metered_trip_coordinator_test.dart`, `revenue_summary_test.dart`, `safety_service_status_test.dart`, `serialized_gps_stop_test.dart`, `strict_tariff_codec_test.dart`, `taximeter_engine_test.dart`, `tiered_fare_test.dart`, `tiered_quote_test.dart`, `trip_history_pagination_test.dart`, `trip_recovery_test.dart`, `trip_repository_ffi_test.dart`, `trip_route_persistence_test.dart`.

**Tài liệu được track:** `docs/AI_HANDOFF_STATE.md`, `docs/HANDOFF_2026-11-15_CYCLE_7-7.md` (bàn giao chu kỳ trước), `docs/ISSUE_3_SINGLE_OWNER_WRITER_ADR_DRAFT.md`, `docs/HEADLESS_SQLITE_PROBE_DEBUG_ONLY.md`, `docs/GPS_SINGLE_OWNER_INTERLOCK.md`, `docs/TRIP_LOCATION_SERVICE_CONTRACT.md`, `docs/SQLITE_ACK_TRANSACTION_PROOF.md`, `docs/NATIVE_GPS_SAFETY_SERVICE.md`, `docs/PHASE2_TARIFF_GPS.md`, `docs/PHASE2_METER_SQLITE.md`, `docs/PHASE2_LAB_ANDROID_GPS.md`, `docs/FOUNDATION_STATUS.md`. **Tệp bàn giao này** nên lưu mới dưới `docs/HANDOFF_2026-11-15_CYCLE2_7-7.md` nếu quyền ghi GitHub cho phép.

**DB/runtime files:** app DB `navitaximeter_v1.db` tạo khi chạy, schema 3, **không phải Git file**. Prefs tariff key `navi_confirmed_tariffs_v1`. DB test Python `DISPOSABLE_TEST_ONLY.db` trong tempfile; DB debug Flutter probe `navitaximeter_HEADLESS_PROBE_ONLY.db` chỉ cho thử nghiệm. **Không có SQLite v4 runtime hoặc offline map tile/dataset files**.

**Bảy ảnh UI người dùng đã cung cấp:** `IMG_4488.png`, `IMG_4489.png`, `IMG_4490.png`, `IMG_4491.png`, `IMG_4492.png`, `IMG_4493.png`, `IMG_4494.png` (863×1822, xuất hiện trong cuộc trò chuyện khi soạn). **Không ở repo**; cuộc trò chuyện mới cần đính kèm lại nếu assistant không thể thấy. Tệp quy tắc 7 lượt và bản bàn giao trước cũng là user uploads; bản này trích yêu cầu, nhưng chat mới không mặc nhiên đọc được tất cả tài sản. Hồ sơ `NaviTaxiMeter_GiaiDoan1_HoSo_KhoiDong.zip` được nêu trong bàn giao cũ; **không xác minh có trong repo/file uploads hiện tại**, không khẳng định sẵn có.

**Build/check trên máy có Flutter stable, Android SDK, Java 17, Python3:**

```sh
git clone https://github.com/ThanhTaxiXanh/NaviTaxiMeter.git
cd NaviTaxiMeter
git checkout feature/navitaximeter-foundation
flutter create . --platforms=android --org vn --project-name navitaximeter
python3 tool/bootstrap_android.py
python3 tool/bootstrap_android.py --check
python3 -m unittest discover -s tool -p 'test_checkpoint_sqlite_contract.py' -v
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

**CHỈ khi có Android emulator/test device thực sự đang kết nối:**

```sh
(cd android && ./gradlew :app:connectedDebugAndroidTest --no-daemon)
python3 tool/verify_android_probe_results.py build/app/outputs/androidTest-results/connected
```

Workflow PR `emulator-probe` dùng `ReactiveCircus/android-emulator-runner@v2`, API 34, x86_64; job `build-test` chạy trước, rồi test thực, XML gate phải PASS. **Không dùng các lệnh trên như bằng chứng rằng thiết bị thật đã được thử**. Bản Debug APK artifact được upload qua GitHub Actions, **không phải bản signed release**; không nhúng khóa keystore trong repo/handoff.

---

## 3.8. QUYẾT ĐỊNH KỸ THUẬT ĐÃ THỐNG NHẤT / ỨNG VIÊN CHƯA DUYỆT

**Giữ nguyên, đã xác nhận:** Android-first Flutter/Kotlin; fare engine Dart hiện hữu và SQLite offline; driver-confirmed immutable tariff snapshot; chỉ physical GNSS trusted cho tính cước; fail-closed/PAUSED/no gap billing; privacy/no fabricated data; one GNSS owner + one SQLite writer production target; Zero Paid API 0 USD; không merge main/TTX/Billing/thu cước hoặc signed release không phê duyệt. Cấm dùng test debug như sản phẩm.

**Đã chọn làm *candidate thử trước*, KHÔNG phải chấp thuận đưa vào production:** `TripLocationService` native Kotlin duy nhất sở hữu GNSS/FGS và **service-owned headless `FlutterEngine`** nuôi Dart `TripSessionWorker` (một isolate/serialized writer) sở hữu `TaximeterEngine` và app `sqflite` transaction; Activity chỉ client. Lý do: bảo toàn thuật toán tiền Dart, tránh hai SQLite writers và không port tiền không có parity. **Bằng chứng giới hạn mới:** Android 14 Emulator đã chứng minh bound-service headless FlutterEngine + sqflite với DB riêng, kể cả destroy/rebind; **CHƯA** chứng minh native location FGS đa phiên/OEM hay app DB ACK/cước.

**Không được tự chọn/loại bỏ phương án trong im lặng:** Kotlin-native SQLite writer và port tính tiền sang Kotlin **không tự động được duyệt** khi headless spike gặp khó; phải có parity/rounding tests, tài liệu tradeoff, phương án di trú và chủ dự án phê duyệt. Google Maps chỉ khi zero-cost hợp lệ, MapLibre/OSM offline là nhánh dự phòng nghiên cứu và phải tuân thủ licenses; nhà cung cấp tile/route/POI chưa chốt. Android Auto chưa được triển khai/chứng minh.

**Giới hạn đã chốt:** service heartbeat/ACK liveness không phải DB ACK. Python `sqlite3` 12 tests không phải Android app. SQLite app vẫn v3, chưa migration. Recovery luôn PAUSED/manual RESUME, dữ liệu cước phải từ COMMIT durable snapshot, không smoothing/backfill. Chỉ dùng CLI/CI không thay thử máy Android thật, đặc biệt issue #2.

---

## 3.9. KẾ HOẠCH TIẾP TỤC THEO THỨ TỰ ƯU TIÊN, CÓ TIÊU CHÍ ĐẠT

| Ưu tiên | Mục tiêu | Thành phần và các bước cụ thể | Kết quả mong đợi / tiêu chí kiểm thử |
| --- | --- | --- | --- |
| **P0 — Đối chiếu** | Xác nhận repo sau docs-only handoff commit | Đọc HEAD `feature/navitaximeter-foundation`, PR #1, CI Foundation/ZeroCost đúng SHA mới; compare code `85cfa50` với docs commits; verify main/TTX, issues. | SHA/run rõ, nhận biết nếu workflow còn chạy/CANCELLED; PR vẫn Draft, main/TTX không đổi. |
| **P1 — Cổng A được chứng minh** | Bảo toàn kết quả emulator, không mở rộng vô căn cứ | Đọc log run `43725473578`, Android XML actual testcase, `HeadlessSqliteProbeInstrumentedTest`, `HeadlessProbeCallbackFence`, `docs/HEADLESS_SQLITE_PROBE_DEBUG_ONLY.md`; tạo thêm tests lifecycle timeout/late callback *chỉ trong debug* nếu có lỗi chứng minh. | Debug headless SQLite proven on Android 14 emulator, không khai báo physical GNSS hay ACK app DB. |
| **P2 — Single-writer contract/test** | Một owner cho mutation trip và trạng thái sau COMMIT | Issue #3 ADR, typed IPC native→Dart, sessionId/generation/sequence/checkpointId/hash/monotonic metadata, stop/start fencing, bounded queue, staged immutable fare candidate, persisted snapshot only; UI/Lab/Preview không được mở production writer song song. Viết contract/test trước implementation. | Unit/instrumented tests stale, gap, mock, parallel 8 requests, duplicate exact/conflict, callback timeout/destroy; no phantom money, no orphan ACK. |
| **P3 — DB clone/migration safety** | Có durable ACK đúng app schema mà không mất dữ liệu | Sao chép anonymized/fixture `navitaximeter_v1.db` v2/v3 và confirmed Prefs; backup consistent + hash/preflight; mô phỏng schema v4 *trên bản sao*, route+header+fence+ACK ledger **cùng transaction**; inject lỗi trước/sau COMMIT, lost ACK, corrupt header/route, rollback, migration update/restore. | Không mất/ghi đè receipt/tariff/route; exact replay idempotent, conflict reject; ACK chỉ sau COMMIT; unknown ACK recover PAUSED, không double-charge. **Không migrate production tự động.** |
| **P4 — Native GNSS service / issue #2** | Một GNSS/location FGS owner thực, không overlap | Khi P2–P3 đủ proof và được duyệt, tích hợp một `TripLocationService`, gỡ/khóa Preview/Lab GNSS writers khỏi production. Chạy issue #2 trên Android 11–16 physical nơi có thiết bị: permission precise/approx, Start/Stop-before-ACK, stale notification token, Home/lock, Doze/OEM, disable provider, revoke, kill/reboot, wall-time, storage fault; nhìn OS FGS thật. | Redacted model/API/OEM/sha/run/expected/observed/PASS/FAIL. Còn thiếu case ghi NOT TESTED; observed failure phải mở issue; chỉ manual RESUME với segment mới, không backfill. |
| **P5 — Fare/receipt parity** | Đồng hồ đáng tin cậy trước thu cước | Independent distance/cost calibration, confirmed tariff snapshot, bậc km/rounding/wait/BOT/discount, receipt immutability/revenue/history, backup/restore sau update APK, stress tài nguyên. | Kết quả đối chiếu sai số rõ ràng, parity Dart/Kotlin nếu thay runtime; không đưa demo vào khách. |
| **P6 — UI/map/navigation** | 7 màn đúng mockup, dữ liệu bản đồ thật | Khi safety cho phép, lấy 7 PNG, xây giao diện tiếng Việt dark navy/cyan, camera follow modes; quyết định Google SDK thường nếu license 0 cost hoặc MapLibre+OSM offline hợp pháp; dataset/POI/FTS5/route engine/GIS/Mapillary khi có nguồn; test nhãn Biển Đông, Hoàng Sa, Trường Sa theo yêu cầu hiển thị. | Screenshot so mockup, attribution/giấy phép style/tile/POI, routing online/offline thực, bản đồ không giả; tính tiền độc lập camera. |
| **P7 — Thanh toán/chi phí/release** | Chỉ phát hành khi được duyệt và đã kiểm thử | Chuyển khoản/cash, local VietQR test bank-app, 1/50/100 users×30d phí thực 0 USD, review mọi SKU/terms, pin/RAM/60 FPS, signed ARM64 APK, migration/update/backup/device matrix, owner approval. | Báo cáo chi phí/license và test đầy đủ, chủ dự án duyệt riêng; chỉ lúc đó mới xem xét merge `main` và phát hành. |

**ĐIỂM TIẾP TỤC CHÍNH XÁC:** Sau khi đọc bản này và kiểm HEAD/CI, **mở lại issue #3**, bắt đầu **P2 contract writer Dart/native và P3 DB clone/migration test**, không viết lại probe vừa PASS hoặc thu cước production. Issue #2 chạy song song khi có Android thật, không bao giờ bỏ qua.

---

## 3.10. CHỈ THỊ BẮT BUỘC CHO AI TRONG CUỘC TRÒ CHUYỆN MỚI

1. **Đọc trọn vẹn bản bàn giao này** và quy tắc 7 lượt. Có thể kiểm tra các tài liệu được liên kết trong GitHub; không giả định chat mới có các ảnh/mockup hay file tải lên. Khi cần dựng UI mới yêu cầu 7 ảnh nếu không có.
2. **Khởi tạo `AI_REPLY_COUNT = 0` ngay khi mở chat mới.** Mỗi trả lời AI hoàn tất tăng đúng 1; lượt 1–6 làm việc bình thường và kết thúc `Trạng thái bàn giao: n/7`; lượt **7** bắt buộc tạo bản bàn giao đủ mục 3.1–3.10; các lượt 14, 21, 28,... cùng nguyên tắc. Nếu thiếu lịch sử, ghi rõ không xác minh bộ đếm và bàn giao sớm, không bịa.
3. Bảo toàn **tất cả yêu cầu cứng 3.2**, đặc biệt 0 USD paid API, không Google Billing, GNSS physical, PAUSED/manual RESUME, immutable tariff, privacy, 7 màn + map content, hai hình thức thanh toán, signed release chỉ sau duyệt.
4. Không tự thay kiến trúc; **candidate Kotlin one GNSS FGS + service-owned Dart single SQLite writer** chưa production approved. Không port fare sang Kotlin hoặc tự migrate DB v3 khi chưa parity/backup/migration tests và owner approval.
5. **Kiểm GitHub live trước khi ghi:** HEAD feature, PR #1 Draft/unmerged, main SHA, TTX reference SHA, issue #2/#3, CI đúng SHA; đối chiếu code PASS `85cfa50` với docs-only SHA. Chỉ sửa nhánh `feature/navitaximeter-foundation`; **KHÔNG merge main, KHÔNG sửa repo TTX**.
6. Phân biệt tuyệt đối: Python SQLite temporary proof, Kotlin fake writer, Dart FFI headless probe, Android 14 Emulator debug proof, và Android production SQLite ACK **là các phạm vi khác nhau**. Không gọi emulator proof là chứng nhận physical GNSS/FGS, không gọi source Zero Cost PASS là bill audit.
7. Tiếp tục từ **issue #3 P2/P3**: một production writer, typed session/generation fence, staged candidate, route+header+ACK ledger post-COMMIT trên app DB **clone**, backup/rollback. Issue #2 **OPEN** đến khi có bằng chứng máy Android thật.
8. Không tự bịa file, map/route/POI/GeoJSON, speed limit, mock tests, GPS data, cước, hóa đơn, billing cost hay Android physical PASS. Lỗi/FAIL phải nêu và sửa từng case có proof.
9. Không ghi/share mật khẩu, token, API key, keystore, địa chỉ hoặc tuyến GPS riêng, số tài khoản, dữ liệu khách trong code, CI logs, issue hay handoff. Chỉ lưu test fixture kỹ thuật vô danh, nguồn đã kiểm license.
10. Khi có quyền, duy trì `docs/AI_HANDOFF_STATE.md` với count, SHA, CI, current work, next step; tạo bản bàn giao mỗi 7 lượt **độc lập**, không chỉ append một summary. Nếu CI đang chạy sau docs commit, nói rõ `IN PROGRESS` và không claim success.

### CÂU LỆNH KHỞI ĐỘNG CHAT MỚI (SAO CHÉP CÙNG TÀI LIỆU NÀY)

> Hãy tiếp quản NaviTaxiMeter từ **BẢN BÀN GIAO BẮT BUỘC — LƯỢT 7/7, chu kỳ thứ hai, ngày 15/11/2026**. Đọc đầy đủ các mục 3.1–3.10 và giữ nguyên yêu cầu cứng. Đặt `AI_REPLY_COUNT = 0`. Xác minh GitHub HEAD, PR #1 Draft, issue #2/#3 và CI đúng SHA. Không merge `main`, không sửa repo TTX, không Google Billing và không thu cước khách. Android 14 Emulator headless SQLite debug probe đã PASS run `43725473578` tại code SHA `85cfa50`, nhưng **chưa** có một `TripLocationService` GNSS production hoặc app SQLite writer có ACK sau COMMIT, Android physical issue #2 vẫn OPEN. Tiếp tục issue #3 từ typed IPC/single-writer contract, staged candidate và thử DB clone/migration an toàn; không làm lại phần đã có bằng chứng trừ khi có lỗi mới. Sau mỗi 6 lượt trả lời thông thường, lượt 7 lại tạo bản bàn giao đủ mục 3.1–3.10.

---

**KẾT LUẬN VÀ ĐIỂM DỪNG:** Tại 15/11/2026, NaviTaxiMeter có nền Flutter/Kotlin, SQLite v3, source CI và **headless SQLite probe đã chạy thành công trên Android 14 Emulator**, kèm kiểm thử hủy/bind lại service. Nhưng **không có GNSS production owner, không có app DB ACK after COMMIT, không có kiểm thử Android thật, không có sản phẩm thu cước khách**. Việc tiếp theo rõ ràng: **xác minh latest GitHub CI → issue #3 single writer fenced transaction trên DB clone → issue #2 physical test → chỉ tiếp tục sản phẩm sau gates và phê duyệt**.

**Trạng thái bàn giao: 7/7. `AI_REPLY_COUNT = 7`.**
