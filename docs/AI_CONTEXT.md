# AI Context Pack (Load-first)

Mục tiêu: giảm token nạp mặc định khi làm việc với AI. **Mặc định chỉ đọc các file “Core” bên dưới**; các tài liệu dài chỉ mở khi task chạm đúng chủ đề.

## Core (auto-load)
- `docs/brief.md` — dự án là gì + core flows
- `docs/plans/master-plan.md` — đang ở phase nào, task nào còn thiếu
- `CHANGELOG.md` — những thay đổi gần nhất (tránh làm lại/đụng nhầm)
- `docs/BRD_SUMMARY.md` — tóm tắt BRD (mở `docs/BRD.md` khi cần chi tiết)

## When to open (reference on-demand)
- **Business rules/flows chi tiết** → `docs/BRD.md` (+ `docs/SRS_IEEE_830_ReConnect.md` nếu cần chuẩn hoá)
- **Risk Index / red flag / cron** → `docs/THUAT_TOAN_RISK_INDEX.md`
- **Database/ERD/quan hệ bảng** → `docs/diagrams/MVP_DATABASE_SCHEMA.md`
- **Backend auth/JWT/security** → `reconnect_backend/docs/SIMPLE_JWT_GUIDE.md`
- **Backend API/DB design (thực thi)** → `reconnect_backend/docs/API_DESIGN.md`, `reconnect_backend/docs/DATABASE_DESIGN.md`
- **Flutter API usage** → `FLUTTER_API_GUIDE.md`, `reconnect_app/docs/HOW_API_WORKS.md`

## Quick glossary (minimal)
- **Patient**: người dùng app Flutter (ẩn danh/đăng nhập)
- **Therapist/Admin**: dùng Web CMS
- **Daily Loop**: mood check-in → journal/CBT → AI risk → roadmap/quest
- **Risk Index**: điểm 0–100, dùng bật red-flag & can thiệp khẩn cấp

