# BÁO CÁO KẾ HOẠCH DỰ ÁN (TUẦN 1 - 2)
**Hạng mục:** Đánh giá chất lượng của bản kế hoạch dự án AI - Y tế
**Dự án ứng dụng:** Re-Connect (Nền tảng hỗ trợ trị liệu tâm lý CBT tích hợp AI)

---

## 1. Cơ sở khoa học về Liệu pháp Nhận thức Hành vi (CBT)

Liệu pháp Nhận thức Hành vi (Cognitive Behavioral Therapy - CBT) là một trong những phương pháp tâm lý trị liệu dựa trên bằng chứng (evidence-based) hàng đầu thế giới. Theo định nghĩa gốc rễ từ Hiệp hội Tâm lý học Hoa Kỳ (APA): Những rối loạn tâm lý như trầm cảm hay lo âu phần lớn bắt nguồn từ những kiểu suy nghĩ lệch lạc và những mô thức hành vi phản tác dụng [1].

Dựa trên cơ sở khoa học được xuất bản bởi Viện Y tế Quốc gia Hoa Kỳ (NIH/PubMed), CBT vận hành dựa trên 2 cơ chế nòng cốt:
1. **Tái lập nhận thức (Cognitive Restructuring - CR):** Kỹ thuật này giúp bệnh nhân nhận diện các "suy nghĩ tự động tiêu cực", phân tích chúng và thay thế bằng góc nhìn thực tế, đa chiều hơn [2]. CR được chứng minh rât hiệu quả làm giảm chứng trầm cảm ở người lớn.
2. **Kích hoạt hành vi (Behavioral Activation - BA):** Khuyến khích người bệnh thực hiện những thói quen, công việc mang lại cho họ cảm giác thành tựu hoặc niềm vui nhỏ. Việc thay đổi hành vi nhỏ bé này sẽ đảo ngược vòng lặp "cô lập xã hội" (social withdrawal loop) thường thấy ở bệnh trầm cảm [3].

### 🔥 Re-Connect áp dụng CBT vào nền tảng như thế nào?
Ứng dụng Re-Connect là một phiên bản số hóa của CBT (digital CBT / dCBT). Thay vì bệnh nhân phải gặp bác sĩ để thực hành bài tập trên giấy, ứng dụng số hóa những kỹ thuật này thành các tính năng tương tác tự động trực tiếp trên điện thoại:
- **Áp dụng "Kích hoạt hành vi (BA)" qua tính năng Gamification Roadmap:** Ứng dụng vẽ ra một bản đồ "Hành trình chữa lành", nơi mỗi trạm nhỏ là một hành vi cần kích hoạt (ví dụ: Trạm 1: Mở rèm đón nắng, Trạm 2: Đi dạo 10 phút, Trạm 3: Nhắn tin cho mẹ). Qua việc hoàn thành trạm và chụp ảnh nộp lên hệ thống, bệnh nhân được nhận huy hiệu nhỏ, kích thích Dopamine tự nhiên.
- **Áp dụng "Tái lập nhận thức (CR)" qua tính năng Nhật ký AI (AI Journaling):** Hệ thống tạo ra một không gian trò chuyện bí mật, giúp người dùng xả những dòng suy nghĩ tiêu cực ra màn hình thay vì gặm nhấm chúng, từ đó từ từ tháo gỡ vấn đề tâm lý gốc rễ.

---

## 2. Tính khả thi của việc tích hợp Trí tuệ Nhân tạo (AI)

Việc tích hợp Trí tuệ nhân tạo (AI) vào ứng dụng sức khỏe tâm thần là **hoàn toàn khả thi và tiết kiệm chi phí triển khai lớn**, đặc biệt là đóng vai trò hỗ trợ phân tích tâm lý.

### Tích hợp Google Gemini API:
Dự án Re-Connect áp dụng chiến lược thiết kế "AI-as-a-Service" (AI như một dịch vụ) bằng cách gọi trực tiếp (Call API) mô hình Ngôn ngữ lớn (LLM) **Google Gemini AI**.
- Thay vì tự huấn luyện một mô hình NLP phức tạp tốn hàng tháng trời, việc sử dụng Gemini API cung cấp một "hệ thống não bộ" NLP xử lý ngôn ngữ tự nhiên tối tân bậc nhất để phân tích cảm xúc (Sentiment Analysis).
- Nhờ API Gemini, ứng dụng hoạt động 24/7 để trò chuyện, phân rã cú pháp nhật ký của bệnh nhân và ngầm đánh giá mức độ tiêu cực của nội dung (thành một con số rủi ro rủi ro 0-100) mà không cần can thiệp của con người.

### Thách thức & Biện pháp (Lưu ý lâm sàng):
Nghiên cứu từ Đại học Columbia [4] chỉ ra rằng các Chatbot AI tiêu chuẩn có thể rơi vào bẫy "sycophancy" (cố tình thỏa hiệp với suy nghĩ rủi ro của người dùng). Hơn nữa, nó không thể xử lý ca khủng hoảng tức thì.
- **Biện pháp rào chắn trên Re-Connect:** Nếu AI Gemini trả về phân tích rủi ro quá lớn (Negative Emotion Score chạm ngưỡng nguy hiểm), ứng dụng sẽ tự động khóa chức năng Chat tự kỷ và định tuyến (Routing) màn hình điều hướng sang cửa sổ **Telehealth**, ép buộc người dùng kết nối lịch hẹn tư vấn khẩn cấp với bác sĩ có chuyên môn thật (Tầng 2 của hệ thống).

---

## 3. Thời gian thực hiện các module (Timeline Dự kiến)

Xét vì ứng dụng không phải train (huấn luyện) mô hình AI riêng biệt do đã tích hợp Gemini API, thời gian phát triển được cắt giảm đáng kể:

| Hạng mục / Module | Nền tảng | Trạng thái / Tiến độ |
| :--- | :--- | :--- |
| **Đánh giá Lâm sàng & Lập Kế hoạch (Tuần 1 - 2)** | Document | Hoàn thành tài liệu chuyên đề và tham chiếu PubMed. |
| **Module 1: User Profiles & Database** (Test PHQ-9) | App & Backend | Xây dựng Entity, MySQL (Đã xong cơ sở đồ án). |
| **Module 2: Gamification Roadmap** (Bản đồ BA) | App & Backend | UI/UX hoàn thiện, logic khóa giờ (Time-lock) hoạt động tốt. |
| **Module 3: Nhật ký AI Tái lập nhận thức** | App | Giao diện Chat, xử lý logic gọi Google Gemini API (Sắp tới). |
| **Module 4: Telehealth & Transaction Lịch khám** | App & Web CMS | Màn hình đặt lịch, chuyển chế độ Ẩn danh. |
| **Đóng gói & Chạy kiểm chứng** | All | Tổng hợp 14 Tuần (Khả thi mức độ luận văn/đồ án). |

---
**Nguồn tham khảo trích dẫn (Harvard Referencing style):**
- [1] *American Psychological Association (APA)*. (2017). What Is Cognitive Behavioral Therapy? Truy xuất từ APA.org.
- [2] Ugueto, A. M., et al. (2020). *Efficacy of Cognitive Restructuring and Behavioral Activation alone vs. combined CBT*. Thư viện Y khoa PubMed (NIH).
- [3] *Journal of Medical Internet Research (JMIR)*. (2021). Efficacy of Digital Cognitive Behavioral Therapy for Symptoms of Depression.
- [4] *Columbia University Dept of Psychiatry*. (2023). AI in Mental Health: Opportunities and Risks.
