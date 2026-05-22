# Summary: THUAT_TOAN_RISK_INDEX (Risk Index 0–100)

Tóm tắt nhanh để giảm token. Bản đầy đủ: `docs/THUAT_TOAN_RISK_INDEX.md`.

## Công thức tổng hợp (ý tưởng)
- Risk Index = tổng hợp có trọng số từ:
  - **PHQ-9** (thường trọng số lớn)
  - **AI/NLP** (phát hiện ngôn ngữ rủi ro)
  - **Mood** (check-in hằng ngày)
- Có **Override Rule**: nếu tín hiệu khẩn cấp → nâng risk lên ngưỡng can thiệp dù các biến khác thấp.

## Kết quả & rẽ nhánh
- **Risk < ngưỡng khẩn cấp**: luồng bình thường (roadmap/quest, theo dõi).
- **Risk ≥ ngưỡng khẩn cấp**: bật red-flag, cảnh báo therapist, kích hoạt can thiệp.

## DB/APIs liên quan (ở mức định hướng)
- Các bảng nguồn: PHQ-9 submissions, mood, journals, quests.
- Điểm hiện tại + trạng thái red-flag thường nằm ở `patient_profiles` (hoặc bảng tương đương).

## Khi nào cần mở bản đầy đủ
- Khi implement cron tính risk, hiệu chỉnh ngưỡng/trọng số, hoặc cần danh sách field DB chi tiết.

