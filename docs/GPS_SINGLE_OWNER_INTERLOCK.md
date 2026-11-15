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

## Bổ sung kiểm thử tranh chấp, chu kỳ tiếp nhận 2/7 (15/11/2026)

Trong Dart, cả Preview và Lab dùng `SerializedGpsStop` để gộp các yêu cầu
dừng đồng thời, không trả lease khi `StreamSubscription.cancel()` vẫn
chưa hoàn tất. Lab còn phải checkpoint trạng thái PAUSED trước khi trả
lease; lỗi SQLite tiếp tục giữ lease theo fail-closed. Kiểm thử Dart
dùng luồng hủy trì hoãn để thử điều kiện này, không mô phỏng GPS thật.

Trong Kotlin, `LocationOwnerRegistryTest.kt` chạy bằng
`:app:testDebugUnitTest` của Gradle; xác minh hai nguồn vị trí không
cùng nhận lease, token stale không trả lease mới, từ chối owner lạ và
16 yêu cầu đồng thời chỉ một yêu cầu thành công. Bootstrap Android
cài test vào Android skeleton được tạo từ Flutter, cùng dependency JUnit
chỉ dùng kiểm thử. Test không yêu cầu Google key/Billing.

**Giới hạn quan trọng:** Android registry đồng bộ và Dart stop barrier
không chứng minh Geolocator *thực sự* giải phóng foreground service ngay
khi Future cancel hoàn thành; chỉ thiết bị Android thật và quan sát
FGS mới xác minh được cửa sổ giao thoa này. Các ca Home/lock,
permission revoke, kill/reboot/Doze/OEM và chi phí vẫn chưa đo thực.

## Gia cố phiên thông báo và heartbeat (15/11/2026, chu kỳ 3/7)

Bổ sung fencing token khi xử lý các lệnh `stop` từ hai phía:
- `MainActivity.stop` yêu cầu `leaseId` chính xác; từ chối request không có
  token và stale token. `ownerStatus` báo token đang giữ cho tab
  chẩn đoán dùng khi dừng.
- `LocationOwnerRegistry.cancelPendingSafety(expectedLeaseId)` chỉ giải
  phóng reservation đúng token; không dùng hàm reset owner không điều kiện.
- Notification Android gắn `EXTRA_LEASE_ID` và một URI khác nhau theo
  token vào `PendingIntent`; không chỉ thay `extras`, vì Android có thể
  tái sử dụng pending intent khi chỉ extras thay đổi.
- `LocationSafetyService` bỏ qua STOP với token cũ nếu có phiên mới đang
  sống. START cũ cũng không được `stopSelf` làm gián đoạn phiên đang sống.
- Heartbeat 3 giây kiểm tra lại quyền vị trí, nguồn vị trí đang đăng ký và
  token owner; khi mất điều kiện, dừng dịch vụ, không duy trì ACK cũ.
  Bắt `SecurityException` khi chọn provider trong `onStartCommand`.

Đã mở rộng kiểm thử JVM của registry để bảo đảm token cũ không giải phóng
owner mới. Kiểm thử nguồn Python kiểm tra cấu hình notification/session token
và heartbeat. Việc FGS thực sự dừng trên Android sau thao tác cancellation,
hoạt động của `PendingIntent` qua process death/permission revoke, và Doze/OEM
**vẫn cần thử thiết bị thật**. Không có thay đổi liên quan tính cước,
VietQR, Google Billing, hay SQLite thương mại.


## Gia cố Start/Stop bất đồng bộ (chu kỳ 4/7, 15/11/2026)

Rủi ro tìm thấy ở HEAD `1bf47af5`: Activity có thể gọi `stopService`
và trả `native_safety` lease khi `startForegroundService` vừa được
dispatch nhưng Kotlin Service chưa chạy `onStartCommand`. Android có
thể còn lệnh Start đang đợi, từ đó cho phép luồng Geolocator thứ hai.

Sửa đổi ở HEAD tiếp theo:
- `requestSafetyStop(leaseId)` chỉ ghi ý định dừng, **không** release
  reservation. Mọi yêu cầu lấy owner khác đều bị từ chối cho tới khi
  `onDestroy` của Service release đúng token.
- Với Start chưa ACK, Activity không gọi `stopService` sớm;
  `onStartCommand` gọi `startForeground` rồi kiểm tra cờ dừng. Nếu có
  yêu cầu dừng, không đăng ký LocationManager, gọi `stopSelf(startId)`.
- Với Service đã active, Activity gửi stop và ACK bị vô hiệu ngay khi
  cờ dừng được đặt. Giao diện không được hiểu ACK cũ là dịch vụ còn
  đủ điều kiện hoạt động.
- Lease ID được gieo bằng `SecureRandom` theo từng process rồi tăng
  dần, giảm khả năng lệnh dừng từ notification cũ trùng lease mới sau
  process death. Đây là fencing token, **không phải khóa xác thực**.
- Kotlin JVM test mới kiểm tra `stopRequested` giữ độc quyền,
  idempotent STOP, stale STOP và release chỉ sau teardown.

**Fail-closed có chủ ý:** nếu Android không bao giờ thực thi Start và
cũng không phát sinh `onDestroy`, owner có thể ở trạng thái pending
cho tới khi process được khởi động lại. Không dùng timeout để tự nhả
lease khi chưa có bằng chứng Android đã dừng. Đây vẫn là giới hạn cần
kiểm chứng trên Android thật (issue #2), không phải chứng nhận FGS.
