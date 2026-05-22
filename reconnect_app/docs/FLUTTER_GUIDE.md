# 📱 Flutter App — Tài liệu Phát triển

## 1. Cấu trúc thư mục chuẩn (`lib/`)

```
lib/
├── main.dart                    # Entry point
├── app/                         # App config (routes, theme, providers)
│   └── app.dart
├── core/                        # Hằng số, tiện ích dùng toàn app
│   ├── constants/
│   │   └── api_constants.dart   # Base URL, endpoint paths
│   └── utils/
│       └── token_storage.dart   # Lưu/đọc JWT token
├── network/                     # Tầng giao tiếp HTTP
│   ├── api_client.dart          # Dio/Http client cấu hình sẵn header
│   └── api_service.dart         # (Legacy - xem xét refactor)
├── features/                    # Mỗi tính năng là 1 folder độc lập
│   └── auth/
│       ├── data/
│       │   ├── models/
│       │   │   ├── login_request.dart
│       │   │   ├── login_response.dart
│       │   │   └── register_request.dart
│       │   └── repositories/
│       │       └── auth_repository.dart  # Gọi HTTP
│       ├── domain/
│       │   └── auth_service.dart         # Business logic
│       └── presentation/
│           ├── screens/
│           │   ├── login_screen.dart
│           │   └── register_screen.dart
│           └── providers/
│               └── auth_provider.dart    # State management (Provider)
├── shared/                      # Widgets tái sử dụng
│   └── widgets/
│       ├── custom_button.dart
│       └── custom_text_field.dart
└── theme/                       # Màu sắc, font, style
    └── app_theme.dart
```

---

## 2. Quy tắc gọi API

### Chuỗi gọi API chuẩn:
```
Screen (UI)
  → Provider/Controller (State)
    → Service/Repository (Business Logic)
      → ApiClient (HTTP)
        → Backend Server
```

### Cấu hình Base URL:
```dart
// lib/core/constants/api_constants.dart
class ApiConstants {
  // Android Emulator: 10.0.2.2 (localhost của máy host)
  // iOS Simulator:    localhost
  // Flutter Web:      localhost
  // Thiết bị thật:    địa chỉ IP máy chạy backend
  static const String baseUrl = 'http://10.0.2.2:8081/api';
}
```

### Gửi request có Token (Authenticated):
```dart
final response = await http.get(
  Uri.parse('${ApiConstants.baseUrl}/users'),
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',  // ← Token lấy từ TokenStorage
  },
);
```

---

## 3. Mô hình ApiResponse chuẩn

Backend luôn trả về dạng:
```json
{ "status": 200, "message": "...", "data": { ... } }
```

Dart model tương ứng:
```dart
class ApiResponse<T> {
  final int status;
  final String message;
  final T? data;

  ApiResponse({required this.status, required this.message, this.data});

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return ApiResponse(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }
}
```

---

## 4. Checklist khi thêm tính năng mới

1. ✅ Tạo **Model** trong `features/<name>/data/models/`
2. ✅ Tạo **Repository** trong `features/<name>/data/repositories/`
3. ✅ Tạo **Provider** trong `features/<name>/presentation/providers/`
4. ✅ Tạo **Screen** trong `features/<name>/presentation/screens/`
5. ✅ Đăng ký **Route** trong `app/app.dart`
6. ✅ Đăng ký **Provider** trong `main.dart`

---

## 5. Xử lý lỗi mạng chuẩn

```dart
try {
  final result = await authRepository.login(email, password);
  // Xử lý thành công
} on SocketException {
  // Không có internet
} on HttpException {
  // Server trả lỗi
} catch (e) {
  // Lỗi không xác định
}
```
