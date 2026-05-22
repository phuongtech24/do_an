import '../../../../core/network/api_client.dart';
import '../models/quest_template_model.dart';

class AdminQuestTemplateRepository {
  final ApiClient _api = ApiClient();

  Future<List<QuestTemplateModel>> list({required String token}) async {
    final res = await _api.get<List<QuestTemplateModel>>(
      '/admin/quest-templates',
      headers: {'Authorization': 'Bearer $token'},
      parseData: (raw) {
        final list = (raw as List<dynamic>? ?? []);
        return list.map((e) => QuestTemplateModel.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
    if (res.status != 200 || res.data == null) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Cannot load quest templates');
    }
    return res.data!;
  }

  Future<QuestTemplateModel> create({required String token, required QuestTemplateModel input}) async {
    final res = await _api.post<QuestTemplateModel>(
      '/admin/quest-templates',
      headers: {'Authorization': 'Bearer $token'},
      body: input.toCreateJson(),
      parseData: (raw) => raw is Map<String, dynamic> ? QuestTemplateModel.fromJson(raw) : null,
    );
    if (res.status != 200 || res.data == null) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Cannot create quest template');
    }
    return res.data!;
  }

  Future<QuestTemplateModel> update({required String token, required String id, required QuestTemplateModel input}) async {
    final res = await _api.put<QuestTemplateModel>(
      '/admin/quest-templates/$id',
      headers: {'Authorization': 'Bearer $token'},
      body: input.toCreateJson(),
      parseData: (raw) => raw is Map<String, dynamic> ? QuestTemplateModel.fromJson(raw) : null,
    );
    if (res.status != 200 || res.data == null) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Cannot update quest template');
    }
    return res.data!;
  }

  Future<void> delete({required String token, required String id}) async {
    final res = await _api.delete<Object?>(
      '/admin/quest-templates/$id',
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.status != 200) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Cannot delete quest template');
    }
  }
}
