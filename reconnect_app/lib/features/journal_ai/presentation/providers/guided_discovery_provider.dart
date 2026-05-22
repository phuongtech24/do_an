import 'package:flutter/material.dart';
import 'package:reconnect_app/features/journal_ai/data/repositories/guided_discovery_repository.dart';

enum GuidedDiscoveryStatus { idle, loading, success, error }

class GuidedDiscoveryProvider extends ChangeNotifier {
  final GuidedDiscoveryRepository _repository = GuidedDiscoveryRepository();

  GuidedDiscoveryStatus _status = GuidedDiscoveryStatus.idle;
  String _errorMessage = '';
  List<String> _questions = [];

  GuidedDiscoveryStatus get status => _status;
  String get errorMessage => _errorMessage;
  List<String> get questions => _questions;

  Future<void> fetchQuestions({
    required String situation,
    required String automaticThought,
    String? emotion,
    int? moodScore,
  }) async {
    _status = GuidedDiscoveryStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _questions = await _repository.getQuestions(
        situation: situation,
        automaticThought: automaticThought,
        emotion: emotion,
        moodScore: moodScore,
      );
      _status = GuidedDiscoveryStatus.success;
    } catch (e) {
      _status = GuidedDiscoveryStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners();
  }

  void reset() {
    _status = GuidedDiscoveryStatus.idle;
    _errorMessage = '';
    _questions = [];
    notifyListeners();
  }
}

