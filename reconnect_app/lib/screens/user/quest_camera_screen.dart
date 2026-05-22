import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';

class QuestCameraScreen extends StatefulWidget {
  const QuestCameraScreen({super.key});

  @override
  State<QuestCameraScreen> createState() => _QuestCameraScreenState();
}

class _QuestCameraScreenState extends State<QuestCameraScreen> {
  bool _isAnalyzing = false;
  String? _resultMessage;
  bool _isSuccess = false;

  void _simulateTakePhotoAndAnalyze() {
    setState(() {
      _isAnalyzing = true;
      _resultMessage = null;
    });

    // Simulate AI processing time
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          // Randomize success/fail for demo purposes
          _isSuccess = DateTime.now().second % 2 == 0;
          if (_isSuccess) {
            _resultMessage = 'Tuyệt vời! AI phát hiện đây đúng là bầu trời. Cậu đã làm rất tốt! (+10 Năng lượng)';
          } else {
            _resultMessage = 'Hình như đây không phải là ngoài trời. Cậu thử ra cửa sổ hoặc ban công xem sao nhé?';
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thử thách: Đón bình minh'),
        backgroundColor: AppColors.secondary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Nhiệm vụ Level 1',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hãy chụp một bức ảnh bầu trời hoặc quanh cảnh ngoài cửa sổ phòng bạn.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey[400]!, width: 2),
                ),
                child: _isAnalyzing
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.secondary),
                      )
                    : const Center(
                        child: Icon(
                          Icons.camera_alt_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            if (_resultMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isSuccess ? AppColors.success.withValues(alpha: 0.2) : AppColors.alert.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isSuccess ? Icons.check_circle : Icons.error_outline,
                      color: _isSuccess ? AppColors.success : AppColors.alert,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _resultMessage!,
                        style: TextStyle(
                          color: _isSuccess ? Colors.green[800] : Colors.red[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            CustomButton(
              text: 'Chụp ảnh xác thực bằng AI',
              onPressed: _isAnalyzing ? () {} : _simulateTakePhotoAndAnalyze,
              color: AppColors.secondary,
              icon: Icons.camera,
            ),
          ],
        ),
      ),
    );
  }
}
