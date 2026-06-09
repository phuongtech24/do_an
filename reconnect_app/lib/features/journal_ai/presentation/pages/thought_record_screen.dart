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
  static const List<String> _quickSuggestions = [
    'Đang họp và bị gọi tên bất ngờ',
    'Chuẩn bị nhắn tin hoặc gọi điện cho ai đó',
    'Đang ở trong lớp và sắp phải phát biểu',
    'Gặp người có thẩm quyền / cấp trên',
    'Đi vào nơi đông người và thấy bị chú ý',
    'Ngồi trong nhóm nhỏ nhưng không biết mở lời',
  ];

  static const List<String> _emotionOptions = [
    'Lo âu',
    'Sợ hãi',
    'Xấu hổ',
    'Ngượng ngùng',
    'Căng thẳng',
  ];

  static const List<String> _bodySymptomOptions = [
    'Tim đập nhanh',
    'Run tay hoặc run giọng',
    'Mặt nóng hoặc đỏ mặt',
    'Khó thở',
    'Căng cứng cơ thể',
    'Đầu óc trống rỗng',
  ];

  static const List<String> _safetyBehaviorOptions = [
    'Cúi gằm mặt / né giao tiếp mắt',
    'Nói thật nhanh cho xong',
    'Chuẩn bị sẵn câu trả lời trong đầu',
    'Giả vờ nhìn điện thoại',
    'Im lặng để không bị chú ý',
    'Rời tình huống sớm',
    'Nắm chặt tay hoặc cố che run',
    'Nói lí nhí để đỡ bị nghe rõ',
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

  final List<Map<String, String>> _distortions = const [
    {'code': 'MIND_READING', 'label': 'Đọc suy nghĩ người khác'},
    {'code': 'CATASTROPHIZING', 'label': 'Thảm họa hóa'},
    {'code': 'EMOTIONAL_REASONING', 'label': 'Lập luận theo cảm xúc'},
    {'code': 'ALL_OR_NOTHING', 'label': 'Trắng đen'},
    {'code': 'LABELING', 'label': 'Dán nhãn bản thân'},
    {'code': 'OVERGENERALIZATION', 'label': 'Khái quát hóa quá mức'},
    {'code': 'SHOULD_MUST', 'label': 'Áp lực phải / nên'},
    {'code': 'MENTAL_FILTER', 'label': 'Chỉ nhìn mặt tiêu cực'},
    {'code': 'PERSONALIZATION', 'label': 'Cá nhân hóa'},
    {'code': 'TUNNEL_VISION', 'label': 'Tầm nhìn đường hầm'},
    {'code': 'DISQUALIFYING_POSITIVE', 'label': 'Bác bỏ điều tích cực'},
  ];

  int _currentStep = 0;
  bool _guidedDiscoveryRequested = false;
  bool _distortionsRequested = false;
  List<String> _suggestedDistortions = [];

  late String _situation;
  String _worstPrediction = '';
  String _emotionLabel = 'Lo âu';
  String _thought = '';
  String _selfFocusThought = '';
  String _negativeSelfImage = '';
  String _adaptiveResponse = '';
  String _selectedCommitment = '';
  bool _saveAsCopingCard = true;

  double _intensity = 50;
  double _belief = 60;
  double _finalIntensity = 30;
  double _finalBelief = 35;

  final List<String> _selectedBodySymptoms = [];
  final List<String> _selectedSafetyBehaviors = [];
  List<String> _selectedDistortions = [];

  @override
  void initState() {
    super.initState();
    _situation = widget.agenda?.trim() ?? '';
    _situationController.text = _situation;
    _intensity = (widget.initialAnxietyScore ?? 50).toDouble().clamp(0, 100);
    _finalIntensity = (_intensity > 20 ? _intensity - 20 : _intensity).clamp(0, 100);
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

  Future<void> _handleBackIntent() async {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOut,
      );
      return;
    }
    _resetAiDraftState();
    if (mounted) {
      context.go('/journal');
    }
  }

  void _resetAiDraftState() {
    Provider.of<CognitiveDistortionsProvider>(context, listen: false).reset();
    Provider.of<GuidedDiscoveryProvider>(context, listen: false).reset();
  }

  void _onPageChanged(int index) {
    setState(() => _currentStep = index);
    if (index == 4 && !_distortionsRequested) {
      _distortionsRequested = true;
      _requestDistortions();
    }
    if (index == 5 && !_guidedDiscoveryRequested) {
      _guidedDiscoveryRequested = true;
      _requestGuidedDiscovery();
    }
  }

  void _nextStep() {
    if (!_canContinueCurrentStep) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn điền thêm một chút nhé để mình dẫn tiếp đúng bước.'),
        ),
      );
      return;
    }
    if (_currentStep < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOut,
      );
      return;
    }
    _finish();
  }

  bool get _canContinueCurrentStep {
    switch (_currentStep) {
      case 0:
        return _situationController.text.trim().isNotEmpty;
      case 1:
        return _emotionLabel.trim().isNotEmpty;
      case 2:
        return _effectiveSafetyBehaviors.isNotEmpty;
      case 3:
        return _thoughtController.text.trim().isNotEmpty;
      case 4:
        return _selectedDistortions.isNotEmpty;
      case 5:
        return _adaptiveResponseController.text.trim().isNotEmpty && _selectedCommitment.trim().isNotEmpty;
      default:
        return true;
    }
  }

  List<String> get _effectiveBodySymptoms {
    final values = [..._selectedBodySymptoms];
    final custom = _customBodySymptomController.text.trim();
    if (custom.isNotEmpty) {
      values.add(custom);
    }
    return values;
  }

  List<String> get _effectiveSafetyBehaviors {
    final values = [..._selectedSafetyBehaviors];
    final custom = _customSafetyBehaviorController.text.trim();
    if (custom.isNotEmpty) {
      values.add(custom);
    }
    return values;
  }

  Future<void> _requestDistortions() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final provider = Provider.of<CognitiveDistortionsProvider>(context, listen: false);
    await provider.detect(
      situation: _situationController.text.trim().isEmpty ? 'N/A' : _situationController.text.trim(),
      automaticThought: _thoughtController.text.trim().isEmpty ? 'N/A' : _thoughtController.text.trim(),
      token: auth.loginResponse?.token,
    );
    if (!mounted) {
      return;
    }
    final suggested = provider.distortions;
    setState(() {
      _suggestedDistortions = List<String>.from(suggested);
      for (final code in suggested) {
        if (!_selectedDistortions.contains(code)) {
          _selectedDistortions.add(code);
        }
      }
      if (_selectedDistortions.length > 4) {
        _selectedDistortions = _selectedDistortions.take(4).toList();
      }
    });
  }

  Future<void> _requestGuidedDiscovery() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final provider = Provider.of<GuidedDiscoveryProvider>(context, listen: false);
    await provider.fetchQuestions(
      situation: _situationController.text.trim().isEmpty ? 'N/A' : _situationController.text.trim(),
      automaticThought: _thoughtController.text.trim().isEmpty ? 'N/A' : _thoughtController.text.trim(),
      emotion: _emotionLabel,
      moodScore: _intensity.toInt(),
      token: auth.loginResponse?.token,
    );
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
        situation: _situationController.text.trim(),
        worstPrediction: _worstPredictionController.text.trim().isEmpty ? null : _worstPredictionController.text.trim(),
        automaticThought: _thoughtController.text.trim(),
        emotion: _emotionLabel,
        emotionScore: _intensity.toInt(),
        bodySymptoms: _effectiveBodySymptoms.isEmpty ? null : _effectiveBodySymptoms,
        selfFocusThought: _selfFocusController.text.trim().isEmpty ? null : _selfFocusController.text.trim(),
        negativeSelfImage: _negativeImageController.text.trim().isEmpty ? null : _negativeImageController.text.trim(),
        safetyBehaviors: _effectiveSafetyBehaviors.isEmpty ? null : _effectiveSafetyBehaviors,
        distortions: _selectedDistortions.isEmpty ? null : _selectedDistortions,
        adaptiveResponse: _adaptiveResponseController.text.trim(),
        safetyBehaviorCommitment: _selectedCommitment.trim(),
        reRatedScore: _finalIntensity.toInt(),
        reRatedBeliefScore: _finalBelief.toInt(),
        behavioralExperimentIdea: _behaviorExperimentController.text.trim().isEmpty
            ? null
            : _behaviorExperimentController.text.trim(),
      );

      final success = await journalProvider.saveNewJournal(
        model,
        token: auth.loginResponse?.token,
      );
      final savedJournal = journalProvider.selectedJournal;

      if (mounted) {
        Navigator.pop(context);
      }

      if (!success || !mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lưu nhật ký thất bại: ${journalProvider.errorMessage}'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text(
            'Đã lưu nhật ký suy nghĩ',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: Text(_successMessage(savedJournal)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/journal');
              },
              child: const Text('Về nhật ký'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra: $error'),
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
            ? 'AI Risk: $aiRisk/100 - hệ thống đã ưu tiên theo dõi.'
            : 'AI Risk: $aiRisk/100.';
    final severityLine = severity == null || severity.isEmpty ? '' : '\nMức AI: $severity.';
    final baseMessage = _saveAsCopingCard
        ? 'Bạn đã hoàn thành Thought Record 6 bước. Phản hồi cân bằng này có thể dùng lại như một thẻ đối phó.'
        : 'Bạn đã hoàn thành Thought Record 6 bước và có thêm một góc nhìn thực tế hơn.';
    return '$baseMessage\n\nGợi ý lỗi tư duy được xử lý riêng ở Bước 5; AI Risk chỉ được chấm khi bạn bấm lưu cuối phiên.\n\n$riskLine$severityLine';
  }

  String _distortionLabel(String code) {
    for (final item in _distortions) {
      if (item['code'] == code) {
        return item['label'] ?? code;
      }
    }
    return code;
  }

  String _distortionReasonSummary(List<String> codes) {
    if (codes.any((code) => code == 'MIND_READING')) {
      return 'Hệ thống thấy suy nghĩ có xu hướng đoán người khác đang nghĩ gì về bạn.';
    }
    if (codes.any((code) => code == 'CATASTROPHIZING')) {
      return 'Hệ thống thấy suy nghĩ đang nghiêng về dự đoán kết quả tệ nhất.';
    }
    if (codes.any((code) => code == 'LABELING')) {
      return 'Hệ thống thấy bạn có thể đang gắn nhãn tiêu cực lên bản thân quá nhanh.';
    }
    if (codes.any((code) => code == 'SHOULD_MUST')) {
      return 'Hệ thống thấy có các câu “phải / nên” khá cứng, dễ tạo áp lực lên bản thân.';
    }
    return 'Đây là các nhãn hệ thống gợi ý trước để bạn rà nhanh, sau đó vẫn tự chọn nhãn phù hợp nhất.';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          return;
        }
        await _handleBackIntent();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4FBFA),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: _handleBackIntent,
          ),
          title: const Text('Nhật ký suy nghĩ 6 bước'),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 18),
              child: Center(
                child: Text(
                  'Bước ${_currentStep + 1}/6',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
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
                onPageChanged: _onPageChanged,
                children: [
                  _buildSituationStep(),
                  _buildEmotionStep(),
                  _buildSafetyBehaviorStep(),
                  _buildAutomaticThoughtStep(),
                  _buildDistortionStep(),
                  _buildAdaptiveResponseStep(),
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
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeInOut,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
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

  Widget _buildSituationStep() {
    return _buildStepContainer(
      stepLabel: 'Bước 1',
      title: 'Xác định tình huống',
      description: 'Điều gì vừa xảy ra khiến bạn thấy tệ hoặc hoảng loạn? Bạn đang ở đâu, làm gì?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_hasCheckInContext) _buildCheckInContextCard(),
          _buildTextField(
            controller: _situationController,
            label: 'Tình huống đang xảy ra',
            hint: 'Ví dụ: Đang ngồi trong cuộc họp và sếp bất ngờ gọi tên mình.',
            minLines: 4,
            onChanged: (value) => _situation = value,
          ),
          const SizedBox(height: 16),
          const Text(
            'Gợi ý bấm nhanh',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickSuggestions.map((item) {
              return ActionChip(
                label: Text(item),
                backgroundColor: Colors.white,
                side: BorderSide(color: AppColors.primary.withOpacity(0.18)),
                onPressed: () {
                  setState(() {
                    _situationController.text = item;
                    _situationController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _situationController.text.length),
                    );
                    _situation = item;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          _buildTextField(
            controller: _worstPredictionController,
            label: 'Điều tệ nhất bạn sợ sẽ xảy ra là gì? (tùy chọn)',
            hint: 'Ví dụ: Mọi người sẽ nghĩ mình kém cỏi hoặc cười mình.',
            minLines: 3,
            onChanged: (value) => _worstPrediction = value,
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionStep() {
    return _buildStepContainer(
      stepLabel: 'Bước 2',
      title: 'Đo cảm xúc lúc này',
      description: 'Bạn đang thấy thế nào và mức độ mạnh đến đâu?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _emotionOptions.map((emotion) {
              final selected = _emotionLabel == emotion;
              return ChoiceChip(
                label: Text(emotion),
                selected: selected,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
                onSelected: (_) => setState(() => _emotionLabel = emotion),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          _buildSliderCard(
            title: 'Mức độ ${_emotionLabel.toLowerCase()}',
            subtitle: '0 = rất nhẹ • 100 = rất mạnh',
            value: _intensity,
            onChanged: (value) => setState(() => _intensity = value),
          ),
          const SizedBox(height: 18),
          const Text(
            'Phản ứng cơ thể đi kèm (tùy chọn)',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _bodySymptomOptions.map((item) {
              final selected = _selectedBodySymptoms.contains(item);
              return FilterChip(
                label: Text(item),
                selected: selected,
                onSelected: (value) {
                  setState(() {
                    if (value) {
                      _selectedBodySymptoms.add(item);
                    } else {
                      _selectedBodySymptoms.remove(item);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _customBodySymptomController,
            label: 'Triệu chứng khác (nếu có)',
            hint: 'Ví dụ: Khô miệng, đau bụng, chóng mặt...',
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyBehaviorStep() {
    return _buildStepContainer(
      stepLabel: 'Bước 3',
      title: 'Bắt hành vi an toàn',
      description: 'Để che giấu sự lo lắng ngay lúc này, bạn đang làm gì?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _safetyBehaviorOptions.map((item) {
              final selected = _selectedSafetyBehaviors.contains(item);
              return FilterChip(
                label: Text(item),
                selected: selected,
                selectedColor: AppColors.primary.withOpacity(0.14),
                checkmarkColor: AppColors.primary,
                onSelected: (value) {
                  setState(() {
                    if (value) {
                      _selectedSafetyBehaviors.add(item);
                    } else {
                      _selectedSafetyBehaviors.remove(item);
                      if (_selectedCommitment == item) {
                        _selectedCommitment = '';
                      }
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _customSafetyBehaviorController,
            label: 'Hành vi an toàn khác',
            hint: 'Ví dụ: Nắm chặt tay, chỉnh tóc liên tục, nói lí nhí...',
          ),
          const SizedBox(height: 18),
          _buildTextField(
            controller: _selfFocusController,
            label: 'Bạn đang tập trung vào điều gì ở bản thân? (tùy chọn)',
            hint: 'Ví dụ: Mình đang đỏ mặt, giọng mình run, mọi người đang nhìn mình...',
            minLines: 2,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _negativeImageController,
            label: 'Bạn có hình ảnh tiêu cực nào về bản thân không? (tùy chọn)',
            hint: 'Ví dụ: Mình trông rất vụng về hoặc kỳ cục trước mặt người khác.',
            minLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildAutomaticThoughtStep() {
    return _buildStepContainer(
      stepLabel: 'Bước 4',
      title: 'Bắt suy nghĩ tự động',
      description: 'Chính xác điều tồi tệ gì đang chạy qua đầu bạn lúc này?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TherapyGuideCard(
            title: 'Gợi ý khi bạn bí ý',
            message: 'Nếu chưa rõ câu chữ, hãy thử hỏi mình: “Mình có đang tưởng tượng ra hình ảnh nào không?”',
            icon: Icons.lightbulb_outline_rounded,
            accentColor: AppColors.primary,
          ),
          const SizedBox(height: 18),
          _buildTextField(
            controller: _thoughtController,
            label: 'Suy nghĩ tự động cốt lõi',
            hint: 'Ví dụ: Sếp và đồng nghiệp đang nghĩ mình kém cỏi.',
            minLines: 4,
            onChanged: (value) => _thought = value,
          ),
          const SizedBox(height: 18),
          _buildSliderCard(
            title: 'Mức độ bạn đang tin vào suy nghĩ này',
            subtitle: '0 = không tin • 100 = tin hoàn toàn',
            value: _belief,
            onChanged: (value) => setState(() => _belief = value),
          ),
        ],
      ),
    );
  }

  Widget _buildDistortionStep() {
    return Consumer<CognitiveDistortionsProvider>(
      builder: (context, provider, _) {
        return _buildStepContainer(
          stepLabel: 'Bước 5',
          title: 'Nhận diện lỗi tư duy',
          description: 'AI có thể gợi ý, nhưng bạn là người tự gắn nhãn cuối cùng.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (provider.status == CognitiveDistortionsStatus.loading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: LinearProgressIndicator(color: AppColors.primary),
                ),
              if (provider.status == CognitiveDistortionsStatus.loading)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Đang phân tích suy nghĩ của bạn để gợi ý lỗi tư duy phù hợp...',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      height: 1.45,
                    ),
                  ),
                ),
              if (provider.status != CognitiveDistortionsStatus.loading && _suggestedDistortions.isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F8F6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withOpacity(0.14)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đã gợi ý ${_suggestedDistortions.length} lỗi tư duy',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _distortionReasonSummary(_suggestedDistortions),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _suggestedDistortions.map((code) {
                          return Chip(
                            label: Text(_distortionLabel(code)),
                            avatar: const Icon(
                              Icons.auto_awesome_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            backgroundColor: Colors.white,
                            side: BorderSide(color: AppColors.primary.withOpacity(0.18)),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              if (provider.status == CognitiveDistortionsStatus.success && _suggestedDistortions.isEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7EA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.warning.withOpacity(0.24)),
                  ),
                  child: const Text(
                    'Chưa thấy mẫu lỗi tư duy quá rõ từ câu bạn vừa viết. Bạn vẫn có thể tự chọn thủ công 1-3 nhãn bên dưới cho sát nhất với trải nghiệm của mình.',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      height: 1.45,
                    ),
                  ),
                ),
              if (provider.hint != null && provider.hint!.trim().isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    provider.hint!,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      height: 1.45,
                    ),
                  ),
                ),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _distortions.map((item) {
                  final code = item['code']!;
                  final label = item['label']!;
                  final selected = _selectedDistortions.contains(code);
                  final suggestedBySystem = _suggestedDistortions.contains(code);
                  return FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(label),
                        if (suggestedBySystem) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.auto_awesome_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ],
                      ],
                    ),
                    selected: selected,
                    selectedColor: const Color(0xFFE0F4F2),
                    checkmarkColor: AppColors.primary,
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          _selectedDistortions.add(code);
                        } else {
                          _selectedDistortions.remove(code);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              if (provider.status == CognitiveDistortionsStatus.error)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Text(
                    'AI gợi ý đang tạm lỗi: ${provider.errorMessage}',
                    style: const TextStyle(color: AppColors.alert),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdaptiveResponseStep() {
    return Consumer<GuidedDiscoveryProvider>(
      builder: (context, provider, _) {
        return _buildStepContainer(
          stepLabel: 'Bước 6',
          title: 'Phản hồi thích nghi',
          description: 'Mình thử bẻ lại vòng lặp lo âu bằng câu hỏi Socrates, rồi cam kết một hành động nhỏ.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Câu hỏi gợi mở',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              if (provider.status == GuidedDiscoveryStatus.loading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: LinearProgressIndicator(color: AppColors.primary),
                ),
              if (provider.questions.isEmpty)
                _buildQuestionCard('Bạn có bằng chứng nào chắc chắn 100% cho suy nghĩ này không?'),
              ...provider.questions.take(3).map(_buildQuestionCard),
              if (provider.status == GuidedDiscoveryStatus.error)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'AI gợi câu hỏi đang tạm lỗi: ${provider.errorMessage}',
                    style: const TextStyle(color: AppColors.alert),
                  ),
                ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _adaptiveResponseController,
                label: 'Suy nghĩ cân bằng hơn',
                hint: 'Ví dụ: Mình chỉ bị bất ngờ thôi, chưa chắc ai đã đánh giá mình. Dù mình nói vấp thì cũng không phải thảm họa.',
                minLines: 4,
                onChanged: (value) => _adaptiveResponse = value,
              ),
              const SizedBox(height: 18),
              const Text(
                'Cam kết giảm hoặc bỏ một hành vi an toàn',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _effectiveSafetyBehaviors.map((item) {
                  final selected = _selectedCommitment == item;
                  return ChoiceChip(
                    label: Text(item),
                    selected: selected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    onSelected: (_) => setState(() => _selectedCommitment = item),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              _buildSliderCard(
                title: 'Chấm lại mức độ lo âu sau khi viết',
                subtitle: '0 = đã dịu đi • 100 = vẫn rất cao',
                value: _finalIntensity,
                onChanged: (value) => setState(() => _finalIntensity = value),
              ),
              const SizedBox(height: 14),
              _buildSliderCard(
                title: 'Chấm lại mức độ tin vào suy nghĩ cũ',
                subtitle: '0 = không còn tin • 100 = vẫn tin hoàn toàn',
                value: _finalBelief,
                onChanged: (value) => setState(() => _finalBelief = value),
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _behaviorExperimentController,
                label: 'Ý tưởng thử nghiệm hành vi tiếp theo (tùy chọn)',
                hint: 'Ví dụ: Ngẩng đầu lên và trả lời đủ 1 câu trong cuộc họp tiếp theo.',
                minLines: 2,
              ),
              const SizedBox(height: 12),
              SwitchListTile.adaptive(
                value: _saveAsCopingCard,
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Lưu phản hồi này thành thẻ đối phó',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text('Để bạn có thể xem lại khi lo âu quay trở lại.'),
                onChanged: (value) => setState(() => _saveAsCopingCard = value),
              ),
            ],
          ),
        );
      },
    );
  }

  bool get _hasCheckInContext =>
      widget.initialAnticipatoryAnxietyScore != null ||
      widget.initialPostEventRuminationScore != null ||
      widget.initialAnxietyScore != null ||
      widget.initialAvoidanceUrgeScore != null;

  Widget _buildCheckInContextCard() {
    final anticipatory = widget.initialAnticipatoryAnxietyScore ?? 0;
    final rumination = widget.initialPostEventRuminationScore ?? 0;
    final anxiety = widget.initialAnxietyScore ?? 0;
    final avoidance = widget.initialAvoidanceUrgeScore ?? 0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE9F8F6), Color(0xFFF7FCFB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'AI vừa gợi ý bạn viết nhật ký',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Check-in gần nhất: Lo âu $anxiety/100 • Né tránh $avoidance/100 • Lo âu dự kiến $anticipatory/8 • Nhai lại $rumination/8.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(String question) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.help_outline_rounded, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              question,
              style: const TextStyle(
                color: AppColors.textPrimary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContainer({
    required String stepLabel,
    required String title,
    required String description,
    required Widget child,
  }) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primary.withOpacity(0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  stepLabel,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              child,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSliderCard({
    required String title,
    required String subtitle,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${value.toInt()}%',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int minLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: minLines == 1 ? 1 : minLines + 1,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
    );
  }
}
