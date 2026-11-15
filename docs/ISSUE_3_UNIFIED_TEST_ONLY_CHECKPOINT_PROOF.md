# Issue #3 - P1 unified test-only IPC / staged fare / SQLite ACK
Ngày: 16/11/2026 (Việt Nam). Chỉ dùng fixture và DB clone tạm. Không sản xuất, không GNSS thật, không Android vật lý, không tính cước khách.

## Phạm vi và mã nguồn
- test/support/issue3_unified_checkpoint_writer.dart
- test/issue3_unified_checkpoint_test.dart
- Nhánh được ghi: feature/navitaximeter-foundation
- Không chạm DB thật navitaximeter_v1.db, xác nhận tariff trong SharedPreferences hay schema migration của ứng dụng.

Hệ thống thử: immutable synthetic CloneFix -> typed IpcProposal / IpcCheckpointGate (session + generation + seq) -> TaximeterEngine.forkForCheckpoint() -> copy-on-write fare candidate -> một giao dịch sqflite trên disposable v3-shaped/v4-dry-run clone, ghi route + header tiền + session fence + ACK ledger -> await COMMIT -> công bố fare test và IPC ACK. Callback mất sau COMMIT không làm cộng kép; phải đọc bền vững và phục hồi PAUSED.

## Trường hợp kiểm thử
- 8 lệnh song song có thứ tự; 8 replay đồng nhất không thêm tiền/route/ACK.
- Stale generation, conflicting same-sequence replay, missing sequence, mock GNSS, GNSS timestamp gap.
- Giữ candidate chưa COMMIT: published fare không được thay đổi.
- SQL injected fail beforeRoute, afterRoute, afterHeader, afterFence, afterLedger: rollback toàn bộ, fail closed.
- Lost ACK sau COMMIT, callback revoked, close/reopen DB, recovery PAUSED, không tự RESUME.
- Thử tamper last header/money, last route coordinates, ACK digest, checkpoint ID, last GNSS nanos, frozen tariff; fabricated fare khi chưa có ACK. Recovery phải từ chối và không sửa durable phase.

## Bằng chứng đúng SHA
- SHA c5b8678d694c250e91b50651e15e9df185f4ccea: Foundation workflow 43741664068 SUCCESS gồm Flutter analyze/test và Android 14 emulator headless DEBUG SQLite probe; Zero Cost Source Gate 43741664065 SUCCESS.
- Thay đổi recovery integrity tiếp theo ở 4b2a4c63898f084e59ceb6f4b5669ab0cfe8700e và 373b38c218ab30c5d86fdecf6dac5c4d9b600ac6: CI cần đối chiếu lại ở final HEAD mới, không lấy PASS SHA cũ để chứng minh.
- Source gate không phải kiểm toán 0 USD thực tế trong 30 ngày.

## Recovery-integrity và giới hạn
Checkpoint ID của harness hash sample digest và exact bytes của fare header sau COMMIT. Khi recovery, kiểm tra last route + last GNSS nanos + ACK digest + checkpoint ID so với header, frozen tariff parity và số hàng; PAUSED được ghi sau validation trong transaction. CHƯA có full historical hash chain bảo vệ từng điểm route đã commit, chưa có production durable identity từ Android service hoặc chứng minh SQLite fsync mất điện.

Các proof vẫn chỉ là thử nghiệm độc lập với app: chưa có native TripLocationService một GNSS owner, Android physical GNSS, Android native→Dart IPC thực, production one writer, v3→v4 production migration, backup DB cùng SharedPreferences, hay commercial fare parity. MeteredTripCoordinator production vẫn có mutable state trước COMMIT.

## Điểm tiếp
1. Xác minh cả Foundation và Zero Cost CI ở SHA HEAD mới nhất, sửa lỗi nếu fail.
2. Chứng minh full-history ledger/ACK integrity hoặc ghi rõ giới hạn, rollback và lifecycle.
3. Review copy-on-write cho coordinator accept/resume/suspend/finish, chưa bật thương mại.
4. Test Android native→Dart IPC debug-only trên emulator trước khi yêu cầu điện thoại thật.
5. Issue #2 Android physical vẫn NOT TESTED. Nếu cần người dùng thử điện thoại: cung cấp APK+SHA+run đã xác minh, từng nút và bước, PASS/FAIL/NOT TESTED, bằng chứng che thông tin riêng và cách gửi trong chat đúng quy tắc mục 9.

Cấm merge main, sửa TTX reference, bật Google Billing/API trả phí, thu cước khách, release ký hoặc migrate DB ứng dụng khi chưa được phê duyệt.
