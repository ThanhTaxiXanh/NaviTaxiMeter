# BẢN BÀN GIAO DỰ ÁN NAVITAXIMETER

**Loại:** BÀN GIAO BẮT BUỘC, LƯỢT 7/7 trong cuộc trò chuyện hiện tại.  
**Ngày bàn giao:** 16/11/2026 (giờ Việt Nam, UTC+07).  
**Trạng thái:** ĐANG PHÁT TRIỂN / KIỂM THỬ. KHÔNG ĐƯỢC DÙNG ĐỂ THU CƯỚC HÀNH KHÁCH.  
**Bộ đếm:** `AI_REPLY_COUNT = 7` khi hoàn thành lượt này. Chat mới đặt lại `AI_REPLY_COUNT = 0`; trong chat này bàn giao kế tiếp ở lượt 14, 21,...  
**Nguồn đã đọc/đối chiếu:** bản bàn giao được người dùng tải lên cho chu kỳ trước, quy tắc cứng trong tệp đính kèm và `docs/QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md` trên repository, mã GitHub live/CI đúng commit, PR #1, issue #2 và #3. Bản này là tài liệu độc lập, không đòi phải đọc các cuộc trò chuyện trước để hiểu bước kế tiếp.

## Bảng chứng cứ đã xác minh trực tiếp tại lượt 7/7

| Đối tượng | Trạng thái đã kiểm tra |
| --- | --- |
| Repository | https://github.com/ThanhTaxiXanh/NaviTaxiMeter |
| Nhánh **duy nhất được phép ghi** | `feature/navitaximeter-foundation` |
| **HEAD mã nguồn trước khi ghi tài liệu bàn giao** | `55c1c62f9b8b938df34f312a350b7474a4dd073d` |
| Foundation Flutter Android, đúng SHA trên | **SUCCESS**, run `43758959240`: https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43758959240 |
| Job `build-test` thuộc Foundation | **SUCCESS**: Kotlin JVM, Python safety, `flutter analyze`, `flutter test`, `flutter build apk --debug`, APK manifest check |
| Job `Android 14 emulator headless SQLite execution (NOT physical GPS)` | **SUCCESS**, chỉ SQLite DEBUG trên AVD, không phải Android vật lý/GNSS production |
| Zero Cost Source Gate, đúng SHA trên | **SUCCESS**, run `43758959319`: https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43758959319; KHÔNG phải kiểm toán hóa đơn API thực tế |
| PR #1 | **OPEN / DRAFT / NOT MERGED**: https://github.com/ThanhTaxiXanh/NaviTaxiMeter/pull/1 |
| `main` | `539ff788b62be69135e5b3ad2c554dca005249a5`, không được sửa/merge |
| TTX repo tham chiếu | `ThanhTaxiXanh/TTX-AATaximeter`, `feature/flutter-taximeter-foundation`, SHA `a40c246de6fd3799aaddedce3ed0d3b1d9dd524d`, chỉ đọc |
| Issue #2 | **OPEN / NOT TESTED Android vật lý**: https://github.com/ThanhTaxiXanh/NaviTaxiMeter/issues/2 |
| Issue #3 | **OPEN / chưa có single GNSS owner + single production writer**: https://github.com/ThanhTaxiXanh/NaviTaxiMeter/issues/3 |

**Cách hiểu chính xác:** Toàn bộ CI chạy thành công tại SHA `55c1c62` và các thử nghiệm mới của lượt 6 được đưa vào `flutter test`. Tuy nhiên PASS kiểm thử không phải phê duyệt cho thu cước, không chứng minh GNSS thật, FGS trên OEM, mất điện, hoặc SQLite writer production. Khi file bàn giao được commit lên GitHub, HEAD sẽ thay đổi chỉ vì tài liệu; phải kiểm tra CI **theo SHA mới** trước khi gọi run mới là PASS.

---

## 3.1. Tổng quan dự án

- **Tên:** NaviTaxiMeter, package Flutter `navitaximeter`, Android applicationId `vn.navitaximeter`, version `0.1.4+5` trong `pubspec.yaml` tại SHA đã kiểm tra.
- **Mục tiêu:** ứng dụng đồng hồ tính cước taxi Android-first cho tài xế, sử dụng GNSS thực và biểu giá do tài xế xác nhận; quản lý chuyến, lịch sử, doanh thu, hóa đơn, tiền mặt/chuyển khoản và VietQR hợp lệ, đồng thời phát triển bản đồ định vị/dẫn đường Việt Nam 2D/3D online/offline.
- **Đối tượng:** tài xế taxi Việt Nam. Quy trình phát triển/kiểm chứng phải phục vụ người dùng có thể chỉ thao tác bằng điện thoại, không mặc định có PC/ADB.
- **Phạm vi và thứ tự:** Android trước bằng Flutter/Dart + Kotlin, iOS sau khi Android ổn định và được phê duyệt. Tiếp tục bằng GitHub Actions và kiểm thử tách bạch; không giao xe khách cho các bản DEBUG/lab.
- **Mức độ hoàn thiện:** có lõi meter, cước/biểu giá, SQLite v3, các màn kỹ thuật GPS/đồng hồ, các bộ proof Dart/Python/Kotlin/Android 14 Emulator. **Chưa có** dịch vụ GNSS production duy nhất, ACK production bền vững cuối-đầu, toàn bộ bảy màn cuối, bản đồ 2D/3D runtime, VietQR đã kiểm chứng bằng ngân hàng, Android vật lý, signed ARM64 release, hay audit phí 30 ngày.

## 3.2. Yêu cầu cứng không được thay đổi

1. **Zero Paid API:** mục tiêu 0 USD/tháng cho 1, 50 và 100 người dùng chạy 30 ngày (720, 36.000, 72.000 giờ-người). Không mở Google Billing, Google Maps/Navigation/Places/Routes/Directions/Roads/Speed Limits/Map Tiles tính phí, không trông chờ miễn phí vượt quota, không đăng ký dịch vụ trả tiền khi chưa phê duyệt. CI Zero Cost **chỉ là source gate**, không bảo chứng chi phí/licensing/vận hành 30 ngày.
2. **Nền tảng:** Android first, Flutter/Dart SDK `>=3.11.0 <4.0.0`, Kotlin native, Java 17 trong CI; giữ engine Dart và SQLite hiện tại. Không tự ý port thuật toán tính tiền sang Kotlin hoặc chuyển sang iOS trước.
3. **Bản đồ/GIS:** Việt Nam online/offline, 2D/3D, tòa nhà/công trình 3D, đường và làn đường, mũi tên chuyển động, biển báo và giới hạn tốc độ, tìm POI/địa chỉ, tuyến đường và điểm dừng. GIS/Mapillary chỉ khi có nguồn thực/licensing. Không scrape hàng loạt OSM tile servers, không chép Google imagery, không bỏ attribution, không bịa route/POI/biển báo.
4. **Yêu cầu hiển thị chủ quyền theo chủ dự án:** tên **Biển Đông**, thể hiện **Hoàng Sa và Trường Sa thuộc Việt Nam**, không hiển thị nhãn/ranh giới trái yêu cầu hiển thị đã chốt. Đó là tiêu chí sản phẩm của người dùng; việc kiểm tra dữ liệu, nhãn, style, screenshot chỉ làm khi có renderer/dataset hợp lệ. **Hiện CHƯA KIỂM THỬ**.
5. **GPS và tiền:** chỉ sử dụng GNSS vật lý tin cậy đã kiểm chứng. Không dùng GPS mock, smoothing camera, thời gian wall-clock riêng, dữ liệu stale/sai số lớn, hoặc suy diễn đoạn đứt GNSS để cộng cước. Khi mất GPS, quyền, stream, lifecycle FGS, SQLite hoặc ACK không chắc chắn thì **SUSPENDED, fail closed**. Phục hồi **PAUSED**, chỉ lái xe **RESUME thủ công** với fix mới và route segment mới.
6. **One-owner/one-writer:** mục tiêu một Kotlin `TripLocationService` sở hữu location foreground service + GNSS và một headless Dart `TripSessionWorker` sở hữu một `TaximeterEngine` và một SQLite writer. Native gửi fix có session/generation/sequence, GNSS monotonic nanos và bằng chứng nguồn; SQLite commit toàn bộ route, frozen header/fare, durable fence và ACK trước khi phát phản hồi. Kiến trúc này mới là **ADR/ứng viên**, không phải đường production đã hoàn tất.
7. **Biểu giá:** tài xế xác nhận bảng giá; frozen tariff theo từng chuyến, không dùng `TariffConfig.demo()` hoặc fixture để thu tiền. Phải kiểm độ chính xác distance, waiting/grace, tier, BOT, surcharge, discount, flat fare, rounding, parity và hiệu chuẩn với chuyến kiểm soát trước thương mại.
8. **Lưu trữ/offline và riêng tư:** giữ nguyên SQLite DB `navitaximeter_v1.db` **schema 3**; trips/route/receipt lưu SQLite, confirmed tariff ở SharedPreferences key `navi_confirmed_tariffs_v1`. Bảo vệ receipt bất biến, chống ghi đè/duplicate, backup đồng bộ DB+Prefs và restore hash/preflight/rollback trước bất kỳ migration. Không log/chia sẻ hành trình khách, GPS/địa chỉ, ngân hàng, token, keystore.
9. **Thanh toán:** chỉ tiền mặt và chuyển khoản. VietQR phải là QR hợp lệ sinh từ thông tin ngân hàng đã xác nhận trên thiết bị, test bằng ứng dụng ngân hàng, không QR giả; không thêm payment gateway tính phí.
10. **Giao diện bảy màn tiếng Việt:** (1) Home bản đồ/GPS; (2) tìm địa chỉ/POI; (3) tuyến đường/điểm dừng; (4) dẫn đường + đồng hồ; (5) lịch sử/doanh thu; (6) chi tiết/hóa đơn/VietQR; (7) cài đặt. Thêm bảng giá, xe, ngân hàng, backup, GPS diagnostics. Màu mẫu `#071827`, `#10263C`, `#12334D`, `#00D8F0`, `#28F4FF`, `#FFFFFF`, `#A9C5D3`, `#20DFA5`, `#FFB020`, `#FF5266` (dark navy/cyan). **7 PNG đã tải lên chat hiện tại**, `IMG_4488.png` đến `IMG_4494.png`, mỗi ảnh 863×1822; không ở GitHub, chat mới có thể cần người dùng tải lại khi triển khai UI.
11. **Hiệu năng/camera:** camera modes `FOLLOW_HEADING`, `NORTH`, `FREE_EXPLORE`, `RECENTER`, `TRIP_OVERVIEW`; camera mượt không tác động dữ liệu GNSS tính tiền; mục tiêu khoảng 60 FPS, kiểm ANR, RAM, pin, Android OEM; chưa benchmark thiết bị thật. Android Auto mới ở mức nghiên cứu.
12. **Phát hành và Git:** chỉ nhánh `feature/navitaximeter-foundation` được phép ghi; PR #1 luôn Draft và không merge `main`; TTX tham chiếu chỉ đọc. Chưa ký ARM64 release, chưa bật thu cước khách, chưa Google Billing, chưa tự động migrate dữ liệu thật. Cần chủ dự án phê duyệt riêng sau đủ gate.
13. **QUY TẮC CỨNG VỀ TEST ĐIỆN THOẠI:** chỉ mời chủ dự án thử khi đã xác minh APK/SHA/run, đúng nút/màn đang có, mô tả từng bước, kết quả PASS/FAIL/NOT TESTED, bằng chứng che thông tin riêng và cách gửi lại AI. Không mặc định có PC/ADB. **Đọc nguyên văn Phụ lục A** và https://github.com/ThanhTaxiXanh/NaviTaxiMeter/blob/feature/navitaximeter-foundation/docs/QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md . Quy tắc này bắt buộc trong các mục **3.2, 3.9, 3.10**.

## 3.3. Kiến trúc hệ thống, module, SDK, dữ liệu

### 3.3.1. Đường runtime hiện hữu (không phải single-owner production)

```text
Flutter UI (5 tab kỹ thuật: Trạng thái / Bảng giá / GPS thử / Phòng thử / GPS nền)
  |-- ConfirmedTariffStore -> SharedPreferences (navi_confirmed_tariffs_v1)
  |-- GPS preview -> Geolocator stream (không tính cước)
  |-- GPS lab -> MeteredTripCoordinator -> Dart TaximeterEngine
  |                                  -> TripRepository / sqflite
  |                                  -> navitaximeter_v1.db, SQLite v3
  +-- MainActivity MethodChannel -> LocationOwnerRegistry (lease trong process)
                               -> LocationSafetyService (native health FGS)
```

`LocationSafetyService` kiểm heartbeat/liveness, lease token và Stop, **không** làm `TripLocationService`, không chuyển route hay ghi money. Preview/Lab còn đường Geolocator riêng; in-process lease chưa được chứng minh chống hai GNSS FGS trên Android vật lý. Không có production worker bảo toàn vòng đời khi Activity chết.

### 3.3.2. Các lớp đã có

- `TaximeterEngine`: tính tiền Dart (base, per-km, long-distance tiers, waiting/grace, flat fare, BOT, phụ thu, giảm giá, rounding), có `forkForCheckpoint()` sao chép cả GPS anchors và trạng thái thời gian để staged commit.
- `MeteredTripCoordinator`: nhận fix đủ tin cậy, fail-closed, pause/recovery/manual resume; **đã sửa copy-on-write** trong chu kỳ này cho `accept`, `_suspend`, `resume`, `finish`, để chỉ publish candidate sau `saveActiveIncremental/completeActive` thành công. Khi DB uncertain thì faulted/suspend và phục hồi từ durable snapshot. `begin` nay gọi transaction nguyên tử `beginActiveWithInitialFix()`.
- `TripRepository`: SQLite v3, một transaction route + active header; `beginActiveWithInitialFix()` atomic start+first route, reject orphan route; `completeActive()` receipt ID/route guard; không được dùng đường legacy `save(record)` kiểu replace để ghi receipt sản phẩm.
- Dart typed `IpcCheckpointGate` ở `lib/src/lab/trip_ipc_contract.dart`: `IpcFence(sessionId,generation)` / sequence / monotonic nanos / typed wire / frozen tariff digest. **Lab contract**, không có native channel thật.
- Kotlin `TripCheckpointProtocol.kt`: pure JVM design, injected fake `AtomicTripCheckpointWriter`, không có Android GPS/SQLite/IPC integration.

### 3.3.3. Database và trạng thái offline

DB app **`navitaximeter_v1.db`**, SQLite **`user_version=3`**: `trips(id,started_at,total_fare,distance_km,payload)`; `active_trip(id=1,payload,updated_at)`; `active_trip_route(sequence,latitude,longitude,recorded_at,accuracy_meters,speed_kmh,segment)`. Không có `checkpoint_fence` hay `checkpoint_ack` production. SharedPreferences confirmed tariff key **`navi_confirmed_tariffs_v1`**. Những bảng ACK/historical chỉ được thêm vào **DB clone test-only**, không có migration v3→v4 trong runtime.

### 3.3.4. Android 14 headless probe đã có bằng chứng riêng

`android_native/HeadlessSqliteProbeService.kt` trong **debug-only generated Android** sở hữu FlutterEngine độc lập Activity, chạy Dart entrypoint `headlessSqliteProbeMain`, dùng sqflite và DB **`navitaximeter_HEADLESS_PROBE_ONLY.db`** chỉ chứa counter. Test Android emulator API 34 thực thi instrumented test, assert XML, readback, lifecycle teardown/callback fence. Run `43758959240` SUCCESS. **Service này không phải FGS GNSS production, không tính tiền hay ghi app trip DB.**

### 3.3.5. Thiết kế production ứng viên, chưa hiện thực

```text
Android Activity -> tài xế xác nhận START/RESUME
  -> Kotlin TripLocationService (duy nhất GNSS + location FGS; CHƯA CÓ)
  -> verified physical fix + sessionId/generation/seq/elapsedRealtimeNanos
  -> IPC typed/fenced/timeout (CHƯA CÓ nối Kotlin-Dart production)
  -> service-owned headless Dart TripSessionWorker (CHƯA CÓ)
  -> frozen driver-confirmed tariff + cloned TaximeterEngine
  -> một sqflite transaction: route + meter/header + durable fence + ACK ledger
  -> COMMIT + đọc lại checkpoint identity
  -> post-COMMIT ACK -> UI/native chỉ thấy committed state
```

Nếu headless Dart worker không sống qua lifecycle/OEM, **dừng an toàn**, không tự port engine sang Kotlin, không auto resume/bù tiền. Thiết kế và tradeoffs ở `docs/ISSUE_3_SINGLE_OWNER_WRITER_ADR_DRAFT.md`.

### 3.3.6. Các proof phải phân biệt rõ

- **Python sqlite3:** 12 atomic transaction tests trong `DISPOSABLE_TEST_ONLY.db`, không phải Android SQLite writer.
- **Flutter FFI:** clone v3/v4 schema proposal và checkpoint ACK proof; chạy DB tạm, không chạm dữ liệu tài xế.
- **Unified test-only Dart worker:** `test/support/issue3_unified_checkpoint_writer.dart` tích hợp metadata IPC, immutable fixture, `forkForCheckpoint`, route+frozen money/header+fence+ACK+history trong một sqflite COMMIT; callback ACK sau commit. Clone chỉ test; no physical GNSS.
- **Historical integrity chain:** `test/support/issue3_historical_ack_chain.dart` kiểm tra toàn bộ checkpoint/ACK/frozen tariff/history, không chỉ điểm cuối; SHA256 không có khóa nằm trong DB **không chống người sửa lại toàn bộ DB**.
- **Coordinator copy-on-write + atomic BEGIN:** mã thực tại `lib/src/core/...` và `lib/src/data/...` được CI PASS trong môi trường synthetic v3 DB, **chưa đủ để cấp phép commercial** và chưa có durable generation fence production.
- **Dart wire bridge mới:** `test/support/issue3_service_ack_wire_bridge.dart` nhận `IpcProposal.toWire/fromWire`, xếp hàng toàn chuỗi commit → readback durable fence/route/ACK/history/header → phản hồi `IpcAck.toWire`; 9 tests gồm concurrency/replay/stale generation/forged ACK/delayed ACK/lost ACK-after-COMMIT→PAUSED. **Chỉ Dart test, không có Kotlin MethodChannel**.
- **SDK/runtime:** geolocator `^14.1.2`, geolocator_android `^5.2.1`, sqflite `^2.4.2+1`, path `^1.9.1`, shared_preferences `^2.5.6`, crypto `^3.0.8`; dev `flutter_test`, `sqflite_common_ffi ^2.4.5`, `sqlite3 3.8.0`, Flutter stable và Java 17 trong CI.
- **Bản đồ:** chưa có runtime map renderer/tiles/POI/routing/lane/3D/GIS/Mapillary. Google/MapLibre/OSM chỉ đang cân nhắc kèm điều kiện chi phí và bản quyền; không tự nhận đã tích hợp.

## 3.4. Công việc hoàn thành, trạng thái kiểm chứng

### 3.4.1. Đã viết và CI được xác minh trên SHA `55c1c62`

- Lõi Dart meter/biểu giá/route/receipt, SQLite v3, đồng bộ active session theo transaction, checksum/duplicate guards và các test cũ.
- Test-only `IpcCheckpointGate` + FFI clone, Python atomic proof, immutable staged fare, unified worker và full historical chained ACK.
- **Lượt 3/7:** chain toàn lịch sử ACK trên disposable clone, thêm injection sửa checkpoint cũ và kiểm tra rollback. Commit chính `74faf0f...`; Foundation FULL PASS ở HEAD `70112ef...`, run `43748823343`, ZeroCost PASS.
- **Lượt 4/7:** copy-on-write coordinator trong mã feature, fault injection các đường accept/suspend/resume/finish, commit kiểm chứng `eec648499f5e1509ba4bdd2640f36fd3652f008f`, Foundation FULL PASS run `43751413186` và ZeroCost PASS.
- **Lượt 5/7:** `beginActiveWithInitialFix()` atomic initial header+route, chặn route mồ côi, kiểm tra timestamp/segment; tests mất ACK, concurrent start/rollback. SHA `4175d86239efba4b5d55092376770d886d27ee8a`; Foundation FULL PASS run `43754959417`, ZeroCost run `43754959918` PASS.
- **Lượt 6/7:** native-like typed wire → Dart clone readback ACK test harness và 9 Dart tests, code commits `0d391b4`, `473867f`, `fc79162`, docs/handoff commit `55c1c62`. **Tại chính SHA `55c1c62`**, Foundation run `43758959240` **FULL SUCCESS**: Kotlin JVM + Python tests + Flutter analyze/test/build DEBUG + Android14 emulator executed/verified; Zero Cost run `43758959319` **SUCCESS**.
- **Lượt 7/7 này:** chỉ rà lại nguồn/CI, tạo bản bàn giao và cập nhật docs; **không** mở tính năng mới, không merge, không chạy migration.

### 3.4.2. Đã viết nhưng CHƯA chứng minh ở Android production/khách thật

- Full Kotlin→Dart native channel, một `TripLocationService` FGS thật, single service-owned worker và durable ACK ledger **trong app DB thật**: **CHƯA CÓ**.
- Bảy màn mockup hoàn thiện, bản đồ online/offline 2D/3D, GIS/POI/routing, biển báo/giới hạn, VietQR bank app validated, backup+migration v4 thật: **CHƯA ĐẠT**.
- Android vật lý 11–16, OEM Home/lock/Doze/kill/reboot, 30-day zero-cost audit, signed ARM64 release, parity tiền trên thực địa: **NOT TESTED**.

## 3.5. Công việc đang triển khai và điểm tiếp nối chính xác

**Ưu tiên P0 = Issue #3, vẫn OPEN.** Lần viết code gần nhất là `test/support/issue3_service_ack_wire_bridge.dart` và `test/issue3_service_ack_wire_bridge_test.dart`. Đã test qua Dart/FFI clone đúng SHA, **không nối Kotlin**. `docs/ISSUE_3_SERVICE_ACK_WIRE_BRIDGE_TEST_ONLY.md` ghi các bất biến. Bước tiếp nối KHÔNG phải viết lại các proof đã PASS mà là:

1. Xác minh feature HEAD sau commit tài liệu bàn giao và hai workflow **theo đúng SHA**. Nếu docs-only run chưa xong, ghi PENDING, không gán SUCCESS của code SHA cũ.
2. Review `android_native/TripCheckpointProtocol.kt` và service debug probe; thiết kế test-only native Kotlin→Dart wire dispatch với typed fence/timeout/lifecycle (có actual instrumented Android emulator test), **chưa dùng GPS giả để thu cước**.
3. Chứng minh duy nhất một owner native FGS + một Dart worker SQLite writer; khóa đường UI/Lab/Preview và legacy để không double-write/subscribe GNSS trong mode production; có test concurrency/process recreation/ack stale.
4. Thiết kế backup+restore DB v3 và confirmed Prefs tại cùng consistency boundary; chạy v3→v4 **trên clone**, test giữ receipt/route/tariff/rollback. KHÔNG auto migrate DB người dùng.
5. Khi có APK/test path thật và được phê duyệt, issue #2 Android physical theo **Phụ lục A**. Nếu chưa có đúng artifact/nút, `CHƯA THỂ TEST`.

Không khởi động song song các feature UI/map/billing khi issue #3 chưa được khép an toàn.

## 3.6. Lỗi đã sửa và vấn đề còn mở

**Đã sửa và có CI:** lỗi kiểm tra duplicate GPS sequence khác nội dung; staged mutation trước COMMIT trong bốn đường coordinator; khởi tạo session trong hai transaction; route orphan bị xoá; historical ACK chỉ kiểm điểm cuối; delayed/lost ACK test wire bridge. Các lỗi thời kỳ cũ như emulator XML verifier path và Kotlin debug bootstrap đã có fix/CI.

**Còn mở/rủi ro cần tránh:**

- **R1, chưa có production GNSS/FGS owner:** thiết kế native service và OS lifecycle chưa có, preview/lab và native health service không chứng minh cùng một owner trên thiết bị thật.
- **R2, durable ACK production chưa có:** database runtime v3 không có fence/ACK/history; user-visible state chỉ được tính theo one-writer, lifecycle race, callback lost cần proof native thật.
- **R3, unknown commit:** test mô phỏng callback loss và PAUSED; chưa chứng minh kill process thật, power loss, fsync, storage full, corruption WAL/SQLite busy trong thiết bị thực.
- **R4, beginActiveWithInitialFix() chưa có immutable session fence bền vững:** atomic v3 begin **không thay thế** protected v4 generation/ACK production.
- **R5, DB backup/prefs:** v3→v4 migration chưa được chấp thuận và chưa giữ consistency DB/Prefs; không làm trên app DB thật.
- **R6, chi phí/license:** source gate PASS không bằng hợp đồng 0 USD; 1/50/100 × 30 ngày chưa đo thực tế. Không dùng paid SDK ngoài ý muốn.
- **R7, sản phẩm:** bảy màn UI, map/tiles/POI/routing/sovereignty labels, QR bank, motorized camera, 60FPS, pin và signed release chưa được kiểm nghiệm.
- **R8, tiền:** synthetic tariff và GPS proof không tương đương hiệu chuẩn thực địa; phải đối chiếu rounding/tiers/distance độc lập và làm rõ mọi trường hợp fail closed.

**Không có Flutter test FAIL chưa xử lý tại baseline SHA `55c1c62`.** Nhưng không kết luận mọi bug đã hết và không nhận kết quả CI của docs-only HEAD mới nếu chưa thực sự chạy.

## 3.7. Mã nguồn, tệp quan trọng, quy trình build

**Repo:** https://github.com/ThanhTaxiXanh/NaviTaxiMeter. Chỉ ghi `feature/navitaximeter-foundation`, PR #1 Draft.

**Engine / data / UI:** `lib/main.dart`, `lib/src/core/taximeter_engine.dart`, `lib/src/core/metered_trip_coordinator.dart`, `lib/src/core/location_tracking_policy.dart`, `lib/src/data/trip_repository.dart`, `lib/src/data/trip_session_snapshot.dart`, `lib/src/data/tariff_codec.dart`, `lib/src/domain/confirmed_tariffs.dart`, `lib/src/domain/trip_record.dart`, `lib/src/domain/trip_route_point.dart`, `lib/src/ui/gps_lab_page.dart`, `lib/src/ui/gps_preview_page.dart`, `lib/src/ui/tariff_management_page.dart`, `lib/src/ui/safety_service_page.dart`.

**Android:** `android_native/MainActivity.kt`, `LocationSafetyService.kt`, `LocationOwnerRegistry.kt`, `TripCheckpointProtocol.kt`, `HeadlessSqliteProbeService.kt`, `HeadlessProbeCallbackFence.kt`, `HeadlessSqliteProbeInstrumentedTest.kt`, Kotlin JVM tests. Generated Android skeleton trong CI dùng `flutter create` + `tool/bootstrap_android.py`; phần headless probe là debug only.

**Test/lab mới:** `lib/src/lab/trip_ipc_contract.dart`; `test/support/issue3_sqflite_clone_writer.dart`, `issue3_staged_fare_checkpoint.dart`, `issue3_unified_checkpoint_writer.dart`, `issue3_historical_ack_chain.dart`, `issue3_service_ack_wire_bridge.dart`; `test/issue3_unified_checkpoint_test.dart`, `test/issue3_coordinator_copy_on_write_fault_test.dart`, `test/issue3_service_ack_wire_bridge_test.dart`; `test/trip_repository_ffi_test.dart`, `test/metered_trip_coordinator_test.dart`, Kotlin `TripCheckpointProtocolTest.kt`, Python `tool/test_checkpoint_sqlite_contract.py`, `tool/test_v3_clone_migration_proof.py`.

**CI / scripts:** `pubspec.yaml`, `.github/workflows/flutter-foundation.yml`, `.github/workflows/zero-cost-gate.yml`, `tool/bootstrap_android.py`, `tool/check_zero_cost_policy.py`, `tool/verify_apk_manifest.py`, `tool/verify_android_probe_results.py`, `tool/checkpoint_sqlite_contract.py`, `tool/v3_clone_migration_proof.py`.

**Docs:** `docs/QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md`, `docs/AI_HANDOFF_STATE.md`, `docs/ISSUE_3_SINGLE_OWNER_WRITER_ADR_DRAFT.md`, `docs/TRIP_LOCATION_SERVICE_CONTRACT.md`, `docs/HEADLESS_SQLITE_PROBE_DEBUG_ONLY.md`, `docs/ISSUE_3_UNIFIED_TEST_ONLY_CHECKPOINT_PROOF.md`, `docs/ISSUE_3_HISTORICAL_ACK_CHAIN_TEST_ONLY.md`, `docs/ISSUE_3_P2_COW_COORDINATOR_DRAFT.md`, `docs/ISSUE_3_SERVICE_ACK_WIRE_BRIDGE_TEST_ONLY.md`. Các docs cũ là lịch sử, không lấy SHA cũ làm HEAD hiện tại.

**Dữ liệu và ảnh:** `navitaximeter_v1.db` schema v3 + confirmed tariff prefs (không nằm repo); DB test/clone riêng không được dùng làm app. `IMG_4488.png`…`IMG_4494.png` do người dùng tải lên chat, **không Git tracked**, chat mới có thể cần đính kèm lại. Không có tiles/bản đồ offline hoặc tài khoản ngân hàng/GPS thật trong repo.

**Lệnh tham khảo trên máy có Flutter stable, Java 17, Android SDK và Python 3 (không yêu cầu chủ dự án phải có PC):**

```bash
git clone https://github.com/ThanhTaxiXanh/NaviTaxiMeter.git
cd NaviTaxiMeter
git checkout feature/navitaximeter-foundation
flutter create . --platforms=android --org vn --project-name navitaximeter
python3 tool/bootstrap_android.py
python3 tool/bootstrap_android.py --check
python3 -m unittest discover -s tool -p 'test_*.py' -v
flutter pub get
(cd android && ./gradlew :app:testDebugUnitTest --no-daemon)
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
flutter build apk --debug
python3 tool/verify_apk_manifest.py
```

Android 14 instrumented headless test cần emulator/KVM và Gradle `connectedDebugAndroidTest`, theo workflow GitHub; không đồng nhất build test APK với đã thực thi instrumented tests. **Không phát hành/không cài với khách**.

## 3.8. Quyết định kỹ thuật đã thống nhất

- Ưu tiên giữ Flutter/Dart engine tiền và sqflite; Android Kotlin đảm nhận location/FGS liveness/ownership theo Android policy. Mục tiêu one Kotlin GNSS owner + one headless Dart writer, nhưng vẫn là **ứng viên thiết kế cần kiểm chứng**. Không tự đổi Kotlin fare engine.
- Đảm bảo **post-SQL-COMMIT ACK** có fence session/generation/seq và frozen tariff; duplicate replay giống hệt idempotent, khác dữ liệu fail closed, stale/gap/mock reject, interrupted recovery PAUSED/manual RESUME, không backfill.
- SQLite v3 của ứng dụng giữ nguyên, no auto-v4; các bảng durable fence/ACK hiện chỉ trong test clone; backup DB/Prefs cần chứng minh trước migration.
- Không ghi nhận một nguồn GNSS camera smoothing/map hoặc mock làm thật. Không tăng tiền theo wall-clock nếu vị trí/FGS không được xác minh.
- Chỉ tiền mặt + chuyển khoản/VietQR hợp lệ; Zero Paid API; map VN 2D/3D + bản quyền/chủ quyền theo yêu cầu hiển thị; 7 mockup tiếng Việt; Android trước; chỉ release khi đủ kiểm thử và chủ dự án phê duyệt.
- PR #1 tiếp tục Draft, `main`/TTX không thay đổi; commit riêng chỉ trên feature. Không tự ý thực hiện lựa chọn khác khi chưa kiểm chứng phương án hiện tại.

## 3.9. Kế hoạch tiếp tục theo ưu tiên và tiêu chí

| Ưu tiên | Việc / thành phần | Bước thực hiện | Bằng chứng/tiêu chí hoàn thành |
| --- | --- | --- | --- |
| P0 | Xác minh HEAD sau docs handoff | Đọc lại SHA feature, PR #1, issues #2/#3, workflows theo SHA | `main`/TTX không đổi, không lấy CI cũ để gán PASS mới |
| P1 | Native→Dart test transport, issue #3 | Instrumented **debug-only** JNI/MethodChannel bridge giữa Kotlin protocol và Dart service-owned worker; timeout/cancellation/token/teardown, chỉ DB clone | Log/test XML thật trên Android emulator, ACK sau COMMIT/readback, stale callback ignore, không route/GPS giả làm thật |
| P2 | Single owner/writer safety | Kiểm thử OS FGS owner độc quyền, kill/rotation/Home/lock/Doze, chặn UI/Preview/Lab concurrent writer | Chỉ một subscription GNSS/authority; lỗi PAUSED và không double fare |
| P3 | Backup + migration trên clone | Snapshot v3 DB + confirmed Prefs, hash và consistency, clone candidate v4 fence/ACK, restore/rollback | Receipt/tariff/route không mất; không tự thay DB khách |
| P4 | Fault/ACK real Android | Worker service-owned foreground; SQLite busy, duplicate, after COMMIT lost callback, process kill, power-loss limits | Từng case có PASS/FAIL dựa trên evidence, không coi emulator là Android vật lý |
| P5 | Thiết bị Android vật lý Issue #2 | Chỉ khi đã có đúng APK, SHA và nút thử; làm Android 11–16/OEM nếu có; Home/lock/revoke/Doze/Stop/reboot | **Tuân thủ toàn văn Phụ lục A**: hướng dẫn từng nút, PASS/FAIL/NOT TESTED, ảnh/video đã che và cách gửi AI; nếu chưa đủ: CHƯA THỂ TEST |
| P6 | Sản phẩm/UI/map/VietQR/cước | Hoàn thành 7 mockups, GIS/MapLibre/OSM khi hợp pháp, map chủ quyền/nhãn; calibration tariff, VietQR kiểm app ngân hàng | Screenshot nguồn, dữ liệu có license, hành trình và tiền độc lập, không bịa địa chỉ/QR |
| P7 | Năng lượng/chi phí và phê duyệt | Đo Android thật, API license/0 USD 1/50/100 người dùng × 30 ngày, signed ARM64 update | Có chứng cứ thực tế, owner explicit approval mới phát hành/merge |

**Nhắc quy tắc thử điện thoại:** Phụ lục A / `docs/QUY_TAC_CUNG_BAN_GIAO_7_LUOT.md` là bắt buộc ở P5; không có APK hoặc tính năng thì đánh dấu **CHƯA THỂ TEST**, không yêu cầu người dùng dò nút giả định, không bắt dùng ADB và không tự công nhận PASS.

## 3.10. Chỉ thị bắt buộc cho AI tiếp quản

1. **Đọc toàn bộ tài liệu này, từ 3.1–3.10 đến Phụ lục A, cùng toàn văn quy tắc cứng; không chỉ đọc phần tóm tắt.**
2. **Chat mới:** đặt `AI_REPLY_COUNT=0`; mỗi lượt assistant hoàn tất +1, đánh dấu n/7; lượt 7 tạo bản bàn giao đầy đủ, lặp 14,21... nếu ở cùng chat. Không yêu cầu chủ dự án nhắc lại thông tin đã có.
3. Kiểm GitHub **live**: feature HEAD, Foundation/ZeroCost đúng SHA, PR #1 Draft, issues #2/#3 OPEN, main/TTX read-only. Chỉ ghi `feature/navitaximeter-foundation`, không merge main, không sửa TTX.
4. Nhận diện các bằng chứng riêng: Python SQLite proof ≠ Flutter FFI clone ≠ Kotlin JVM fake writer ≠ Android14 emulator headless DEBUG ≠ native GNSS thật ≠ cước production. **Code SHA `55c1c62` có Foundation và ZeroCost FULL SUCCESS**, nhưng nếu có docs commit mới phải tra workflow của docs HEAD.
5. Tập trung Issue #3 **native↔Dart IPC/FGS ownership/one production writer** theo ADR cần proof. Không làm lại test-only unified/history/bridge/atomic begin đã PASS trừ khi có lỗi có chứng cứ; không bật paid APIs/map thương mại.
6. Mọi lỗi GPS, mất ACK, callback trễ, DB busy/killed process phải **SUSPENDED hoặc recovery PAUSED**, no backfill, manual RESUME với GNSS fix mới; không expose money trước COMMIT.
7. Chưa có migration v4 hoặc backup đồng bộ DB+Prefs, không tự sửa/copy DB thật của tài xế. Không sử dụng GPS mock, QR giả hay tiền demo để báo hệ thống đã chạy.
8. **Issue #2 vẫn OPEN/NOT TESTED Android physical**. Khi cần kiểm thử điện thoại, **bắt buộc tuân theo toàn văn Phụ lục A**, đúng APK/commit SHA/run đã kiểm chứng, từng nút, checklist PASS/FAIL/NOT TESTED, bằng chứng đã che thông tin cá nhân và cách gửi lại trong chat. Không có APK/nút đúng thì **CHƯA THỂ TEST**, không giả định có PC/ADB.
9. Giữ bảo mật token/keystore/tọa độ cá nhân/khách/ngân hàng; không đưa file nhạy cảm vào GitHub issues. Giữ giới hạn Zero Paid API, không Google Billing, không signed release, không thu cước khách.
10. Duy trì `docs/AI_HANDOFF_STATE.md` và bản handoff độc lập của chu kỳ; nếu không thể xác minh một chi tiết thì ghi **CHƯA XÁC MINH**, không bịa. Bàn giao tiếp theo ở lượt 7 trong chat mới.

### Lệnh khởi động chat mới (sao chép cùng bản Markdown này)

> Tiếp quản dự án **NaviTaxiMeter** từ **BẢN BÀN GIAO BẮT BUỘC LƯỢT 7/7 ngày 16/11/2026**. Đọc hết mục 3.1–3.10 và toàn văn Phụ lục A. Reset `AI_REPLY_COUNT=0`. Chỉ viết nhánh `feature/navitaximeter-foundation`, không merge main, không sửa TTX, không bật Google Billing/paid API, không thu cước khách. Mốc code `55c1c62f9b8b938df34f312a350b7474a4dd073d` đã có Foundation run `43758959240` FULL SUCCESS và ZeroCost run `43758959319` SUCCESS, nhưng phải xem lại HEAD và CI live. PR #1 Draft; issue #3 một GNSS owner/one writer chưa hoàn thành; issue #2 Android physical NOT TESTED. Ưu tiên test-native Kotlin↔Dart service-owned IPC và durable ACK proof; mọi phone test phải có APK/SHA/run, từng nút, PASS/FAIL/NOT TESTED, bằng chứng che riêng tư và cách gửi AI. Không bắt chủ dự án nhắc lại thông tin đã có. Lượt 7 tiếp theo lại bàn giao đầy đủ.

---

## PHỤ LỤC A. TOÀN VĂN QUY TẮC CỨNG MỤC 9: KIỂM THỬ/KIỂM CHỨNG TRÊN ĐIỆN THOẠI

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

## PHỤ LỤC B. TÌNH TRẠNG GATE ĐIỆN THOẠI VÀ MẪU TRẢ LỜI

**Issue #2: OPEN / NOT TESTED PHYSICAL.** Mặc dù CI có APK DEBUG và Android14 emulator probe PASS, hiện chưa có bằng chứng APK theo đúng kịch bản GNSS/FGS production, các nút test được xác thực, checksum SHA-256 của artifact được chia sẻ cho tài xế, và chuỗi thao tác an toàn tương ứng. **CHƯA THỂ TEST điện thoại theo quy tắc mục 9; không yêu cầu chủ dự án cài một APK không xác thực.**

Khi cổng đủ bằng chứng, AI phải lập từng ca thực tế theo mẫu: `Mã ca | mục tiêu/rủi ro | đúng commit + APK SHA256 + link artifact | model/Android/OEM | quyền vị trí | nút/bước bấm chính xác | PASS khi | FAIL và điều kiện dừng khi | ảnh/video cần chụp đã che | cách gửi AI | PASS/FAIL/NOT TESTED`. Trường hợp thiếu nút: dừng, NOT TESTED, không đoán. Mọi ảnh/video che tọa độ, nhà, hành trình khách, tài khoản, thông báo, token, key. Chỉ nhận PASS khi AI đối chiếu bằng chứng rõ.

**KẾT LUẬN BÀN GIAO:** CI của code SHA `55c1c62` toàn PASS (Foundation + ZeroCost + Android14 debug-only headless SQLite); Issue #3 native owner + durable production ACK và Issue #2 Android thật còn mở; app chưa được phép thu cước. Sau khi tài liệu được commit, verify HEAD/CI mới riêng. **Trạng thái bàn giao: 7/7 · AI_REPLY_COUNT = 7.**