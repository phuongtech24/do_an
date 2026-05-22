import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/mindhealth_scaffold.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/assessment_provider.dart';
import '../../data/models/phq9_question_model.dart';

class Phq9Screen extends StatefulWidget {
  const Phq9Screen({super.key});

  @override
  State<Phq9Screen> createState() => _Phq9ScreenState();
}

class _Phq9ScreenState extends State<Phq9Screen> {
  // Lưu đáp án dưới dạng: Map<QuestionID, Score>
  final Map<String, int> _answers = {};

  @override
  void initState() {
    super.initState();
    // Tải bộ câu hỏi động từ Backend & Kiểm tra trạng thái cooldown của người bệnh
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
        title: 'Đánh giá Lâm sàng (PHQ-9)',
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
                  child: const Text('Đi tới Đăng nhập'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MindHealthScaffold(
      title: 'Đánh giá Lâm sàng (PHQ-9)',
      body: Consumer<AssessmentProvider>(
        builder: (context, provider, child) {
          // 1. Trạng thái Đang tải dữ liệu (Loading)
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

          // 2. Trạng thái lỗi (Error)
          if (provider.status == AssessmentStatus.error && provider.questionnaire == null) {
            return Center(
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
                      if (patientId.isNotEmpty) {
                        final token = authProvider.loginResponse?.token;
                        provider.loadQuestionnaire(token: token);
                        provider.checkCooldown(patientId, token: token);
                      }
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final questionnaire = provider.questionnaire;
          if (questionnaire == null) {
            return const Center(child: Text('Không tìm thấy dữ liệu câu hỏi.'));
          }

          final questions = questionnaire.questions;
          final options = questionnaire.options;

          // 3. Trạng thái Cooldown hoạt động (Locked - Đang trong thời gian khóa 14 ngày)
          if (provider.isCooldown) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock_clock_outlined, size: 80, color: Colors.amber),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Thời gian giãn cách (Cooldown)',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Hệ thống ghi nhận bạn đã làm bài đánh giá PHQ-9 trong vòng 14 ngày qua.\n\nTheo tiêu chuẩn lâm sàng CBT, bạn chỉ nên làm bài test định kỳ sau mỗi 2 tuần để đảm bảo tính chính xác trong chẩn đoán và theo dõi.',
                      style: TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => context.go('/home'),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Quay lại trang chủ'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final totalScore = _calculateTotalScore(questions);
          final severityLabel = _getSeverityLabel(totalScore);
          final isCompleted = _answers.length == questions.length;
          final hasSuicidalRisk = _hasSuicidalRisk(questions);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bộ câu hỏi PHQ-9',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Trong 2 tuần qua, bạn thường xuyên bị làm phiền bởi vấn đề nào sau đây? Chọn phương án phù hợp nhất với trạng thái của bạn.',
                style: TextStyle(color: Colors.black54, height: 1.4),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: _answers.length / questions.length,
                borderRadius: BorderRadius.circular(20),
                minHeight: 8,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: questions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final q = questions[index];
                    return _QuestionCard(
                      question: q,
                      selectedValue: _answers[q.id],
                      options: options,
                      onChanged: (score) {
                        setState(() {
                          _answers[q.id] = score;
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Card(
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
              ),
              if (hasSuicidalRisk)
                Card(
                  color: Colors.red.shade50,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.red.shade100),
                  ),
                  child: const ListTile(
                    leading: Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                    title: Text(
                      'Chú ý an toàn (Cảnh báo Lâm sàng)',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    subtitle: Text(
                      'Bạn đã đánh dấu có ý nghĩ tự hại ở Câu số 9. Hệ thống khuyến nghị bạn nên liên hệ bác sĩ phụ trách hoặc người thân tin cậy ngay lập tức.',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
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
                const Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 4),
                  child: Center(
                    child: Text(
                      'Vui lòng trả lời đầy đủ tất cả các câu để nộp bài.',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // Tính tổng điểm dựa trên các câu đã trả lời
  int _calculateTotalScore(List<Phq9QuestionModel> questions) {
    int sum = 0;
    for (var q in questions) {
      sum += _answers[q.id] ?? 0;
    }
    return sum;
  }

  // Nhận diện mức độ triệu chứng theo lâm sàng
  String _getSeverityLabel(int score) {
    if (score <= 4) return 'Tối thiểu';
    if (score <= 9) return 'Nhẹ (Mild)';
    if (score <= 14) return 'Trung bình (Moderate)';
    if (score <= 19) return 'Trung bình nặng (Moderately Severe)';
    return 'Nặng (Severe)';
  }

  // Kiểm tra xem câu số 9 có câu trả lời có điểm > 0 hay không
  bool _hasSuicidalRisk(List<Phq9QuestionModel> questions) {
    final q9 = questions.firstWhere(
      (q) => q.questionNumber == 9,
      orElse: () => questions.last,
    );
    return (_answers[q9.id] ?? 0) > 0;
  }

  // Đóng gói và nộp bài test lên Backend
  Future<void> _handleSubmit(
    AssessmentProvider provider,
    String patientId,
    List<Phq9QuestionModel> questions,
  ) async {
    // 1. Sắp xếp danh sách câu hỏi theo đúng thứ tự 1 -> 9 trước khi lấy điểm
    final sortedQuestions = List<Phq9QuestionModel>.from(questions);
    sortedQuestions.sort((a, b) => a.questionNumber.compareTo(b.questionNumber));

    // 2. Trích xuất mảng điểm theo đúng thứ tự câu 1 đến câu 9
    final List<int> answersList = sortedQuestions.map((q) => _answers[q.id] ?? 0).toList();

    // 3. Gọi hàm nộp bài lên API
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.loginResponse?.token;
    // Backend sẽ tự ép kiểu BASELINE nếu bệnh nhân chưa từng có baseline.
    final success = await provider.submitPhq9(patientId, answersList, token: token);

    if (success && mounted) {
      final score = provider.lastSubmission?.totalScore ?? _calculateTotalScore(questions);
      final severity = provider.lastSubmission?.severityLevel ?? _getSeverityLabel(score);
      final submissionType = provider.lastSubmission?.submissionType ?? 'PERIODIC';
      final nextRoute = submissionType == 'BASELINE' ? '/goal-setting' : '/home';
      final nextLabel = submissionType == 'BASELINE' ? 'Thiết lập mục tiêu' : 'Về Trang chủ';

      final graduatedNow = provider.lastSubmission?.graduatedNow == true;
      if (graduatedNow) {
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
          'Tổng điểm của bạn là $score điểm (Mức độ: $severity).\n\nLộ trình bài tập nhận thức - hành vi (CBT Quests) của bạn đã được cập nhật tương ứng với mức độ này.',
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
          'Chỉ số PHQ-9 của bạn đã giảm xuống mức an toàn ($score điểm - $severity).\n\nBạn có nhận thấy rằng tâm trạng cải thiện là nhờ sự nỗ lực thay đổi suy nghĩ và hành vi thời gian qua không? Hãy tiếp tục phát huy nhé!',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(nextRoute);
            },
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
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
            Text('Bạn đã Tốt nghiệp!'),
          ],
        ),
        content: const Text(
          'Chúc mừng bạn đã đạt điều kiện Tốt nghiệp (2 chu kỳ PHQ-9 liên tiếp < 5).\n\nHệ thống sẽ chuyển sang giai đoạn duy trì (Tapering) để phòng ngừa tái phát.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(nextRoute);
            },
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
            child: Text(nextLabel),
          ),
        ],
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
            Column(
              children: List.generate(options.length, (index) {
                final opt = options[index];
                final isSelected = selectedValue == opt.score;
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.08) : Colors.transparent,
                  ),
                  child: RadioListTile<int>(
                    title: Text(
                      opt.text,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.black87,
                      ),
                    ),
                    value: opt.score,
                    groupValue: selectedValue,
                    onChanged: (val) {
                      if (val != null) onChanged(val);
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
