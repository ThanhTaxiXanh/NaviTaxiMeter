# Issue #3 P3: Native-like wire to Dart ACK readback bridge (TEST ONLY)

**Ngày** 16/11/2026 (ICT). **Nhánh** feature/navitaximeter-foundation. **Trạng thái**: source/test-only bridge, not an actual Android Kotlin→Dart channel.

## 1. Tại sao thêm proof này

Trước đây `TripCheckpointProtocol.kt` là pure Kotlin và dùng fake `AtomicTripCheckpointWriter`, chưa kết nối Flutter. `IpcCheckpointGate` Dart đã có typed `IpcProposal.toWire/fromWire` và post-writer `IpcAck.toWire`, còn `UnifiedTestOnlyWorker` ghi một transaction SQLite clone chứa synthetic staged Dart fare + route + fence + ACK + chained history. Khoảng cách còn lại: kiểm tra *phản hồi trên ranh giới message* có đối chiếu lại bằng chứng durable sau COMMIT, và mất ACK ngay sau khi ghi nhưng trước khi native nhận được.

## 2. Mã được thêm

- `test/support/issue3_service_ack_wire_bridge.dart`: `TestOnlyServiceAckBridge`, serialized queue bao trùm nhận typed wire, `gate.submit`, đọc lại SQLite trong một read transaction, callback giao ACK. Kiểm tra một durable fence `session_id/generation/last_sequence/last_gnss_nanos`, row ACK `sample_digest/checkpoint_id`, route, history và `active_trip` header `routeCount` cùng exact committed header text. Nếu readback hoặc callback giao thông điệp lỗi thì `markAckUnknown()`, PAUSED, không tự retry.
- `test/issue3_service_ack_wire_bridge_test.dart`: FFI sqflite test chạy trên disposable v3-shaped → v4-dry-run clone, không đọc driver DB/prefs.

## 3. Trường hợp kiểm thử

1. Wire proposal từ `IpcProposal.toWire` chỉ nhận `trip.ack.v1` sau khi SQLite có ACK, route và fence tương ứng.
2. Tám proposal song song được xử lý theo sequence, không để checkpoint sau ghi đè readback của ACK trước.
3. Tám replay giống nhau chỉ ghi một route, ACK và history.
4. Generation cũ bị từ chối, không ảnh hưởng session hợp lệ.
5. Replay cùng sequence khác nội dung làm gate PAUSED.
6. ACK ID bị thay ngoài DB bị từ chối trong durable readback.
7. Callback giao ACK bị giữ: route và ACK đã COMMIT nhưng reply vẫn chưa tới client.
8. Callback giao ACK mất **sau COMMIT**: gate PAUSED; không ghi đôi; mở lại DB và recovery PAUSED, không tự RESUME.
9. Wire sai type bị từ chối trước writer.

**Quy tắc chứng cứ:** PASS chỉ áp dụng nếu workflow Foundation của SHA HEAD chứa code mới hoàn thành `flutter analyze` và `flutter test`. Zero Cost Source Gate không thay thế bằng chứng runtime. Emulator headless DEBUG SQLite probe là job riêng, không phải GNSS vật lý.

## 4. Giới hạn và cổng sản phẩm

- Kết nối được mô phỏng **hoàn toàn trong Dart test**, không có `MethodChannel`/native service call thực. Kotlin `TripCheckpointProtocol.kt` vẫn chưa gọi Dart worker hoặc writer SQLite thật.
- Một writer production **chưa tồn tại**: chưa có `TripLocationService` native duy nhất + headless `FlutterEngine` bền vững + durable v4 schema/ACK trên app DB.
- Test vẫn dùng dữ liệu kỹ thuật, không chứng minh GNSS physical provenance hoặc chi phí 30 ngày trên Android 11–16/OEM, reboot/process kill, power-loss/fsync, chống người có quyền viết lại toàn bộ SQLite và hash.
- Chưa backup+migrate confirmed tariff prefs và DB v3 thật, không build APK release hoặc bật thu cước thương mại.
- P2 coordinator copy-on-write và atomic begin ở SQLite v3 phát triển đã có CI baseline code SHA `4175d86239efba4b5d55092376770d886d27ee8a`: Foundation run 43754959417 SUCCESS cả Flutter build-test và Android 14 debug-only headless SQLite probe; ZeroCost run 43754959918 SUCCESS.
- P3 bridge mới cần verify CI theo final HEAD SHA; không dùng PASS của baseline cũ.

## 5. Bước tiếp theo

1. Kiểm CI đúng latest HEAD và sửa Flutter analyzer/tests nếu FAIL.
2. Phát triển native Kotlin service-owned Dart message transport **debug-only / lab**, với GNSS provenance và one-owner verified; không dùng fake positions để thu cước.
3. Thiết kế durable fence và ACK schema v4 chỉ trên **cloned DB** và kiểm thử backup/rollback confirmed prefs trước khi đề xuất production migration.
4. Kiểm chứng Android vật lý Issue #2 theo hướng dẫn đầy đủ APK SHA, nút và từng bước, PASS/FAIL/NOT TESTED, bằng chứng che riêng tư và cách gửi AI, khi có artifact phù hợp. Chưa yêu cầu driver thử ngay.

Không merge main, không sửa TTX-AATaximeter, không Google Billing/paid APIs, không signed release và không thu cước hành khách.
