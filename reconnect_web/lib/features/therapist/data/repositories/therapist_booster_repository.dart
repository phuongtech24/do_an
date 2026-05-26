import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../models/appointment_model.dart';
import '../models/therapist_schedule_slot_model.dart';
import '../models/therapist_weekly_schedule_slot_model.dart';

class TherapistBoosterRepository {
  final ApiClient _api = ApiClient();

  Future<List<TherapistScheduleSlotModel>> getSchedule({
    required String token,
    required String therapistId,
    required String date,
  }) async {
    final ApiResponse<List<TherapistScheduleSlotModel>> res = await _api.get<List<TherapistScheduleSlotModel>>(
      '/booster/schedule?therapistId=$therapistId&date=$date',
      headers: {'Authorization': 'Bearer $token'},
      parseData: (raw) {
        final list = (raw as List<dynamic>? ?? const []);
        return list.map((e) => TherapistScheduleSlotModel.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
    if (res.status != 200 || res.data == null) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Không thể tải lịch làm việc');
    }
    return res.data!;
  }

  Future<TherapistScheduleSlotModel> toggleSlot({
    required String token,
    required String therapistId,
    required String slotDate,
    required String startTime,
    required bool open,
  }) async {
    final ApiResponse<TherapistScheduleSlotModel> res = await _api.post<TherapistScheduleSlotModel>(
      '/booster/schedule/toggle',
      headers: {'Authorization': 'Bearer $token'},
      body: {
        'therapistId': therapistId,
        'slotDate': slotDate,
        'startTime': startTime,
        'open': open,
      },
      parseData: (raw) => raw == null ? null : TherapistScheduleSlotModel.fromJson(raw as Map<String, dynamic>),
    );
    if (res.status != 200 || res.data == null) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Không thể thay đổi slot');
    }
    return res.data!;
  }

  Future<List<AppointmentModel>> getAppointments({
    required String token,
    required String therapistId,
  }) async {
    final ApiResponse<List<AppointmentModel>> res = await _api.get<List<AppointmentModel>>(
      '/booster/appointments/therapist?therapistId=$therapistId',
      headers: {'Authorization': 'Bearer $token'},
      parseData: (raw) {
        final list = (raw as List<dynamic>? ?? const []);
        return list.map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
    if (res.status != 200 || res.data == null) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Không thể tải lịch hẹn');
    }
    return res.data!;
  }

  Future<AppointmentModel> updateAppointmentStatus({
    required String token,
    required String appointmentId,
    required String status,
  }) async {
    final ApiResponse<AppointmentModel> res = await _api.patch<AppointmentModel>(
      '/booster/appointments/$appointmentId/status?status=$status',
      headers: {'Authorization': 'Bearer $token'},
      parseData: (raw) => raw == null ? null : AppointmentModel.fromJson(raw as Map<String, dynamic>),
    );
    if (res.status != 200 || res.data == null) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Không thể cập nhật lịch hẹn');
    }
    return res.data!;
  }

  Future<AppointmentModel> updateAppointmentNotes({
    required String token,
    required String appointmentId,
    required String notes,
  }) async {
    final ApiResponse<AppointmentModel> res = await _api.patch<AppointmentModel>(
      '/booster/appointments/$appointmentId/notes',
      headers: {'Authorization': 'Bearer $token'},
      body: {'notes': notes},
      parseData: (raw) => raw == null ? null : AppointmentModel.fromJson(raw as Map<String, dynamic>),
    );
    if (res.status != 200 || res.data == null) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Không thể lưu ghi chú');
    }
    return res.data!;
  }

  Future<List<TherapistWeeklyScheduleSlotModel>> getWeeklySchedule({
    required String token,
    required String therapistId,
  }) async {
    final ApiResponse<List<TherapistWeeklyScheduleSlotModel>> res = await _api.get<List<TherapistWeeklyScheduleSlotModel>>(
      '/booster/weekly-schedule?therapistId=$therapistId',
      headers: {'Authorization': 'Bearer $token'},
      parseData: (raw) {
        final list = (raw as List<dynamic>? ?? const []);
        return list.map((e) => TherapistWeeklyScheduleSlotModel.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
    if (res.status != 200 || res.data == null) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Không thể tải lịch tuần');
    }
    return res.data!;
  }

  Future<TherapistWeeklyScheduleSlotModel> toggleWeeklySlot({
    required String token,
    required String therapistId,
    required String dayOfWeek,
    required String startTime,
    required bool open,
  }) async {
    final ApiResponse<TherapistWeeklyScheduleSlotModel> res = await _api.post<TherapistWeeklyScheduleSlotModel>(
      '/booster/weekly-schedule/toggle',
      headers: {'Authorization': 'Bearer $token'},
      body: {
        'therapistId': therapistId,
        'dayOfWeek': dayOfWeek,
        'startTime': startTime,
        'open': open,
      },
      parseData: (raw) => raw == null ? null : TherapistWeeklyScheduleSlotModel.fromJson(raw as Map<String, dynamic>),
    );
    if (res.status != 200 || res.data == null) {
      throw Exception(res.message.isNotEmpty ? res.message : 'Không thể thay đổi lịch tuần');
    }
    return res.data!;
  }
}
