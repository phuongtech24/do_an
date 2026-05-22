# KỊCH BẢN HỆ THỐNG: LUỒNG TRỊ LIỆU 3 GIAI ĐOẠN (USER JOURNEY)
**Tài liệu:** Đặc tả Nghiệp vụ Lâm sàng – Re-Connect Platform  
**Cơ sở khoa học:** Phác đồ CBT chuẩn APA + Digital Therapeutics (DTx)  
**Phiên bản:** 2.0 (cập nhật theo kịch bản chuẩn lâm sàng)

---

## TỔNG QUAN LUỒNG 3 GIAI ĐOẠN

```
[ONBOARDING] → [DAILY LOOP] → [THUYÊN GIẢM 2.5] → [KẾT THÚC & PHÒNG NGỪA]
    Giai đoạn 1      Giai đoạn 2       Giai đoạn 2.5          Giai đoạn 3
```

Bệnh nhân đi theo hành trình tuyến tính từ Giai đoạn 1 → 2 → 2.5 → 3, có thể bị interrupt bởi **Giao thức Cứu trợ** bất kỳ lúc nào nếu Risk Index >= 70.

---

## GIAI ĐOẠN 1: KHỞI ĐẦU (ONBOARDING)

**Mục tiêu lâm sàng:** Sàng lọc bệnh lý và thiết lập nền tảng nhận thức.

### Bước 1 – Đánh giá Baseline (PHQ-9)
- Bệnh nhân đăng nhập **ẩn danh** (chọn Avatar động vật/cỏ cây + Nickname ngẫu nhiên).
- Bắt buộc thực hiện bài test **PHQ-9** trước khi truy cập bất kỳ tính năng nào.
- Hệ thống lưu điểm PHQ-9 đầu tiên là **"Đường cơ sở" (Baseline)** vào `phq9_submissions` với `submission_type = 'BASELINE'`.
- Dựa vào điểm Baseline, hệ thống gán **Lộ trình Mặc định** cho bệnh nhân.

### Bước 2 – Goal Setting (Thiết lập Mục tiêu)
- Bệnh nhân chọn **3–5 mục tiêu cụ thể** từ danh sách gợi ý (có thể tùy chỉnh thêm):
  - Cải thiện giấc ngủ
  - Tự tin giao tiếp xã hội
  - Kiểm soát lo âu/stress
  - Tìm lại niềm vui trong cuộc sống
  - Xây dựng thói quen lành mạnh
  - ...
- Dữ liệu goals được lưu vào `patient_profiles.goals_json`.
- AI sẽ tham chiếu danh sách này khi soạn phản hồi trong các buổi nhật ký.

### Bước 3 – Psychoeducation (Giáo dục Tâm lý)
- Hệ thống tự động gửi **chuỗi thẻ thông tin giáo dục** (Psychoeducation Cards) về:
  - Mô hình Nhận thức: **Tình huống → Suy nghĩ → Cảm xúc → Hành vi**
  - Giải thích ngắn về CBT và cách app sẽ hỗ trợ bệnh nhân.
- Bệnh nhân phải xác nhận đọc (swipe qua hết card) trước khi mở khóa Giai đoạn 2.

---

## GIAI ĐOẠN 2: VÒNG LẶP TRỊ LIỆU (DAILY LOOP)

**Mục tiêu lâm sàng:** Phản biện suy nghĩ tiêu cực và kích hoạt hành vi thông qua AI dẫn dắt.

> Vòng lặp này diễn ra **mỗi ngày**, được reset vào lúc **06:00 sáng**.

### Bước 1 – Mood Check-in (Chấm điểm Tâm trạng)
- Mỗi ngày, bệnh nhân được nhắc **chấm điểm tâm trạng hiện tại** từ **0% đến 100%**.
  - 0% = Kiệt sức hoàn toàn / Không muốn làm gì
  - 100% = Tràn đầy năng lượng / Rất tốt
- Dữ liệu lưu vào bảng `user_moods`:
  - `mood_score` (0–100)
  - `recorded_at` (timestamp)
- Điểm này được dùng làm **Biến số 3** trong công thức Risk Index.

### Bước 2 – Rẽ nhánh AI dựa trên Mood Score

```
IF mood_score >= 50% THEN
    → AI mời viết "Danh sách Ghi nhận" (Credit List)
    → Bệnh nhân liệt kê 1-3 điều tích cực diễn ra hôm nay

ELSE (mood_score < 50%)
    → AI mời viết "Nhật ký Suy nghĩ" (Thought Record)
    → Kích hoạt luồng Khám phá dẫn dắt (Bước 3)
END IF
```

### Bước 3 – AI Khám phá Dẫn dắt (Guided Discovery – chỉ khi Mood Tệ)

Trong luồng **Thought Record**, AI thực hiện quy trình 4 bước:

1. **Lắng nghe:** AI hỏi "Hôm nay điều gì khiến bạn cảm thấy như vậy?"
2. **Nhận diện Lỗi tư duy:** AI (qua Gemini NLP) phân tích ngôn ngữ và gắn nhãn Cognitive Distortion phù hợp:
   - All-or-nothing thinking (Tư duy Trắng-Đen)
   - Catastrophizing (Thảm họa hóa)
   - Mind Reading (Đọc suy nghĩ người khác)
   - Overgeneralization (Tổng quát hóa quá mức)
   - ...
3. **Câu hỏi Socratic:** AI đặt câu hỏi gợi mở để bệnh nhân tự phản biện suy nghĩ của mình (KHÔNG đưa lời khuyên trực tiếp).
4. **Viết Phản ứng Thích nghi:** Bệnh nhân tự viết lại suy nghĩ theo hướng cân bằng hơn.

> **Lưu ý backend:** Sau mỗi cuộc trò chuyện, hệ thống gọi Gemini API để phân tích và tính `ai_risk_score`, lưu vào `journals.risk_index`.

### Bước 4 – Kích hoạt Hành vi (Roadmap Task – Graded Task Assignment)

Hệ thống tự động giao bài tập theo nguyên tắc **chia nhỏ** để tránh quá tải:

| Loại bài tập | Tần suất | Thời lượng | Ví dụ |
|---|---|---|---|
| **Nhận thức (Cognitive)** | Hàng ngày | < 5 phút | Đọc thẻ đối phó, Quiz nhỏ về Lỗi tư duy |
| **Hành vi / Xã hội (Behavioral/Social)** | 3–4 ngày/tuần | 10–15 phút | Dọn bàn 10 phút, Đi bộ ngoài trời |

> **Ràng buộc cứng:** Tối đa **1–2 nhiệm vụ/ngày**. Không thể mở nhiệm vụ tiếp theo trước **06:00 sáng hôm sau** (Time-Gating).

### Bước 5 – Đánh giá Task (Mastery & Pleasure Rating)

Sau khi hoàn thành mỗi nhiệm vụ, bệnh nhân chấm điểm:
- **Mastery Score (Thành tựu):** 0–10 — "Bạn cảm thấy mình làm tốt đến đâu?"
- **Pleasure Score (Niềm vui):** 0–10 — "Bạn cảm thấy vui/nhẹ nhõm đến đâu?"

Dữ liệu lưu vào `patient_quests.mastery_score` và `patient_quests.pleasure_score`.  
Bác sĩ có thể xem xu hướng điểm này để đánh giá mức độ Anhedonia (mất khả năng cảm nhận niềm vui).

---

## GIAI ĐOẠN 2.5: ĐÁNH GIÁ THUYÊN GIẢM & TỐT NGHIỆP

**Mục tiêu:** Hệ thống tự động xác định thời điểm bệnh nhân đủ điều kiện "tốt nghiệp".

### Cơ chế Cooldown PHQ-9

- App chỉ mở khóa bài test PHQ-9 định kỳ **14 ngày/lần**.
- Cột `phq9_submissions.unlocked_at` lưu thời điểm bài test tiếp theo được phép làm.
- Cron Job hàng ngày kiểm tra điều kiện và cập nhật trạng thái.

### Điều kiện Tốt nghiệp (Graduation Criteria)

```
IF (phq9_score < 5 TRONG 2 CHU KỲ LIÊN TIẾP)  -- tương đương tối thiểu 4 tuần
THEN
    → Kích hoạt cấu hình Giai đoạn 3
    → Hiển thị Popup "Quy gán Sự tiến bộ" (Progress Attribution)
    → Trao chứng chỉ tốt nghiệp + Lottie animation pháo hoa
END IF
```

> **Lưu ý:** Hệ thống kiểm tra `submission_type = 'PERIODIC'` và so sánh 2 bản ghi gần nhất.

### Popup "Quy gán Sự tiến bộ" (Progress Attribution)
Nội dung popup nhấn mạnh **bệnh nhân là người đã làm nên sự thay đổi**, không phải app:
> *"Chúc mừng [Nickname]! Bạn đã kiên trì trong [X] tuần. Đây là thành quả của chính bạn – bạn đã học cách là bác sĩ cho chính mình."*

---

## GIAI ĐOẠN 3: KẾT THÚC & PHÒNG NGỪA TÁI PHÁT

**Mục tiêu lâm sàng:** Giãn cách sự phụ thuộc vào app, bệnh nhân tự làm bác sĩ cho chính mình.

### Bước 1 – Giãn cách Tự trị liệu (Tapering Schedule)

AI tự động giảm tần suất nhắc nhở bệnh nhân làm bài tập:

| Thời gian từ Tốt nghiệp | Tần suất nhắc nhở | Ghi chú |
|---|---|---|
| Tháng 1 | 1 lần/tuần | Còn tương tác cao |
| Tháng 2 – Tháng 6 | 1 lần/tháng | Duy trì thói quen |
| Sau 6 tháng | 1 lần/quý | Phòng ngừa tái phát |

Cron Job kiểm tra ngày tốt nghiệp và cập nhật `patient_profiles.tapering_stage` để điều chỉnh tần suất.

### Bước 2 – Fixed Booster Sessions (Phiên củng cố Bắt buộc)

Cron Job tự động trigger yêu cầu bệnh nhân **ôn tập** tại đúng 3 mốc thời gian:

| Mốc | Hành động |
|---|---|
| **Tháng thứ 3** | Bệnh nhân làm lại PHQ-9 + 1 buổi ôn tập với AI |
| **Tháng thứ 6** | Bệnh nhân làm lại PHQ-9 + đặt lịch Bác sĩ (nếu cần) |
| **Tháng thứ 12** | Bệnh nhân làm lại PHQ-9 + đặt lịch Bác sĩ (nếu cần) |

```
IF (phq9_score_booster >= 10)  -- Tái phát
THEN
    → Kích hoạt lại Giai đoạn 2 (Daily Loop)
    → Bác sĩ nhận thông báo "Cần theo dõi lại"
ELSE
    → Tiếp tục Tapering Schedule bình thường
END IF
```

---

## PHỤ LỤC: GIAO THỨC CỨU TRỢ (EMERGENCY PROTOCOL)

Khi Risk Index >= 70 (bất kỳ giai đoạn nào), hệ thống **ngắt luồng bình thường** và thực thi:

### Phía Mobile App (Bệnh nhân)
1. AI **ngưng ngay** tất cả bài tập thông thường.
2. Hiển thị Popup Giao thức Cứu trợ:
   > *"Có vẻ bạn đang trải qua khoảng thời gian rất khó khăn. Hãy kết nối với chuyên gia ngay nhé."*
3. Hiển thị 2 nút hành động:
   - **"Đặt lịch Telehealth khẩn cấp"** → Mở màn hình booking ưu tiên
   - **"Gọi Đường dây hỗ trợ"** → Hotline y tế tâm thần quốc gia

### Phía Web CMS (Bác sĩ)
1. Tên bệnh nhân tự động bị gắn **Cờ Đỏ (Red Flag)** đẩy lên **đầu Roster**.
2. Banner cảnh báo nhấp nháy hiển thị trên Dashboard.
3. Bác sĩ thấy nút **"Gửi yêu cầu Can thiệp"** – sau khi bấm, trạng thái bệnh nhân chuyển sang `EMERGENCY_INTERVENTION`.
4. Bác sĩ phải bấm **"Đã xử lý"** để đóng alert sau khi liên hệ can thiệp.

> Xem chi tiết thuật toán tính Risk Index tại: [THUAT_TOAN_RISK_INDEX.md](./THUAT_TOAN_RISK_INDEX.md)
