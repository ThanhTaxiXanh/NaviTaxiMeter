# Issue #3 - P1 Historical ACK Integrity Chain (TEST ONLY)

**Ngày:** 16/11/2026, Việt Nam. **Quyền ghi:** chỉ `feature/navitaximeter-foundation`. **Trạng thái:** mã thử nghiệm trên clone SQLite. Không phải production, không dùng cho cước khách.

## Mục tiêu và điểm nối
Proof unified trước đó chỉ xác thực checkpoint cuối trên DB clone. Trong thay đổi này, `test/support/issue3_historical_ack_chain.dart` tạo bảng bổ sung `unified_checkpoint_history_test_only`, và `test/support/issue3_unified_checkpoint_writer.dart` tích hợp nó vào **cùng một sqflite transaction**: route INSERT, fare/header UPDATE, fence UPDATE, ACK INSERT, history INSERT. Mọi phép ghi có lỗi đều rollback cùng nhau. Post-COMMIT IPC ACK vẫn chỉ được phép sau Future transaction thành công. Không thay `TripRepository`, không schema v3→v4 runtime.

Mỗi hàng lịch sử thử gồm sequence, session/generation, GNSS elapsed nanos, recorded_at, nguyên văn header tiền/tariff theo checkpoint, previous history ID và chain ID. `unifiedTestCheckpointId` hash digest mẫu GPS + exact header bytes; `unifiedHistoryLink` hash prior chain ID + checkpoint ID. Quá trình đọc phục hồi soát lại toàn bộ route, digest, header, frozen tariff, sequence/monotonic fence và linked IDs; so sánh header cuối với `active_trip`; chỉ cập nhật phase thành PAUSED sau khi tất cả bằng chứng hợp lệ.

**Giới hạn bảo mật rất quan trọng:** SHA256 không khóa trong cùng SQLite file **không chống được kẻ tấn công có quyền sửa lại tất cả dữ liệu và tính lại hash**. Đây chỉ là kiểm chứng tính nhất quán giao dịch và phát hiện các kiểu sửa/hỏng dữ liệu mô phỏng. Bảng history lặp lại full snapshot chỉ phù hợp proof, chưa được duyệt làm schema production hoặc giải pháp lưu trữ cho nhiều km. Không khẳng định Android fsync/power-loss durability.

## Test mới
Tệp `test/issue3_unified_checkpoint_test.dart` thử tám dạng phá hoại ở checkpoint **trước điểm cuối**: sửa route, ACK digest, ACK ID, monotonic GNSS nanos, fare header cũ, recorded_at cũ, previous-link và xóa một hàng history. Trường hợp khác ép SQL fail khi INSERT history, yêu cầu rollback route/header/fence/ACK; một ca kiểm chứng toàn chuỗi hợp lệ rồi phục hồi PAUSED và cấm ghi tiếp. Trước đó đã có test lỗi SQL các điểm cắt giao dịch, lost ACK, staged candidate, duplicate/replay.

## Trạng thái xác minh theo SHA
- **Mốc đã PASS:** commit `23f9b3f2e69e91fe87e5f924dc0a78beb6853768` có Foundation `build-test` SUCCESS (`flutter analyze`, `flutter test`, `flutter build apk --debug`), Zero Cost Source Gate SUCCESS. Android14 headless emulator là bước riêng, không đồng nghĩa device thật.
- **Mã chain mới:** commit `90cbdfef13e3ff5dbc96331ffdabad9162665b60`, `d985cc9ba7a52cd4a679c70e4cffe13a7b980d5b`, `74faf0fbbfc759e216ffc21c1cdc816b815e35ea`. Foundation run `43748400050` **PENDING/IN PROGRESS ở thời điểm lập tài liệu**, Zero Cost run `43748400019` SUCCESS. Phải đọc kết quả Foundation theo đúng SHA cuối cùng, không dùng PASS của SHA cũ.
- Một job bị CANCELLED do push thay đổi mới không có nghĩa test FAIL. Chỉ đánh dấu PASS theo `flutter test` và full-run conclusion đã hoàn thành.

## Rà soát P2 runtime coordinator (chưa sửa code)
- `MeteredTripCoordinator.accept()`: gọi `meter.acceptGps` + `meter.tick` trước `_checkpoint()`; nếu transaction fail, in-memory money có thể đã thay đổi. Cần immutable fork và chỉ publish sau COMMIT.
- `_suspend()`: gọi `meter.suspendForInterruption` trước checkpoint. Cần staged pause, bảo đảm fail closed / last committed snapshot.
- `resume()`: gọi `meter.resume` và `acceptGps` trước khi ghi điểm segment đầu. Cần staged resume, new GNSS segment, manual action, no gap charge.
- `finish()`: gọi `meter.finish()` trước khi `completeActive` hoàn tất. Cần staged receipt, kiểm tra atomic immutable receipt, tránh một trạng thái finished trên UI chưa bền vững.
- `begin()`: hiện `beginActive()` rồi `saveActiveIncremental()` ở hai giao dịch; nếu giao dịch 2 fail thì giữ reservation để phục hồi. Đây chưa phải single production post-COMMIT session ACK protocol.
- Không áp dụng staged helper ở runtime UI/Lab và không thay owner GPS cho đến khi proof Android native/real OS + chính chủ phê duyệt.

## Gate kế tiếp
1. Verify latest feature HEAD và full CI, sửa lỗi kiểm thử lịch sử nếu có.
2. Rà soát staging coordinator + lifecycle/ACK; test-only fault injection trước khi đổi runtime.
3. Chứng minh native→Dart IPC với headless service trên Android emulator, rồi issue #2 trên Android thật theo hướng dẫn APK/SHA/nút/PASS/FAIL/bằng chứng cá nhân đã che theo quy tắc mục 9.
4. Giữ issue #2/#3 OPEN, Zero Paid API, không Google Billing, không sửa TTX/main, không thương mại hoặc signed release.
