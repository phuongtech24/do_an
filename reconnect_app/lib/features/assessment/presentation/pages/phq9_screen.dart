import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/mindhealth_scaffold.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/phq9_question_model.dart';
import '../providers/assessment_provider.dart';

class Phq9Screen extends StatefulWidget {
  const Phq9Screen({super.key});

  @override
  State<Phq9Screen> createState() => _Phq9ScreenState();
}

class _Phq9ScreenState extends State<Phq9Screen> {
  final Map<String, int> _answers = {};
  int? _functionalDifficultyScore;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final patientId = authProvider.loginResponse?.user.id ?? '';
      final token = authProvider.loginResponse?.token;

      if (patientId.isNotEmpty) {
        final assessmentProvider = Provider.of<AssessmentProvider>(context, listen: false);
        assessmentProvider.loadQuestionnaire(token: token);
        assessmentProvider.checkCooldown(patientId, token: token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final patientId = authProvider.loginResponse?.user.id ?? '';

    if (patientId.isEmpty) {
      return MindHealthScaffold(
        title: 'Đánh giá lâm sàng (PHQ-9)',
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.login_rounded, size: 64, color: Color(0xFF6C63FF)),
                const SizedBox(height: 12),
                const Text(
                  'Bạn chưa đăng nhập.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Vui lòng đăng nhập để tải bộ câu hỏi PHQ-9 từ hệ thống.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.go('/auth'),
                  child: const Text('Đi tới đăng nhập'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MindHealthScaffold(
      title: 'Đánh giá lâm sàng (PHQ-9)',
      body: Consumer<AssessmentProvider>(
        builder: (context, provider, child) {
          if (provider.status == AssessmentStatus.loading && provider.questionnaire == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang tải bộ câu hỏi từ máy chủ lâm sàng...'),
                ],
              ),
            );
          }

          if (provider.status == AssessmentStatus.error && provider.questionnaire == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Không thể tải dữ liệu: ${provider.errorMessage}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final token = authProvider.loginResponse?.token;
                        provider.loadQuestionnaire(token: token);
                        provider.checkCooldown(patientId, token: token);
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          final questionnaire = provider.questionnaire;
          if (questionnaire == null) {
            return const Center(child: Text('Không tìm thấy dữ liệu câu hỏi.'));
          }

          if (provider.isCooldown) {
            return _CooldownView(onBackHome: () => context.go('/home'));
          }

          final questions = questionnaire.questions;
          final options = questionnaire.options;
          final totalScore = _calculateTotalScore(questions);
          final severityLabel = _getSeverityLabel(totalScore);
          final hasAnyProblem = _answers.values.any((score) => score > 0);
          final isCompleted = _answers.length == questions.length &&
              (!hasAnyProblem || _functionalDifficultyScore != null);
          final hasSuicidalRisk = _hasSuicidalRisk(questions);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bộ câu hỏi PHQ-9',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                questionnaire.instruction,
                style: const TextStyle(color: Colors.black54, height: 1.4),
              ),
              const SizedBox(height: 8),
              Text(
                'Chọn mức độ phù hợp nhất với bạn trong 2 tuần vừa qua.',
                style: TextStyle(color: Colors.grey.shade700, height: 1.4),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: questions.isEmpty ? 0 : _answers.length / questions.length,
                borderRadius: BorderRadius.circular(20),
                minHeight: 8,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: questions.length + (hasAnyProblem ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == questions.length) {
                      return _FunctionalDifficultyCard(
                        question: questionnaire.functionalDifficultyQuestion,
                        options: questionnaire.functionalDifficultyOptions,
                        selectedValue: _functionalDifficultyScore,
                        onChanged: (score) => setState(() => _functionalDifficultyScore = score),
                      );
                    }
                    final question = questions[index];
                    return _QuestionCard(
                      question: question,
                      selectedValue: _answers[question.id],
                      options: options,
                      onChanged: (score) {
                        setState(() {
                          _answers[question.id] = score;
                          if (!_answers.values.any((value) => value > 0)) {
                            _functionalDifficultyScore = null;
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              _ScoreSummaryCard(totalScore: totalScore, severityLabel: severityLabel),
              if (hasSuicidalRisk) const _SafetyWarningCard(),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: isCompleted && provider.status != AssessmentStatus.loading
                      ? () => _handleSubmit(provider, patientId, questions)
                      : null,
                  child: provider.status == AssessmentStatus.loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Hoàn tất bài đánh giá'),
                ),
              ),
              if (!isCompleted)
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: Center(
                    child: Text(
                      hasAnyProblem
                          ? 'Vui lòng trả lời thêm mức độ ảnh hưởng đến sinh hoạt.'
                          : 'Vui lòng trả lời đầy đủ tất cả các câu để nộp bài.',
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  int _calculateTotalScore(List<Phq9QuestionModel> questions) {
    int sum = 0;
    for (final question in questions) {
      sum += _answers[question.id] ?? 0;
    }
    return sum;
  }

  String _getSeverityLabel(int score) {
    if (score <= 4) return 'Tối thiểu';
    if (score <= 9) return 'Nhẹ';
    if (score <= 14) return 'Trung bình';
    if (score <= 19) return 'Trung bình nặng';
    return 'Nặng';
  }

  bool _hasSuicidalRisk(List<Phq9QuestionModel> questions) {
    if (questions.isEmpty) return false;
    final q9 = questions.firstWhere(
      (question) => question.questionNumber == 9,
      orElse: () => questions.last,
    );
    return (_answers[q9.id] ?? 0) > 0;
  }

  Future<void> _handleSubmit(
    AssessmentProvider provider,
    String patientId,
    List<Phq9QuestionModel> questions,
  ) async {
    final sortedQuestions = List<Phq9QuestionModel>.from(questions)
      ..sort((a, b) => a.questionNumber.compareTo(b.questionNumber));
    final answersList = sortedQuestions.map((question) => _answers[question.id] ?? 0).toList();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.loginResponse?.token;
    final success = await provider.submitPhq9(
      patientId,
      answersList,
      token: token,
      functionalDifficultyScore: _functionalDifficultyScore,
    );

    if (success && mounted) {
      final score = provider.lastSubmission?.totalScore ?? _calculateTotalScore(questions);
      final severity = provider.lastSubmission?.severityLevel ?? _getSeverityLabel(score);
      final submissionType = provider.lastSubmission?.submissionType ?? 'PERIODIC';
      final nextRoute = submissionType == 'BASELINE' ? '/goal-setting' : '/home';
      final nextLabel = submissionType == 'BASELINE' ? 'Thiết lập mục tiêu' : 'Về trang chủ';

      if (provider.lastSubmission?.graduatedNow == true) {
        _showGraduationDialog(nextRoute, nextLabel);
        return;
      }

      if (score < 5) {
        _showRecoveryCongratsDialog(score, severity, nextRoute, nextLabel);
      } else {
        _showResultDialog(score, severity, nextRoute, nextLabel);
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${provider.errorMessage}')),
      );
    }
  }

  void _showResultDialog(int score, String severity, String nextRoute, String nextLabel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Kết quả đánh giá'),
        content: Text(
          'Tổng điểm của bạn là $score/27 (mức độ: $severity).\n\nLộ trình CBT sẽ được cập nhật theo chu kỳ đánh giá PHQ-9.',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(nextRoute);
            },
            child: Text(nextLabel),
          ),
        ],
      ),
    );
  }

  void _showRecoveryCongratsDialog(int score, String severity, String nextRoute, String nextLabel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 28),
            SizedBox(width: 8),
            Text('Chúc mừng bạn!'),
          ],
        ),
        content: Text(
          'Chỉ số PHQ-9 của bạn đang ở mức an toàn ($score/27 - $severity).\n\nHãy tiếp tục duy trì các hành vi và kỹ năng CBT đang giúp bạn tiến bộ.',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(nextRoute);
            },
            child: Text(nextLabel),
          ),
        ],
      ),
    );
  }

  void _showGraduationDialog(String nextRoute, String nextLabel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.deepPurple, size: 26),
            SizedBox(width: 8),
            Text('Bạn đã tốt nghiệp!'),
          ],
        ),
        content: const Text(
          'Chúc mừng bạn đã đạt điều kiện tốt nghiệp: 2 chu kỳ PHQ-9 liên tiếp dưới 5 điểm.\n\nHệ thống sẽ chuyển sang giai đoạn duy trì để phòng ngừa tái phát.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(nextRoute);
            },
            child: Text(nextLabel),
          ),
        ],
      ),
    );
  }
}

class _CooldownView extends StatelessWidget {
  const _CooldownView({required this.onBackHome});

  final VoidCallback onBackHome;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.amber.shade50, shape: BoxShape.circle),
              child: const Icon(Icons.lock_clock_outlined, size: 80, color: Colors.amber),
            ),
            const SizedBox(height: 24),
            Text(
              'Thời gian giãn cách',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Hệ thống ghi nhận bạn đã làm PHQ-9 trong vòng 14 ngày qua. Bài đánh giá định kỳ nên được thực hiện sau mỗi 2 tuần để theo dõi chính xác hơn.',
              style: TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onBackHome,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Quay lại trang chủ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreSummaryCard extends StatelessWidget {
  const _ScoreSummaryCard({required this.totalScore, required this.severityLabel});

  final int totalScore;
  final String severityLabel;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.insights_rounded, color: Colors.indigo),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tổng điểm: $totalScore/27',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'Mức độ: $severityLabel',
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SafetyWarningCard extends StatelessWidget {
  const _SafetyWarningCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red.shade100),
      ),
      child: const ListTile(
        leading: Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
        title: Text(
          'Chú ý an toàn',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        ),
        subtitle: Text(
          'Bạn đã đánh dấu có ý nghĩ tự hại ở câu số 9. Hệ thống sẽ bật cảnh báo để chuyên gia phụ trách hỗ trợ kịp thời.',
          style: TextStyle(color: Colors.black87),
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.selectedValue,
    required this.options,
    required this.onChanged,
  });

  final Phq9QuestionModel question;
  final int? selectedValue;
  final List<Phq9OptionModel> options;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${question.questionNumber}. ${question.text}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 12),
            for (final option in options)
              _OptionTile(
                score: option.score,
                text: option.text,
                selectedValue: selectedValue,
                onChanged: onChanged,
              ),
          ],
        ),
      ),
    );
  }
}

class _FunctionalDifficultyCard extends StatelessWidget {
  const _FunctionalDifficultyCard({
    required this.question,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  });

  final String question;
  final List<Phq9OptionModel> options;
  final int? selectedValue;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.blueGrey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blueGrey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mức độ ảnh hưởng đến sinh hoạt',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Text(
              question,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 12),
            for (final option in options)
              _OptionTile(
                score: option.score,
                text: option.text,
                selectedValue: selectedValue,
                onChanged: onChanged,
              ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.score,
    required this.text,
    required this.selectedValue,
    required this.onChanged,
  });

  final int score;
  final String text;
  final int? selectedValue;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedValue == score;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.08) : Colors.transparent,
      ),
      child: RadioListTile<int>(
        title: Text(
          '$score - $text',
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.black87,
          ),
        ),
        value: score,
        groupValue: selectedValue,
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        activeColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
