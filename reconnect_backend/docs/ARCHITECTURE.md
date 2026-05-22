# Kiến trúc Hệ thống (Architecture)

Reconnect Backend được xây dựng theo kiến trúc **Modular Monolith** bằng Spring Boot.

## 1. Cấu trúc Package Gốc: `com.reconnect.mindhealth`

Mọi code nghiệp vụ được tổ chức vào thư mục `modules`. Mỗi module là một miền nghiệp vụ (Domain) hoàn chỉnh.

### Quy trình trong từng Module:
```text
module_name
├── controller  <-- REST API
├── entity      <-- Database Model
├── repository  <-- JPA Access
├── dto         <-- Request/Response
└── service     <-- Logic nghiệp vụ
    ├── IServiceName.java (Interface)
    └── impl
        └── ServiceNameImpl.java (Implementation)
```

## 2. Danh sách các Module Cốt lõi

| Module | Chức năng |
| --- | --- |
| **auth** | Quản lý User, JWT, Đăng nhập/Đăng ký ẩn danh. |
| **clinical** | Hồ sơ Bác sĩ & Bệnh nhân, Sơ đồ nhận thức (CCD). |
| **assessment** | Bài test PHQ-9 và theo dõi Tâm trạng hàng ngày. |
| **journal** | Nhật ký suy nghĩ, Phân tích lỗi tư duy (AI), Red Flag. |
| **roadmap** | Lộ trình bài tập (Cognitive, Behavioral, Social, Emotional). |
| **booster** | Quản lý lịch hẹn Booster Session & Link Meet. |
| **ai** | Tích hợp Gemini API và quản lý Prompt trị liệu. |

## 3. Các Package Toàn cục
- `common`: Các Exception chung, DTO dùng toàn cục (ApiResponse), Utils.
- `config`: Cấu hình Security, JPA, Jackson, AI Client.

## 4. Nguyên tắc Phát triển
1.  **Low Coupling**: Các module giao tiếp qua Service, không can thiệp trực tiếp vào Database của nhau.
2.  **High Cohesion**: Mọi thứ liên quan đến một nghiệp vụ nằm gọn trong một module.
3.  **Stateless**: Sử dụng JWT để xác thực, không lưu Session trên Server.

---

## 5. Quy chuẩn Phát triển (Coding Standards)
Chi tiết về cấu trúc 5 tầng (ECDS Pattern), quy ước đặt tên và checklist triển khai được quy định tại: **[DEVELOPMENT_STANDARDS.md](file:///d:/DOAN/reconnect_backend/docs/DEVELOPMENT_STANDARDS.md)**

