# KẾ HOẠCH TỔNG THỂ (MASTER PLAN) - RECONNECT MINDHEALTH

Đây là bản đồ toàn cảnh lưu trữ tiến độ phát triển các Phase của dự án. 
Quy tắc: Khi hoàn thành một tính năng hoặc Phase, AI (Antigravity) BẮT BUỘC cập nhật trạng thái `[x]` vào đây và tạo log trong `CHANGELOG.md`.

## LỘ TRÌNH PHÁT TRIỂN (DEVELOPMENT PHASES)

### Phase 1: Authentication & Onboarding (Đang hoàn thiện)
- [x] Đăng ký / Đăng nhập tài khoản Bệnh nhân.
- [x] Đăng ký / Đăng nhập tài khoản Ẩn danh (Guest/Device ID).
- [x] Chấm điểm Baseline PHQ-9 (Lưu dữ liệu đầu vào).
- [x] Goal Setting (Lưu 3-5 mục tiêu trị liệu).
- [x] Psychoeducation Swipe Cards.

### Phase 2: Assessment & Daily Loop (Tiếp theo)
- [x] Fix lỗi CORS và DB của Module Assessment.
- [x] Daily Mood Check-in (Màn hình kéo điểm tâm trạng).
- [x] Thought Record / Credit List Journal (Nhật ký tự do).
- [x] Tích hợp API Google Gemini (Guided Discovery).
- [x] AI Risk Scoring (Lưu điểm cảnh báo NLP).

### Phase 3: Gamification & Roadmap (Lõi Trị liệu)
- [x] Xây dựng Roadmap UI (Bản đồ Cây Nhiệm Vụ).
- [x] Time-gating Logic (Khoá 1-2 nhiệm vụ/ngày, chờ 06:00 sáng).
- [x] Nộp bài và chấm điểm Mastery & Pleasure.
- [x] AI Vision: Tự động chấm điểm ảnh chứng minh nhiệm vụ.
- [x] Rule Tốt nghiệp (PHQ-9 < 5 trong 28 ngày).

### Phase 4: Therapist CMS & Telehealth
- [x] Dashboard Danh sách bệnh nhân (Có cờ Đỏ, xem trạng thái tự động phân bổ).
- [x] Cảnh báo Emergency Alert (Risk >= 70).
- [x] Đặt lịch Khám Video (Telehealth).
  - [x] Backend API nền: Admin assign/reassign therapist (gắn cứng 1 bệnh nhân - 1 bác sĩ).
  - [x] Backend API nền: Therapist patient list + filter red-flag (phục vụ Emergency Alert).

- [x] Duyệt therapist theo chứng chỉ (upload credentials + gating theo trạng thái ACTIVE).
- [x] Admin gán therapist thủ công + giới hạn caseload (20 bệnh nhân/therapist).

### Phase 5: System Admin & Background Jobs
- [x] Admin CRUD User / Nội dung Nhiệm vụ.
- [x] Cron Job: Chấm điểm Risk Index mỗi 00:00 đêm.
- [x] Cron Job: Tapering & Booster sessions.

### Maintenance: Docs & Solo Builder
- [x] Tối ưu token tài liệu Markdown: thêm `docs/AI_CONTEXT.md`, `docs/BRD_SUMMARY.md`, `docs/summaries/*` + audit `docs/TOKEN_AUDIT.md`.

---
*(Các file plan chi tiết cho từng phase sẽ được đặt trong thư mục `docs/plans/`)*
