# CHANGELOG (Nhật ký Thay đổi)

Tất cả các thay đổi lớn về tính năng, sửa lỗi, và cấu trúc hệ thống của dự án ReConnect MindHealth sẽ được lưu trữ tại đây.
Quy tắc: Định dạng theo chuẩn [Keep a Changelog](https://keepachangelog.com/en/1.0.0/). AI phải tự động thêm vào đây sau mỗi lần hoàn thành một phase hoặc fix xong một issue.

## [Unreleased]
### Added
- **Clinical (Backend):** Thêm API `GET /api/clinical/therapist-assignment-status?patientId=...` để UI patient gating “đã được gán bác sĩ chưa?”.
- **Therapist Web:** Thêm màn “Lịch làm việc” (toggle 6 slot/ngày) + “Lịch đã đặt” (load từ backend) dùng `/api/booster/*`.
- **Seed:** Bổ sung & sửa encoding UTF-8 cho `reconnect_backend/src/main/resources/seed_data/quest_templates.csv` để “Kho CBT” luôn có dữ liệu mẫu.

### Fixed
- **Telehealth:** Chuẩn hóa message tiếng Việt (UTF-8) trên backend Booster/Clinical/Auth, tránh lỗi mojibake khi hiển thị trên UI.
- **Patient App:** Sửa toàn bộ text bị mojibake ở flow Telehealth/Booking và Roadmap repository.
### Fixed
- **Web Admin CMS:** Khắc phục lỗi hiển thị của nút "Khoá tài khoản" (bấm khoá nhưng UI bật lại trạng thái cũ) do API Backend `UserDto` thiếu trường `isActive` khi trả về sau lệnh PATCH. Đã bổ sung `isActive` vào `UserDto` để đồng bộ chính xác trạng thái UI.
- **Web Admin CMS:** Sửa triệt để lỗi font tiếng Việt (mojibake) hiển thị trên giao diện quản trị viên duyệt chuyên gia (`reconnect_web/lib/screens/admin/admin_verify_doctor_screen.dart`), chuyển đổi toàn bộ các chuỗi ký tự bị lỗi (như "Chưa đăng nhập", "Chứng chỉ", "Họ tên", "Đã tạo tài khoản...", "ĐÃ CẤP PHÉP", "TỪ CHỐI", "Đóng") về định dạng tiếng Việt chuẩn UTF-8. Bảo toàn 100% các tính năng chỉnh sửa hồ sơ và đặt lại mật khẩu bác sĩ được phát triển trước đó.

### Added
- **Docs:** Thêm “AI Context Pack” để giảm token nạp ngữ cảnh: `docs/AI_CONTEXT.md`, `docs/BRD_SUMMARY.md`, `docs/summaries/*`, kèm audit `docs/TOKEN_AUDIT.md` và script generate `scratch/audit_md_tokens.py`.
- **DevTools:** Thêm Postman artifacts demo nhanh (admin/approval/login): `infra/postman/ReConnectMindHealth_AdminApprovalLogin.postman_collection.json` + env local `infra/postman/ReConnectMindHealth_Local.postman_environment.json`.
- **DevTools:** Thêm Postman collection full để test end-to-end nhanh toàn bộ MVP: `infra/postman/ReConnectMindHealth_Full.postman_collection.json`.
- **DevOps:** Thêm Docker deployment cho full stack (MySQL + Backend + Web CMS): `infra/docker-compose.yml`, `reconnect_backend/Dockerfile`, `reconnect_web/Dockerfile`, `docs/DEPLOY_DOCKER.md`.
- **DevTools:** Cho phép cấu hình `API_BASE_URL` bằng `--dart-define` cho Flutter Web CMS và Flutter App (tránh hard-code localhost).
- **Docs:** Thêm checklist test theo luồng giao diện để demo/bao ve: `docs/UI_TEST_RUNBOOK.md`.
- **Seed:** Bổ sung sẵn tài khoản demo `admin@mindhealth.com`, `therapist1@mindhealth.com`, `patient1@mindhealth.com` + seed `therapist_profiles.csv` để đăng nhập CMS được ngay.
- **Seed:** Seeder chuyển sang chế độ AUTO: chỉ seed khi database còn rỗng (các bảng cốt lõi chưa có dữ liệu), nếu đã có dữ liệu thì tự skip.
- **Seed:** Seeder không còn crash khi trùng dữ liệu (skip theo `email/username`, không bọc 1 transaction toàn seeding).
- **Config:** Backend port mặc định là `8081` (có thể override bằng `SERVER_PORT`) và đã đồng bộ Docker/Postman/docs.
- **Web CMS (Admin):** Bỏ tab Analytics (Demo), đổi "Quản lý Users" thành "Hồ sơ Bệnh nhân" (gán bác sĩ + khóa/mở account), giữ "Kho CBT" và "Quản lý Bác sĩ (Approval)".
- **Backend (Admin):** Thêm API `GET /api/admin/patients` trả DTO hồ sơ bệnh nhân; tách service tạo tài khoản therapist để fix lỗi `detached entity passed to persist`.
- **AI (Phase 2):** Thêm API `POST /api/ai/guided-discovery` (Gemini) và bật chấm `aiRiskScore` server-side khi lưu Journal (cấu hình qua `AI_ENABLED`, `GEMINI_API_KEY`).
- **AI (Thought Record):** Thêm API `POST /api/ai/cognitive-distortions` (gợi ý 1–3 lỗi tư duy) + Flutter auto-tick Step 4, có fallback khi AI bận.
- **Flutter (Phase 2):** Màn Thought Record bước Guided Discovery gọi backend để lấy 1–2 câu hỏi Socratic (fallback câu hỏi mặc định khi AI bận).
 - **Web CMS (Phase 4):** Web login thật qua backend + Therapist dashboard lấy danh sách bệnh nhân từ API, có chế độ Emergency Alert (redFlagOnly) và badge đếm cờ đỏ.
- **Phase 3 (AI Vision):** Thêm API `POST /api/roadmap/quests/{id}/proof/verify` (multipart) lưu ảnh minh chứng vào `/uploads/proofs/*`, gọi **Gemini Vision** để chấm `relevant/confidence/score/reason`, trả về `accepted` để Flutter quyết định hoàn thành quest.
- **Phase 3 (Graduation Rule):** Implement rule “Tốt nghiệp” theo BRD: khi có **2 lần PHQ-9 PERIODIC liên tiếp < 5** thì backend set `patient_profiles.tapering_stage=WEEKLY`, đồng thời trả về `graduatedNow=true` trong response `POST /api/assessment/phq9` để Flutter hiển thị popup Tốt nghiệp.
- **QA:** Thêm checklist test UI theo từng phase: `docs/TEST_SCENARIOS.md`.
- **Phase 4 (Telehealth):** Thêm module Appointment (backend `booster`) với APIs: `GET /api/booster/slots`, `POST /api/booster/appointments/book`, `GET /api/booster/appointments/my`; Flutter wire UI booking + lịch sử đặt khám (Telehealth).
- **Phase 5 (Admin CRUD):** Thêm APIs quản trị: `GET/PATCH /api/admin/users` (set active/role) và `GET/POST/PUT/DELETE /api/admin/quest-templates` để quản lý nội dung nhiệm vụ Roadmap.
- **Phase 5 (Cron):** Thêm job `TaperingBoosterCronJob` chạy hằng ngày để cập nhật `tapering_stage` theo thời gian từ `graduated_at` và tạo appointment `TAPERING/BOOSTER_*` (có endpoint manual `POST /api/booster/scheduling/run`).
- **Web Admin UI:** Wire Web CMS Admin screens để quản lý `Users` và `Quest Templates` qua APIs `/api/admin/*` (không còn mock danh sách quests).
- **Admin Analytics + Approval:** Thêm backend APIs `/api/admin/analytics` và `/api/admin/therapists/*`, đồng thời wire Web Admin analytics + duyệt therapist theo dữ liệu thật.
### Changed
- **AI Risk:** Chuyển sang mô hình hybrid “rule-based trước” và **chỉ gọi Gemini khi nghi ngờ** (mặc định threshold 70) để giảm quota/cost; thêm env `AI_RISK_CALL_AI_ONLY_WHEN_SUSPICIOUS`, `AI_RISK_AI_CALL_THRESHOLD` + script test `scratch/test_journal_ai_rule_scoring.py`.
### Changed
- **Docs:** Tinh chỉnh `docs/BRD_SUMMARY.md` để bám sát các ngưỡng/con số BRD (Risk weights 40/40/20, mood branch 45%, trigger Risk ≥ 70, override Risk=100) nhưng vẫn tối ưu token.
- **Docs:** Đồng bộ lại `PROGRESS_CHECKLIST.md` để khớp tiến độ thực tế theo `docs/plans/master-plan.md` + `CHANGELOG.md`.
### Added
- **Phase 4 (Backend APIs):** Thêm API Admin assign/reassign therapist `POST /api/admin/patients/{patientId}/assign-therapist` và API Therapist list patients `GET /api/therapist/patients?redFlagOnly=...` để phục vụ dashboard + emergency alert.
### Changed
- **Docs:** Đồng bộ ngưỡng rẽ nhánh Mood Check-in theo BRD: `Mood < 45%` → Thought Record, `Mood ≥ 45%` → Credit List (sửa `docs/APP_SPECIFICATION_ReConnect.md` từ 50% về 45%).
### Fixed
- **Flutter Journal:** Parse JSON robust hơn cho `createDate`/điểm số (handle cả trường hợp backend trả timestamp number), tránh crash khi tải danh sách nhật ký.
- **Authentication:** Chặn therapist chưa được duyệt (`approval_status != ACTIVE`) không được login; đồng thời chặn user bị khóa (`is_active=false`) khi login.
### Changed
- **Docs:** Cập nhật `PROGRESS_CHECKLIST.md` để phản ánh đúng tiến độ Module Journal (Entity + APIs đã hoàn thành, còn thiếu Gemini NLP + ai_risk_score).
### Added
- **Automation:** Thêm script smoke-test Journal list API: `scratch/test_journal_list_api.py` (login → lấy danh sách journals).
### Added
- **Assessment:** Enforce Baseline PHQ-9 đúng nghiệp vụ (Baseline chỉ 1 lần; nếu chưa có baseline thì backend tự ghi `submissionType=BASELINE`, set `unlockedAt=+14 ngày`).
- **Clinical:** Thêm API Goal Setting `POST /api/clinical/goals` lưu `patient_profiles.goals_json` (validate 3–5 goals).
- **Flutter Onboarding:** Goal Setting screen gọi API lưu goals trước khi qua Psychoeducation (Provider/Repository riêng).
### Added
- **Clinical:** Thêm API `GET /api/clinical/goals?patientId=...` để app load lại goals đã lưu (phục vụ hiển thị/cho sửa).
### Changed
- **Flutter Onboarding:** Sau khi nộp PHQ-9 nếu là `BASELINE` thì điều hướng sang `Goal Setting` (thay vì về Home). Nếu goals đã có thì màn `Goal Setting` chuyển sang chế độ xem (khóa chỉnh sửa) và cho quay về Home.
### Fixed
- **Flutter PHQ-9:** Khi mở trực tiếp `/phq9` mà chưa đăng nhập (patientId rỗng), hiển thị màn nhắc đăng nhập thay vì báo “Không tìm thấy dữ liệu câu hỏi.”
### Added
- **Docs:** Thêm test account local vào `SETUP_GUIDE.md`.
### Added
- **Roadmap (Backend):** Thêm Module Roadmap (QuestTemplate/PatientQuest), seed `quest_templates.csv`, API `GET /api/roadmap/daily` (tối đa 2 quest/ngày, mở khóa 06:00) và `POST /api/roadmap/quests/{id}/complete` (lưu Mastery/Pleasure).
- **Roadmap (Flutter):** Roadmap UI lấy dữ liệu thật từ backend + hoàn thành quest từ `QuestDetailScreen`.
- **Automation:** Thêm script smoke-test Roadmap: `scratch/test_roadmap_daily_api.py`.
### Added
- **Clinical:** Thêm onboarding gating APIs: `GET /api/clinical/onboarding-status` và `POST /api/clinical/psychoeducation/complete` (lưu cờ hoàn thành psychoeducation trên `patient_profiles`).
- **Flutter Onboarding:** Psychoeducation màn cuối gọi API complete; Patient shell tự redirect về bước onboarding còn thiếu.
- **Automation:** Thêm script smoke-test onboarding: `scratch/test_onboarding_status_api.py`.
### Added
- **Risk Index (Cron):** Bật `@EnableScheduling`, thêm Cron Job chạy 00:00 mỗi ngày (Asia/Bangkok) tính Risk Index theo BRD (PHQ-9 + AI + Mood + Override Rule) và lưu `patient_profiles.current_risk_score` + `is_red_flag_active`.
- **Risk Index (API/Automation):** Thêm API `POST /api/risk/run-now` và `POST /api/risk/run-one?patientId=...` + script `scratch/test_risk_index_api.py` để test không cần chờ 00:00.
### Fixed
- **Assessment:** Sửa `q2_score` lưu đúng theo PHQ-9 câu #2 (0-3) thay vì cộng câu 1+2.

## [1.0.2] - 2026-05-12
### Added
- **Journal Module (CBT Journal):** Thiết lập trọn gói kiến trúc cho Module Nhật ký tự do bao gồm:
  - **Backend:**
    - Khởi tạo thực thể `Journal.java` kế thừa `BaseObject` liên kết 1-N với `PatientProfile` và tự động mapping tạo bảng `journals` trong MySQL.
    - Xây dựng lớp tiện ích mã hóa y tế `EncryptionUtil.java` sử dụng thuật toán **AES-128 CBC** bảo mật tuyệt đối các thông tin nhạy cảm (PHI) của bệnh nhân.
    - Triển khai cơ chế đóng gói linh hoạt (JSON Serialization) các trường của Thought Record (`situation`, `automaticThought`, `emotion`, `emotionScore`, `adaptiveResponse`, `reRatedScore`) và Credit List (`content`) thành JSON, mã hóa, giải mã ngược lại sang DTO phẳng `JournalDto.java` cho App Flutter hiển thị dễ dàng.
    - Cung cấp các Endpoint RESTful: `POST /api/journal/thought-records` (Lưu nhật ký), `GET /api/journal/thought-records` (Lấy danh sách nhật ký), `GET /api/journal/thought-records/{id}` (Xem chi tiết nhật ký kèm kiểm tra phân quyền an toàn).
    - Viết tập lệnh kiểm thử tự động `test_journal_module.py` tại thư mục scratch kiểm tra thành công 100% tất cả các APIs và xác thực dữ liệu được mã hóa dạng ciphertext dưới cơ sở dữ liệu MySQL.
  - **Frontend (Flutter):**
    - Thiết lập mô hình dữ liệu y tế `JournalModel.dart` hỗ trợ tuần tự hóa JSON hai chiều khớp tuyệt đối với DTO ở Backend.
    - Xây dựng lớp kho lưu trữ kết nối `JournalRepository.dart` bằng thư viện `http` kế thừa đồng bộ cơ chế Token JWT bảo mật.
    - Triển khai state management `JournalProvider.dart` quản lý phản hồi, tự động cập nhật danh sách nhật ký cục bộ ngay sau khi người dùng gửi thành công.
    - Tích hợp `JournalProvider` toàn cục vào `MultiProvider` tại `app.dart`.
    - Kết nối luồng lưu dữ liệu y tế thực tế tại `ThoughtRecordScreen` thay thế cho dữ liệu tĩnh trước đó, hỗ trợ tự động gửi 6 bước nhận thức lên DB khi nhấn nút hoàn tất.
    - Thiết kế lại toàn bộ màn hình `journal_ai_screen.dart` thành một Timeline lịch sử sống động, tự động phân tách giao diện trực quan cho Nhật ký 6 bước (màu vàng ấm) và Thẻ ghi nhận nỗ lực (màu xanh mát), đồng thời phát triển các hộp thoại (Details Dialog) hiển thị cực kỳ sang xịn mịn.

## [1.0.1] - 2026-05-10
### Added
- Khởi tạo hệ thống tài liệu Solo Builder (`AGENTS.md`, `brief.md`, `BRD.md`, `master-plan.md`).

### Fixed
- **Authentication:** Khắc phục lỗi đăng nhập ẩn danh không tự động tạo `PatientProfile` khiến chức năng submit Mood bị lỗi `EntityNotFoundException` ở Backend.
- **Database Seeder:** Khắc phục lỗi `DatabaseSeeder` lưu profile sai UUID do Hibernate `@GeneratedValue` tự động đè UUID từ file CSV. Đã thêm logic mapping qua `csvIdToEmailMap` và bổ sung `@Transactional` để khắc phục lỗi Detached Entity triệt để.
- **Assessment:** Chức năng `Daily Mood Check-in` đã hoạt động thành công từ Flutter App và được nâng cấp lên cơ chế **Upsert** (Cập nhật tự động nếu đã có bản ghi Mood trong ngày, ngăn ngừa sinh bản ghi trùng lặp gây lãng phí dung lượng database).

## [1.0.0] - Trước 2026-05-10
### Added
- Khởi tạo Spring Boot Backend (Auth, Assessment, Security JWT).
- Khởi tạo Flutter Mobile App (Provider architecture, Dio API client).
- Tích hợp Database MySQL và cấu hình Seeder cơ bản.
## [1.0.3] - 2026-05-22
### Added
- **Clinical (Backend):** Thêm entity `TherapistCredential` + lưu file vào `uploads/therapist-credentials/<therapistId>/...` và API upload/list/download cho therapist & admin.
- **Clinical (Backend):** Thêm `TherapistAccessGuardService` để chặn các API chuyên môn của therapist khi chưa `ACTIVE` (PENDING chỉ được upload chứng chỉ).
- **CMS (Web):** Thêm màn therapist upload chứng chỉ + Admin xem/tải chứng chỉ trong màn “Quản lý Bác sĩ (Approval)”, và chặn duyệt `ACTIVE` nếu chưa có chứng chỉ.
- **Seeder (Backend):** Seed theo từng bước, lỗi 1 bảng không làm dừng seed các bảng khác; seed profiles dùng `getReferenceById` để tránh detached.
- **Admin CMS:** Bổ sung quản lý tài khoản bác sĩ: khóa/mở (`/api/admin/users/{id}/active`), chỉnh sửa profile + reset mật khẩu (`/api/admin/therapists/{id}` / `reset-password`).
- **Clinical (Backend/Web/App):** Admin gán bác sĩ thủ công cho bệnh nhân + giới hạn caseload 20; app patient bỏ luồng chọn bác sĩ, booking chỉ theo therapist đã gán.
### Changed
- **Auth (Backend):** Therapist `PENDING` được login để upload chứng chỉ (chỉ chặn login khi `REJECTED` hoặc `is_active=false`).
### Docs
- Cập nhật `docs/UI_TEST_RUNBOOK.md` theo luồng “Upload chứng chỉ -> Admin duyệt -> ACTIVE”.
