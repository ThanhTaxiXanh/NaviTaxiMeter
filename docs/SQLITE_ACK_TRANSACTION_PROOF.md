# SQLite ACK sau COMMIT, thí nghiệm cách ly (chu kỳ 6/7)

**Ngày:** 15/11/2026. **Trạng thái:** proof chạy trên Python `sqlite3` thật,
KHÔNG được tích hợp vào ứng dụng Android/Flutter, KHÔNG phải schema migration,
KHÔNG tính cước khách, KHÔNG có chứng nhận Android/background.

## 1. Phạm vi chính xác

- `tool/checkpoint_sqlite_contract.py` tạo một DB riêng có tên
  `DISPOSABLE_TEST_ONLY.db` trong thư mục tạm `navitaxi-sqlite-proof-*`.
  Nó **từ chối** đường dẫn đến `navitaximeter_v1.db`, tên DB khác,
  thư mục sai và file symlink. Không truy cập dữ liệu thật của người dùng.
- Trong DB thử: hai bảng `active_trip` và `active_trip_route` sao chép
  **dạng cột của schema v3**, cộng hai bảng **mới chỉ dùng cho phép thử**:
  `checkpoint_fence(id=1, session_id, generation, last_sequence,
  last_gnss_nanos, phase)` và
  `checkpoint_ack(session_id, generation, sequence, sample_digest,
  checkpoint_id)`. Bảng mới chỉ minh họa đề xuất metadata tương lai;
  chúng **không** được tạo trong app và **không** phải migration v3→v4.
- Đầu vào `RouteFix` của unit tests dùng số liệu kỹ thuật vô danh
  để kiểm chứng ràng buộc SQL. Không được hiển thị như GPS/tuyến đường
  thật hoặc dùng làm giá cước.

## 2. Bất biến giao dịch được thử

1. Mỗi ghi chạy `BEGIN IMMEDIATE`, xác minh cùng
   `session_id + generation`, trạng thái thử `TEST_OPEN`,
   `last_sequence` và `routeCount` từ DB.
2. Đúng `sequence = last_sequence + 1`, GPS monotonic mới,
   gap không vượt 12 giây, fix không mock, accuracy/speed không bất thường.
   Thiếu fix hoặc stale generation -> từ chối, không nhận hàng mới.
3. `INSERT` route, `UPDATE` header, `UPDATE` fence, `INSERT` ACK
   ledger nằm trong **cùng một giao dịch SQLite**. Nếu SQL lỗi,
   toàn bộ transaction rollback và không trả ACK.
4. `CommitAck(sessionId,generation,sequence,checkpointId)` chỉ trả
   sau `db.commit()` thành công. `checkpointId` được tính từ
   session/fence/sequence và fingerprint của mẫu, không phải bằng chứng
   bảo mật GNSS.
5. Nếu gửi lại **đúng mẫu vừa commit**, đọc và xác minh ledger **và**
   hàng route/routeCount trước khi trả đúng ACK cũ, không ghi thêm row.
   Gửi lại cùng sequence với tọa độ/speed khác -> xung đột.
6. Nếu commit thành công nhưng ACK tới caller bị mất, đây là trạng thái
   **không chắc chắn ở phía caller**. Không giả định rollback;
   khi `recover_paused()`, đối chiếu checkpoint bền vững và ghi phase
   `PAUSED`, không tự ghi tiếp hoặc resume.
7. Khi nhiều kết nối SQLite cạnh tranh cùng mẫu, `BEGIN IMMEDIATE`
   tuần tự hóa writer: chỉ một transaction tạo ACK thực, các lời gọi
   còn lại đọc lại ACK giống hệt.

## 3. Kiểm thử đã chuẩn bị

`tool/test_checkpoint_sqlite_contract.py` có **12 phép thử**:
- Chặn đường dẫn không phải DB tạm và symlink.
- Kiểm chứng ACK chỉ sau SQLite COMMIT và tồn tại sau reopen.
- Trigger gây lỗi INSERT route -> rollback header, route, fence, ACK.
- Trigger gây lỗi UPDATE header -> rollback dữ liệu đã chèn.
- Duplicate giống hệt idempotent, duplicate khác speed/toạ độ -> từ chối.
- Generation cũ và sequence nhảy -> từ chối.
- Monotonic time đảo/đứt, mock -> từ chối.
- COMMIT thành công nhưng mất ACK -> khôi phục PAUSED.
- Chưa nhận GPS nhưng recover -> PAUSED.
- Bảng route hư -> từ chối recover.
- Header lệch count -> từ chối ACK cũ và mẫu mới.
- 8 kết nối cùng ghi -> duy nhất một ACK bền vững.

**Kiểm chứng cục bộ:** 12/12 PASS bằng CPython + `sqlite3`. Kết quả
GitHub Actions chính thức phải được kiểm tra sau commit mới.

## 4. Những thứ tuyệt đối CHƯA được chứng minh

- Không chứng minh Kotlin `SQLiteDatabase` trong Android, JDBC hoặc
  Flutter `sqflite` có tính năng giống hệt trong mọi máy/OEM.
- Không kiểm thử crash chính giữa ghi trong hệ thống Android thật,
  `fsync`/journal/độ bền của NAND hay thay đổi trạng thái nguồn điện.
- Không phải DB app schema 3: phần metadata fence và ACK hiện **chưa
  được lưu vào `navitaximeter_v1.db`**.
- Không có single `TripLocationService`, physical GNSS, FGS ACK,
  đồng bộ giữa engine Dart và SQLite writer hay transaction giá cước.
- Không có real trip, bản đồ/đường/POI, thanh toán, hóa đơn hoặc
  Google Cloud Billing. **Không bật thu cước thương mại**.

## 5. Công việc tiếp theo (issue #3, cổng chặn)

1. Quyết định một writer runtime duy nhất và sở hữu engine tính cước
   khi Android FGS chạy nền. Giữ engine Dart và rounding/parity đã chốt;
   không lén đổi sang Kotlin.
2. Thiết kế/thử migration có backup v3→v4 với fence + ACK persistent,
   bảo toàn receipt/tariff/route v3 và ngăn session stale. Không chạy
   migration thật khi chưa có thử rollback dữ liệu người dùng.
3. Implement native writer adapter *sau* quyết định kiến trúc và test
   engine lifecycle, rồi instrumented SQLite tests trên Android.
4. Issue #2 thử thiết bị Android 11–16, Home/lock, Doze, kill, reboot,
   GPS permission, notification STOP và chồng lấn FGS.
5. Duy trì Zero Paid API, PR Draft, không merge main, không sửa TTX,
   không Google Billing/thu cước cho tới khi chủ dự án phê duyệt.
