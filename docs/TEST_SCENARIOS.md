# KỊCH BẢN TEST UI (CHECKLIST) — ReConnect MindHealth

Mục tiêu: sau khi code xong, bạn có thể test 1 thể theo từng Phase/chức năng trên giao diện (Flutter App + Web CMS nếu có).

> Ghi chú chung
> - Nếu test local: đảm bảo backend chạy `:8081`, app trỏ đúng `ApiConstants.baseUrl`.
> - Nếu có JWT: test bằng account trong `SETUP_GUIDE.md` (hoặc account bạn tự tạo).
> - Với các case có điều kiện giờ (Roadmap unlock 06:00), nếu test trước 06:00 thì quest có thể `LOCKED`.

---

## Phase 1 — Authentication & Onboarding

### P1.1 Đăng ký/Đăng nhập (Patient)
1. Mở app → màn Auth.
2. Đăng ký (standard signup) với email/password hợp lệ.
3. Đăng nhập lại bằng tài khoản vừa tạo.
Kỳ vọng:
- Nhận token, vào được Home.
- Không crash/không loop login.

### P1.2 Đăng nhập ẩn danh (Guest/Device)
1. Mở app → chọn Anonymous/Guest.
2. Hoàn tất tạo profile ẩn danh.
Kỳ vọng:
- Vào Home bình thường.
- Backend tạo `PatientProfile` tương ứng (không lỗi `EntityNotFoundException`).

### P1.3 Baseline PHQ-9 + Goal Setting + Psychoeducation
1. Vào PHQ-9 → làm bài lần đầu.
2. Submit.
3. App điều hướng sang Goal Setting.
4. Chọn 3–5 goals → lưu.
5. Hoàn thành Psychoeducation.
Kỳ vọng:
- Baseline chỉ được 1 lần.
- Lưu goals thành công.
- Psychoeducation được ghi nhận là completed.

---

## Phase 2 — Assessment & Daily Loop

### P2.1 Mood Check-in + Agenda Setting
1. Vào luồng Mood Check-in.
2. Chọn mood score và nhập 1 agenda (1 vấn đề/ngày).
3. Submit.
Kỳ vọng:
- Backend lưu mood.
- Không tạo nhiều agenda trong cùng ngày (nếu có ràng buộc).

### P2.2 Rẽ nhánh Thought Record vs Credit List theo ngưỡng 45%
1. Mood < 45% → vào Thought Record flow.
2. Mood ≥ 45% → vào Credit List flow.
Kỳ vọng:
- Đúng rẽ nhánh theo BRD (45%).

### P2.3 AI Guided Discovery (Gemini — text)
1. Trong Thought Record, tới bước cần câu hỏi Socratic.
2. App gọi `POST /api/ai/guided-discovery`.
Kỳ vọng:
- Trả 1–2 câu hỏi.
- Nếu AI tắt/thiếu key: app vẫn có câu hỏi fallback.

### P2.4 AI Cognitive Distortions (Gemini — text)
1. Hoàn tất Thought Record (tới bước gợi ý lỗi tư duy).
2. App gọi `POST /api/ai/cognitive-distortions`.
Kỳ vọng:
- Trả 1–3 nhãn.
- Nếu AI tắt/thiếu key: fallback an toàn.

---

## Phase 3 — Gamification & Roadmap

### P3.1 Load Daily Quests (1–2 nhiệm vụ/ngày, unlock 06:00)
1. Vào tab Roadmap.
2. Kéo refresh.
Kỳ vọng:
- API `GET /api/roadmap/daily?patientId=...` trả danh sách.
- Trước 06:00: có thể thấy `LOCKED` (đúng logic).

### P3.2 Nộp Mastery & Pleasure + hoàn thành quest
1. Chọn quest `AVAILABLE` → bấm “Nộp minh chứng”.
2. Chỉnh sliders Mastery/Pleasure.
3. Bấm “Xác nhận hoàn thành nhiệm vụ”.
Kỳ vọng:
- Quest chuyển `DONE`.
- Quay về danh sách, item hiển thị completed.

### P3.3 AI Vision verify ảnh minh chứng (Gemini Vision)
Áp dụng cho quest category: **Hành vi** / **Xã hội**.
1. Vào màn Quest detail.
2. Bấm khung chụp ảnh minh chứng → chụp ảnh (camera).
3. Đợi verify.
4. Nếu accepted: bấm hoàn thành quest.
Kỳ vọng:
- API `POST /api/roadmap/quests/{id}/proof/verify` trả `accepted=true/false` + `score/confidence/reason`.
- Nếu `accepted=false`: UI yêu cầu chụp lại, không cho complete.
- Nếu `accepted=true`: completeQuest gửi kèm `proofImageUrl`.

### P3.4 Rule Tốt nghiệp (2 chu kỳ PERIODIC liên tiếp < 5)
1. Làm PHQ-9 PERIODIC lần 1 với totalScore < 5 → submit.
2. Làm PHQ-9 PERIODIC lần 2 (sau đó) vẫn totalScore < 5 → submit.
Kỳ vọng:
- Lần 2 hiển thị popup “Bạn đã Tốt nghiệp!” (backend trả `graduatedNow=true`).
- Backend set `patient_profiles.tapering_stage=WEEKLY`.

---

## Phase 4 — Therapist CMS & Telehealth

### P4.1 Dashboard bệnh nhân + Emergency Alert (CMS)
1. Đăng nhập CMS bằng account therapist/admin (nếu có).
2. Mở dashboard patient list.
3. Bật filter red-flag only.
Kỳ vọng:
- Danh sách load ổn.
- Badge/count hiển thị đúng.

### P4.3 Admin duyệt bác sĩ (Web Admin UI)
1. Đăng nhập Web CMS bằng account `ADMIN`.
2. Sidebar → `Quản lý Bác sĩ`.
3. Bấm `CẤP TÀI KHOẢN` → nhập `Họ tên/Email/Mật khẩu` → tạo.
4. Tìm applicant vừa tạo → bấm `DUYỆT` (ACTIVE) hoặc `TỪ CHỐI` (REJECTED).
Kỳ vọng:
- Danh sách lấy từ backend `/api/admin/therapists`.
- Trạng thái cập nhật đúng theo approval.

### P4.3b Enforce duyệt therapist khi login (backend)
Tiền đề:
- Có 1 user role `THERAPIST` và có `therapist_profiles.approval_status`.

Test:
1. Tạo therapist mới bằng Web Admin (mặc định `PENDING`).
2. Thử login bằng therapist đó (CMS hoặc Postman gọi `POST /api/auth/login`).
3. Admin duyệt therapist sang `ACTIVE`.
4. Login lại bằng đúng account therapist.
5. (Tuỳ chọn) Set therapist `REJECTED` → thử login.

Kỳ vọng:
- `PENDING`: login bị chặn, trả lỗi “đang chờ duyệt”.
- `ACTIVE`: login thành công và trả JWT.
- `REJECTED`: login bị chặn, trả lỗi “bị từ chối”.

### P4.2 Telehealth booking (Đặt lịch khám video)
Tiền đề:
- Patient đã được **assign therapist** (backend đã có API assign).

Test:
1. App → tab `Telehealth` → `Danh bạ bác sĩ` → chọn 1 bác sĩ (màn mock) → vào `Chọn Lịch Khám`.
2. Chọn 1 slot (chip giờ).
3. Bật/tắt “Giao tiếp Ẩn Danh”.
4. Bấm `XÁC NHẬN ĐẶT CA`.
5. Quay lại → vào `Lịch sử đặt khám` (`/telehealth/my-appointments`).

Kỳ vọng:
- API `GET /api/booster/slots?patientId=...&date=YYYY-MM-DD` trả danh sách slot + available.
- API `POST /api/booster/appointments/book` tạo appointment (30 phút), không trùng slot đã book.
- API `GET /api/booster/appointments/my?patientId=...` trả danh sách lịch hẹn.
- UI hiển thị lịch hẹn theo thời gian + trạng thái + ẩn danh.

---

## Phase 5 — System Admin & Background Jobs

> Gợi ý:
> - Admin CRUD có thể test bằng Web CMS (UI) hoặc Postman/curl.

### P5.1 Cron Risk Index 00:00 (backend)
1. Kiểm tra log scheduler hoặc trigger thủ công (nếu có script/endpoint).
Kỳ vọng:
- Risk Index tính đúng theo rule.

### P5.4 Cron Tapering & Booster sessions
Tiền đề:
- Patient đã “Tốt nghiệp” (backend set `tapering_stage != NONE` và có `graduated_at`).
- Patient đã được assign therapist (để có `meetingLink`).

Test nhanh (manual trigger):
1. Login patient lấy JWT.
2. Gọi `POST /api/booster/scheduling/run`.
3. Gọi `GET /api/booster/appointments/my?patientId=...` để xem lịch hẹn được tạo.

Kỳ vọng:
- Tạo appointment purpose `TAPERING` (slot 10:00, 30 phút) nếu chưa có.
- Tạo appointment `BOOSTER_3M/6M/12M` khi đến gần mốc (trong 30 ngày tới).

### P5.2 Admin CRUD Users (API)
Tiền đề:
- Có 1 account `ADMIN` để gọi API.

Test:
1. Login admin lấy JWT.
2. Gọi `GET /api/admin/users` (kèm Bearer token).
3. Chọn 1 userId → gọi `PATCH /api/admin/users/{id}/active?active=false`.
4. Gọi lại `GET /api/admin/users` để kiểm tra `isActive=false`.
5. (Tuỳ chọn) gọi `PATCH /api/admin/users/{id}/role?role=THERAPIST` để đổi role.

Kỳ vọng:
- Chỉ `ADMIN` gọi được (user khác gọi sẽ bị lỗi).
- Update `isActive/role` thành công.

### P5.2b Admin CRUD Users (Web Admin UI)
1. Đăng nhập Web CMS bằng account `ADMIN`.
2. Ở sidebar chọn `Quản lý Users`.
3. Tìm 1 user bằng email.
4. Gạt switch `active` để khóa/mở khóa.
5. Đổi role bằng dropdown (PATIENT/THERAPIST/ADMIN).
Kỳ vọng:
- UI cập nhật ngay; refresh vẫn giữ đúng trạng thái.
- Nếu token hết hạn: UI báo lỗi.

### P5.3 Admin CRUD Quest Templates (API)
Tiền đề:
- Có 1 account `ADMIN`.

Test:
1. `GET /api/admin/quest-templates` → thấy danh sách quest templates.
2. `POST /api/admin/quest-templates` với body:
   - `title`, `description`, `category` (`BEHAVIORAL/COGNITIVE/EMOTIONAL/SOCIAL`), `difficulty` (`EASY/MEDIUM/HARD`).
3. `PUT /api/admin/quest-templates/{id}` để sửa title/description/category/difficulty.
4. `DELETE /api/admin/quest-templates/{id}` để xoá.

Kỳ vọng:
- CRUD hoạt động, roadmap seed/assign dùng templates mới.

### P5.3b Admin CRUD Quest Templates (Web Admin UI)
1. Đăng nhập Web CMS bằng account `ADMIN`.
2. Ở sidebar chọn `Kho Nội dung CBT`.
3. Bấm `THÊM` → nhập `Title/Description`, chọn `Category/Difficulty` → `Lưu`.
4. Sửa 1 template bằng icon bút.
5. Xóa 1 template bằng icon thùng rác.
Kỳ vọng:
- Danh sách cập nhật sau khi tạo/sửa/xóa.
- Search filter hoạt động.
