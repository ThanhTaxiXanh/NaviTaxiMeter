# NaviTaxiMeter · AI_HANDOFF_STATE · 2026-11-15

**Bộ đếm sau lượt AI này: 6/7.** Lượt trả lời tiếp theo là lượt 7/7: BẮT BUỘC lập báo cáo bàn giao ĐẦY ĐỦ và độc lập, gồm mã nguồn đã làm, các tệp liên quan, mọi commit, trạng thái PR/CI, quyết định kỹ thuật, rủi ro, chỗ thiếu, từng bước công việc kế tiếp và trạng thái phê duyệt; đồng thời cập nhật tệp này. Hãy đọc HEAD GitHub để biết commit cuối cùng, không dự đoán.

## Nguồn dự án
- Main repo: https://github.com/ThanhTaxiXanh/NaviTaxiMeter
- Nhánh làm việc: feature/navitaximeter-foundation, PR #1 **Draft**, không merge main.
- Repo tham chiếu ĐỘC LẬP: ThanhTaxiXanh/TTX-AATaximeter @ feature/flutter-taximeter-foundation, nguồn SHA a40c246de6fd3799aaddedce3ed0d3b1d9dd524d, không chỉnh sửa hoặc merge.
- Main Navi repo gốc tại SHA 539ff788b62be69135e5b3ad2c554dca005249a5.
- Các commit tính đến lượt 5: 17fcb86d3a2acf0249a393ad825bee105af3f1b3 (0.1.0+1), f7aac734041d3c6f0a9999c1218352b5f11c1ed2 (0.1.1+2), 0e21de0ed690f49562b9e223fd6d5ef3ce58939a (0.1.2+3), 7b9f46c4db3593cecd6100a74cf3a43bf6336ed2 (0.1.3+4), fa1f9a18021561a2137fdfccb1c92090a5ef5337 (sửa aapt). Mốc CI thành công: https://github.com/ThanhTaxiXanh/NaviTaxiMeter/actions/runs/43703032204.

## Lượt 6 đang thực hiện
- Version 0.1.4+5: riêng một Kotlin `LocationSafetyService` giám sát sức khỏe GPS qua Android LocationManager, START_NOT_STICKY, notification có Stop, chỉ chấp nhận bật từ Activity RESUMED, không đụng tới tiền hay SQLite.
- Flutter tab `GPS nền` hiển thị health status, đếm fix và tuổi monotonic, không hiển thị tọa độ/cước.
- Bootstrap Android copy native MainActivity/Service into generated project, manifest `foregroundServiceType=location` and `exported=false`, no ACCESS_BACKGROUND_LOCATION.
- Compiled APK manifest gate verifies *both* Geolocator service and new Kotlin service.
- Cần xác minh CI của commit lượt 6 sau khi cập nhật GitHub; nếu fail thì sửa ngay và chạy lại. Chưa có device tests.

## Tệp chính
- lib/main.dart, lib/src/ui/gps_preview_page.dart, lib/src/ui/gps_lab_page.dart, lib/src/ui/tariff_management_page.dart, lib/src/ui/safety_service_page.dart
- lib/src/core/taximeter_engine.dart, lib/src/core/location_tracking_policy.dart, lib/src/core/lab_session_safety.dart, lib/src/core/metered_trip_coordinator.dart
- lib/src/domain/confirmed_tariffs.dart, lib/src/domain/trip_record.dart, lib/src/domain/revenue_summary.dart
- lib/src/data/trip_repository.dart, lib/src/data/trip_session_snapshot.dart, lib/src/data/tariff_codec.dart
- android_native/MainActivity.kt, android_native/LocationSafetyService.kt
- tool/bootstrap_android.py, tool/verify_apk_manifest.py, tool/check_zero_cost_policy.py, tool/test_bootstrap_android.py, tool/test_verify_apk_manifest.py
- test/ Dart tests, docs/PHASE2_METER_SQLITE.md, docs/PHASE2_LAB_ANDROID_GPS.md, docs/NATIVE_GPS_SAFETY_SERVICE.md
- .github/workflows/flutter-foundation.yml, .github/workflows/zero-cost-gate.yml

## Quy tắc bắt buộc
- Không tự bật Google Cloud Billing; tuyệt đối không tích hợp paid Places/Routes/Navigation/3D Immersive. Kiểm tra zero-cost bằng mã nguồn chỉ là sơ bộ, không phải bằng chứng hoá đơn $0.
- Không GPS mẫu/hóa đơn giả trong UI sản xuất; các test dùng fix mô phỏng được gắn trong test.
- Chuyến phải dùng bảng giá thực do tài xế xác nhận; GPS thực với kiểm tra chất lượng; SQLite atomic checkpoint; tạm ngừng khi không chắc chắn; không tính cước khi không có GPS.
- Chỉ hỗ trợ cash/chuyển khoản và VietQR theo yêu cầu; 7 mockup UI dark navy/cyan; offline map + route search phải xác minh bản quyền và chủ quyền lãnh thổ trước xuất bản.
- Chưa thử Android thật, không release signing, không chứng nhận đồng hồ taxi, không gộp TTX, không merge main nếu chưa được duyệt. Giai đoạn kế tiếp: test Android máy thật và thống nhất một native trip service owner duy nhất.
- Stress test 1/50/100 tài xế và 30 ngày chưa thực hiện; bản đồ 2D/3D, tìm đường, VietQR & sao lưu chưa xong.
