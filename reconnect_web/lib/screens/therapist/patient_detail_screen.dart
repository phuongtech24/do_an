import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/auth/auth_provider.dart';
import '../../features/cbt_intervention/assign_quest_screen.dart';
import '../../features/therapist/data/models/therapist_quest_progress_model.dart';
import '../../features/therapist/data/models/therapist_risk_analytics_model.dart';
import '../../features/therapist/data/repositories/therapist_patient_repository.dart';
import '../../theme/app_colors.dart';

class PatientDetailScreen extends StatefulWidget {
  final Map<String, dynamic> patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  final TherapistPatientRepository _therapistPatientRepository = TherapistPatientRepository();
  TherapistQuestProgressModel? _questProgress;
  bool _questProgressLoading = false;
  String? _questProgressError;
  TherapistRiskAnalyticsModel? _riskAnalytics;
  bool _riskAnalyticsLoading = false;
  String? _riskAnalyticsError;

  final List<Map<String, dynamic>> _cbtTemplates = [
    {'level': 1, 'title': 'Uống 1 cốc nước ấm sáng sớm', 'color': Colors.blue},
    {'level': 1, 'title': 'Mở rèm cửa 5 phút', 'color': Colors.blue},
    {'level': 2, 'title': 'Đi dạo quanh nhà 5 phút', 'color': Colors.green},
    {'level': 2, 'title': 'Chụp ảnh một cái cây', 'color': Colors.green},
    {'level': 3, 'title': 'Mua đồ ở Konbini', 'color': Colors.purple},
    {'level': 3, 'title': 'Nói "Cảm ơn" với người lạ', 'color': Colors.purple},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQuestProgress();
      _loadRiskAnalytics();
    });
  }

  Future<void> _loadQuestProgress() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final patientId = widget.patient['id']?.toString() ?? '';
    if (token == null || token.isEmpty || patientId.isEmpty) return;
    setState(() {
      _questProgressLoading = true;
      _questProgressError = null;
    });
    try {
      final progress = await _therapistPatientRepository.getQuestProgress(
        token: token,
        patientId: patientId,
      );
      if (!mounted) return;
      setState(() => _questProgress = progress);
    } catch (e) {
      if (!mounted) return;
      setState(() => _questProgressError = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() => _questProgressLoading = false);
    }
  }

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
          
          // Right Zone: CBT Progress Monitor
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(32),
              child: _buildQuestProgressPanel(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadRiskAnalytics() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final patientId = widget.patient['id']?.toString() ?? '';
    if (token == null || token.isEmpty || patientId.isEmpty) return;
    setState(() {
      _riskAnalyticsLoading = true;
      _riskAnalyticsError = null;
    });
    try {
      final analytics = await _therapistPatientRepository.getRiskAnalytics(
        token: token,
        patientId: patientId,
        days: 14,
      );
      if (!mounted) return;
      setState(() => _riskAnalytics = analytics);
    } catch (e) {
      if (!mounted) return;
      setState(() => _riskAnalyticsError = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() => _riskAnalyticsLoading = false);
    }
  }

  Widget _buildQuestProgressPanel() {
    final progress = _questProgress;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Tiến độ CBT',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
            IconButton(
              tooltip: 'Tải lại',
              onPressed: _questProgressLoading ? null : _loadQuestProgress,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Theo dõi bài hệ thống giao và bài bác sĩ giao cho bệnh nhân.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        if (_questProgressLoading && progress == null)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (_questProgressError != null)
          Expanded(
            child: Center(
              child: Text(_questProgressError!, style: const TextStyle(color: AppColors.alert)),
            ),
          )
        else if (progress == null)
          const Expanded(child: Center(child: Text('Chưa có dữ liệu tiến độ CBT.')))
        else
          Expanded(
            child: ListView(
              children: [
                _buildProgressSummary(progress),
                const SizedBox(height: 16),
                _buildScoreSummary(progress),
                const SizedBox(height: 24),
                const Text('Bài gần đây', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                if (progress.recentQuests.isEmpty)
                  const Text('Chưa có bài tập CBT nào.', style: TextStyle(color: AppColors.textSecondary))
                else
                  ...progress.recentQuests.map(_buildQuestProgressCard),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildProgressSummary(TherapistQuestProgressModel progress) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildProgressMetric('Tổng bài', '${progress.totalAssigned}', Icons.assignment_outlined, AppColors.primary)),
            const SizedBox(width: 12),
            Expanded(child: _buildProgressMetric('Hoàn thành', '${progress.completed}', Icons.check_circle_outline, AppColors.success)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildProgressMetric('Tỷ lệ', '${progress.completionRate.toStringAsFixed(0)}%', Icons.trending_up, Colors.orange)),
            const SizedBox(width: 12),
            Expanded(child: _buildProgressMetric('Bác sĩ giao', '${progress.therapistAssigned}', Icons.medical_services_outlined, Colors.purple)),
          ],
        ),
        const SizedBox(height: 12),
        _buildProgressMetric('Hệ thống giao', '${progress.systemAssigned}', Icons.auto_awesome, Colors.teal),
      ],
    );
  }

  Widget _buildProgressMetric(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
                Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSummary(TherapistQuestProgressModel progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Điểm tự đánh giá trung bình', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildScoreChip('Mastery', progress.averageMastery)),
              const SizedBox(width: 8),
              Expanded(child: _buildScoreChip('Pleasure', progress.averagePleasure)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreChip(String label, double? value) {
    final text = value == null ? 'Chưa có' : '${value.toStringAsFixed(1)}/10';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text('$label: $text', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildQuestProgressCard(TherapistQuestProgressItemModel quest) {
    final done = quest.status == 'DONE';
    final sourceText = quest.sourceType == 'THERAPIST' ? 'Bác sĩ' : 'Hệ thống';
    final assignedText = _formatDateTime(quest.assignedAt);
    final completedText = _formatDateTime(quest.completedAt);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, color: done ? AppColors.success : Colors.orange),
              const SizedBox(width: 10),
              Expanded(child: Text(quest.title, style: const TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSmallBadge(_statusText(quest.status), done ? AppColors.success : Colors.orange),
              _buildSmallBadge(sourceText, quest.sourceType == 'THERAPIST' ? Colors.purple : Colors.teal),
              if (quest.category.isNotEmpty) _buildSmallBadge(quest.category, AppColors.primary),
            ],
          ),
          const SizedBox(height: 10),
          Text('Giao: $assignedText', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          if (quest.completedAt != null)
            Text('Hoàn thành: $completedText', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          if (quest.masteryScore != null || quest.pleasureScore != null) ...[
            const SizedBox(height: 8),
            Text(
              'Mastery: ${quest.masteryScore?.toString() ?? "-"} / Pleasure: ${quest.pleasureScore?.toString() ?? "-"}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSmallBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  String _statusText(String status) {
    switch (status) {
      case 'DONE':
        return 'Đã hoàn thành';
      case 'AVAILABLE':
        return 'Đang mở';
      case 'LOCKED':
        return 'Đang khóa';
      default:
        return status;
    }
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return '-';
    return DateFormat('dd/MM/yyyy HH:mm').format(value);
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
                  _buildInterventionButton(Icons.send_rounded, 'Gán bài tập CBT', Colors.orange, () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AssignQuestScreen(
                          patientId: widget.patient['id'].toString(),
                          patientName: widget.patient['name'].toString(),
                        ),
                      ),
                    );
                    if (mounted) {
                      _loadQuestProgress();
                    }
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
    final analytics = _riskAnalytics;
    if (_riskAnalyticsLoading && analytics == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_riskAnalyticsError != null) {
      return Center(child: Text(_riskAnalyticsError!, style: const TextStyle(color: AppColors.alert)));
    }
    if (analytics == null || analytics.points.isEmpty) {
      final currentRisk = widget.patient['riskScore'] as int? ?? 0;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Giám sát rủi ro 14 ngày', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.alert)),
          const SizedBox(height: 16),
          _buildRiskMetric('Risk hiện tại', '$currentRisk', Icons.monitor_heart_outlined, currentRisk >= 70 ? AppColors.alert : AppColors.primary),
          const SizedBox(height: 16),
          const Text('Chưa có DailyRiskLog để vẽ biểu đồ. Hãy chạy cron/manual risk scoring để sinh lịch sử risk theo ngày.', style: TextStyle(color: AppColors.textSecondary)),
        ],
      );
    }

    final points = analytics.points;
    final riskSpots = _riskSpots(points, (point) => point.riskScore);
    final phqSpots = _riskSpots(points, (point) => point.scorePhq9);
    final aiSpots = _riskSpots(points, (point) => point.scoreAi);
    final moodSpots = _riskSpots(points, (point) => point.scoreMood);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: Text('Giám sát rủi ro 14 ngày', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.alert))),
            IconButton(
              tooltip: 'Tải lại analytics',
              onPressed: _riskAnalyticsLoading ? null : _loadRiskAnalytics,
              icon: const Icon(Icons.refresh, size: 18),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildRiskMetric('Mới nhất', '${analytics.latestRiskScore ?? 0}', Icons.monitor_heart_outlined, (analytics.latestRiskScore ?? 0) >= 70 ? AppColors.alert : AppColors.primary)),
            const SizedBox(width: 12),
            Expanded(child: _buildRiskMetric('Trung bình', analytics.averageRiskScore?.toStringAsFixed(1) ?? '-', Icons.show_chart, Colors.orange)),
            const SizedBox(width: 12),
            Expanded(child: _buildRiskMetric('Cờ đỏ', '${analytics.redFlagDays} ngày', Icons.flag_outlined, AppColors.alert)),
            const SizedBox(width: 12),
            Expanded(child: _buildRiskMetric('Xu hướng', _riskTrendText(analytics.trend), Icons.trending_up, _riskTrendColor(analytics.trend))),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _buildRiskLegend('Risk', AppColors.alert),
            _buildRiskLegend('PHQ-9', AppColors.primary),
            _buildRiskLegend('AI', Colors.purple),
            _buildRiskLegend('Mood', Colors.teal),
          ],
        ),
        const SizedBox(height: 8),
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
                    interval: points.length <= 7 ? 1 : 2,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= points.length) return const Text('');
                      final date = points[index].riskDate;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(date == null ? '' : DateFormat('dd/MM').format(date), style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: (points.length - 1).toDouble(),
              minY: 0,
              maxY: 100,
              lineBarsData: [
                _riskLine(riskSpots, AppColors.alert, width: 4, area: true),
                _riskLine(phqSpots, AppColors.primary),
                _riskLine(aiSpots, Colors.purple),
                _riskLine(moodSpots, Colors.teal),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRiskMetric(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
                Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  List<FlSpot> _riskSpots(List<TherapistRiskPointModel> points, int Function(TherapistRiskPointModel point) selector) {
    return List.generate(points.length, (index) => FlSpot(index.toDouble(), selector(points[index]).toDouble()));
  }

  LineChartBarData _riskLine(List<FlSpot> spots, Color color, {double width = 2.5, bool area = false}) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: width,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: true),
      belowBarData: BarAreaData(show: area, color: color.withValues(alpha: 0.08)),
    );
  }

  String _riskTrendText(String trend) {
    switch (trend) {
      case 'UP':
        return 'Tăng';
      case 'DOWN':
        return 'Giảm';
      case 'STABLE':
        return 'Ổn định';
      default:
        return 'Chưa đủ';
    }
  }

  Color _riskTrendColor(String trend) {
    switch (trend) {
      case 'UP':
        return AppColors.alert;
      case 'DOWN':
        return AppColors.success;
      case 'STABLE':
        return Colors.orange;
      default:
        return AppColors.textSecondary;
    }
  }

}
