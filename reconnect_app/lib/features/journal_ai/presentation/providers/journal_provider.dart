import 'package:flutter/material.dart';
import 'package:reconnect_app/features/journal_ai/data/models/journal_model.dart';
import 'package:reconnect_app/features/journal_ai/data/repositories/journal_repository.dart';

enum JournalProviderStatus { idle, loading, success, error }

class JournalProvider extends ChangeNotifier {
  final JournalRepository _repository = JournalRepository();

  JournalProviderStatus _status = JournalProviderStatus.idle;
  String _errorMessage = '';
  List<JournalModel> _journals = [];
  JournalModel? _selectedJournal;

  // Getters
  JournalProviderStatus get status => _status;
  String get errorMessage => _errorMessage;
  List<JournalModel> get journals => _journals;
  JournalModel? get selectedJournal => _selectedJournal;

  // ======================================================
  // 1. TẢI DANH SÁCH LỊCH SỬ NHẬT KÝ
  // ======================================================
  Future<void> loadJournals(String patientId, {String? token}) async {
    _status = JournalProviderStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _journals = await _repository.getJournals(patientId, token: token);
      _status = JournalProviderStatus.success;
    } catch (e) {
      _status = JournalProviderStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners();
  }

  // ======================================================
  // 2. LƯU BÀI VIẾT NHẬT KÝ MỚI (Thought Record / Credit List)
  // ======================================================
  Future<bool> saveNewJournal(JournalModel journal, {String? token}) async {
    _status = JournalProviderStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final saved = await _repository.saveJournal(journal, token: token);
      // Thêm bài viết mới vào đầu danh sách để cập nhật tức thời trên UI
      _journals.insert(0, saved);
      _selectedJournal = saved;
      _status = JournalProviderStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _status = JournalProviderStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // ======================================================
  // 3. TẢI CHI TIẾT MỘT BÀI NHẬT KÝ CỤ THỂ
  // ======================================================
  Future<void> loadJournalById(String id, String patientId, {String? token}) async {
    _status = JournalProviderStatus.loading;
    _errorMessage = '';
    _selectedJournal = null;
    notifyListeners();

    try {
      _selectedJournal = await _repository.getJournalById(id, patientId, token: token);
      _status = JournalProviderStatus.success;
    } catch (e) {
      _status = JournalProviderStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners();
  }
}
