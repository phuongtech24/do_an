import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../features/cbt_intervention/assign_quest_screen.dart';
import '../../theme/app_colors.dart';

class PatientDetailScreen extends StatefulWidget {
  final Map<String, dynamic> patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  final List<Map<String, dynamic>> _cbtTemplates = [
    {'level': 1, 'title': 'Uống 1 cốc nước ấm sáng sớm', 'color': Colors.blue},
    {'level': 1, 'title': 'Mở rèm cửa 5 phút', 'color': Colors.blue},
    {'level': 2, 'title': 'Đi dạo quanh nhà 5 phút', 'color': Colors.green},
    {'level': 2, 'title': 'Chụp ảnh một cái cây', 'color': Colors.green},
    {'level': 3, 'title': 'Mua đồ ở Konbini', 'color': Colors.purple},
    {'level': 3, 'title': 'Nói "Cảm ơn" với người lạ', 'color': Colors.purple},
  ];

  @override
  Widget build(BuildContext context) {
    final isWarning = widget.patient['status'] == 'Cảnh báo';

    return Scaffold(
      appBar: AppBar(
        title: Text('Hồ sơ: ${widget.patient['name']} ${widget.patient['isAnonymous'] ? "(Ẩn danh)" : ""}'),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Zone: Patient Stats & Tabs
          Expanded(
            flex: 2,
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  // Tab Bar
                  Container(
                    color: Colors.white,
                    child: const TabBar(
                      labelColor: AppColors.primary,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: AppColors.primary,
                      tabs: [
                        Tab(text: 'Tổng quan & AI'),
                        Tab(text: 'Kết quả Bài Test'),
                        Tab(text: 'Trò chuyện trực tiếp'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Tab 1: Overview & AI Chart
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Basic Info Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: widget.patient['color'].withValues(alpha: 0.2),
                          child: Icon(widget.patient['avatar'], size: 40, color: widget.patient['color']),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.patient['name'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isWarning ? AppColors.alert.withValues(alpha: 0.1) : AppColors.success.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      widget.patient['status'],
                                      style: TextStyle(
                                        color: isWarning ? AppColors.alert : AppColors.success,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  if (widget.patient['isAnonymous'])
                                    const Row(
                                      children: [
                                        Icon(Icons.shield, color: AppColors.success, size: 16),
                                        SizedBox(width: 4),
                                        Text('Người dùng không chia sẻ tên thật', style: TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Cognitive Conceptualization Grid
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Distortion Pie Chart
                      Expanded(
                        child: _buildDistortionSection(),
                      ),
                      const SizedBox(width: 24),
                      // Core Beliefs Section
                      Expanded(
                        child: _buildCoreBeliefSection(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Mood & PHQ-9 Line Charts
                  const Text('Diễn biến Tâm lý & Nguy cơ (Mood Tracker)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    height: 300,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: _buildSentimentChart(),
                  ),
                  const SizedBox(height: 32),
                  
                  // One-Click Intervention Panel
                  _buildInterventionPanel(),
                ],
              ),
            ),
            // End Tab 1
            _buildAssessmentTab(),
            _buildChatTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Vertical Divider
          Container(width: 1, color: Colors.grey[200]),
          
          // Right Zone: AI Roadmap Monitor (Read-only)
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tiến độ Lộ trình AI (AI Roadmap)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 8),
                  const Text('Bác sĩ giám sát tiến độ tự động do AI sinh ra.', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 24),
                  
                  Expanded(
                    child: ListView(
                      children: [
                        _buildHomeworkCard(
                          'Ghi nhận việc tốt',
                          'DONE',
                          mastery: 8,
                          pleasure: 6,
                          time: 'Hôm nay, 07:30',
                        ),
                        _buildHomeworkCard(
                          'Tập hít thở sâu',
                          'DONE',
                          mastery: 9,
                          pleasure: 8,
                          time: 'Hôm nay, 08:00',
                        ),
                        _buildHomeworkCard(
                          'Dọn dẹp góc học tập (10p)',
                          'TODO',
                          mastery: 0,
                          pleasure: 0,
                          time: 'Dự kiến: Chiều nay',
                        ),
                      ],
                    ),
                  ),
                  
                  const Divider(height: 48),
                  const Text(
                    'Lưu ý: Hệ thống AI tự động giao bài tập dựa trên chỉ số rủi ro của bệnh nhân mỗi ngày.',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tiến độ Đánh giá Tâm lý Dài hạn (PHQ-9 Long-term Progress)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Hiển thị từ ngày đầu tiên (Baseline) đến nay để đánh giá sự thuyên giảm.', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          Container(
            height: 300,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            // Reusing LineChart for simplicity, mock data
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['Baseline', 'Tuần 2', 'Tuần 4', 'Hiện tại'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(days[value.toInt()], style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0, maxX: 3, minY: 0, maxY: 27,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 22), // Baseline: Severe
                      FlSpot(1, 18), // Week 2: Moderately severe
                      FlSpot(2, 14), // Week 4: Moderate
                      FlSpot(3, 10), // Current: Mild
                    ],
                    isCurved: false,
                    color: AppColors.primary,
                    barWidth: 4,
                    dotData: const FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Kết luận của Bác sĩ:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Nhập đánh giá và nhận xét của bạn...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Lưu Đánh Giá'),
          )
        ],
      ),
    );
  }

  Widget _buildChatTab() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildChatBubble('Chào em, tuần vừa qua mức độ lo âu của em thế nào?', true),
              const SizedBox(height: 8),
              _buildChatBubble('Em làm nhiệm vụ đầy đủ nhưng vẫn thấy khó ngủ bác sĩ ạ.', false),
              const SizedBox(height: 8),
              _buildChatBubble('Em đã thử bài tập hít thở rèm cửa 5 phút chưa?', true),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Nhập tin nhắn bảo mật...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: AppColors.primary,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 20),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildChatBubble(String text, bool isTherapist) {
    return Align(
      alignment: isTherapist ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isTherapist ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isTherapist ? const Radius.circular(0) : const Radius.circular(16),
            bottomLeft: isTherapist ? const Radius.circular(16) : const Radius.circular(0),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(color: isTherapist ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  Widget _buildTemplateCard(Map<String, dynamic> template) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: template['color'].withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'Lv.${template['level']}',
            style: TextStyle(color: template['color'], fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(template['title'], style: const TextStyle(fontSize: 14)),
        trailing: const Icon(Icons.drag_indicator, color: Colors.grey),
      ),
    );
  }

  Widget _buildDistortionSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('AI Nhãn Lỗi Tư Duy (Distortions)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(color: Colors.red, value: 70, title: '70%', radius: 20, showTitle: false),
                  PieChartSectionData(color: Colors.orange, value: 20, title: '20%', radius: 20, showTitle: false),
                  PieChartSectionData(color: Colors.blue, value: 10, title: '10%', radius: 20, showTitle: false),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildDistortionLabel(Colors.red, 'Thảm họa hóa (Catastrophizing)'),
          _buildDistortionLabel(Colors.orange, 'Đọc tâm trí (Mind Reading)'),
          _buildDistortionLabel(Colors.blue, 'Suy nghĩ trắng đen'),
        ],
      ),
    );
  }

  Widget _buildDistortionLabel(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
        ],
      ),
    );
  }

  Widget _buildCoreBeliefSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dự báo Niềm tin Cốt lõi (AI Core Beliefs)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          _buildCoreBeliefBar('Sự bất lực (Helplessness)', 85, Colors.purple),
          _buildCoreBeliefBar('Sự không thể yêu thương (Unlovability)', 40, Colors.pink),
          _buildCoreBeliefBar('Sự vô giá trị (Worthlessness)', 20, Colors.teal),
          const SizedBox(height: 8),
          const Text(
            '*AI dự đoán dựa trên kỹ thuật Mũi tên đi xuống (Downward Arrow) từ dữ liệu Nhật ký Suy nghĩ.',
            style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCoreBeliefBar(String title, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              Text('${value.toInt()}%', style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterventionPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('CAN THIỆP 1 CHẠM & GHI CHÚ BÁC SĨ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ghi chú của Bác sĩ (Therapy Notes)', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    const TextField(
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'VD: Bệnh nhân đã giảm lỗi suy nghĩ trắng đen, tiếp tục theo dõi...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                      child: const Text('Lưu Ghi chú'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  _buildInterventionButton(Icons.send_rounded, 'Gán bài tập CBT', Colors.orange, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AssignQuestScreen(
                          patientId: widget.patient['id'].toString(),
                          patientName: widget.patient['name'].toString(),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  _buildInterventionButton(Icons.phone_callback_rounded, 'YÊU CẦU BOOSTER SESSION', AppColors.alert, () {}),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInterventionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(height: 8),
              Text(
                label, 
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeworkCard(String title, String status, {int mastery = 0, int pleasure = 0, String time = ''}) {
    final isDone = status == 'DONE';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isDone ? Icons.check_circle : Icons.radio_button_unchecked, color: isDone ? AppColors.success : Colors.grey),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
              Text(status, style: TextStyle(color: isDone ? AppColors.success : Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          if (isDone) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatBadge('Mastery', mastery, Colors.purple),
                const SizedBox(width: 8),
                _buildStatBadge('Pleasure', pleasure, Colors.orange),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          Text('$value/10', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSentimentChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Giám sát Rủi ro Ngắn hạn (14 ngày qua)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.alert)),
        const SizedBox(height: 16),
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 20),
              titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                if (value.toInt() >= 0 && value.toInt() < days.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(days[value.toInt()], style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 60),
              FlSpot(1, 65),
              FlSpot(2, 55),
              FlSpot(3, 40),
              FlSpot(4, 30),
              FlSpot(5, 25),
              FlSpot(6, 20),
            ],
            isCurved: true,
            color: AppColors.alert,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.alert.withOpacity(0.1),
            ),
          ),
          LineChartBarData(
            spots: const [
              FlSpot(0, 80),
              FlSpot(1, 75),
              FlSpot(2, 70),
              FlSpot(3, 60),
              FlSpot(4, 55),
              FlSpot(5, 50),
              FlSpot(6, 45),
            ],
            isCurved: true,
            color: AppColors.primary,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    ),
    ),
    ],
    );
  }
}
