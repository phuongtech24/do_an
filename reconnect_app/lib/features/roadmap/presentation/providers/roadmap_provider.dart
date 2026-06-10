import 'package:flutter/material.dart';
import 'dart:io';

import '../../data/models/behavioral_experiment_model.dart';
import '../../data/models/fear_ladder_item_model.dart';
import '../../data/models/patient_quest_model.dart';
import '../../data/models/roadmap_program_state_model.dart';
import '../../data/models/roadmap_safety_overlay_model.dart';
import '../../data/models/verify_quest_proof_result.dart';
import '../../data/repositories/roadmap_repository.dart';

enum RoadmapStatus { idle, loading, success, error }

class RoadmapProvider extends ChangeNotifier {
  final RoadmapRepository _repository = RoadmapRepository();

  RoadmapStatus _status = RoadmapStatus.idle;
  String _errorMessage = '';
  List<PatientQuestModel> _dailyQuests = [];
  List<PatientQuestModel> _questHistory = [];
  List<FearLadderItemModel> _fearLadder = [];
  BehavioralExperimentModel? _todayExperiment;
  bool _historyLoading = false;
  RoadmapSafetyOverlayModel _safetyOverlay = RoadmapSafetyOverlayModel.inactive;
  RoadmapProgramStateModel _programState = RoadmapProgramStateModel.empty;

  RoadmapStatus get status => _status;
  String get errorMessage => _errorMessage;
  List<PatientQuestModel> get dailyQuests => _dailyQuests;
  List<PatientQuestModel> get questHistory => _questHistory;
  List<FearLadderItemModel> get fearLadder => _fearLadder;
  BehavioralExperimentModel? get todayExperiment => _todayExperiment;
  bool get historyLoading => _historyLoading;
  RoadmapSafetyOverlayModel get safetyOverlay => _safetyOverlay;
  RoadmapProgramStateModel get programState => _programState;

  Future<void> loadJourney(String patientId, {String? token}) async {
    _status = RoadmapStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final ladderFuture = _repository.getFearLadder(patientId, token: token);
      final experimentFuture = _repository.getTodayExperiment(patientId, token: token);
      final overlayFuture = _repository.getSafetyOverlay(patientId, token: token);
      final programStateFuture = _repository.getProgramState(patientId, token: token);
      _fearLadder = await ladderFuture;
      _todayExperiment = await experimentFuture;
      _safetyOverlay = await overlayFuture;
      _programState = await programStateFuture;
      _dailyQuests = _programState.todayAssignments;
      _status = RoadmapStatus.success;
    } catch (e) {
      _status = RoadmapStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners();
  }

  Future<bool> startTodayExperiment({
    required String experimentId,
    required String prediction,
    required int predictionBelief,
    required List<String> safetyBehaviors,
    String? token,
  }) async {
    _status = RoadmapStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _todayExperiment = await _repository.startBehavioralExperiment(
        experimentId,
        prediction: prediction,
        predictionBelief: predictionBelief,
        safetyBehaviors: safetyBehaviors,
        token: token,
      );
      _status = RoadmapStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _status = RoadmapStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> debriefTodayExperiment({
    required String experimentId,
    required String executionNotes,
    required String debrief,
    required int postFearScore,
    required int postAvoidanceScore,
    String? token,
  }) async {
    _status = RoadmapStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _todayExperiment = await _repository.debriefBehavioralExperiment(
        experimentId,
        executionNotes: executionNotes,
        debrief: debrief,
        postFearScore: postFearScore,
        postAvoidanceScore: postAvoidanceScore,
        token: token,
      );
      _status = RoadmapStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _status = RoadmapStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> loadDailyQuests(String patientId, {String? token}) async {
    _status = RoadmapStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final questsFuture = _repository.getDailyQuests(patientId, token: token);
      final overlayFuture = _repository.getSafetyOverlay(patientId, token: token);
      final historyFuture = _repository.getQuestHistory(patientId, token: token);
      final programStateFuture = _repository.getProgramState(patientId, token: token);
      _dailyQuests = await questsFuture;
      _safetyOverlay = await overlayFuture;
      _questHistory = await historyFuture;
      _programState = await programStateFuture;
      _status = RoadmapStatus.success;
    } catch (e) {
      _status = RoadmapStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners();
  }

  Future<void> loadQuestHistory(String patientId, {String? token}) async {
    _historyLoading = true;
    notifyListeners();

    try {
      _questHistory = await _repository.getQuestHistory(patientId, token: token);
    } catch (e) {
      debugPrint('RoadmapProvider: Error loading CBT history: $e');
    } finally {
      _historyLoading = false;
      notifyListeners();
    }
  }

  Future<bool> completeQuest(
    String patientId,
    String questId, {
    required int masteryScore,
    required int pleasureScore,
    String? proofImageUrl,
    String? token,
  }) async {
    _status = RoadmapStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final updated = await _repository.completeQuest(
        patientId,
        questId,
        masteryScore: masteryScore,
        pleasureScore: pleasureScore,
        proofImageUrl: proofImageUrl,
        token: token,
      );

      final idx = _dailyQuests.indexWhere((q) => q.id == updated.id);
      if (idx >= 0) {
        _dailyQuests[idx] = updated;
      }
      _status = RoadmapStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _status = RoadmapStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<VerifyQuestProofResult?> verifyQuestProof(
    String patientId,
    String questId, {
    required File imageFile,
    String? token,
  }) async {
    _status = RoadmapStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _repository.verifyQuestProof(
        patientId,
        questId,
        imageFile: imageFile,
        token: token,
      );
      _status = RoadmapStatus.success;
      notifyListeners();
      return result;
    } catch (e) {
      _status = RoadmapStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    }
  }
}
