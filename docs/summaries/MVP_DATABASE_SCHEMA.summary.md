# Summary: MVP_DATABASE_SCHEMA (ERD rút gọn)

Tóm tắt nhanh để giảm token. Bản đầy đủ: `docs/diagrams/MVP_DATABASE_SCHEMA.md`.

## Mục tiêu
- Giữ schema tối thiểu cho luồng MVP: đăng nhập → PHQ-9 → journal → AI risk → quest/roadmap → therapist theo dõi risk.

## Bảng cốt lõi (điển hình)
- `users`, `patient_profiles`, `therapist_profiles`
- `phq9_submissions`
- `journals`
- `quest_templates`, `patient_quests`

## Quan hệ nghiệp vụ chính
- Patient có nhiều PHQ-9 submissions, journals, quests.
- Risk index tổng hợp liên quan trực tiếp `patient_profiles` (current score, red-flag) và các nguồn dữ liệu (mood/journal/phq9).

## Khi nào cần mở bản đầy đủ
- Khi thêm cột/quan hệ mới, cần mapping JPA hoặc kiểm tra khoá chính/ngoại, hoặc cần phần “khuyến nghị implement backend”.

