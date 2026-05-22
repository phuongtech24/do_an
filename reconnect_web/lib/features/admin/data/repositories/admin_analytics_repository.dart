import '../../../../core/network/api_client.dart';
import '../models/admin_analytics_model.dart';

class AdminAnalyticsRepository {
  final ApiClient _api = ApiClient();

  Future<AdminAnalyticsModel> getAnalytics({required String token}) async {
    final res = await _api.get<AdminAnalyticsModel>(
      '/admin/analytics',
      headers: {'Authorization': 'Bearer $token'},
      parseData: (raw) => raw is Map<String, dynamic> ? AdminAnalyticsModel.fromJson(raw) : null,
    );
    if (res.status != 200 || res.data == null) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Cannot load analytics');
    }
    return res.data!;
  }
}

