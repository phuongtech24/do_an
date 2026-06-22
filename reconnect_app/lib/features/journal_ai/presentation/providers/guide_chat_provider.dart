import 'package:flutter/material.dart';

import 'package:reconnect_app/features/journal_ai/data/models/guide_chat_response_model.dart';
import 'package:reconnect_app/features/journal_ai/data/repositories/guide_chat_repository.dart';

enum GuideChatRole { user, assistant }

class GuideChatMessage {
  final GuideChatRole role;
  final String text;
  final List<GuideChatSuggestedActionModel> suggestedActions;
  final bool safetyEscalation;

  const GuideChatMessage({
    required this.role,
    required this.text,
    this.suggestedActions = const [],
    this.safetyEscalation = false,
  });
}

enum GuideChatStatus { idle, loading, success, error }

class GuideChatProvider extends ChangeNotifier {
  final GuideChatRepository _repository = GuideChatRepository();

  GuideChatStatus _status = GuideChatStatus.idle;
  String _errorMessage = '';
  final List<GuideChatMessage> _messages = [];

  GuideChatStatus get status => _status;
  String get errorMessage => _errorMessage;
  List<GuideChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _status == GuideChatStatus.loading;

  void resetConversation({String? intro}) {
    _messages
      ..clear()
      ..add(
        GuideChatMessage(
          role: GuideChatRole.assistant,
          text: intro ??
              'Mình là Trợ lý đồng hành. Mình giúp bạn hiểu màn hiện tại, giải thích công cụ CBT mức nhẹ và gợi ý bước tiếp theo trong app.',
        ),
      );
    _status = GuideChatStatus.idle;
    _errorMessage = '';
    notifyListeners();
  }

  Future<void> askGuide({
    required String userMessage,
    required String screenContext,
    required String patientRoute,
    int? programWeek,
    String? programPhaseCode,
    required bool redFlagActive,
    required int currentRiskScore,
    String? token,
  }) async {
    _messages.add(GuideChatMessage(role: GuideChatRole.user, text: userMessage));
    _status = GuideChatStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _repository.sendGuideMessage(
        userMessage: userMessage,
        screenContext: screenContext,
        patientRoute: patientRoute,
        programWeek: programWeek,
        programPhaseCode: programPhaseCode,
        redFlagActive: redFlagActive,
        currentRiskScore: currentRiskScore,
        token: token,
      );

      _messages.add(
        GuideChatMessage(
          role: GuideChatRole.assistant,
          text: response.answer,
          suggestedActions: response.suggestedActions,
          safetyEscalation: response.safetyEscalation,
        ),
      );
      _status = GuideChatStatus.success;
    } catch (e) {
      _status = GuideChatStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _messages.add(
        GuideChatMessage(
          role: GuideChatRole.assistant,
          text: 'Mình chưa trả lời được lúc này. Bạn thử lại hoặc chọn một gợi ý nhanh để mình hỗ trợ đúng màn hơn nhé.',
        ),
      );
    }
    notifyListeners();
  }
}
