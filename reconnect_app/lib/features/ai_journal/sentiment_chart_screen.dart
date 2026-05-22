import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class SentimentChartScreen extends StatelessWidget {
  const SentimentChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for negative scores over 7 days (0 -> 100)
    final List<int> weeklyScores = [
      40, 55, 60, 85, 45, 30, 20
    ];
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Biểu đồ Cảm xúc'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Biến động tâm lý (7 ngày qua)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Điểm tiêu cực được AI phân tích từ nhật ký chat của bạn. Điểm cao thể hiện nguy cơ rủi ro cao.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            
            // Mock Chart UI
            Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Y-Axis
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('100', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      Text('75', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      Text('50', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      Text('25', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      Text('0', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(width: 8),
                  
                  // Graph Area Placeholder
                  Expanded(
                    child: Stack(
                      children: [
                        // Grid lines
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(5, (index) => const Divider(color: Colors.black12)),
                        ),
                        
                        // Fake Bar Chart
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(weeklyScores.length, (index) {
                            final score = weeklyScores[index];
                            final isDanger = score > 80;
                            
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Tooltip(
                                  message: 'Điểm: $score',
                                  child: Container(
                                    width: 24,
                                    height: (score / 100) * 180, // scale based on max height
                                    decoration: BoxDecoration(
                                      color: isDanger ? AppColors.alert : AppColors.secondary,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'T${index + 2}',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                ),
                              ],
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Alert Box
            if (weeklyScores.any((score) => score > 80))
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.alert.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.alert.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_rounded, color: AppColors.alert, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Cảnh báo Rủi ro', style: TextStyle(color: AppColors.alert, fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(height: 4),
                          Text(
                            'AI phát hiện tâm lý của bạn có dấu hiệu bất ổn hôm Thứ 5. Bạn có muốn đặt lịch gặp Bác sĩ không?',
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                        ],
                      ),
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
