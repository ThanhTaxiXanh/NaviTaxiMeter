# Giai đoạn 2.4 · Native Android GPS safety service
**Version:** 0.1.4+5 · 15/11/2026 · NHÁNH THỬ, KHÔNG THU CƯỚC

## Mục tiêu
Thử dịch vụ Android location foreground độc lập với vòng đời màn hình Flutter, bằng API GPS do Android cung cấp, không phát hành hóa đơn và không kích hoạt API tính phí.

## Đã triển khai
- Android Kotlin `android_native/LocationSafetyService.kt` (Service + LocationListener). Dùng `LocationManager`, kiểm tra quyền trước khi đăng ký, bỏ vị trí mock/độ chính xác kém, dùng `elapsedRealtimeNanos` để đo tuổi GPS bằng đồng hồ đơn điệu. Không lưu/tải lên/toString tọa độ GPS, không đụng tới SQLite và bộ đếm cước.
- Android Kotlin `android_native/MainActivity.kt`: `MethodChannel vn.navitaximeter/safety_location_service` cung cấp lệnh `start`, `stop`, `status`. Chỉ chấp nhận khởi động khi Activity ở trạng thái RESUMED, đã có quyền vị trí, GPS được bật, quyền thông báo nếu Android 13+. Mã trả `start=true` chỉ nói lệnh đã gửi, không chứng thực dịch vụ thực sự sống; phải đọc lại `status`.
- Dịch vụ thông báo hệ thống có nút Dừng. `START_NOT_STICKY` chặn tự bật lại khi tiến trình bị tiêu diệt.
- Flutter tab `GPS nền` gọi native MethodChannel để xem dịch vụ có còn chạy, số mẫu GPS hợp lệ và thời gian kể từ mẫu gần nhất; KHÔNG hiển thị tọa độ/tiền.
- `tool/bootstrap_android.py` sao chép hai tệp Kotlin vào thư mục Android do `flutter create` tạo, thêm service `android:exported="false"`, `android:foregroundServiceType="location"`, các permission cần thiết. KHÔNG xin `ACCESS_BACKGROUND_LOCATION`.
- `tool/verify_apk_manifest.py` kiểm tra **APK đã biên dịch**: cả Geolocator FGS và dịch vụ Kotlin được khai báo đúng location type, dịch vụ Kotlin không exported, đủ permission, không khóa Google Maps.
- Kiểm thử Python bootstrap và parser service, kiểm thử Flutter trạng thái dịch vụ fail closed; luôn để PR Draft.

## Quyết định kiến trúc
Dịch vụ Kotlin trong phiên này là **health monitor độc lập**. Phòng thử Flutter + SQLite hiện có vẫn tạm dừng khi ứng dụng bị ẩn và KHÔNG dùng monitor này để tính cước. Nguyên nhân: điều kiện hoạt động của FGS và việc Flutter tự tồn tại không bảo đảm có thể ghi quãng đường/kilômét và cước an toàn trong nền. Không được giới thiệu hai dịch vụ này là bộ tính cước hoạt động ngoài màn hình.

## Các giới hạn cần được chủ dự án biết
- Chưa thử máy thật Android 11–16, quyền vị trí gần đúng/chính xác, dừng bằng notification, Home/back, kill, reboot, tắt GPS, doze/OEM.
- Bản debug có thể có 2 foreground location service nếu đồng thời mở Phòng thử Geolocator và Native Monitor. Chỉ dùng từng một khi kiểm nghiệm pin; cần tập trung duy nhất một owner ở giai đoạn sau.
- Không có nền tảng dịch vụ phát sinh hóa đơn, mạng lưới bản đồ, điều hướng, 7 màn hình thiết kế đầy đủ, VietQR, sao lưu tổng hợp hay bản phát hành ký chính thức.
- CI kiểm tra build và manifest nhưng không thể chứng nhận khả năng hoạt động GPS nền, độ chính xác thu cước hoặc hóa đơn API bằng 0 đồng.

## Ma trận kiểm thử trên thiết bị (chưa thực hiện)
| Tình huống | Quan sát cần ghi |
| --- | --- |
| Bắt đầu khi app hiển thị | Hộp xác nhận và notification hiện, health active=true |
| Quay về Home | Native monitor có thể tiếp tục quan sát; không phát sinh tiền/chuyến |
| Mở lại app | Chỉ tuổi GPS mới được coi fresh, mẫu cũ bị stale |
| Thu hồi quyền vị trí hoặc tắt GPS | Dịch vụ không tự cộng cước; cảnh báo/dừng |
| Bấm Dừng ở notification | Notification mất, active=false, hủy callback |
| Force Stop hoặc reboot | Không âm thầm bật lại, không sinh hóa đơn |
| Đổi giờ hệ thống | Tuổi GPS không bị tăng theo giờ đồng hồ |
| Android 14/15/16 | Kiểm tra quy tắc FGS location và quyền đã cấp |
| Máy yếu, pin hạn chế | Ghi nhận bị kill, không lấp khoảng cách GPS |
| Chạy nhiều giờ | Theo dõi pin, bộ nhớ, số fix và leak service |

## Việc kế tiếp
1. Xác minh GitHub Actions + artifact Debug/manifest, xử lý mọi lỗi Kotlin/CI trên nhánh riêng.
2. Test Android thực theo ma trận và thu log vòng đời, tuyệt đối không tự giả định service sống.
3. Thiết kế **một owner duy nhất** chịu trách nhiệm nhận GPS + lưu SQLite + giám sát, có ACK của foreground service. Nếu service/GPS không bảo đảm, tạm ngừng thu cước và khôi phục thủ công.
4. Sau khi ổn định, hoàn thiện 7 mockup, tìm kiếm/tuyến offline, 2D/3D và giao diện VietQR; xác thực giấy phép dữ liệu bản đồ và ranh giới, đảo biển theo yêu cầu.

Nguồn Android chính thức:
- https://developer.android.com/about/versions/14/changes/fgs-types-required
- https://developer.android.com/develop/background-work/services/fgs/restrictions-bg-start
- https://developer.android.com/reference/android/location/LocationManager
