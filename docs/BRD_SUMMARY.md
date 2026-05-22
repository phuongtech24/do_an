# BRD Summary (Core, token-optimized)

Tài liệu này là **bản rút gọn** (ít token) nhưng **giữ đúng các con số/ngưỡng chính** theo BRD. Khi cần chi tiết nghiệp vụ, mở bản đầy đủ: `docs/BRD.md`.

## 1) Safety Protocol & Risk (0–100)
- **Mục tiêu**: phát hiện sớm rủi ro (đặc biệt self-harm) và kích hoạt can thiệp.
- **Display anonymity**: backend vẫn lưu email/SĐT thật; CMS hiển thị ẩn danh. Chỉ **Super Admin** được phá ẩn danh khi bật “cờ đỏ” khẩn cấp.
- **Risk Index (0–100, chạy hằng ngày)** = tổng hợp 3 biến:
  - **40% PHQ-9**: dùng **Câu 9** (ý định tự hại) + **Câu 2** (tuyệt vọng). Nếu **Câu 9 > 0 ⇒ gán Max/100**.
  - **40% AI NLP từ journal**: quét 3 nhóm core belief (bất lực/không thể yêu thương/vô giá trị). Có mức **70** (bế tắc cùng cực) và **100** (từ khoá tự sát/cái chết).
  - **20% Mood trend**: nếu **trung bình mood 3 ngày liên tiếp < 20% ⇒ gán Max/100**.
- **Override rule (khẩn cấp)**: nếu **AI có từ khoá tự sát** **HOẶC** **PHQ-9 Câu 9 > 0** ⇒ **Risk Index = 100**.
- **Trigger**: khi **Risk Index ≥ 70** ⇒ bật **Red Flag** trên CMS + kích hoạt **PHQ-9 đột xuất (TRIGGERED)** + gợi ý luồng **Telehealth** trên app.

## 2) User Journey 3 giai đoạn
- **Giai đoạn 1 (Onboarding — chỉ ngày đầu cài app)**:
  - Baseline PHQ-9 (lưu `submission_type=BASELINE`)
  - Goal Setting: chọn **3–5** mục tiêu hành vi
  - Psychoeducation: hướng dẫn ngắn **< 5 phút**
- **Giai đoạn 2 (Daily Loop — tối thiểu 4 tuần, mỗi ngày 5–15 phút)**:
  - Mood check-in: chấm **0–100%**
  - AI rẽ nhánh theo ngưỡng **45%**:
    - **Mood < 45%** ⇒ Thought Record (Socratic 1–2 câu hỏi)
    - **Mood ≥ 45%** ⇒ Credit List (tự ghi nhận)
  - Agenda setting: chỉ chọn **1 vấn đề/ngày** (tránh quá tải)
- **Giai đoạn 3 (Termination/Prevention)**: tiêu chí kết thúc & phòng ngừa tái phát (tapering/booster) theo phase kế tiếp.

## 3) PHQ-9 submission business rules
- `submission_type`: phân loại hoàn cảnh nộp (ví dụ baseline vs theo chu kỳ).
- `severity_level`: phân loại mức độ y khoa để phục vụ can thiệp.

## 4) Admin/CMS nghiệp vụ chính
- Xác thực, quản lý bệnh nhân, quản lý therapist/tình nguyện viên.
- CMS tập trung vào theo dõi risk theo thời gian và xử lý red-flag.

## 5) Lưu ý lâm sàng cốt lõi (để tránh hiểu sai khi implement)
- **Mood KHÔNG thay đổi Roadmap bài tập**. Roadmap là kế hoạch **14 ngày** và chỉ bị ảnh hưởng bởi **PHQ-9** (chốt cho 1 chu kỳ 14 ngày).
- Mood chỉ dùng cho: (1) góp phần tính Risk Index theo **trung bình 3 ngày**, (2) rẽ nhánh AI theo ngưỡng **45%** tại thời điểm đó.

## 5) Liên quan tài liệu khác (mở khi cần)
- Risk index chi tiết + DB fields: `docs/THUAT_TOAN_RISK_INDEX.md`
- Schema MVP: `docs/diagrams/MVP_DATABASE_SCHEMA.md`
- SRS chuẩn hoá yêu cầu: `docs/SRS_IEEE_830_ReConnect.md`
