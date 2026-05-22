# Quy chuẩn Phát triển Backend (Development Standards)

Tài liệu này quy định cấu trúc 5 tầng chuẩn (ECDS Pattern) áp dụng cho mọi module trong dự án Reconnect MindHealth.

---

## 1. Cấu trúc 5 Tầng (5-Layer Architecture)

Mọi module nghiệp vụ phải tuân thủ nghiêm ngặt luồng dữ liệu sau:

### 1️⃣ Tầng DOMAIN (Entity Layer)
*   **Vị trí:** `modules.<module>.entity`
*   **Quy tắc:**
    *   Sử dụng UUID cho khóa chính.
    *   Mọi Entity nên `extends BaseObject` (chứa các trường audit: `createdAt`, `updatedAt`, `voided`).
    *   Sử dụng `@Column(unique = true)` cho các mã nghiệp vụ (Email, Nickname).
    *   Hỗ trợ Soft Delete qua trường `voided`.

### 2️⃣ Tầng REPOSITORY (Data Access)
*   **Vị trí:** `modules.<module>.repository`
*   **Quy tắc:**
    *   `extends JpaRepository<Entity, UUID>`.
    *   Sử dụng Query Method của Spring Data JPA (ví dụ: `findByEmail`).

### 3️⃣ Tầng DTO (Data Transfer Object)
*   **Vị trí:** `modules.<module>.dto`
*   **Quy tắc:**
    *   `extends BaseObjectDto`.
    *   **Bắt buộc:** Có Constructor nhận vào Entity để tự động convert dữ liệu (Entity -> DTO).
    *   Không bao giờ trả về mật khẩu hoặc dữ liệu nhạy cảm ở tầng này.

### 4️⃣ Tầng SERVICE (Interface + Implementation)
*   **Vị trí:** `modules.<module>.service` và `modules.<module>.service.impl`
*   **Quy tắc:**
    *   Sử dụng `@Service` và `@Transactional` (để đảm bảo tính toàn vẹn dữ liệu).
    *   Xử lý logic nghiệp vụ, filter các bản ghi đã xóa (`voided = true`).
    *   Convert Entity sang DTO trước khi trả về cho Controller.

### 5️⃣ Tầng CONTROLLER (REST API)
*   **Vị trí:** `modules.<module>.controller`
*   **Quy tắc:**
    *   Sử dụng `@RestController` và `@RequestMapping("/api/v1/...")`.
    *   Mọi kết quả trả về phải được bọc trong class `ApiResponse`.
    *   Xử lý Exception bằng Try-catch hoặc Global Exception Handler.

---

## 2. Quy ước Đặt tên (Naming Conventions)

*   **Entity:** `User`, `PatientProfile`
*   **Repository:** `UserRepository`, `PatientProfileRepository`
*   **DTO:** `UserDto`, `PatientProfileDto`
*   **Service Interface:** `IAuthService`, `IPatientService`
*   **Service Impl:** `AuthServiceImpl`, `PatientServiceImpl`
*   **Controller:** `AuthController`, `PatientController`

---

## 3. Checklist khi tạo Module mới

1.  ✅ **Domain:** Tạo Entity, check quan hệ JPA.
2.  ✅ **Repository:** Tạo Interface kế thừa JpaRepository.
3.  ✅ **DTO:** Tạo DTO với Constructor convert từ Entity.
4.  ✅ **Service:** Định nghĩa Interface và viết Logic trong Impl (có @Transactional).
5.  ✅ **Controller:** Viết các Endpoint REST, bọc kết quả trong ApiResponse.

---
**Ghi chú:** Khi AI thực hiện các module tiếp theo, AI sẽ đọc tài liệu này để đảm bảo code đúng flow 5 tầng đã quy định.
