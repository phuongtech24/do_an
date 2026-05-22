import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:reconnect_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:reconnect_app/features/journal_ai/data/models/journal_model.dart';
import 'package:reconnect_app/features/journal_ai/presentation/providers/cognitive_distortions_provider.dart';
import 'package:reconnect_app/features/journal_ai/presentation/providers/guided_discovery_provider.dart';
import 'package:reconnect_app/features/journal_ai/presentation/providers/journal_provider.dart';

class ThoughtRecordScreen extends StatefulWidget {
  final String? agenda;
  const ThoughtRecordScreen({super.key, this.agenda});

  @override
  State<ThoughtRecordScreen> createState() => _ThoughtRecordScreenState();
}

class _ThoughtRecordScreenState extends State<ThoughtRecordScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _guidedDiscoveryRequested = false;
  bool _distortionsRequested = false;

  @override
  void initState() {
    super.initState();
    _situation = widget.agenda ?? '';
  }

  // Data
  late String _situation;
  String _thought = '';
  double _belief = 50;
  String _emotionLabel = 'Lo âu';
  double _intensity = 50;
  List<String> _selectedDistortions = []; // distortion codes
  String _adaptiveResponse = '';
  double _finalBelief = 30;
  double _finalIntensity = 30;
  bool _saveAsCopingCard = true;

  final List<Map<String, String>> _distortions = [
    {'code': 'CATASTROPHIZING', 'label': 'Thảm họa hóa (Catastrophizing)'},
    {'code': 'MIND_READING', 'label': 'Đọc tâm trí (Mind Reading)'},
    {'code': 'ALL_OR_NOTHING', 'label': 'Suy nghĩ trắng - đen'},
    {'code': 'OVERGENERALIZATION', 'label': 'Khái quát hóa quá mức'},
    {'code': 'EMOTIONAL_REASONING', 'label': 'Lập luận bằng cảm xúc'},
    {'code': 'LABELING', 'label': 'Dán nhãn (Labeling)'},
  ];

  void _nextStep() {
    if (_currentStep < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _finish() async {
    // 1. Hiển thị Loading Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
        ),
      ),
    );

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final journalProvider = Provider.of<JournalProvider>(context, listen: false);

      final model = JournalModel(
        patientId: auth.loginResponse?.user.id ?? '',
        journalType: 'THOUGHT_RECORD',
        situation: _situation,
        automaticThought: _thought,
        emotion: _emotionLabel,
        emotionScore: _intensity.toInt(),
        distortions: _selectedDistortions.isEmpty ? null : _selectedDistortions,
        adaptiveResponse: _adaptiveResponse,
        reRatedScore: _finalIntensity.toInt(),
      );

      final success = await journalProvider.saveNewJournal(model, token: auth.loginResponse?.token);

      // Đóng Loading Dialog
      if (mounted) Navigator.pop(context);

      if (success) {
        // Hiển thị Dialog thành công
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Hoàn thành Nhật ký', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Text(_saveAsCopingCard 
                ? 'Bạn đã hoàn thành bản ghi nhận thức. Một Thẻ đối phó mới đã được thêm vào kho lưu trữ. AI sẽ cập nhật tiến triển này lên Web CMS của Bác sĩ.'
                : 'Bạn đã hoàn thành bản ghi nhận thức. Cảm xúc của bạn đã dịu đi đáng kể. AI sẽ lưu trữ kết quả này để Bác sĩ tiện theo dõi.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Đóng Dialog thành công
                    context.go('/home'); // Quay lại trang chủ
                  },
                  child: const Text('Trở về Trang chủ', style: TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        }
      } else {
        // Hiển thị thông báo lỗi
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lưu nhật ký thất bại: ${journalProvider.errorMessage}'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Đóng Loading Dialog
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Nhật ký Suy nghĩ 6 bước', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                'Bước ${_currentStep + 1}/6',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6C63FF)),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentStep + 1) / 6,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (v) {
                setState(() => _currentStep = v);
                if (v == 3 && !_distortionsRequested) {
                  _distortionsRequested = true;
                  final cd = Provider.of<CognitiveDistortionsProvider>(context, listen: false);
                  cd
                      .detect(
                        situation: _situation.isEmpty ? 'N/A' : _situation,
                        automaticThought: _thought.isEmpty ? 'N/A' : _thought,
                      )
                      .then((_) {
                    if (!mounted) return;
                    final suggested = cd.distortions;
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
                  });
                }
                if (v == 4 && !_guidedDiscoveryRequested) {
                  _guidedDiscoveryRequested = true;
                  final gd = Provider.of<GuidedDiscoveryProvider>(context, listen: false);
                  gd.fetchQuestions(
                    situation: _situation.isEmpty ? 'N/A' : _situation,
                    automaticThought: _thought.isEmpty ? 'N/A' : _thought,
                    emotion: _emotionLabel,
                  );
                }
              },
              physics: const NeverScrollableScrollPhysics(),
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
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Quay lại'),
                  ),
                ),
              if (_currentStep > 0) const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _currentStep == 5 ? 'Lưu kết quả' : 'Tiếp tục',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildStep1() {
    return _buildStepContainer(
      title: 'Bước 1: Tình huống',
      description: 'Điều gì đã thực sự xảy ra? Bạn đang ở đâu, với ai?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.agenda != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.push_pin, size: 16, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Vấn đề ưu tiên hôm nay: ${widget.agenda}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          TextField(
            maxLines: 5,
            controller: TextEditingController(text: _situation)..selection = TextSelection.fromPosition(TextPosition(offset: _situation.length)),
            onChanged: (v) => _situation = v,
            decoration: InputDecoration(
              hintText: 'VD: Bạn thân không trả lời tin nhắn của tôi suốt 2 tiếng...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return _buildStepContainer(
      title: 'Bước 2: Suy nghĩ tự động',
      description: 'Ý tưởng nào lóe lên trong đầu bạn ngay lúc đó?',
      child: Column(
        children: [
          TextField(
            maxLines: 3,
            onChanged: (v) => _thought = v,
            decoration: InputDecoration(
              hintText: 'VD: Họ chắc chắn đang ghét mình và muốn cắt đứt liên lạc.',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),
          Text('Bạn tin vào suy nghĩ này đến mức nào? (${_belief.toInt()}%)'),
          Slider(
            value: _belief,
            min: 0,
            max: 100,
            activeColor: const Color(0xFF6C63FF),
            onChanged: (v) => setState(() => _belief = v),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return _buildStepContainer(
      title: 'Bước 3: Cảm xúc',
      description: 'Bạn cảm thấy thế nào và mức độ mãnh liệt ra sao?',
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _emotionLabel,
            items: ['Lo âu', 'Buồn bã', 'Giận dữ', 'Tội lỗi', 'Tuyệt vọng']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => _emotionLabel = v!),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 24),
          Text('Cường độ cảm xúc: (${_intensity.toInt()}%)'),
          Slider(
            value: _intensity,
            min: 0,
            max: 100,
            activeColor: Colors.redAccent,
            onChanged: (v) => setState(() => _intensity = v),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    final cd = Provider.of<CognitiveDistortionsProvider>(context);
    return _buildStepContainer(
      title: 'Bước 4: Nhận diện Lỗi tư duy',
      description: 'AI Gemini tự động phân tích các khuôn mẫu tư duy của bạn.',
      child: Column(
        children: [
          _buildAIChatBubble(
            (cd.hint != null && cd.hint!.isNotEmpty)
                ? cd.hint!
                : 'Dựa trên suy nghĩ "$_thought", mình gợi ý bạn có thể đang mắc một số lỗi tư duy sau:',
          ),
          const SizedBox(height: 12),
          if (cd.status == CognitiveDistortionsStatus.loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: LinearProgressIndicator(),
            ),
          if (cd.status == CognitiveDistortionsStatus.error)
            _buildAIChatBubble(
              'AI đang bận, bạn có thể tự tick 1–3 lỗi tư duy phù hợp. (${cd.errorMessage})',
              isSecondary: true,
            ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _distortions.length,
            itemBuilder: (context, index) {
              final code = _distortions[index]['code'] ?? '';
              final label = _distortions[index]['label'] ?? code;
              final isSelected = _selectedDistortions.contains(code);
              return CheckboxListTile(
                title: Text(label, style: const TextStyle(fontSize: 14)),
                value: isSelected,
                activeColor: const Color(0xFF6C63FF),
                onChanged: (v) {
                  setState(() {
                    if (v!) {
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
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep5() {
    final gd = Provider.of<GuidedDiscoveryProvider>(context);
    final questions = gd.questions.isNotEmpty
        ? gd.questions
        : const [
            'Bằng chứng nào cho thấy suy nghĩ này là ĐÚNG? Và bằng chứng nào cho thấy nó có thể SAI?',
            'Có cách giải thích nào khác (ít tiêu cực hơn) cho tình huống này không?',
          ];

    return _buildStepContainer(
      title: 'Bước 5: Khám phá cùng AI (Guided Discovery)',
      description: 'AI Gemini sẽ cùng bạn phản biện suy nghĩ tiêu cực này.',
      child: Column(
        children: [
          _buildAIChatBubble(
            'Để đánh giá tính xác thực của suy nghĩ "$_thought", hãy thử trả lời câu hỏi này nhé:',
          ),
          const SizedBox(height: 12),
          if (gd.status == GuidedDiscoveryStatus.loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: LinearProgressIndicator(),
            ),
          if (gd.status == GuidedDiscoveryStatus.error)
            _buildAIChatBubble(
              'AI đang bận, tạm dùng câu hỏi gợi ý mặc định. (${gd.errorMessage})',
              isSecondary: true,
            ),
          for (final q in questions) _buildAIChatBubble(q, isSecondary: true),
          const SizedBox(height: 24),
          TextField(
            maxLines: 5,
            onChanged: (v) => _adaptiveResponse = v,
            decoration: InputDecoration(
              hintText: 'Nhập câu trả lời thực tế và khách quan hơn của bạn...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          _buildAIChatBubble(
            'Lời khuyên của bạn dành cho một người bạn thân nếu họ cũng gặp tình huống này là gì?',
            isSecondary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAIChatBubble(String text, {bool isSecondary = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSecondary ? Colors.blue[50] : const Color(0xFF6C63FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16).copyWith(topLeft: const Radius.circular(0)),
        border: Border.all(color: isSecondary ? Colors.blue[100]! : const Color(0xFF6C63FF).withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isSecondary ? Icons.help_outline : Icons.auto_awesome, 
            color: isSecondary ? Colors.blue : const Color(0xFF6C63FF), 
            size: 20
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14, 
                color: isSecondary ? Colors.blue[900] : const Color(0xFF6C63FF),
                fontStyle: isSecondary ? FontStyle.normal : FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep6() {
    return _buildStepContainer(
      title: 'Bước 6: Kết quả',
      description: 'Sau khi suy nghĩ lại, hãy đánh giá lại niềm tin của bạn.',
      child: Column(
        children: [
          Text('Niềm tin vào suy nghĩ cũ giờ còn: (${_finalBelief.toInt()}%)'),
          Slider(
            value: _finalBelief,
            min: 0,
            max: 100,
            activeColor: const Color(0xFF6C63FF),
            onChanged: (v) => setState(() => _finalBelief = v),
          ),
          const SizedBox(height: 24),
          Text('Cường độ cảm xúc hiện tại: (${_finalIntensity.toInt()}%)'),
          Slider(
            value: _finalIntensity,
            min: 0,
            max: 100,
            activeColor: Colors.green,
            onChanged: (v) => setState(() => _finalIntensity = v),
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text('Lưu thành Thẻ đối phó', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Phản ứng mới này sẽ được lưu vào kho vũ khí tinh thần của bạn.'),
            value: _saveAsCopingCard,
            activeColor: const Color(0xFF6C63FF),
            onChanged: (v) => setState(() => _saveAsCopingCard = v),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContainer({required String title, required String description, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          Expanded(child: SingleChildScrollView(child: child)),
        ],
      ),
    );
  }
}
