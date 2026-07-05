import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:reconnect_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:reconnect_app/features/journal_ai/data/models/guide_chat_response_model.dart';
import 'package:reconnect_app/features/journal_ai/presentation/providers/guide_chat_provider.dart';
import 'package:reconnect_app/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:reconnect_app/features/roadmap/presentation/providers/roadmap_provider.dart';
import 'package:reconnect_app/theme/app_colors.dart';

class CbtChatScreen extends StatefulWidget {
  const CbtChatScreen({
    super.key,
    this.screenContext = 'home',
  });

  final String screenContext;

  @override
  State<CbtChatScreen> createState() => _CbtChatScreenState();
}

class _CbtChatScreenState extends State<CbtChatScreen> {
  static const List<String> _quickActions = [
    'Màn này dùng để làm gì?',
    'Tôi nên làm gì tiếp theo?',
    'Giải thích bài tập này',
    'Tôi đang lo, bắt đầu từ đâu?',
  ];

  final TextEditingController _controller = TextEditingController();
  bool _showFreeText = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<GuideChatProvider>().resetConversation(
            intro: _buildIntro(widget.screenContext),
          );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _buildIntro(String screenContext) {
    switch (screenContext) {
      case 'roadmap':
        return 'Mình là Trợ lý đồng hành ở màn Lộ trình. Mình có thể giải thích Fear Ladder, bài thực hành đang mở và gợi ý bước tiếp theo cho bạn.';
      case 'thought-record':
        return 'Mình đang đồng hành cùng bạn ở màn Nhật ký suy nghĩ. Mình có thể giải thích từng bước, vì sao app hỏi câu này và khi nào nên viết tiếp.';
      case 'lsas':
        return 'Mình có thể giải thích bài LSAS, cách chấm điểm và ý nghĩa của kết quả theo đúng bối cảnh lo âu xã hội.';
      default:
        return 'Mình là Trợ lý đồng hành. Mình giúp bạn hiểu app, giải thích các công cụ CBT mức nhẹ và gợi ý bước tiếp theo phù hợp.';
    }
  }

  Future<void> _askGuide(String message) async {
    final auth = context.read<AuthProvider>();
    final onboarding = context.read<OnboardingProvider>();
    final roadmap = context.read<RoadmapProvider>();
    final route = onboarding.onboardingStatus?.lsasClinicalRoute ?? 'REASSURANCE';
    final isRedFlag = route == 'URGENT_RED_FLAG';

    await context.read<GuideChatProvider>().askGuide(
          userMessage: message,
          screenContext: widget.screenContext,
          patientRoute: route,
          programWeek: roadmap.programState.programWeek,
          programPhaseCode: roadmap.programState.programPhaseCode,
          redFlagActive: isRedFlag,
          currentRiskScore: isRedFlag ? 70 : 0,
          token: auth.token,
        );
  }

  void _submitFreeText() {
    final message = _controller.text.trim();
    if (message.isEmpty) return;
    _controller.clear();
    _askGuide(message);
  }

  void _openSuggestedRoute(String route) {
    if (route.isEmpty) return;
    Navigator.of(context).popUntil((routeState) => routeState.isFirst);
    context.go(route);
  }

  String _screenLabel() {
    switch (widget.screenContext) {
      case 'roadmap':
        return 'Lộ trình CBT';
      case 'thought-record':
        return 'Nhật ký suy nghĩ';
      case 'lsas':
        return 'Đánh giá LSAS';
      default:
        return 'Trang hiện tại';
    }
  }

  @override
  Widget build(BuildContext context) {
    final guide = context.watch<GuideChatProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4FBFA),
      appBar: AppBar(
        title: const Text('Trợ lý đồng hành'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bạn đang ở: ${_screenLabel()}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Mình là người bạn dẫn đường trong app: giải thích màn hình, gợi ý bước tiếp theo và hỗ trợ CBT mức nhẹ cho lo âu xã hội.',
                          style: TextStyle(height: 1.45, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final action in _quickActions)
                        ActionChip(
                          label: Text(action),
                          onPressed: () => _askGuide(action),
                          backgroundColor: AppColors.primary.withOpacity(0.08),
                          labelStyle: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ActionChip(
                        label: const Text('Hỏi thêm'),
                        onPressed: () => setState(() => _showFreeText = !_showFreeText),
                        backgroundColor: Colors.white,
                        side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
                        labelStyle: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  if (_showFreeText) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            minLines: 1,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Hỏi ngắn gọn để mình hướng dẫn đúng màn này...',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(color: AppColors.primary.withOpacity(0.12)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(color: AppColors.primary.withOpacity(0.12)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: guide.isLoading ? null : _submitFreeText,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Gửi'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.primary.withOpacity(0.08)),
                ),
                child: ListView(
                  children: [
                    for (final message in guide.messages) ...[
                      _ChatBubble(
                        isUser: message.role == GuideChatRole.user,
                        text: message.text,
                        safetyEscalation: message.safetyEscalation,
                      ),
                      if (message.role == GuideChatRole.assistant &&
                          message.suggestedActions.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 4, right: 4, bottom: 12),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: message.suggestedActions
                                .map(
                                  (action) => OutlinedButton(
                                    onPressed: () => _openSuggestedRoute(action.route),
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: Text(action.label),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                    ],
                    if (guide.isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2.2),
                            ),
                            SizedBox(width: 10),
                            Text('Trợ lý đang suy nghĩ...'),
                          ],
                        ),
                      ),
                    if (guide.status == GuideChatStatus.error && guide.errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          guide.errorMessage,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.isUser,
    required this.text,
    required this.safetyEscalation,
  });

  final bool isUser;
  final String text;
  final bool safetyEscalation;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isUser
        ? AppColors.primary
        : (safetyEscalation ? const Color(0xFFFFF5F4) : const Color(0xFFF3FBFA));

    final borderColor = safetyEscalation ? AppColors.alert.withOpacity(0.2) : AppColors.primary.withOpacity(0.08);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isUser ? Colors.transparent : borderColor),
        ),
        child: Text(
          text,
          style: TextStyle(
            height: 1.45,
            color: isUser ? Colors.white : AppColors.textPrimary,
            fontWeight: safetyEscalation ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
