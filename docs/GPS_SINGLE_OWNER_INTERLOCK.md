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


## Thiết kế đích: chỉ MỘT service sở hữu GNSS và chuyến (CHƯA LẬP TRÌNH)

Khi qua kiểm thử thiết bị, chuyển từ ba owner thử nghiệm sang một
`TripLocationService` Kotlin duy nhất để quản lý vòng đời và nguồn GNSS
thực. Các trang Flutter sẽ là **client** xem trạng thái/điểm thử, không
tự mở thêm Geolocator foreground service. Mỗi phiên chạy có `sessionId`,
`generation` và fencing token; restart phải tạo phiên mới, không dùng
lease cũ để nối quãng đường.

Giao thức chuyển trạng thái dự kiến:
`IDLE → START_REQUESTED → SERVICE_ACKED → GPS_ACQUIRING → ACTIVE`,
và bất cứ lỗi nào ở quyền, service, tín hiệu hoặc SQLite sẽ chuyển sang
`SUSPENDED`; chỉ tài xế xác nhận thủ công mới được `RESUME`. Không
tự tạo phí trong khoảng mất tín hiệu. Lệnh start chỉ hợp lệ khi Activity
đang hiển thị và đủ quyền Android.

Mỗi quan sát GNSS được gán số thứ tự tăng và thời gian đơn điệu để lọc
lặp/stale/jump/mock. Domain `TaximeterEngine` Dart vẫn là nguồn quy tắc
tính cước đã kiểm thử, nhưng **chưa có runtime nền đáng tin cậy** cho nó:
không được dựa vào Flutter UI isolate tiếp tục sống sau Home/kill.
Trước khi bật trip thực, phải chứng minh một worker tồn tại dưới FGS,
ghi `active_trip` và `active_trip_route` trong **cùng giao dịch SQLite**,
rồi mới trả ACK checkpoint theo `sessionId + sequence + DB commit`.
Nếu worker/ACK chết, dừng ghi tiền và khôi phục `PAUSED` sau restart.
Không tính lại quãng đường đã thiếu fix, không ghi hóa đơn trùng.

**Cổng chặn phát hành:** chỉ tiếp tục sau khi có Kotlin runtime tests,
integration/instrumented tests, Android thực 11–16, crash/reboot/Doze/
permission/OEM/SQLite fault, đối chiếu đo quãng đường và số tiền thực,
và phê duyệt riêng của chủ dự án. Tuyệt đối không chuyển health monitor
hiện tại thành nguồn tính cước bằng cách nối trực tiếp số mẫu GPS.
