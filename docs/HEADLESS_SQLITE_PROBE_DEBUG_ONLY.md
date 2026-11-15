# Issue #3 — thử nghiệm headless FlutterEngine + SQLite tách biệt (DEBUG ONLY)

**Ngày:** 15/11/2026. **Loại:** code spike, không thu cước, không phải production writer, không phải kết quả thử Android vật lý. **Issue #2 vẫn là blocker.**

## Mục tiêu và ranh giới

Tìm hiểu liệu *một FlutterEngine do Android Service sở hữu*, độc lập với Activity Flutter UI, có đăng ký được plugin `sqflite`, thực hiện transaction và đọc lại DB sau khi đóng/mở kết nối hay không. Thử nghiệm này **không** dùng GPS, LocationManager, FGS, `TripLocationService`, `TripRepository`, `TaximeterEngine`, hóa đơn, bảng giá hoặc bản đồ. Không được dùng kết quả của thử nghiệm để cho phép thu cước.

- `android_native/HeadlessSqliteProbeService.kt` là **bound Service riêng cho debug/instrumentation**, không phải location FGS. Bootstrap copy vào generated `android/app/src/debug/kotlin/vn/navitaximeter/` và thêm service `android:exported="false"` chỉ trong generated `android/app/src/debug/AndroidManifest.xml`. Không có trong manifest/source set chính để phát hành release.
- `lib/main.dart` chỉ thêm `@pragma('vm:entry-point') headlessSqliteProbeMain` để FlutterEngine chạy một entrypoint headless. Không thêm nút UI hoặc subscriber GPS.
- `lib/src/lab/headless_sqlite_probe.dart`: chỉ cho phép một DB tên `navitaximeter_HEADLESS_PROBE_ONLY.db`, bảng `headless_probe(id,count)`, chạy `await db.transaction(...)`, đóng SQLite, mở lại `readOnly` và trả kết quả đọc. Không mở `navitaximeter_v1.db` và không có route/receipt/fence. Kết quả này là **probe readback**, *không* phải ACK production và không đo fsync.
- `android_native/HeadlessSqliteProbeInstrumentedTest.kt`: bind service không phụ thuộc Activity, chờ Dart worker `ready`, gọi `writeAndRead`, kiểm tra `probeOnly=true`, `reopened=true`, `passengerFareEnabled=false`, tên DB đúng. Test thuộc generated `src/androidTest`, chỉ chạy khi có Android emulator/device.
- `test/headless_sqlite_probe_test.dart`: Flutter/sqflite_common_ffi test trên thư mục tạm; từ chối tên DB sản xuất, kiểm tra transaction + mở lại 2 lần. Đây là FFI unit test, **không** chứng minh engine Service hay Android SQLite trên máy thật.
- `tool/bootstrap_android.py`, `tool/test_bootstrap_android.py`: idempotent debug-only wiring, kiểm tra không lẫn vào manifest chính, Kotlin test dependencies và runner; `.github/workflows/flutter-foundation.yml` bổ sung `:app:assembleDebugAndroidTest` **chỉ biên dịch** test APK.

## Lệnh kiểm chứng tại GitHub Actions

```sh
flutter create . --platforms=android --org vn --project-name navitaximeter
python3 tool/bootstrap_android.py
python3 tool/bootstrap_android.py --check
python3 -m unittest discover -s tool -p 'test_*.py' -v
flutter pub get
(cd android && ./gradlew :app:testDebugUnitTest --no-daemon)
(cd android && ./gradlew :app:assembleDebugAndroidTest --no-daemon)
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
flutter build apk --debug
python3 tool/verify_apk_manifest.py
```

Sau khi có emulator/máy Android thử, mới có thể chạy `(cd android && ./gradlew :app:connectedDebugAndroidTest --no-daemon)`. Khi đó cần lưu thiết bị/API/run SHA và log đã loại PII. Build/instrumentation test compilation **không tương đương execution**. Bound Service không tương đương location FGS liên tục khi Home/lock/Doze/OEM.

## Các cổng chưa đạt, không được tự động bỏ qua

1. Xác minh plugin registration headless trên Android thật bằng instrumented test. Thực hiện lifecycle start/stop, disconnect, Home/lock và process kill trên thiết bị, ghi FAIL/NOT TESTED trung thực.
2. Nếu service-owned engine chứng minh chạy ổn: thiết kế *một* native `TripLocationService` sở hữu GNSS và *một* Dart serialized writer duy nhất, không cho UI/legacy `TripRepository.save()` ghi production song song.
3. Cần staged/immutable candidate meter, persistent sessionId/generation/sequence/fence, unique ACK ledger, route + header trong transaction thực trên SQLite app, ACK chỉ **sau COMMIT**; post-commit-lost-ACK recovery PAUSED.
4. Backup/preferences parity v2/v3, migration v3→v4 trên bản sao và rollback; chưa sửa DB production. Issue #2 Android thực vẫn OPEN.
5. Không merge main, sửa TTX, bật Google Billing/API phí hoặc thu cước khách.

**Bằng chứng khi viết tài liệu:** đã commit nguồn thử nghiệm; các workflow đang được đối chiếu, chưa ghi nhận PASS từ Android physical device và chưa có production SQLite ACK.
