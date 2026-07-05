import 'package:flutter/material.dart';
import 'package:reconnect_app/core/models/paged_result.dart';
import 'package:reconnect_app/features/journal_ai/data/models/journal_model.dart';
import 'package:reconnect_app/features/journal_ai/data/repositories/journal_repository.dart';

enum JournalProviderStatus { idle, loading, success, error }

class JournalProvider extends ChangeNotifier {
  final JournalRepository _repository = JournalRepository();

  JournalProviderStatus _status = JournalProviderStatus.idle;
  String _errorMessage = '';
  List<JournalModel> _journals = [];
  JournalModel? _selectedJournal;
  int _pageIndex = 1;
  int _pageSize = 10;
  int _totalPages = 0;
  int _totalElements = 0;
  String _keyword = '';

  // Getters
  JournalProviderStatus get status => _status;
  String get errorMessage => _errorMessage;
  List<JournalModel> get journals => _journals;
  JournalModel? get selectedJournal => _selectedJournal;
  int get pageIndex => _pageIndex;
  int get pageSize => _pageSize;
  int get totalPages => _totalPages;
  int get totalElements => _totalElements;
  String get keyword => _keyword;

  // ======================================================
  // 1. TẢI DANH SÁCH LỊCH SỬ NHẬT KÝ
  // ======================================================
  Future<void> loadJournals(String patientId, {String? token}) async {
    await loadJournalsPaged(patientId, token: token);
  }

  Future<void> loadJournalsPaged(
    String patientId, {
    String? token,
    String? keyword,
    int? pageIndex,
    int? pageSize,
  }) async {
    _status = JournalProviderStatus.loading;
    _errorMessage = '';
    if (keyword != null) {
      _keyword = keyword;
    }
    if (pageIndex != null) {
      _pageIndex = pageIndex;
    }
    if (pageSize != null) {
      _pageSize = pageSize;
    }
    notifyListeners();

    try {
      final PagedResult<JournalModel> page = await _repository.getJournalsPaged(
        patientId,
        token: token,
        keyword: _keyword,
        pageIndex: _pageIndex,
        pageSize: _pageSize,
      );
      _journals = page.content;
      _pageIndex = page.pageIndex;
      _pageSize = page.size;
      _totalPages = page.totalPages;
      _totalElements = page.totalElements;
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
