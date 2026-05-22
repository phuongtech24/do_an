import '../../../../core/network/api_client.dart';
import '../models/admin_user_model.dart';

class AdminUserRepository {
  final ApiClient _api = ApiClient();

  Future<List<AdminUserModel>> listUsers({required String token}) async {
    final res = await _api.get<List<AdminUserModel>>(
      '/admin/users',
      headers: {'Authorization': 'Bearer $token'},
      parseData: (raw) {
        final list = (raw as List<dynamic>? ?? []);
        return list.map((e) => AdminUserModel.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
    if (res.status != 200 || res.data == null) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Cannot load users');
    }
    return res.data!;
  }

  Future<AdminUserModel> setActive({
    required String token,
    required String userId,
    required bool active,
  }) async {
    final res = await _api.patch<AdminUserModel>(
      '/admin/users/$userId/active?active=$active',
      headers: {'Authorization': 'Bearer $token'},
      parseData: (raw) => raw is Map<String, dynamic> ? AdminUserModel.fromJson(raw) : null,
    );
    if (res.status != 200 || res.data == null) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Cannot update user');
    }
    return res.data!;
  }

  Future<AdminUserModel> setRole({
    required String token,
    required String userId,
    required String role,
  }) async {
    final res = await _api.patch<AdminUserModel>(
      '/admin/users/$userId/role?role=$role',
      headers: {'Authorization': 'Bearer $token'},
      parseData: (raw) => raw is Map<String, dynamic> ? AdminUserModel.fromJson(raw) : null,
    );
    if (res.status != 200 || res.data == null) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Cannot update user');
    }
    return res.data!;
  }
}
