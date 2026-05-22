# 🚀 Hướng dẫn Quy trình Tích hợp API (MindHealth Standard)

Tài liệu này hướng dẫn các bước chuẩn hóa để tích hợp một Module API mới vào Flutter App ReConnect theo mô hình **Clean Architecture**.

---

## 🏗️ Quy trình 4 Bước (Bottom-Up)

### Bước 1: Khởi tạo Model (DTO)
Nằm tại: `lib/features/[feature_name]/data/models/`

*   **Nhiệm vụ:** Định nghĩa cấu trúc dữ liệu gửi đi và nhận về.
*   **Yêu cầu:** Phải có hàm `fromJson` để chuyển đổi từ dữ liệu Backend sang Object Dart.

```dart
// Ví dụ: login_response.dart
class LoginResponse {
  final String token;
  final UserDto user;

  LoginResponse({required this.token, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      user: UserDto.fromJson(json['user']),
    );
  }
}
```

---

### Bước 2: Viết Repository (Data Layer)
Nằm tại: `lib/features/[feature_name]/data/repositories/`

*   **Nhiệm vụ:** Thực hiện gọi HTTP request (POST/GET/PUT/DELETE).
*   **Quy tắc:** Chỉ xử lý logic mạng và chuyển đổi dữ liệu, không xử lý giao diện.

```dart
class MyRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future<MyResponse> fetchData(MyRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/my-endpoint'),
      body: jsonEncode(request.toJson()),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return MyResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Lỗi API');
    }
  }
}
```

---

### Bước 3: Xây dựng Provider (State Management)
Nằm tại: `lib/features/[feature_name]/presentation/providers/`

*   **Nhiệm vụ:** Quản lý trạng thái (Loading, Success, Error) và dữ liệu cho UI.
*   **Quy tắc:** Luôn sử dụng `notifyListeners()` để cập nhật giao diện.

```dart
enum MyStatus { idle, loading, success, error }

class MyProvider extends ChangeNotifier {
  final MyRepository _repository = MyRepository();
  MyStatus _status = MyStatus.idle;
  String? _errorMessage;

  // Getters
  MyStatus get status => _status;
  String? get errorMessage => _errorMessage;

  Future<void> executeAction() async {
    _status = MyStatus.loading;
    notifyListeners();

    try {
      await _repository.fetchData(...);
      _status = MyStatus.success;
    } catch (e) {
      _status = MyStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }
}
```

---

### Bước 4: Presentation (UI Layer)
Nằm tại: `lib/features/[feature_name]/presentation/pages/`

*   **Nhiệm vụ:** Hiển thị dữ liệu và nhận tương tác người dùng.
*   **Công cụ:** Sử dụng `Consumer<MyProvider>` để lắng nghe thay đổi.

```dart
Consumer<MyProvider>(
  builder: (context, provider, child) {
    if (provider.status == MyStatus.loading) {
      return CircularProgressIndicator();
    }
    
    return FilledButton(
      onPressed: () => provider.executeAction(),
      child: Text('Gửi dữ liệu'),
    );
  },
)
```

---

## 💡 Các lưu ý "Senior"
1.  **Safety:** Luôn kiểm tra `if (context.mounted)` sau mỗi lệnh `await` trước khi dùng `context`.
2.  **Validation:** Dùng `_formKey.currentState!.validate()` để kiểm tra dữ liệu đầu vào trước khi gọi Provider.
3.  **Controllers:** Luôn `dispose()` các `TextEditingController` để tránh rò rỉ bộ nhớ (Memory Leak).
4.  **UX:** Vô hiệu hóa nút bấm (set `onPressed: null`) khi đang ở trạng thái `loading`.

---
*Tài liệu này được biên soạn bởi Antigravity AI Assistant cho dự án MindHealth.*
