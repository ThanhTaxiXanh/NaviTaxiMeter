# Một chủ GPS duy nhất (liên khóa an toàn thử nghiệm)

**Ngày:** 15/11/2026 · **Trạng thái:** code thử nghiệm, chưa có kết quả CI mới
hoặc thử máy thật khi tài liệu này được soạn.

## Vấn đề nguồn
Phiên trước có ba nơi dùng GPS: Flutter Geolocator Preview, Flutter
Geolocator Lab + SQLite và Kotlin LocationSafetyService. Có thể đồng thời
tồn tại hai Android foreground location services nếu không liên khóa.

## Giao thức owner
- Android quản lý một lease trong `LocationOwnerRegistry.kt`: đúng một
  owner thuộc `preview`, `lab`, `native_safety`; generation/leaseId
  ngăn release cũ mở khóa nhầm service khác. Đây là khóa **trong tiến trình**.
- Preview và Lab phải lấy lease từ `MainActivity` trước khi mở
  `Geolocator.getPositionStream`. Chỉ trả lease sau khi stream đã hủy;
  với Lab, sau khi thực hiện watchdog checkpoint/pause SQLite.
- Safety service phải nhận lease trước `startForegroundService`. Lệnh
  dispatch không phải ACK. `onStartCommand` kiểm tra đúng token, sau đó
  phát heartbeat bằng thời gian monotonic mỗi 3 giây. Flutter yêu cầu
  `acknowledged`, leaseId trùng và `heartbeatAgeMs <= 7000`.
- `GPS_BUSY` từ chối mở FGS thứ hai. Phím dừng notification giải phóng
  native lease qua `onDestroy`; stop có token giúp tránh dừng nhầm lease.
- Preview dừng theo dõi khi ứng dụng rời foreground. GPS Lab vẫn tuân
  theo chính sách tạm dừng trước đó. Kotlin chỉ đếm health/age, không
  truyền tọa độ vào Flutter để thu tiền; `billingEnabled=false`.

## Giới hạn và thử nghiệm bắt buộc
Đây **không** phải service chủ trì chuyến thu cước, không đảm bảo SQLite
transaction chạy nền và không hợp thức hóa thu cước khách. Không tự
resume, không lấp khoảng trống GPS, không tính phí dựa vào health counter.

Kiểm tra trên Android 11-16 thực: Preview → Safety phải GPS_BUSY;
Lab → Safety phải GPS_BUSY; Safety → Preview/Lab phải GPS_BUSY; chuyển
tab liên tục; Home/lock; notification Stop; quyền GPS bị thu hồi; GPS
disabled; Doze/OEM; kill/reboot; đổi giờ; lỗi SQLite; ACK/heartbeat sai
token; không có chồng lấn FGS hay hóa đơn giả. Ghi log và phân loại PASS/FAIL.

Kiểm thử nguồn Python, Dart, build Kotlin và manifest CI chỉ là bằng
chứng tự động; phải chờ kết quả GitHub Actions cho commit chứa thay đổi.
Không kết luận thử máy thật đã đạt hay ứng dụng đủ điều kiện thu cước.
