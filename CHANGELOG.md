# CHANGELOG (Nháº­t kÃ½ Thay Ä‘á»•i)

Táº¥t cáº£ cÃ¡c thay Ä‘á»•i lá»›n vá» tÃ­nh nÄƒng, sá»­a lá»—i, vÃ  cáº¥u trÃºc há»‡ thá»‘ng cá»§a dá»± Ã¡n ReConnect MindHealth sáº½ Ä‘Æ°á»£c lÆ°u trá»¯ táº¡i Ä‘Ã¢y.
Quy táº¯c: Äá»‹nh dáº¡ng theo chuáº©n [Keep a Changelog](https://keepachangelog.com/en/1.0.0/). AI pháº£i tá»± Ä‘á»™ng thÃªm vÃ o Ä‘Ã¢y sau má»—i láº§n hoÃ n thÃ nh má»™t phase hoáº·c fix xong má»™t issue.

## [Unreleased]
### Added
- **Assessment:** Chuẩn hóa PHQ-9 theo form gốc: API questionnaire trả `instruction`, scale 0-3, câu impairment/functioning, lựa chọn 1-4 và citation nguồn Kroenke/Spitzer/Williams; submission lưu thêm `functionalDifficultyScore` nullable.
- **AI:** ThÃªm debug log cho Gemini runtime: log lÃºc báº¯t Ä‘áº§u gá»i model, lÃºc HTTP 2xx thÃ nh cÃ´ng, lÃºc response rá»—ng/parse guided-discovery rá»—ng Ä‘á»ƒ phÃ¢n biá»‡t gá»i Gemini tháº­t hay fallback.
- **AI:** Siáº¿t prompt Guided Discovery tráº£ JSON thuáº§n vÃ  thÃªm `responseMimeType=application/json`; log snippet response ngáº¯n Ä‘á»ƒ debug parse fail mÃ  khÃ´ng lá»™ API key.
- **AI:** ThÃªm JSON response schema riÃªng cho Guided Discovery, tÄƒng `maxOutputTokens` vÃ  giáº£m temperature Ä‘á»ƒ trÃ¡nh Gemini tráº£ markdown/code fence lÃ m parser fallback.
- **AI:** TÄƒng token Guided Discovery lÃªn `1024` vÃ  log raw Gemini response snippet Ä‘á»ƒ debug trÆ°á»ng há»£p JSON bá»‹ cáº¯t giá»¯a chá»«ng.
- **AI:** ThÃªm log startup an toÃ n `AI startup config: enabled=..., geminiModel=..., apiKeyPresent=...` Ä‘á»ƒ kiá»ƒm tra env Gemini mÃ  khÃ´ng lá»™ API key.
- **Telehealth:** ThÃªm ghi chÃº sau buá»•i tÆ° váº¥n (`therapistNotes`) cho appointment vÃ  API `PATCH /api/booster/appointments/{appointmentId}/notes`; chá»‰ admin hoáº·c bÃ¡c sÄ© phá»¥ trÃ¡ch Ä‘Æ°á»£c lÆ°u.
- **Telehealth:** ThÃªm lá»‹ch lÃ m viá»‡c cá»‘ Ä‘á»‹nh theo tuáº§n qua `therapist_weekly_schedule_slots`, API `GET /api/booster/weekly-schedule` vÃ  `POST /api/booster/weekly-schedule/toggle`; lá»‹ch theo ngÃ y váº«n dÃ¹ng Ä‘á»ƒ ghi Ä‘Ã¨ ngoáº¡i lá»‡.
- **CBT:** ThÃªm API therapist gÃ¡n quest cÃ¡ nhÃ¢n hÃ³a cho bá»‡nh nhÃ¢n (`GET /api/therapist/quest-templates`, `POST /api/therapist/patients/{patientId}/quests`) vÃ  mÃ n web chá»n/gÃ¡n bÃ i táº­p CBT tá»« kho tháº­t.
- **CBT/Roadmap:** NÃ¢ng cáº¥p auto-assignment theo rule cÃ¡ nhÃ¢n hÃ³a dá»±a trÃªn PHQ-9, risk score vÃ  red flag; patient app hiá»ƒn thá»‹ nhÃ£n `Tá»± Ä‘á»™ng` hoáº·c `BÃ¡c sÄ© giao`.
- **Docs:** ThÃªm `docs/GEMINI_SETUP.md` hÆ°á»›ng dáº«n láº¥y Gemini API key, báº­t/táº¯t `AI_ENABLED` vÃ  cÃ¡c luá»“ng Ä‘ang dÃ¹ng Gemini.
- **Therapist Profile:** ThÃªm upload avatar `POST /api/therapist/profile/avatar` vÃ  quáº£n lÃ½ chá»©ng chá»‰ ngay trong há»“ sÆ¡; há»— trá»£ xÃ³a chá»©ng chá»‰ cá»§a chÃ­nh bÃ¡c sÄ© qua `DELETE /api/therapist/credentials/{credentialId}`.
- **Therapist Profile:** ThÃªm API `GET/PUT /api/therapist/profile` Ä‘á»ƒ bÃ¡c sÄ© tá»± lÆ°u há»“ sÆ¡ vÃ  `meetingLink`; khi lÆ°u link sáº½ tá»± bá»• sung cho cÃ¡c lá»‹ch `BOOKED` Ä‘ang thiáº¿u link.
- **Telehealth:** Bá»• sung API cáº­p nháº­t tráº¡ng thÃ¡i lá»‹ch háº¹n `PATCH /api/booster/appointments/{appointmentId}/status?status=COMPLETED|CANCELLED`, chá»‰ cho admin hoáº·c bÃ¡c sÄ© phá»¥ trÃ¡ch thao tÃ¡c.
- **Telehealth UI:** Patient App hiá»ƒn thá»‹ lá»‹ch háº¹n dáº¡ng card cÃ³ tráº¡ng thÃ¡i, giá» háº¹n vÃ  nÃºt copy link phÃ²ng tÆ° váº¥n; Therapist Web cÃ³ action vÃ o phÃ²ng há»p, hoÃ n thÃ nh vÃ  há»§y lá»‹ch.
- **Clinical (Backend):** ThÃªm API `GET /api/clinical/therapist-assignment-status?patientId=...` Ä‘á»ƒ UI patient gating â€œÄ‘Ã£ Ä‘Æ°á»£c gÃ¡n bÃ¡c sÄ© chÆ°a?â€.
- **Therapist Web:** ThÃªm mÃ n â€œLá»‹ch lÃ m viá»‡câ€ (toggle 6 slot/ngÃ y) + â€œLá»‹ch Ä‘Ã£ Ä‘áº·tâ€ (load tá»« backend) dÃ¹ng `/api/booster/*`.
- **Seed:** Bá»• sung & sá»­a encoding UTF-8 cho `reconnect_backend/src/main/resources/seed_data/quest_templates.csv` Ä‘á»ƒ â€œKho CBTâ€ luÃ´n cÃ³ dá»¯ liá»‡u máº«u.

### Changed
- **Therapist Web:** Há»“ sÆ¡ chuyÃªn gia hiá»ƒn thá»‹ avatar tháº­t náº¿u cÃ³, thÃªm nÃºt Ä‘á»•i áº£nh vÃ  danh sÃ¡ch chá»©ng chá»‰ vá»›i upload/táº£i xuá»‘ng/xÃ³a.
- **Therapist Web:** MÃ n â€œHá»“ sÆ¡ & CÃ i Ä‘áº·t ChuyÃªn giaâ€ chuyá»ƒn tá»« mock sang load/lÆ°u dá»¯ liá»‡u tháº­t, validate meeting link pháº£i báº¯t Ä‘áº§u báº±ng `http://` hoáº·c `https://`.
- **Telehealth:** DTO lá»‹ch háº¹n tráº£ thÃªm `patientDisplayName`, `therapistDisplayName` vÃ  giá»¯ `meetingLink` Ä‘á»ƒ patient/bÃ¡c sÄ© dÃ¹ng trá»±c tiáº¿p trong MVP, khÃ´ng gá»­i email tá»± Ä‘á»™ng.

### Fixed
- **Assessment:** Sửa seed PHQ-9 UTF-8 tiếng Việt và upsert lại 9 câu chuẩn khi backend khởi động để DB cũ không giữ dữ liệu mojibake.
- **Telehealth:** Chuáº©n hÃ³a message tiáº¿ng Viá»‡t (UTF-8) trÃªn backend Booster/Clinical/Auth, trÃ¡nh lá»—i mojibake khi hiá»ƒn thá»‹ trÃªn UI.
- **Patient App:** Sá»­a toÃ n bá»™ text bá»‹ mojibake á»Ÿ flow Telehealth/Booking vÃ  Roadmap repository.
### Fixed
- **Web Admin CMS:** Kháº¯c phá»¥c lá»—i hiá»ƒn thá»‹ cá»§a nÃºt "KhoÃ¡ tÃ i khoáº£n" (báº¥m khoÃ¡ nhÆ°ng UI báº­t láº¡i tráº¡ng thÃ¡i cÅ©) do API Backend `UserDto` thiáº¿u trÆ°á»ng `isActive` khi tráº£ vá» sau lá»‡nh PATCH. ÄÃ£ bá»• sung `isActive` vÃ o `UserDto` Ä‘á»ƒ Ä‘á»“ng bá»™ chÃ­nh xÃ¡c tráº¡ng thÃ¡i UI.
- **Web Admin CMS:** Sá»­a triá»‡t Ä‘á»ƒ lá»—i font tiáº¿ng Viá»‡t (mojibake) hiá»ƒn thá»‹ trÃªn giao diá»‡n quáº£n trá»‹ viÃªn duyá»‡t chuyÃªn gia (`reconnect_web/lib/screens/admin/admin_verify_doctor_screen.dart`), chuyá»ƒn Ä‘á»•i toÃ n bá»™ cÃ¡c chuá»—i kÃ½ tá»± bá»‹ lá»—i (nhÆ° "ChÆ°a Ä‘Äƒng nháº­p", "Chá»©ng chá»‰", "Há» tÃªn", "ÄÃ£ táº¡o tÃ i khoáº£n...", "ÄÃƒ Cáº¤P PHÃ‰P", "Tá»ª CHá»I", "ÄÃ³ng") vá» Ä‘á»‹nh dáº¡ng tiáº¿ng Viá»‡t chuáº©n UTF-8. Báº£o toÃ n 100% cÃ¡c tÃ­nh nÄƒng chá»‰nh sá»­a há»“ sÆ¡ vÃ  Ä‘áº·t láº¡i máº­t kháº©u bÃ¡c sÄ© Ä‘Æ°á»£c phÃ¡t triá»ƒn trÆ°á»›c Ä‘Ã³.

### Added
- **Docs:** ThÃªm â€œAI Context Packâ€ Ä‘á»ƒ giáº£m token náº¡p ngá»¯ cáº£nh: `docs/AI_CONTEXT.md`, `docs/BRD_SUMMARY.md`, `docs/summaries/*`, kÃ¨m audit `docs/TOKEN_AUDIT.md` vÃ  script generate `scratch/audit_md_tokens.py`.
- **DevTools:** ThÃªm Postman artifacts demo nhanh (admin/approval/login): `infra/postman/ReConnectMindHealth_AdminApprovalLogin.postman_collection.json` + env local `infra/postman/ReConnectMindHealth_Local.postman_environment.json`.
- **DevTools:** ThÃªm Postman collection full Ä‘á»ƒ test end-to-end nhanh toÃ n bá»™ MVP: `infra/postman/ReConnectMindHealth_Full.postman_collection.json`.
- **DevOps:** ThÃªm Docker deployment cho full stack (MySQL + Backend + Web CMS): `infra/docker-compose.yml`, `reconnect_backend/Dockerfile`, `reconnect_web/Dockerfile`, `docs/DEPLOY_DOCKER.md`.
- **DevTools:** Cho phÃ©p cáº¥u hÃ¬nh `API_BASE_URL` báº±ng `--dart-define` cho Flutter Web CMS vÃ  Flutter App (trÃ¡nh hard-code localhost).
- **Docs:** ThÃªm checklist test theo luá»“ng giao diá»‡n Ä‘á»ƒ demo/bao ve: `docs/UI_TEST_RUNBOOK.md`.
- **Seed:** Bá»• sung sáºµn tÃ i khoáº£n demo `admin@mindhealth.com`, `therapist1@mindhealth.com`, `patient1@mindhealth.com` + seed `therapist_profiles.csv` Ä‘á»ƒ Ä‘Äƒng nháº­p CMS Ä‘Æ°á»£c ngay.
- **Seed:** Seeder chuyá»ƒn sang cháº¿ Ä‘á»™ AUTO: chá»‰ seed khi database cÃ²n rá»—ng (cÃ¡c báº£ng cá»‘t lÃµi chÆ°a cÃ³ dá»¯ liá»‡u), náº¿u Ä‘Ã£ cÃ³ dá»¯ liá»‡u thÃ¬ tá»± skip.
- **Seed:** Seeder khÃ´ng cÃ²n crash khi trÃ¹ng dá»¯ liá»‡u (skip theo `email/username`, khÃ´ng bá»c 1 transaction toÃ n seeding).
- **Config:** Backend port máº·c Ä‘á»‹nh lÃ  `8081` (cÃ³ thá»ƒ override báº±ng `SERVER_PORT`) vÃ  Ä‘Ã£ Ä‘á»“ng bá»™ Docker/Postman/docs.
- **Web CMS (Admin):** Bá» tab Analytics (Demo), Ä‘á»•i "Quáº£n lÃ½ Users" thÃ nh "Há»“ sÆ¡ Bá»‡nh nhÃ¢n" (gÃ¡n bÃ¡c sÄ© + khÃ³a/má»Ÿ account), giá»¯ "Kho CBT" vÃ  "Quáº£n lÃ½ BÃ¡c sÄ© (Approval)".
- **Backend (Admin):** ThÃªm API `GET /api/admin/patients` tráº£ DTO há»“ sÆ¡ bá»‡nh nhÃ¢n; tÃ¡ch service táº¡o tÃ i khoáº£n therapist Ä‘á»ƒ fix lá»—i `detached entity passed to persist`.
- **AI (Phase 2):** ThÃªm API `POST /api/ai/guided-discovery` (Gemini) vÃ  báº­t cháº¥m `aiRiskScore` server-side khi lÆ°u Journal (cáº¥u hÃ¬nh qua `AI_ENABLED`, `GEMINI_API_KEY`).
- **AI (Thought Record):** ThÃªm API `POST /api/ai/cognitive-distortions` (gá»£i Ã½ 1â€“3 lá»—i tÆ° duy) + Flutter auto-tick Step 4, cÃ³ fallback khi AI báº­n.
- **Flutter (Phase 2):** MÃ n Thought Record bÆ°á»›c Guided Discovery gá»i backend Ä‘á»ƒ láº¥y 1â€“2 cÃ¢u há»i Socratic (fallback cÃ¢u há»i máº·c Ä‘á»‹nh khi AI báº­n).
 - **Web CMS (Phase 4):** Web login tháº­t qua backend + Therapist dashboard láº¥y danh sÃ¡ch bá»‡nh nhÃ¢n tá»« API, cÃ³ cháº¿ Ä‘á»™ Emergency Alert (redFlagOnly) vÃ  badge Ä‘áº¿m cá» Ä‘á».
- **Phase 3 (AI Vision):** ThÃªm API `POST /api/roadmap/quests/{id}/proof/verify` (multipart) lÆ°u áº£nh minh chá»©ng vÃ o `/uploads/proofs/*`, gá»i **Gemini Vision** Ä‘á»ƒ cháº¥m `relevant/confidence/score/reason`, tráº£ vá» `accepted` Ä‘á»ƒ Flutter quyáº¿t Ä‘á»‹nh hoÃ n thÃ nh quest.
- **Phase 3 (Graduation Rule):** Implement rule â€œTá»‘t nghiá»‡pâ€ theo BRD: khi cÃ³ **2 láº§n PHQ-9 PERIODIC liÃªn tiáº¿p < 5** thÃ¬ backend set `patient_profiles.tapering_stage=WEEKLY`, Ä‘á»“ng thá»i tráº£ vá» `graduatedNow=true` trong response `POST /api/assessment/phq9` Ä‘á»ƒ Flutter hiá»ƒn thá»‹ popup Tá»‘t nghiá»‡p.
- **QA:** ThÃªm checklist test UI theo tá»«ng phase: `docs/TEST_SCENARIOS.md`.
- **Phase 4 (Telehealth):** ThÃªm module Appointment (backend `booster`) vá»›i APIs: `GET /api/booster/slots`, `POST /api/booster/appointments/book`, `GET /api/booster/appointments/my`; Flutter wire UI booking + lá»‹ch sá»­ Ä‘áº·t khÃ¡m (Telehealth).
- **Phase 5 (Admin CRUD):** ThÃªm APIs quáº£n trá»‹: `GET/PATCH /api/admin/users` (set active/role) vÃ  `GET/POST/PUT/DELETE /api/admin/quest-templates` Ä‘á»ƒ quáº£n lÃ½ ná»™i dung nhiá»‡m vá»¥ Roadmap.
- **Phase 5 (Cron):** ThÃªm job `TaperingBoosterCronJob` cháº¡y háº±ng ngÃ y Ä‘á»ƒ cáº­p nháº­t `tapering_stage` theo thá»i gian tá»« `graduated_at` vÃ  táº¡o appointment `TAPERING/BOOSTER_*` (cÃ³ endpoint manual `POST /api/booster/scheduling/run`).
- **Web Admin UI:** Wire Web CMS Admin screens Ä‘á»ƒ quáº£n lÃ½ `Users` vÃ  `Quest Templates` qua APIs `/api/admin/*` (khÃ´ng cÃ²n mock danh sÃ¡ch quests).
- **Admin Analytics + Approval:** ThÃªm backend APIs `/api/admin/analytics` vÃ  `/api/admin/therapists/*`, Ä‘á»“ng thá»i wire Web Admin analytics + duyá»‡t therapist theo dá»¯ liá»‡u tháº­t.
### Changed
- **AI Risk:** Chuyá»ƒn sang mÃ´ hÃ¬nh hybrid â€œrule-based trÆ°á»›câ€ vÃ  **chá»‰ gá»i Gemini khi nghi ngá»** (máº·c Ä‘á»‹nh threshold 70) Ä‘á»ƒ giáº£m quota/cost; thÃªm env `AI_RISK_CALL_AI_ONLY_WHEN_SUSPICIOUS`, `AI_RISK_AI_CALL_THRESHOLD` + script test `scratch/test_journal_ai_rule_scoring.py`.
### Changed
- **Docs:** Tinh chá»‰nh `docs/BRD_SUMMARY.md` Ä‘á»ƒ bÃ¡m sÃ¡t cÃ¡c ngÆ°á»¡ng/con sá»‘ BRD (Risk weights 40/40/20, mood branch 45%, trigger Risk â‰¥ 70, override Risk=100) nhÆ°ng váº«n tá»‘i Æ°u token.
- **Docs:** Äá»“ng bá»™ láº¡i `PROGRESS_CHECKLIST.md` Ä‘á»ƒ khá»›p tiáº¿n Ä‘á»™ thá»±c táº¿ theo `docs/plans/master-plan.md` + `CHANGELOG.md`.
### Added
- **Phase 4 (Backend APIs):** ThÃªm API Admin assign/reassign therapist `POST /api/admin/patients/{patientId}/assign-therapist` vÃ  API Therapist list patients `GET /api/therapist/patients?redFlagOnly=...` Ä‘á»ƒ phá»¥c vá»¥ dashboard + emergency alert.
### Changed
- **Docs:** Äá»“ng bá»™ ngÆ°á»¡ng ráº½ nhÃ¡nh Mood Check-in theo BRD: `Mood < 45%` â†’ Thought Record, `Mood â‰¥ 45%` â†’ Credit List (sá»­a `docs/APP_SPECIFICATION_ReConnect.md` tá»« 50% vá» 45%).
### Fixed
- **Flutter Journal:** Parse JSON robust hÆ¡n cho `createDate`/Ä‘iá»ƒm sá»‘ (handle cáº£ trÆ°á»ng há»£p backend tráº£ timestamp number), trÃ¡nh crash khi táº£i danh sÃ¡ch nháº­t kÃ½.
- **Authentication:** Cháº·n therapist chÆ°a Ä‘Æ°á»£c duyá»‡t (`approval_status != ACTIVE`) khÃ´ng Ä‘Æ°á»£c login; Ä‘á»“ng thá»i cháº·n user bá»‹ khÃ³a (`is_active=false`) khi login.
### Changed
- **Docs:** Cáº­p nháº­t `PROGRESS_CHECKLIST.md` Ä‘á»ƒ pháº£n Ã¡nh Ä‘Ãºng tiáº¿n Ä‘á»™ Module Journal (Entity + APIs Ä‘Ã£ hoÃ n thÃ nh, cÃ²n thiáº¿u Gemini NLP + ai_risk_score).
### Added
- **Automation:** ThÃªm script smoke-test Journal list API: `scratch/test_journal_list_api.py` (login â†’ láº¥y danh sÃ¡ch journals).
### Added
- **Assessment:** Enforce Baseline PHQ-9 Ä‘Ãºng nghiá»‡p vá»¥ (Baseline chá»‰ 1 láº§n; náº¿u chÆ°a cÃ³ baseline thÃ¬ backend tá»± ghi `submissionType=BASELINE`, set `unlockedAt=+14 ngÃ y`).
- **Clinical:** ThÃªm API Goal Setting `POST /api/clinical/goals` lÆ°u `patient_profiles.goals_json` (validate 3â€“5 goals).
- **Flutter Onboarding:** Goal Setting screen gá»i API lÆ°u goals trÆ°á»›c khi qua Psychoeducation (Provider/Repository riÃªng).
### Added
- **Clinical:** ThÃªm API `GET /api/clinical/goals?patientId=...` Ä‘á»ƒ app load láº¡i goals Ä‘Ã£ lÆ°u (phá»¥c vá»¥ hiá»ƒn thá»‹/cho sá»­a).
### Changed
- **Flutter Onboarding:** Sau khi ná»™p PHQ-9 náº¿u lÃ  `BASELINE` thÃ¬ Ä‘iá»u hÆ°á»›ng sang `Goal Setting` (thay vÃ¬ vá» Home). Náº¿u goals Ä‘Ã£ cÃ³ thÃ¬ mÃ n `Goal Setting` chuyá»ƒn sang cháº¿ Ä‘á»™ xem (khÃ³a chá»‰nh sá»­a) vÃ  cho quay vá» Home.
### Fixed
- **Flutter PHQ-9:** Khi má»Ÿ trá»±c tiáº¿p `/phq9` mÃ  chÆ°a Ä‘Äƒng nháº­p (patientId rá»—ng), hiá»ƒn thá»‹ mÃ n nháº¯c Ä‘Äƒng nháº­p thay vÃ¬ bÃ¡o â€œKhÃ´ng tÃ¬m tháº¥y dá»¯ liá»‡u cÃ¢u há»i.â€
### Added
- **Docs:** ThÃªm test account local vÃ o `SETUP_GUIDE.md`.
### Added
- **Roadmap (Backend):** ThÃªm Module Roadmap (QuestTemplate/PatientQuest), seed `quest_templates.csv`, API `GET /api/roadmap/daily` (tá»‘i Ä‘a 2 quest/ngÃ y, má»Ÿ khÃ³a 06:00) vÃ  `POST /api/roadmap/quests/{id}/complete` (lÆ°u Mastery/Pleasure).
- **Roadmap (Flutter):** Roadmap UI láº¥y dá»¯ liá»‡u tháº­t tá»« backend + hoÃ n thÃ nh quest tá»« `QuestDetailScreen`.
- **Automation:** ThÃªm script smoke-test Roadmap: `scratch/test_roadmap_daily_api.py`.
### Added
- **Clinical:** ThÃªm onboarding gating APIs: `GET /api/clinical/onboarding-status` vÃ  `POST /api/clinical/psychoeducation/complete` (lÆ°u cá» hoÃ n thÃ nh psychoeducation trÃªn `patient_profiles`).
- **Flutter Onboarding:** Psychoeducation mÃ n cuá»‘i gá»i API complete; Patient shell tá»± redirect vá» bÆ°á»›c onboarding cÃ²n thiáº¿u.
- **Automation:** ThÃªm script smoke-test onboarding: `scratch/test_onboarding_status_api.py`.
### Added
- **Risk Index (Cron):** Báº­t `@EnableScheduling`, thÃªm Cron Job cháº¡y 00:00 má»—i ngÃ y (Asia/Bangkok) tÃ­nh Risk Index theo BRD (PHQ-9 + AI + Mood + Override Rule) vÃ  lÆ°u `patient_profiles.current_risk_score` + `is_red_flag_active`.
- **Risk Index (API/Automation):** ThÃªm API `POST /api/risk/run-now` vÃ  `POST /api/risk/run-one?patientId=...` + script `scratch/test_risk_index_api.py` Ä‘á»ƒ test khÃ´ng cáº§n chá» 00:00.
### Fixed
- **Assessment:** Sá»­a `q2_score` lÆ°u Ä‘Ãºng theo PHQ-9 cÃ¢u #2 (0-3) thay vÃ¬ cá»™ng cÃ¢u 1+2.

## [1.0.2] - 2026-05-12
### Added
- **Journal Module (CBT Journal):** Thiáº¿t láº­p trá»n gÃ³i kiáº¿n trÃºc cho Module Nháº­t kÃ½ tá»± do bao gá»“m:
  - **Backend:**
    - Khá»Ÿi táº¡o thá»±c thá»ƒ `Journal.java` káº¿ thá»«a `BaseObject` liÃªn káº¿t 1-N vá»›i `PatientProfile` vÃ  tá»± Ä‘á»™ng mapping táº¡o báº£ng `journals` trong MySQL.
    - XÃ¢y dá»±ng lá»›p tiá»‡n Ã­ch mÃ£ hÃ³a y táº¿ `EncryptionUtil.java` sá»­ dá»¥ng thuáº­t toÃ¡n **AES-128 CBC** báº£o máº­t tuyá»‡t Ä‘á»‘i cÃ¡c thÃ´ng tin nháº¡y cáº£m (PHI) cá»§a bá»‡nh nhÃ¢n.
    - Triá»ƒn khai cÆ¡ cháº¿ Ä‘Ã³ng gÃ³i linh hoáº¡t (JSON Serialization) cÃ¡c trÆ°á»ng cá»§a Thought Record (`situation`, `automaticThought`, `emotion`, `emotionScore`, `adaptiveResponse`, `reRatedScore`) vÃ  Credit List (`content`) thÃ nh JSON, mÃ£ hÃ³a, giáº£i mÃ£ ngÆ°á»£c láº¡i sang DTO pháº³ng `JournalDto.java` cho App Flutter hiá»ƒn thá»‹ dá»… dÃ ng.
    - Cung cáº¥p cÃ¡c Endpoint RESTful: `POST /api/journal/thought-records` (LÆ°u nháº­t kÃ½), `GET /api/journal/thought-records` (Láº¥y danh sÃ¡ch nháº­t kÃ½), `GET /api/journal/thought-records/{id}` (Xem chi tiáº¿t nháº­t kÃ½ kÃ¨m kiá»ƒm tra phÃ¢n quyá»n an toÃ n).
    - Viáº¿t táº­p lá»‡nh kiá»ƒm thá»­ tá»± Ä‘á»™ng `test_journal_module.py` táº¡i thÆ° má»¥c scratch kiá»ƒm tra thÃ nh cÃ´ng 100% táº¥t cáº£ cÃ¡c APIs vÃ  xÃ¡c thá»±c dá»¯ liá»‡u Ä‘Æ°á»£c mÃ£ hÃ³a dáº¡ng ciphertext dÆ°á»›i cÆ¡ sá»Ÿ dá»¯ liá»‡u MySQL.
  - **Frontend (Flutter):**
    - Thiáº¿t láº­p mÃ´ hÃ¬nh dá»¯ liá»‡u y táº¿ `JournalModel.dart` há»— trá»£ tuáº§n tá»± hÃ³a JSON hai chiá»u khá»›p tuyá»‡t Ä‘á»‘i vá»›i DTO á»Ÿ Backend.
    - XÃ¢y dá»±ng lá»›p kho lÆ°u trá»¯ káº¿t ná»‘i `JournalRepository.dart` báº±ng thÆ° viá»‡n `http` káº¿ thá»«a Ä‘á»“ng bá»™ cÆ¡ cháº¿ Token JWT báº£o máº­t.
    - Triá»ƒn khai state management `JournalProvider.dart` quáº£n lÃ½ pháº£n há»“i, tá»± Ä‘á»™ng cáº­p nháº­t danh sÃ¡ch nháº­t kÃ½ cá»¥c bá»™ ngay sau khi ngÆ°á»i dÃ¹ng gá»­i thÃ nh cÃ´ng.
    - TÃ­ch há»£p `JournalProvider` toÃ n cá»¥c vÃ o `MultiProvider` táº¡i `app.dart`.
    - Káº¿t ná»‘i luá»“ng lÆ°u dá»¯ liá»‡u y táº¿ thá»±c táº¿ táº¡i `ThoughtRecordScreen` thay tháº¿ cho dá»¯ liá»‡u tÄ©nh trÆ°á»›c Ä‘Ã³, há»— trá»£ tá»± Ä‘á»™ng gá»­i 6 bÆ°á»›c nháº­n thá»©c lÃªn DB khi nháº¥n nÃºt hoÃ n táº¥t.
    - Thiáº¿t káº¿ láº¡i toÃ n bá»™ mÃ n hÃ¬nh `journal_ai_screen.dart` thÃ nh má»™t Timeline lá»‹ch sá»­ sá»‘ng Ä‘á»™ng, tá»± Ä‘á»™ng phÃ¢n tÃ¡ch giao diá»‡n trá»±c quan cho Nháº­t kÃ½ 6 bÆ°á»›c (mÃ u vÃ ng áº¥m) vÃ  Tháº» ghi nháº­n ná»— lá»±c (mÃ u xanh mÃ¡t), Ä‘á»“ng thá»i phÃ¡t triá»ƒn cÃ¡c há»™p thoáº¡i (Details Dialog) hiá»ƒn thá»‹ cá»±c ká»³ sang xá»‹n má»‹n.

## [1.0.1] - 2026-05-10
### Added
- Khá»Ÿi táº¡o há»‡ thá»‘ng tÃ i liá»‡u Solo Builder (`AGENTS.md`, `brief.md`, `BRD.md`, `master-plan.md`).

### Fixed
- **Authentication:** Kháº¯c phá»¥c lá»—i Ä‘Äƒng nháº­p áº©n danh khÃ´ng tá»± Ä‘á»™ng táº¡o `PatientProfile` khiáº¿n chá»©c nÄƒng submit Mood bá»‹ lá»—i `EntityNotFoundException` á»Ÿ Backend.
- **Database Seeder:** Kháº¯c phá»¥c lá»—i `DatabaseSeeder` lÆ°u profile sai UUID do Hibernate `@GeneratedValue` tá»± Ä‘á»™ng Ä‘Ã¨ UUID tá»« file CSV. ÄÃ£ thÃªm logic mapping qua `csvIdToEmailMap` vÃ  bá»• sung `@Transactional` Ä‘á»ƒ kháº¯c phá»¥c lá»—i Detached Entity triá»‡t Ä‘á»ƒ.
- **Assessment:** Chá»©c nÄƒng `Daily Mood Check-in` Ä‘Ã£ hoáº¡t Ä‘á»™ng thÃ nh cÃ´ng tá»« Flutter App vÃ  Ä‘Æ°á»£c nÃ¢ng cáº¥p lÃªn cÆ¡ cháº¿ **Upsert** (Cáº­p nháº­t tá»± Ä‘á»™ng náº¿u Ä‘Ã£ cÃ³ báº£n ghi Mood trong ngÃ y, ngÄƒn ngá»«a sinh báº£n ghi trÃ¹ng láº·p gÃ¢y lÃ£ng phÃ­ dung lÆ°á»£ng database).

## [1.0.0] - TrÆ°á»›c 2026-05-10
### Added
- Khá»Ÿi táº¡o Spring Boot Backend (Auth, Assessment, Security JWT).
- Khá»Ÿi táº¡o Flutter Mobile App (Provider architecture, Dio API client).
- TÃ­ch há»£p Database MySQL vÃ  cáº¥u hÃ¬nh Seeder cÆ¡ báº£n.
## [1.0.3] - 2026-05-22
### Added
- **Clinical (Backend):** ThÃªm entity `TherapistCredential` + lÆ°u file vÃ o `uploads/therapist-credentials/<therapistId>/...` vÃ  API upload/list/download cho therapist & admin.
- **Clinical (Backend):** ThÃªm `TherapistAccessGuardService` Ä‘á»ƒ cháº·n cÃ¡c API chuyÃªn mÃ´n cá»§a therapist khi chÆ°a `ACTIVE` (PENDING chá»‰ Ä‘Æ°á»£c upload chá»©ng chá»‰).
- **CMS (Web):** ThÃªm mÃ n therapist upload chá»©ng chá»‰ + Admin xem/táº£i chá»©ng chá»‰ trong mÃ n â€œQuáº£n lÃ½ BÃ¡c sÄ© (Approval)â€, vÃ  cháº·n duyá»‡t `ACTIVE` náº¿u chÆ°a cÃ³ chá»©ng chá»‰.
- **Seeder (Backend):** Seed theo tá»«ng bÆ°á»›c, lá»—i 1 báº£ng khÃ´ng lÃ m dá»«ng seed cÃ¡c báº£ng khÃ¡c; seed profiles dÃ¹ng `getReferenceById` Ä‘á»ƒ trÃ¡nh detached.
- **Admin CMS:** Bá»• sung quáº£n lÃ½ tÃ i khoáº£n bÃ¡c sÄ©: khÃ³a/má»Ÿ (`/api/admin/users/{id}/active`), chá»‰nh sá»­a profile + reset máº­t kháº©u (`/api/admin/therapists/{id}` / `reset-password`).
- **Clinical (Backend/Web/App):** Admin gÃ¡n bÃ¡c sÄ© thá»§ cÃ´ng cho bá»‡nh nhÃ¢n + giá»›i háº¡n caseload 20; app patient bá» luá»“ng chá»n bÃ¡c sÄ©, booking chá»‰ theo therapist Ä‘Ã£ gÃ¡n.
### Changed
- **Auth (Backend):** Therapist `PENDING` Ä‘Æ°á»£c login Ä‘á»ƒ upload chá»©ng chá»‰ (chá»‰ cháº·n login khi `REJECTED` hoáº·c `is_active=false`).
### Docs
- Cáº­p nháº­t `docs/UI_TEST_RUNBOOK.md` theo luá»“ng â€œUpload chá»©ng chá»‰ -> Admin duyá»‡t -> ACTIVEâ€.
