# TIÊU CHUẨN MÃ HÓA BẢO MẬT DỮ LIỆU Y TẾ (PHI ENCRYPTION STANDARD)

Để bảo vệ thông tin sức khỏe cá nhân nhạy cảm (**Protected Health Information - PHI**) của bệnh nhân trên hệ thống **ReConnect MindHealth** theo đúng luật bảo mật thông tin y tế quốc tế (**HIPAA**), hệ thống Backend Spring Boot áp dụng tiêu chuẩn mã hóa đối xứng cấp quân sự.

---

## 🛡️ Thuật Toán Mã Hóa: AES-128 CBC

Dữ liệu nội dung nhật ký nhạy cảm của bệnh nhân được mã hóa bằng thuật toán **AES** (Advanced Encryption Standard) - thuật toán mã hóa đối xứng được phê duyệt bởi Viện Tiêu chuẩn và Công nghệ Quốc gia Hoa Kỳ (**NIST**) và là tiêu chuẩn bắt buộc cho dữ liệu chính phủ & y tế quốc tế.

### 1. Đặc tả kỹ thuật (Technical Specification)

| Tham số | Giá trị tiêu chuẩn | Ý nghĩa |
| :--- | :--- | :--- |
| **Thuật toán** | **AES** (Advanced Encryption Standard) | Tiêu chuẩn mã hóa dữ liệu hàng đầu của Mỹ và quốc tế. |
| **Độ dài khóa (Key length)** | **128-bit** (16 bytes) | Cực kỳ an toàn, cân bằng hiệu năng hoàn hảo cho các thiết bị di động và máy chủ. |
| **Chế độ hoạt động** | **CBC** (Cipher Block Chaining) | Mỗi khối plaintext được XOR với khối ciphertext trước đó trước khi được mã hóa. Đảm bảo 2 nội dung nhật ký giống hệt nhau sẽ cho ra 2 chuỗi mã hóa hoàn toàn khác nhau. |
| **Cơ chế đệm (Padding)** | **PKCS5Padding** | Tự động thêm các byte đệm vào khối cuối cùng nếu độ dài dữ liệu không chia hết cho kích thước khối (16 bytes). |
| **Mã hóa truyền tải** | **Base64** | Chuyển đổi dữ liệu binary sau mã hóa thành chuỗi ký tự chữ-số an toàn để lưu trữ dạng cột `TEXT` trong cơ sở dữ liệu MySQL và truyền tải qua API JSON mà không sợ lỗi font chữ/unicode. |

---

## 🔄 Quy trình Mã hóa và Giải hóa (Encryption Flow)

### 📥 Quy trình Lưu Nhật ký mới (Encryption Flow):
1. Bệnh nhân nhập thông tin thô (Ví dụ: `Situation`, `Automatic Thought`, `Emotion`...).
2. Backend gom tất cả các trường dữ liệu thô này thành một bản đồ cấu trúc động `Map<String, Object>`.
3. Bản đồ được chuyển đổi (**Serialized**) thành chuỗi ký tự JSON phẳng.
4. Chuỗi JSON này được đưa vào bộ xử lý mã hóa **AES-128-CBC** kết hợp với **Secret Key** và **Initialization Vector (IV)** để cho ra mảng byte mã hóa.
5. Mảng byte mã hóa được chuyển thành chuỗi **Base64** và cất vào cột `content_encrypted` của bảng `journals` trong MySQL.

```
Plaintext (JSON) ──> [ AES-128 CBC Encryption ] ──> [ Base64 Encoder ] ──> Ciphertext (Lưu DB)
```

### 📤 Quy trình Đọc Nhật ký (Decryption Flow):
1. App gửi yêu cầu đọc nhật ký (truy vấn theo `patientId`).
2. Backend lấy chuỗi ciphertext từ cột `content_encrypted`.
3. Khôi phục chuỗi ciphertext bằng **Base64 Decoder** về dạng mảng byte.
4. Đưa mảng byte qua bộ xử lý giải mã **AES-128-CBC** kết hợp với khóa bí mật để khôi phục lại chuỗi JSON gốc tiếng Việt.
5. Biên dịch (**Deserialized**) chuỗi JSON ngược về các trường phẳng của DTO và gửi trả về Flutter hiển thị lên màn hình.

```
Ciphertext (DB) ──> [ Base64 Decoder ] ──> [ AES-128 CBC Decryption ] ──> Plaintext (JSON) ──> DTO phẳng
```

---

## 🔒 Danh mục Mã nguồn Liên quan

*   **Bộ xử lý mã hóa:** [EncryptionUtil.java](file:///d:/DOAN/reconnect_backend/src/main/java/com/reconnect/mindhealth/common/util/EncryptionUtil.java)
*   **Thực thể lưu trữ:** [Journal.java](file:///d:/DOAN/reconnect_backend/src/main/java/com/reconnect/mindhealth/modules/journal/entity/Journal.java)
*   **Cấu trúc truyền tải:** [JournalDto.java](file:///d:/DOAN/reconnect_backend/src/main/java/com/reconnect/mindhealth/modules/journal/dto/JournalDto.java)
*   **Logic dịch vụ đóng/mở gói:** [JournalServiceImpl.java](file:///d:/DOAN/reconnect_backend/src/main/java/com/reconnect/mindhealth/modules/journal/service/impl/JournalServiceImpl.java)
