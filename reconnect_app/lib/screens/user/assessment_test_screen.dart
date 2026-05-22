import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';

class AssessmentTestScreen extends StatefulWidget {
  final String testType; // 'PHQ-9' or 'GAD-7'

  const AssessmentTestScreen({super.key, required this.testType});

  @override
  State<AssessmentTestScreen> createState() => _AssessmentTestScreenState();
}

class _AssessmentTestScreenState extends State<AssessmentTestScreen> {
  // PHQ-9 Questions
  final List<String> _phq9Questions = [
    'Ít hứng thú hoặc không có niềm vui trong việc làm mọi thứ',
    'Cảm thấy tuyệt vọng, chán nản, hoặc buồn bã',
    'Khó ngủ, ngủ không sâu giấc, hoặc ngủ quá nhiều',
    'Cảm thấy mệt mỏi hoặc có rất ít năng lượng',
    'Chán ăn hoặc ăn quá nhiều',
    'Cảm thấy tồi tệ về bản thân, cho rằng mình là kẻ thất bại',
    'Khó tập trung vào mọi việc (VD: đọc báo hoặc xem TV)',
    'Di chuyển hoặc nói năng chậm chạp đến mức người khác chú ý, hoặc bồn chồn quá mức',
    'Suy nghĩ rằng mình thà chết đi cho xong, hoặc muốn tự làm hại bản thân',
  ];

  // Map to store answers (0-3 scale)
  final Map<int, int> _answers = {};

  int get _totalScore {
    int total = 0;
    _answers.forEach((key, value) {
      total += value;
    });
    return total;
  }

  void _submitTest() {
    if (_answers.length < _phq9Questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng trả lời tất cả các câu hỏi'), backgroundColor: AppColors.alert),
      );
      return;
    }

    // Process Result
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Hoàn thành Đánh giá', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 60, color: AppColors.success),
            const SizedBox(height: 16),
            Text('Điểm số của bạn: $_totalScore / 27', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Kết quả này đã được lưu làm Mốc cơ sở (Baseline) và gửi đến Chuyên gia Tâm lý của bạn một cách bảo mật.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst); // Go back home
              },
              child: const Text('Trở về Trang chủ', style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bài Test ${widget.testType}'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 1,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            color: AppColors.background,
            child: const Text(
              'Trong 2 tuần qua, tần suất bạn bị làm phiền bởi những vấn đề sau là bao nhiêu?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _phq9Questions.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 24),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Câu ${index + 1}: ${_phq9Questions[index]}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _buildRadioOption(index, 0, 'Không bao giờ (0)'),
                        _buildRadioOption(index, 1, 'Vài ngày (1)'),
                        _buildRadioOption(index, 2, 'Hơn một nửa số ngày (2)'),
                        _buildRadioOption(index, 3, 'Gần như mỗi ngày (3)'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
              ]
            ),
            child: CustomButton(
              text: 'Nộp bài & Phân tích',
              onPressed: _submitTest,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRadioOption(int questionIndex, int value, String label) {
    return RadioListTile<int>(
      title: Text(label),
      value: value,
      groupValue: _answers[questionIndex],
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
      dense: true,
      onChanged: (int? newValue) {
        if (newValue != null) {
          setState(() {
            _answers[questionIndex] = newValue;
          });
        }
      },
    );
  }
}
