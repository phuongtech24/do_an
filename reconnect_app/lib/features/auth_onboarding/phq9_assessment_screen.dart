import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';

class PHQ9AssessmentScreen extends StatefulWidget {
  const PHQ9AssessmentScreen({super.key});

  @override
  State<PHQ9AssessmentScreen> createState() => _PHQ9AssessmentScreenState();
}

class _PHQ9AssessmentScreenState extends State<PHQ9AssessmentScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  List<int?> _answers = List.filled(9, null);

  final List<String> _questions = [
    "Ít hứng thú hoặc niềm vui trong việc làm mọi thứ.",
    "Cảm thấy buồn rầu, chán nản hoặc tuyệt vọng.",
    "Khó đi vào giấc ngủ hoặc ngủ không yên, hoặc ngủ quá nhiều.",
    "Cảm thấy mệt mỏi hoặc có ít năng lượng.",
    "Ăn kém ngon miệng hoặc ăn quá nhiều.",
    "Cảm thấy tồi tệ về bản thân, hoặc cho rằng mình là người thất bại.",
    "Khó tập trung vào mọi việc, chẳng hạn như đọc báo hoặc xem tivi.",
    "Di chuyển hoặc nói năng chậm chạp đến mức người khác có thể nhận thấy.",
    "Có ý nghĩ rằng bạn thà chết đi cho xong hoặc muốn làm tổn thương bản thân theo cách nào đó."
  ];

  final List<String> _options = [
    "Hoàn toàn không (0)",
    "Vài ngày (1)",
    "Hơn một nửa số ngày (2)",
    "Gần như mỗi ngày (3)"
  ];

  void _answerQuestion(int score) {
    setState(() {
      _answers[_currentIndex] = score;
    });
    
    if (_currentIndex < _questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      // Calculate total and mock
      int total = _answers.map((e) => e ?? 0).reduce((a, b) => a + b);
      _showResultDialog(total);
    }
  }

  void _showResultDialog(int score) {
    String severity = "";
    if (score <= 4) severity = "Bình thường";
    else if (score <= 9) severity = "Nhẹ";
    else if (score <= 14) severity = "Vừa";
    else if (score <= 19) severity = "Nặng";
    else severity = "Rất nặng";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hoàn tất đánh giá Baseline'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Điểm PHQ-9 của bạn: $score/27', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text('Mức độ: $severity', style: const TextStyle(color: AppColors.secondary, fontSize: 16)),
            const SizedBox(height: 16),
            const Text('Hệ thống đã lưu lại mức độ này. Chúng tôi sẽ thiết kế Roadmap Game hóa phù hợp riêng cho bạn!'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              context.go('/chat'); // Go to Main App (Chat tab)
            },
            child: const Text('BẮT ĐẦU HÀNH TRÌNH'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Đánh giá PHQ-9 (${_currentIndex + 1}/${_questions.length})'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _questions.length,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
              minHeight: 8,
            ),
            
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Disable swipe
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Trong 2 tuần qua, bạn có thường xuyên bị làm phiền bởi vấn đề sau đây không?",
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Text(
                            _questions[index],
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 22),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 48),
                        
                        ...List.generate(_options.length, (optIndex) {
                          bool isSelected = _answers[index] == optIndex;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: OutlinedButton(
                              onPressed: () => _answerQuestion(optIndex),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
                                side: BorderSide(
                                  color: isSelected ? AppColors.primary : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                _options[optIndex],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
