import 'package:flutter/material.dart';

import '../../data/models/available_slot_model.dart';
import '../../data/models/appointment_model.dart';
import '../../data/repositories/telehealth_repository.dart';

enum TelehealthStatus { idle, loading, success, error }

class TelehealthProvider extends ChangeNotifier {
  final TelehealthRepository _repository = TelehealthRepository();

  TelehealthStatus _status = TelehealthStatus.idle;
  String _errorMessage = '';
  List<AvailableSlotModel> _slots = [];
  List<AppointmentModel> _myAppointments = [];

  TelehealthStatus get status => _status;
  String get errorMessage => _errorMessage;
  List<AvailableSlotModel> get slots => _slots;
  List<AppointmentModel> get myAppointments => _myAppointments;

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

  Future<AppointmentModel?> book(String patientId, DateTime startAt, bool isAnonymous, {String? token}) async {
    _status = TelehealthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final appt = await _repository.bookAppointment(
        patientId,
        startAt: startAt,
        isAnonymous: isAnonymous,
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

