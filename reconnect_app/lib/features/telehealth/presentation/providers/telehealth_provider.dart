import 'package:flutter/material.dart';

import '../../data/models/available_slot_model.dart';
import '../../data/models/appointment_model.dart';
import '../../data/models/therapist_assignment_status_model.dart';
import '../../data/repositories/telehealth_repository.dart';

enum TelehealthStatus { idle, loading, success, error }

class TelehealthProvider extends ChangeNotifier {
  final TelehealthRepository _repository = TelehealthRepository();

  TelehealthStatus _status = TelehealthStatus.idle;
  String _errorMessage = '';
  List<AvailableSlotModel> _slots = [];
  List<AppointmentModel> _myAppointments = [];
  TherapistAssignmentStatusModel? _assignmentStatus;

  TelehealthStatus get status => _status;
  String get errorMessage => _errorMessage;
  List<AvailableSlotModel> get slots => _slots;
  List<AppointmentModel> get myAppointments => _myAppointments;
  TherapistAssignmentStatusModel? get assignmentStatus => _assignmentStatus;

  bool get isAssigned => _assignmentStatus?.assigned == true;
  String get assignmentMessage => _assignmentStatus?.message ?? '';
  String get therapistName => _assignmentStatus?.therapistName ?? '';
  String get carePhaseCode => _assignmentStatus?.carePhaseCode ?? 'STANDARD_WEEKLY';
  String get carePhaseLabel => _assignmentStatus?.carePhaseLabel ?? 'Điều trị tiêu chuẩn';
  String get recommendedFrequencyLabel => _assignmentStatus?.recommendedFrequencyLabel ?? '1 lần / tuần';
  String get recommendedPlanSummary =>
      _assignmentStatus?.recommendedPlanSummary ?? 'Liệu trình chuẩn gồm 14 phiên CBT hàng tuần.';
  String get durationGuidance =>
      _assignmentStatus?.durationGuidance ?? '45-50 phút cho CBT chuẩn, 60 phút cho phiên khởi đầu, 90 phút cho Behavioral Experiment.';
  String get recommendedPurposeCode => _assignmentStatus?.recommendedPurposeCode ?? 'CBT_SESSION';
  bool get allowOverride => _assignmentStatus?.allowOverride == true;

  Future<void> loadAssignmentStatus(String patientId, {String? token}) async {
    _status = TelehealthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _assignmentStatus = await _repository.getTherapistAssignmentStatus(patientId, token: token);
      _status = TelehealthStatus.success;
    } catch (e) {
      _status = TelehealthStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners();
  }

  Future<void> loadSlots(String patientId, DateTime date, {String? token}) async {
    _status = TelehealthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _slots = await _repository.getAvailableSlots(patientId, date, token: token);
      _status = TelehealthStatus.success;
    } catch (e) {
      _status = TelehealthStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners();
  }

  Future<AppointmentModel?> book(
    String patientId,
    DateTime startAt,
    bool isAnonymous, {
    required int durationMinutes,
    String purpose = 'CBT_SESSION',
    String? carePhaseCode,
    String? token,
  }) async {
    _status = TelehealthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final appt = await _repository.bookAppointment(
        patientId,
        startAt: startAt,
        isAnonymous: isAnonymous,
        durationMinutes: durationMinutes,
        purpose: purpose,
        carePhaseCode: carePhaseCode,
        token: token,
      );
      _status = TelehealthStatus.success;
      notifyListeners();
      return appt;
    } catch (e) {
      _status = TelehealthStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  Future<void> loadMyAppointments(String patientId, {String? token}) async {
    _status = TelehealthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _myAppointments = await _repository.getMyAppointments(patientId, token: token);
      _status = TelehealthStatus.success;
    } catch (e) {
      _status = TelehealthStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners();
  }
}
