import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:reconnect_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:reconnect_app/features/journal_ai/data/models/journal_model.dart';
import 'package:reconnect_app/features/journal_ai/presentation/providers/cognitive_distortions_provider.dart';
import 'package:reconnect_app/features/journal_ai/presentation/providers/guided_discovery_provider.dart';
import 'package:reconnect_app/features/journal_ai/presentation/providers/journal_provider.dart';
import 'package:reconnect_app/shared/widgets/therapy_guide_card.dart';
import 'package:reconnect_app/theme/app_colors.dart';

class ThoughtRecordScreen extends StatefulWidget {
  final String? agenda;
  final int? initialAnxietyScore;
  final int? initialAvoidanceUrgeScore;
  final int? initialAnticipatoryAnxietyScore;
  final int? initialPostEventRuminationScore;

  const ThoughtRecordScreen({
    super.key,
    this.agenda,
    this.initialAnxietyScore,
    this.initialAvoidanceUrgeScore,
    this.initialAnticipatoryAnxietyScore,
    this.initialPostEventRuminationScore,
  });

  @override
  State<ThoughtRecordScreen> createState() => _ThoughtRecordScreenState();
}

class _ThoughtRecordScreenState extends State<ThoughtRecordScreen> {
  static const _bodySymptomOptions = [
    'Tim đập nhanh',
    'Run tay hoặc giọng',
    'Mặt nóng hoặc đỏ',
    'Khó thở',
    'Căng cứng cơ thể',
    'Đầu óc trống rỗng',
  ];

  static const _safetyBehaviorOptions = [
    'Tránh giao tiếp bằng mắt',
    'Nói thật nhanh cho xong',
    'Chuẩn bị quá kỹ từng câu',
    'Im lặng để không bị chú ý',
    'Nhìn điện thoại để né tránh',
    'Rời khỏi tình huống sớm',
  ];

  final PageController _pageController = PageController();
  final TextEditingController _situationController = TextEditingController();
  final TextEditingController _worstPredictionController = TextEditingController();
  final TextEditingController _thoughtController = TextEditingController();
  final TextEditingController _selfFocusController = TextEditingController();
  final TextEditingController _negativeImageController = TextEditingController();
  final TextEditingController _adaptiveResponseController = TextEditingController();
  final TextEditingController _behaviorExperimentController = TextEditingController();
  final TextEditingController _customBodySymptomController = TextEditingController();
  final TextEditingController _customSafetyBehaviorController = TextEditingController();

  int _currentStep = 0;
  bool _guidedDiscoveryRequested = false;
  bool _distortionsRequested = false;

  late String _situation;
  String _worstPrediction = '';
  String _thought = '';
  String _emotionLabel = 'Lo âu';
  double _belief = 50;
  double _intensity = 50;
  double _finalBelief = 30;
  double _finalIntensity = 30;
  String _selfFocusThought = '';
  String _negativeSelfImage = '';
  String _adaptiveResponse = '';
  String _selectedCommitment = '';
  bool _saveAsCopingCard = true;
  final List<String> _selectedBodySymptoms = [];
  final List<String> _selectedSafetyBehaviors = [];
  List<String> _selectedDistortions = [];

  final List<Map<String, String>> _distortions = const [
    {'code': 'ALL_OR_NOTHING', 'label': 'Trắng đen'},
    {'code': 'CATASTROPHIZING', 'label': 'Thảm hoạ hoá'},
    {'code': 'DISQUALIFYING_POSITIVE', 'label': 'Bác bỏ điều tích cực'},
    {'code': 'EMOTIONAL_REASONING', 'label': 'Lập luận theo cảm xúc'},
    {'code': 'LABELING', 'label': 'Dán nhãn bản thân'},
    {'code': 'MENTAL_FILTER', 'label': 'Chỉ nhìn mặt tiêu cực'},
    {'code': 'MIND_READING', 'label': 'Đọc suy nghĩ người khác'},
    {'code': 'OVERGENERALIZATION', 'label': 'Khái quát hoá quá mức'},
    {'code': 'PERSONALIZATION', 'label': 'Cá nhân hoá'},
    {'code': 'SHOULD_MUST', 'label': 'Áp lực phải / nên'},
    {'code': 'TUNNEL_VISION', 'label': 'Tầm nhìn đường hầm'},
  ];

  @override
  void initState() {
    super.initState();
    _situation = widget.agenda ?? '';
    _situationController.text = _situation;
    _intensity = (widget.initialAnxietyScore ?? 50).toDouble().clamp(0, 100);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _situationController.dispose();
    _worstPredictionController.dispose();
    _thoughtController.dispose();
    _selfFocusController.dispose();
    _negativeImageController.dispose();
    _adaptiveResponseController.dispose();
    _behaviorExperimentController.dispose();
    _customBodySymptomController.dispose();
    _customSafetyBehaviorController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 5) {
      _pageController.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  void _previousStep() {
    if (_currentStep == 0) return;
    _pageController.previousPage(duration: const Duration(milliseconds: 280), curve: Curves.easeInOut);
  }

  Future<void> _handleBackIntent() async {
    if (_currentStep > 0) {
      _previousStep();
      return;
    }
    _resetAiDraftState();
    if (mounted) {
      context.go('/home');
    }
  }

  void _resetAiDraftState() {
    Provider.of<CognitiveDistortionsProvider>(context, listen: false).reset();
    Provider.of<GuidedDiscoveryProvider>(context, listen: false).reset();
  }

  Future<void> _finish() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final journalProvider = Provider.of<JournalProvider>(context, listen: false);

      final model = JournalModel(
        patientId: auth.loginResponse?.user.id ?? '',
        journalType: 'THOUGHT_RECORD',
        situation: _situation.trim(),
        worstPrediction: _worstPrediction.trim(),
        automaticThought: _thought.trim(),
        emotion: _emotionLabel,
        emotionScore: _intensity.toInt(),
        bodySymptoms: _effectiveBodySymptoms,
        selfFocusThought: _selfFocusThought.trim(),
        negativeSelfImage: _negativeSelfImage.trim(),
        safetyBehaviors: _effectiveSafetyBehaviors,
        distortions: _selectedDistortions.isEmpty ? null : _selectedDistortions,
        adaptiveResponse: _adaptiveResponse.trim(),
        safetyBehaviorCommitment: _selectedCommitment.trim().isEmpty ? null : _selectedCommitment.trim(),
        reRatedScore: _finalIntensity.toInt(),
        reRatedBeliefScore: _finalBelief.toInt(),
        behavioralExperimentIdea: _behaviorExperimentController.text.trim().isEmpty
            ? null
            : _behaviorExperimentController.text.trim(),
      );

      final success = await journalProvider.saveNewJournal(model, token: auth.loginResponse?.token);
      final savedJournal = journalProvider.selectedJournal;

      if (mounted) Navigator.pop(context);

      if (!success || !mounted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lưu nhật ký thất bại: ${journalProvider.errorMessage}'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Đã lưu Thought Record', style: TextStyle(fontWeight: FontWeight.w800)),
          content: Text(_successMessage(savedJournal)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/home');
              },
              child: const Text('Về trang chủ'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  String _successMessage(JournalModel? savedJournal) {
    final aiRisk = savedJournal?.aiRiskScore;
    final severity = savedJournal?.severityLevel;
    final riskLine = aiRisk == null
        ? 'AI Risk: chưa có dữ liệu.'
        : aiRisk >= 70
            ? 'AI Risk: $aiRisk/100 - hệ thống đã bật theo dõi ưu tiên.'
            : 'AI Risk: $aiRisk/100.';
    final severityLine = severity == null || severity.isEmpty ? '' : '\nMức AI: $severity.';
    final baseMessage = _saveAsCopingCard
        ? 'Bạn đã hoàn thành nhật ký lo âu xã hội. Phản hồi cân bằng này có thể dùng như một thẻ đối phó.'
        : 'Bạn đã hoàn thành nhật ký lo âu xã hội và có thêm một góc nhìn thực tế hơn.';
    return '$baseMessage\n\n$riskLine$severityLine';
  }

  List<String>? get _effectiveBodySymptoms {
    final values = [..._selectedBodySymptoms];
    final custom = _customBodySymptomController.text.trim();
    if (custom.isNotEmpty) {
      values.add(custom);
    }
    return values.isEmpty ? null : values;
  }

  List<String>? get _effectiveSafetyBehaviors {
    final values = [..._selectedSafetyBehaviors];
    final custom = _customSafetyBehaviorController.text.trim();
    if (custom.isNotEmpty) {
      values.add(custom);
    }
    return values.isEmpty ? null : values;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackIntent();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4FBFA),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: _handleBackIntent,
          ),
          title: const Text('Nhật ký lo âu xã hội'),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 18),
              child: Center(
                child: Text(
                  'Bước ${_currentStep + 1}/6',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentStep + 1) / 6,
              minHeight: 6,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (value) {
                  setState(() => _currentStep = value);
                  if (value == 3 && !_distortionsRequested) {
                    _distortionsRequested = true;
                    _requestDistortions();
                  }
                  if (value == 4 && !_guidedDiscoveryRequested) {
                    _guidedDiscoveryRequested = true;
                    _requestGuidedDiscovery();
                  }
                },
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                  _buildStep5(),
                  _buildStep6(),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Quay lại'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(_currentStep == 5 ? 'Lưu kết quả' : 'Tiếp tục'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _requestDistortions() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final provider = Provider.of<CognitiveDistortionsProvider>(context, listen: false);
    await provider.detect(
      situation: _situation.isEmpty ? 'N/A' : _situation,
      automaticThought: _thought.isEmpty ? 'N/A' : _thought,
      token: auth.loginResponse?.token,
    );
    if (!mounted) return;
    final suggested = provider.distortions;
    if (suggested.isEmpty) return;
    setState(() {
      for (final code in suggested) {
        if (!_selectedDistortions.contains(code)) {
          _selectedDistortions.add(code);
        }
      }
      if (_selectedDistortions.length > 3) {
        _selectedDistortions = _selectedDistortions.sublist(0, 3);
      }
    });
  }

  Future<void> _requestGuidedDiscovery() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final provider = Provider.of<GuidedDiscoveryProvider>(context, listen: false);
    await provider.fetchQuestions(
      situation: _situation.isEmpty ? 'N/A' : _situation,
      automaticThought: _thought.isEmpty ? 'N/A' : _thought,
      emotion: _emotionLabel,
      moodScore: widget.initialAnxietyScore,
      token: auth.loginResponse?.token,
    );
  }

  Widget _buildStep1() {
    return _buildStepContainer(
      title: 'Tình huống & dự đoán tệ nhất',
      description: 'Ghi lại sự kiện xã hội thực tế và điều tệ nhất bạn sợ sẽ xảy ra.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.agenda != null && widget.agenda!.trim().isNotEmpty)
            _buildPinnedCard('Tình huống ưu tiên hôm nay', widget.agenda!),
          _buildTextField(
            controller: _situationController,
            label: 'Tình huống thực tế',
            hint: 'Ví dụ: Mình phải phát biểu trong buổi họp nhóm chiều nay.',
            minLines: 3,
            maxLines: 5,
            onChanged: (value) => _situation = value,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _worstPredictionController,
            label: 'Dự đoán tệ nhất',
            hint: 'Ví dụ: Mọi người sẽ thấy mình ngớ ngẩn và đánh giá mình kém.',
            minLines: 3,
            maxLines: 4,
            onChanged: (value) => _worstPrediction = value,
          ),
          const SizedBox(height: 16),
          _buildCheckInSnapshot(),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return _buildStepContainer(
      title: 'Suy nghĩ tự động',
      description: 'Bắt đúng câu vừa loé lên trong đầu bạn lúc ấy và chấm mức tin vào suy nghĩ đó.',
      child: Column(
        children: [
          const TherapyGuideCard(
            title: 'Mẹo nhỏ',
            message: 'Càng ghi gần nguyên văn câu trong đầu bạn thì phần phản biện phía sau càng hữu ích.',
            icon: Icons.psychology_outlined,
            accentColor: AppColors.primary,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _thoughtController,
            label: 'Suy nghĩ tự động',
            hint: 'Ví dụ: Chắc chắn mình sẽ nói hỏng và mọi người sẽ chê cười.',
            minLines: 3,
            maxLines: 4,
            onChanged: (value) => _thought = value,
          ),
          const SizedBox(height: 20),
          _buildSliderCard(
            title: 'Mức tin vào suy nghĩ này',
            valueLabel: '${_belief.toInt()}%',
            value: _belief,
            onChanged: (value) => setState(() => _belief = value),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return _buildStepContainer(
      title: 'Cảm xúc, cơ thể & self-focus',
      description: 'Nhìn rõ lo âu biểu hiện thế nào trong cảm xúc, cơ thể và hình ảnh tiêu cực về bản thân.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: _emotionLabel,
            items: const ['Lo âu', 'Xấu hổ', 'Buồn bã', 'Giận dữ', 'Thất vọng']
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            decoration: InputDecoration(
              labelText: 'Cảm xúc nổi bật',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onChanged: (value) => setState(() => _emotionLabel = value ?? 'Lo âu'),
          ),
          const SizedBox(height: 18),
          _buildSliderCard(
            title: 'Cường độ cảm xúc hiện tại',
            valueLabel: '${_intensity.toInt()}%',
            value: _intensity,
            onChanged: (value) => setState(() => _intensity = value),
          ),
          const SizedBox(height: 18),
          const Text('Triệu chứng cơ thể', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          _buildSelectableWrap(
            options: _bodySymptomOptions,
            selected: _selectedBodySymptoms,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _customBodySymptomController,
            label: 'Triệu chứng khác (nếu có)',
            hint: 'Ví dụ: Đau bụng, đổ mồ hôi tay...',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _selfFocusController,
            label: 'Bạn đang chú ý vào điều gì ở bản thân?',
            hint: 'Ví dụ: Mình chỉ chăm chăm xem giọng có run không.',
            minLines: 2,
            maxLines: 3,
            onChanged: (value) => _selfFocusThought = value,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _negativeImageController,
            label: 'Hình ảnh tiêu cực về bản thân xuất hiện là gì?',
            hint: 'Ví dụ: Mình tưởng tượng mình đứng lúng túng, mặt đỏ và ai cũng nhìn.',
            minLines: 2,
            maxLines: 3,
            onChanged: (value) => _negativeSelfImage = value,
          ),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    final provider = Provider.of<CognitiveDistortionsProvider>(context);
    return _buildStepContainer(
      title: 'Hành vi an toàn & lỗi tư duy',
      description: 'Tìm các cách né tránh tinh vi mà bạn dùng để bớt lo và xem AI gợi ý lỗi tư duy nào đang nổi bật.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Hành vi an toàn bạn đã dùng', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          _buildSelectableWrap(
            options: _safetyBehaviorOptions,
            selected: _selectedSafetyBehaviors,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _customSafetyBehaviorController,
            label: 'Hành vi an toàn khác',
            hint: 'Ví dụ: Mình học thuộc nguyên câu trước khi nói.',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 18),
          _buildAiBubble(
            provider.hint?.isNotEmpty == true
                ? provider.hint!
                : 'Dựa trên suy nghĩ bạn vừa ghi, hệ thống đang gợi ý một vài lỗi tư duy phổ biến để bạn đối chiếu.',
          ),
          if (provider.status == CognitiveDistortionsStatus.loading) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
          if (provider.status == CognitiveDistortionsStatus.error) ...[
            const SizedBox(height: 10),
            _buildAiBubble('AI đang bận, bạn vẫn có thể tự chọn 1–3 lỗi tư duy phù hợp.', secondary: true),
          ],
          const SizedBox(height: 12),
          ..._distortions.map((item) {
            final code = item['code'] ?? '';
            final label = item['label'] ?? code;
            return CheckboxListTile(
              value: _selectedDistortions.contains(code),
              activeColor: AppColors.primary,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: Text(label),
              onChanged: (selected) {
                setState(() {
                  if (selected == true) {
                    if (!_selectedDistortions.contains(code)) {
                      _selectedDistortions.add(code);
                    }
                    if (_selectedDistortions.length > 3) {
                      _selectedDistortions = _selectedDistortions.sublist(0, 3);
                    }
                  } else {
                    _selectedDistortions.remove(code);
                  }
                });
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStep5() {
    final provider = Provider.of<GuidedDiscoveryProvider>(context);
    final questions = provider.questions.isNotEmpty
        ? provider.questions
        : const [
            'Bằng chứng nào cho thấy dự đoán này chắc chắn đúng? Có bằng chứng nào đi ngược lại không?',
            'Nếu một người bạn thân ở cùng tình huống này, bạn sẽ nói gì với họ?',
            'Mình có đang chú ý quá nhiều vào cảm giác trong người nên quên quan sát dữ liệu bên ngoài không?',
          ];

    return _buildStepContainer(
      title: 'Phản biện thực tế',
      description: 'Dùng câu hỏi Socratic để viết lại phản hồi cân bằng hơn và chọn 1 hành vi an toàn sẽ giảm bớt.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAiBubble('Hãy thử trả lời các câu hỏi sau để kiểm tra lại dự đoán tệ nhất của mình.'),
          const SizedBox(height: 12),
          if (provider.status == GuidedDiscoveryStatus.loading) const LinearProgressIndicator(),
          if (provider.status == GuidedDiscoveryStatus.error)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: _buildAiBubble('AI đang bận, mình dùng bộ câu hỏi chuẩn CBT để bạn tiếp tục nhé.', secondary: true),
            ),
          const SizedBox(height: 12),
          ...questions.map((question) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildAiBubble(question, secondary: true),
              )),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _adaptiveResponseController,
            label: 'Phản hồi cân bằng hơn',
            hint: 'Ví dụ: Mình có thể lo thật, nhưng điều đó không có nghĩa là mọi người sẽ đánh giá mình tệ.',
            minLines: 4,
            maxLines: 6,
            onChanged: (value) => _adaptiveResponse = value,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedCommitment.isEmpty ? null : _selectedCommitment,
            decoration: InputDecoration(
              labelText: 'Hôm nay bạn sẽ giảm bớt hành vi an toàn nào?',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
            items: (_effectiveSafetyBehaviors ?? const <String>[])
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) => setState(() => _selectedCommitment = value ?? ''),
          ),
        ],
      ),
    );
  }

  Widget _buildStep6() {
    return _buildStepContainer(
      title: 'Đánh giá lại & bước tiếp theo',
      description: 'Chấm lại mức tin, cảm xúc và nếu muốn hãy viết một ý tưởng Behavioral Experiment ngắn.',
      child: Column(
        children: [
          _buildSliderCard(
            title: 'Bây giờ bạn còn tin vào suy nghĩ cũ bao nhiêu?',
            valueLabel: '${_finalBelief.toInt()}%',
            value: _finalBelief,
            onChanged: (value) => setState(() => _finalBelief = value),
          ),
          const SizedBox(height: 18),
          _buildSliderCard(
            title: 'Cường độ cảm xúc hiện tại',
            valueLabel: '${_finalIntensity.toInt()}%',
            value: _finalIntensity,
            onChanged: (value) => setState(() => _finalIntensity = value),
          ),
          const SizedBox(height: 18),
          _buildTextField(
            controller: _behaviorExperimentController,
            label: 'Một bước thực hành nhỏ bạn muốn thử',
            hint: 'Ví dụ: Trong cuộc họp tới, mình sẽ nói chậm hơn và giữ giao tiếp mắt 2–3 giây.',
            minLines: 3,
            maxLines: 4,
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: _saveAsCopingCard,
            activeColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
            title: const Text('Lưu phản hồi này làm thẻ đối phó'),
            subtitle: const Text('Để bạn đọc lại khi lo âu quay trở lại.'),
            onChanged: (value) => setState(() => _saveAsCopingCard = value),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContainer({
    required String title,
    required String description,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Text(description, style: const TextStyle(height: 1.45, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    ValueChanged<String>? onChanged,
    int minLines = 1,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: maxLines > 1,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.12)),
        ),
      ),
    );
  }

  Widget _buildSliderCard({
    required String title,
    required String valueLabel,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              ),
              Text(valueLabel, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
            ],
          ),
          Slider(
            value: value,
            min: 0,
            max: 100,
            divisions: 100,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectableWrap({
    required List<String> options,
    required List<String> selected,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((item) {
        final isSelected = selected.contains(item);
        return FilterChip(
          label: Text(item),
          selected: isSelected,
          selectedColor: AppColors.primary.withOpacity(0.14),
          checkmarkColor: AppColors.primary,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
          side: BorderSide(color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.16)),
          onSelected: (value) {
            setState(() {
              if (value) {
                selected.add(item);
              } else {
                selected.remove(item);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildAiBubble(String text, {bool secondary = false}) {
    final background = secondary ? const Color(0xFFF4FAFF) : AppColors.primary.withOpacity(0.08);
    final border = secondary ? const Color(0xFFD7EAFB) : AppColors.primary.withOpacity(0.16);
    final iconColor = secondary ? const Color(0xFF3B82F6) : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(secondary ? Icons.help_outline_rounded : Icons.auto_awesome_rounded, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(height: 1.45, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinnedCard(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF3D98B)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.push_pin_rounded, color: Color(0xFFC99100)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(content, style: const TextStyle(height: 1.4, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInSnapshot() {
    final values = [
      widget.initialAnxietyScore,
      widget.initialAvoidanceUrgeScore,
      widget.initialAnticipatoryAnxietyScore,
      widget.initialPostEventRuminationScore,
    ];
    if (values.every((item) => item == null)) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tóm tắt từ Daily Check-in', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(
            'Lo âu ${widget.initialAnxietyScore ?? 0}/100 • '
            'Né tránh ${widget.initialAvoidanceUrgeScore ?? 0}/100 • '
            'Lo âu dự kiến ${widget.initialAnticipatoryAnxietyScore ?? 0}/8 • '
            'Nhai lại ${widget.initialPostEventRuminationScore ?? 0}/8',
            style: const TextStyle(height: 1.4, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
