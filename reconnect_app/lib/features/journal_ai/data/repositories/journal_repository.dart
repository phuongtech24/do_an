import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:reconnect_app/core/constants/api_constants.dart';
import 'package:reconnect_app/features/journal_ai/data/models/journal_model.dart';

class JournalRepository {
  // ======================================================
  // Helper to handle and format HTTP response errors robustly
  // ======================================================
  void _handleHttpError(http.Response response, String actionName) {
    if (response.statusCode == 401) {
      throw Exception('Phiên đăng nhập hết hạn hoặc không hợp lệ. Vui lòng đăng nhập lại.');
    } else if (response.statusCode == 403) {
      throw Exception('Bạn không có quyền thực hiện hành động này (403 Forbidden).');
    } else if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Máy chủ phản hồi lỗi ${response.statusCode} khi $actionName.');
    }
  }

  // ======================================================
  // 1. LƯU NHẬT KÝ MỚI (Thought Record hoặc Credit List)
  // ======================================================
  Future<JournalModel> saveJournal(JournalModel journal, {String? token}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.saveJournal),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(journal.toJson()),
      );

      _handleHttpError(response, 'lưu nhật ký');

      final bodyStr = utf8.decode(response.bodyBytes);
      if (bodyStr.isEmpty) {
        throw Exception('Phản hồi từ máy chủ trống rỗng.');
      }

      final json = jsonDecode(bodyStr);

      if (json['status'] == 200 && json['data'] != null) {
        return JournalModel.fromJson(json['data']);
      } else {
        throw Exception(json['message'] ?? 'Lưu nhật ký thất bại');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // ======================================================
  // 2. LẤY DANH SÁCH LỊCH SỬ NHẬT KÝ CỦA BỆNH NHÂN
  // ======================================================
  Future<List<JournalModel>> getJournals(String patientId, {String? token}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.getJournals}?patientId=$patientId'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      _handleHttpError(response, 'tải danh sách nhật ký');

      final bodyStr = utf8.decode(response.bodyBytes);
      if (bodyStr.isEmpty) {
        throw Exception('Phản hồi từ máy chủ trống rỗng.');
      }

      final json = jsonDecode(bodyStr);

      if (json['status'] == 200 && json['data'] != null) {
        final List<dynamic> listData = json['data'];
        return listData.map((item) => JournalModel.fromJson(item)).toList();
      } else {
        throw Exception(json['message'] ?? 'Không thể tải danh sách nhật ký');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // ======================================================
  // 3. XEM CHI TIẾT MỘT BÀI NHẬT KÝ CỤ THỂ
  // ======================================================
  Future<JournalModel> getJournalById(String id, String patientId, {String? token}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.getJournalById(id)}?patientId=$patientId'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      _handleHttpError(response, 'lấy chi tiết nhật ký');

      final bodyStr = utf8.decode(response.bodyBytes);
      if (bodyStr.isEmpty) {
        throw Exception('Phản hồi từ máy chủ trống rỗng.');
      }

      final json = jsonDecode(bodyStr);

      if (json['status'] == 200 && json['data'] != null) {
        return JournalModel.fromJson(json['data']);
      } else {
        throw Exception(json['message'] ?? 'Không thể lấy chi tiết nhật ký');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
