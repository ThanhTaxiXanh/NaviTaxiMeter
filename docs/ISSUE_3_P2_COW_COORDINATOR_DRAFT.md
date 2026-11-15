# Issue #3 P2 - Draft copy-on-write coordinator (feature branch only)

**Ngày:** 16/11/2026 (ICT). **Trạng thái:** thay đổi mã runtime trên nhánh PR #1 Draft, **KHÔNG PHÊ DUYỆT tính cước/thu tiền khách**. Không merge main. Không kết nối one-native-GNSS-owner hoặc Android physical.

## Vì sao sửa
Trong `MeteredTripCoordinator` cũ, `accept()` cập nhật `TaximeterEngine.acceptGps/tick` trước khi `TripRepository.saveActiveIncremental()` hoàn tất. Tương tự, `_suspend()` và `resume()` mutate engine trước COMMIT, còn `finish()` tạo trạng thái FINISHED trước khi giao dịch hóa đơn thành công. Nếu SQLite lỗi, fare/time/GPS in-memory có thể vượt checkpoint bền vững.

## Giải pháp P2 bước đầu (không thay schema)
- `_checkpoint(candidate, newPoints)`: ghi snapshot của `candidate` và route mới trong một transaction SQLite v3 của `TripRepository`; **chỉ sau khi Future saveActiveIncremental hoàn tất**, gán `_meter = candidate` và công bố route. Nếu lỗi, giữ meter cuối cùng đã COMMIT và cờ `_faulted` chặn mọi lệnh; `_markStorageFault` suspend in-memory fail-closed ở last trusted fix.
- `accept()`: `meter.forkForCheckpoint()`, xử lý GPS và `tick` trên candidate, không mutate published meter trước COMMIT.
- `_suspend()`: clone + suspend tại last trusted fix rồi ghi; khi lỗi không tính thêm waiting/seconds.
- `resume()`: clone PAUSED, manual resume + nhận baseline mới trên candidate, ghi điểm segment mới trước khi publish. Nếu GPS bị loại, meter vẫn PAUSED.
- `finish()`: nếu đang RUNNING thì persist một PAUSED checkpoint trước, fork clone để tạo receipt; gọi `completeActive()` trên SQLite, chỉ khi transaction thành công mới dọn session in-memory và trả hóa đơn. Lỗi SQLite không làm phantom FINISHED.
- `begin()`: vẫn có hai transaction reserve active session + initial route; **chưa giải quyết** atomic start/ACK. Không chỉnh `TripRepository`, schema v3 hoặc prefs.

## Kiểm thử P2 mới
`test/issue3_coordinator_copy_on_write_fault_test.dart` chỉ dùng đường DB `DISPOSABLE_V3_ONLY.db` dưới thư mục tạm, tariff/định vị **giả lập phục vụ unit test**. Các kịch bản:
1. chặn Future save trước COMMIT: UI fare/distance/time/route phải giữ nguyên cho tới lúc release;
2. trigger lỗi INSERT route khi accept: rollback fare + route, faulted và recovery PAUSED;
3. trigger lỗi INSERT header khi suspend: không tăng tiền/thời gian;
4. trigger lỗi INSERT route khi resume: giữ meter PAUSED, không lấp GPS gap;
5. trigger lỗi INSERT receipt khi finish: không để phantom FINISHED/receipt;
6. hoàn tất bình thường: receipt bền vững, active checkpoint biến mất.

**Quy tắc công nhận:** Flutter analyze/test phải PASS ở SHA chứa thay đổi; build-test và Android14 headless debug probe phải báo kết quả riêng. Test này không chứng minh Android FGS/GNSS, stop/start OS, power failure, one-writer/IPC production v4 ACK, race giữa isolate/process hoặc giá vé thương mại. Không test điện thoại nếu chưa có APK SHA/run và hướng dẫn bằng chứng đầy đủ.

## Chưa giải quyết và P3 tiếp theo
- Repository v3 chưa có transaction durable `sessionId/generation/sequence`/ACK ledger production; vẫn chỉ dùng trong harness clone của Issue #3.
- Single native Kotlin GNSS `TripLocationService` + service-owned headless Dart worker, reboot/kill/restart, stale callback fencing, SQLite busy + WAL cross-isolate tests.
- App v3 database & confirmed tariff prefs backup/restore và v4 migration: mới dry-run clone, không đụng dữ liệu thật.
- `begin()` hai transactions: cần atomic reserve + initial baseline route; kiểm thử rollback và duplicate session.
- Bảo đảm fallback với unknown COMMIT, idempotent receipt và chống mất điện trên Android thật còn thiếu.
- Cần review kỹ năng lượng (1, 50, 100 lái xe x 30 ngày) để giữ Zero Paid API thật, không phụ thuộc Google Paid API.

**Cấm:** thương mại, GPS giả như thật, merge main, sửa TTX-AATaximeter, Google Billing/paid API, signed release, tự migrate app DB.
