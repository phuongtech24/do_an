# 🔄 Giải thích: Flutter gọi API Backend như thế nào?

---

## 📌 Tổng quan bằng hình ảnh

```
[Người dùng bấm nút "Đăng nhập"]
         ↓
[LoginScreen] — thu thập email + password từ form
         ↓
[AuthProvider] — quản lý trạng thái (loading, success, error)
         ↓
[AuthRepository] — tạo HTTP request và gửi đến Backend
         ↓
[Spring Boot Backend :8081] — xử lý, trả về token + thông tin user
         ↓
[AuthRepository] — nhận response JSON, parse thành Dart object
         ↓
[AuthProvider] — lưu token, cập nhật trạng thái "success"
         ↓
[LoginScreen] — nhận biết success → chuyển sang màn hình Home
```

---

## 🗂️ Giải thích từng file đã tạo

### 1. `api_constants.dart` — Địa chỉ server
```dart
static const String baseUrl = 'http://10.0.2.2:8081/api';
static const String login = '$baseUrl/auth/login';
```
> **Vai trò:** Khai báo địa chỉ URL một lần, dùng ở nhiều nơi.
> Nếu đổi server, chỉ cần sửa 1 chỗ duy nhất ở đây.

---

### 2. `login_request.dart` — Dữ liệu GỬI đi
```dart
class LoginRequest {
  final String email;
  final String password;

  // toJson() = chuyển thành JSON để gửi qua mạng
  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}
```
> **Vai trò:** Đóng gói dữ liệu cần gửi.
> `toJson()` chuyển Dart object → chuỗi JSON:
> `{"email": "abc@gmail.com", "password": "123456"}`

---

### 3. `login_response.dart` — Dữ liệu NHẬN về
```dart
class LoginResponse {
  final UserDto user;   // Thông tin user
  final String token;   // JWT Token

  // fromJson() = nhận JSON từ server → chuyển thành Dart object
  factory LoginResponse.fromJson(Map<String, dynamic> json) { ... }
}
```
> **Vai trò:** Khi server trả về JSON, `fromJson()` đọc và tạo object Dart.
> Backend trả về:
> ```json
> {
>   "status": 200,
>   "data": {
>     "user": { "id": "...", "email": "...", "role": "PATIENT" },
>     "token": "eyJhbGci..."
>   }
> }
> ```
> → `LoginResponse.fromJson(json['data'])` tạo ra object dùng được trong code.

---

### 4. `auth_repository.dart` — Người gửi HTTP
```dart
Future<LoginResponse> login(LoginRequest request) async {
  // Bước 1: Gửi POST request đến server
  final response = await http.post(
    Uri.parse(ApiConstants.login),          // URL: .../api/auth/login
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(request.toJson()),     // Body: {"email":..., "password":...}
  );

  // Bước 2: Giải mã response JSON (hỗ trợ tiếng Việt với utf8)
  final json = jsonDecode(utf8.decode(response.bodyBytes));

  // Bước 3: Kiểm tra thành công hay thất bại
  if (json['status'] == 200 && json['data'] != null) {
    return LoginResponse.fromJson(json['data']); // ✅ Thành công
  } else {
    throw Exception(json['message']); // ❌ Thất bại → ném lỗi
  }
}
```
> **Vai trò:** Phụ trách toàn bộ việc giao tiếp mạng.
> Screen và Provider **không biết** HTTP là gì, chúng chỉ gọi `repository.login()`.

---

### 5. `auth_provider.dart` — Người quản lý trạng thái
```dart
Future<void> login(String email, String password) async {
  _status = AuthStatus.loading;   // Bật loading spinner
  notifyListeners();               // Thông báo cho UI cập nhật

  try {
    _loginResponse = await _repository.login(request); // Gọi repository
    _status = AuthStatus.success;  // Thành công!
  } catch (e) {
    _status = AuthStatus.error;    // Thất bại
    _errorMessage = e.toString();
  }
  notifyListeners();               // Thông báo cho UI cập nhật lần 2
}
```
> **Vai trò:** Quản lý các trạng thái của màn hình.
> UI lắng nghe Provider thay vì tự gọi API.

---

## 🔁 Flow chi tiết khi bấm "Đăng nhập"

```
Bước 1: LoginScreen gọi
   → context.read<AuthProvider>().login(email, password)

Bước 2: AuthProvider set status = loading
   → UI thấy "loading" → hiển thị CircularProgressIndicator

Bước 3: AuthProvider gọi AuthRepository.login()

Bước 4: AuthRepository gửi HTTP POST:
   POST http://10.0.2.2:8081/api/auth/login
   Body: {"email": "patient@gmail.com", "password": "123456"}

Bước 5: Backend Spring Boot xử lý:
   → Tìm user trong DB
   → So sánh password BCrypt
   → Tạo JWT Token
   → Trả về JSON

Bước 6: AuthRepository nhận JSON:
   {"status":200, "data": {"user":{...}, "token":"eyJ..."}}
   → Parse thành LoginResponse object
   → Trả về cho AuthProvider

Bước 7: AuthProvider set status = success, lưu token
   → notifyListeners()

Bước 8: LoginScreen nhận biết success:
   → Navigator.pushReplacement → HomeScreen
```

---

## 💡 Cách dùng Provider trong UI

```dart
// Trong LoginScreen widget

// Đọc Provider (không lắng nghe)
final authProvider = context.read<AuthProvider>();
authProvider.login(email, password);

// Lắng nghe Provider (tự động rebuild khi thay đổi)
final status = context.watch<AuthProvider>().status;

if (status == AuthStatus.loading) {
  return CircularProgressIndicator();
} else if (status == AuthStatus.error) {
  return Text(context.watch<AuthProvider>().errorMessage);
}
```

---

## 🌐 Tại sao dùng `10.0.2.2` thay vì `localhost`?

Android Emulator chạy trong máy ảo riêng:
- `localhost` trong Emulator = chính Emulator (không phải máy tính của bạn)
- `10.0.2.2` = địa chỉ đặc biệt trỏ về máy tính thật (host machine)

| Môi trường | Địa chỉ backend |
|-----------|----------------|
| Android Emulator | `10.0.2.2:8081` |
| iOS Simulator | `localhost:8081` |
| Điện thoại thật (cùng WiFi) | `192.168.x.x:8081` |
