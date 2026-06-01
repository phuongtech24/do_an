import 'package:flutter/material.dart';
import 'package:reconnect_app/features/journal_ai/data/repositories/cognitive_distortions_repository.dart';

enum CognitiveDistortionsStatus { idle, loading, success, error }

class CognitiveDistortionsProvider extends ChangeNotifier {
  final CognitiveDistortionsRepository _repository = CognitiveDistortionsRepository();

  CognitiveDistortionsStatus _status = CognitiveDistortionsStatus.idle;
  String _errorMessage = '';
  List<String> _distortions = [];
  String? _hint;

  CognitiveDistortionsStatus get status => _status;
  String get errorMessage => _errorMessage;
  List<String> get distortions => _distortions;
  String? get hint => _hint;

  Future<void> detect({
    required String situation,
    required String automaticThought,
    String? token,
  }) async {
    _status = CognitiveDistortionsStatus.loading;
    _errorMessage = '';
    _distortions = [];
    _hint = null;
    notifyListeners();

    try {
      final data = await _repository.detect(
        situation: situation,
        automaticThought: automaticThought,
        token: token,
      );
      final list = (data['distortions'] as List<dynamic>? ?? []);
      _distortions = list.map((e) => e.toString()).toList();
      _hint = data['hint']?.toString();
      _status = CognitiveDistortionsStatus.success;
    } catch (e) {
      _status = CognitiveDistortionsStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners();
  }

  void reset() {
    _status = CognitiveDistortionsStatus.idle;
    _errorMessage = '';
    _distortions = [];
    _hint = null;
    notifyListeners();
  }
}
