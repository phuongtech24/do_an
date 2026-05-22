import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../shared/widgets/mindhealth_scaffold.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock PHQ-9 data over 8 weeks
    final dataPoints = [
      const FlSpot(0, 18), // Week 0: Severe
      const FlSpot(2, 14), // Week 2: Moderate
      const FlSpot(4, 9),  // Week 4: Mild
      const FlSpot(6, 4),  // Week 6: Minimal
      const FlSpot(8, 3),  // Week 8: Recovery
    ];

    return MindHealthScaffold(
      title: 'Tiến trình Phục hồi',
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Chỉ số PHQ-9 của bạn',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Biểu đồ thể hiện mức độ trầm cảm của bạn giảm dần qua các tuần trị liệu.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 40),
          
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text('W${value.toInt()}', style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey[300]!)),
                lineBarsData: [
                  LineChartWidgetData(dataPoints),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          _buildInsightCard(
            title: 'Sự tiến bộ vượt bậc!',
            content: 'Bạn đã giảm từ 18 điểm (Nặng) xuống còn 3 điểm (Ổn định). Đây là kết quả của việc bạn đã kiên trì thực hiện Nhật ký suy nghĩ và Bài tập về nhà.',
            icon: Icons.trending_down,
            color: Colors.green[50]!,
          ),
          
          const SizedBox(height: 16),
          _buildInsightCard(
            title: 'Giai đoạn Duy trì',
            content: 'Hiện tại bạn đang ở chế độ duy trì. Hãy tiếp tục đọc Thẻ đối phó hàng ngày để phòng ngừa tái phát.',
            icon: Icons.shield_outlined,
            color: Colors.blue[50]!,
          ),
        ],
      ),
    );
  }

  LineChartBarData LineChartWidgetData(List<FlSpot> spots) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: const Color(0xFF6C63FF),
      barWidth: 4,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: true),
      belowBarData: BarAreaData(
        show: true,
        color: const Color(0xFF6C63FF).withOpacity(0.1),
      ),
    );
  }

  Widget _buildInsightCard({required String title, required String content, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6C63FF)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(content, style: const TextStyle(fontSize: 12, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
