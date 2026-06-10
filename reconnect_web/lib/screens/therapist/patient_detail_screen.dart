import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/auth/auth_provider.dart';
import '../../features/cbt_intervention/assign_quest_screen.dart';
import '../../features/therapist/data/models/therapist_quest_progress_model.dart';
import '../../features/therapist/data/models/therapist_pre_session_review_model.dart';
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
  final TherapistPatientRepository _repository = TherapistPatientRepository();

  TherapistQuestProgressModel? _questProgress;
  TherapistRiskAnalyticsModel? _riskAnalytics;
  TherapistPreSessionReviewModel? _preSessionReview;
  bool _questProgressLoading = false;
  bool _riskAnalyticsLoading = false;
  bool _preSessionLoading = false;
  String? _questProgressError;
  String? _riskAnalyticsError;
  String? _preSessionError;

  String get _patientId => widget.patient['id']?.toString() ?? '';
  String get _patientName => widget.patient['name']?.toString() ?? 'Bệnh nhân';
  int get _currentRiskScore => (widget.patient['riskScore'] as num?)?.toInt() ?? 0;
  bool get _hasRedFlag => widget.patient['hasRedFlag'] == true || _currentRiskScore >= 70;
  bool get _isAnonymous => widget.patient['isAnonymous'] == true;
  String get _realFullName => widget.patient['realFullName']?.toString() ?? 'Chưa cập nhật';
  String get _phoneNumber => widget.patient['phoneNumber']?.toString() ?? 'Chưa cập nhật';
  String get _emergencyContactPhone => widget.patient['emergencyContactPhone']?.toString() ?? 'Chưa cập nhật';
  String get _dateOfBirth => widget.patient['dateOfBirth']?.toString() ?? 'Chưa cập nhật';
  String get _gender => widget.patient['gender']?.toString() ?? 'Chưa cập nhật';
  String get _educationLevel => widget.patient['educationLevel']?.toString() ?? 'Chưa cập nhật';
  String get _occupation => widget.patient['occupation']?.toString() ?? 'Chưa cập nhật';
  String get _relationshipStatus => widget.patient['relationshipStatus']?.toString() ?? 'Chưa cập nhật';
  String get _medicalHistory => widget.patient['medicalHistory']?.toString() ?? 'Chưa cập nhật';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRiskAnalytics();
      _loadQuestProgress();
      _loadPreSessionReview();
    });
  }

  Future<void> _loadRiskAnalytics() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null || token.isEmpty || _patientId.isEmpty) return;
    setState(() {
      _riskAnalyticsLoading = true;
      _riskAnalyticsError = null;
    });
    try {
      final analytics = await _repository.getRiskAnalytics(
        token: token,
        patientId: _patientId,
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

  Future<void> _loadQuestProgress() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null || token.isEmpty || _patientId.isEmpty) return;
    setState(() {
      _questProgressLoading = true;
      _questProgressError = null;
    });
    try {
      final progress = await _repository.getQuestProgress(
        token: token,
        patientId: _patientId,
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

  Future<void> _loadPreSessionReview() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null || token.isEmpty || _patientId.isEmpty) return;
    setState(() {
      _preSessionLoading = true;
      _preSessionError = null;
    });
    try {
      final review = await _repository.getPreSessionReview(
        token: token,
        patientId: _patientId,
      );
      if (!mounted) return;
      setState(() => _preSessionReview = review);
    } catch (e) {
      if (!mounted) return;
      setState(() => _preSessionError = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() => _preSessionLoading = false);
    }
  }

  Future<void> _assignQuest() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AssignQuestScreen(
          patientId: _patientId,
          patientName: _patientName,
        ),
      ),
    );
    if (!mounted) return;
    _loadQuestProgress();
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      _loadRiskAnalytics(),
      _loadQuestProgress(),
      _loadPreSessionReview(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _hasRedFlag ? AppColors.alert : AppColors.success;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Hồ sơ: $_patientName${_isAnonymous ? ' (Ẩn danh)' : ''}'),
        actions: [
          IconButton(
            tooltip: 'Tải lại dữ liệu',
            onPressed: _refreshAll,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPatientHeader(statusColor),
                  const SizedBox(height: 24),
                  _buildIdentityPanel(),
                  const SizedBox(height: 24),
                  _buildPreSessionReviewPanel(),
                  const SizedBox(height: 24),
                  _buildRiskAnalyticsPanel(),
                  const SizedBox(height: 24),
                  _buildActionPanel(),
                ],
              ),
            ),
          ),
          Container(width: 1, color: Colors.grey.shade200),
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

  Widget _buildPatientHeader(Color statusColor) {
    return _Card(
      child: Row(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: statusColor.withValues(alpha: 0.15),
            child: Icon(_isAnonymous ? Icons.shield_outlined : Icons.person, color: statusColor, size: 40),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_patientName, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _Badge(label: _hasRedFlag ? 'Cảnh báo' : 'Ổn định', color: statusColor),
                    _Badge(label: 'Risk $_currentRiskScore/100', color: _currentRiskScore >= 70 ? AppColors.alert : AppColors.primary),
                    if (_isAnonymous)
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.privacy_tip_outlined, color: AppColors.textSecondary, size: 16),
                          SizedBox(width: 4),
                          Text('Bệnh nhân đang ẩn danh', style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildIdentityPanel() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hồ sơ y tế & danh tính kép',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            _isAnonymous
                ? 'Bệnh nhân đang bật chế độ ẩn danh. Khi trao đổi, nên ưu tiên gọi bằng biệt danh nếu người bệnh chưa sẵn sàng lộ diện.'
                : 'Bệnh nhân đang cho phép hiển thị tên thật rõ hơn trong quá trình trị liệu.',
            style: const TextStyle(color: AppColors.textSecondary, height: 1.45),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _Badge(label: 'Biệt danh: $_patientName', color: AppColors.primary),
              _Badge(label: 'Họ tên thật: $_realFullName', color: AppColors.secondary),
              _Badge(label: 'SĐT: $_phoneNumber', color: AppColors.primary),
              _Badge(label: 'Liên hệ khẩn cấp: $_emergencyContactPhone', color: AppColors.alert),
              _Badge(label: 'Ngày sinh: $_dateOfBirth', color: AppColors.secondary),
              _Badge(label: 'Giới tính: $_gender', color: AppColors.primary),
              _Badge(label: 'Học vấn: $_educationLevel', color: AppColors.secondary),
              _Badge(label: 'Nghề nghiệp: $_occupation', color: AppColors.primary),
              _Badge(label: 'Quan hệ: $_relationshipStatus', color: AppColors.secondary),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tiền sử bệnh lý / thuốc đang dùng', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(_medicalHistory, style: const TextStyle(color: AppColors.textSecondary, height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildRiskAnalyticsPanel() {
    final analytics = _riskAnalytics;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Risk analytics 14 ngày',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
              IconButton(
                tooltip: 'Tải lại risk analytics',
                onPressed: _riskAnalyticsLoading ? null : _loadRiskAnalytics,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Dữ liệu lấy từ DailyRiskLog, dùng để theo dõi xu hướng nguy cơ và Red Flag.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          if (_riskAnalyticsLoading && analytics == null)
            const SizedBox(height: 260, child: Center(child: CircularProgressIndicator()))
          else if (_riskAnalyticsError != null)
            _ErrorBox(message: _riskAnalyticsError!)
          else if (analytics == null || analytics.points.isEmpty)
            _EmptyBox(
              icon: Icons.monitor_heart_outlined,
              title: 'Chưa có dữ liệu risk theo ngày',
              message: 'Hãy chạy risk scoring hoặc dùng Demo Controls bật risk cao để sinh dữ liệu kiểm thử.',
              value: 'Risk hiện tại: $_currentRiskScore/100',
            )
          else ...[
            _buildRiskMetricRow(analytics),
            const SizedBox(height: 16),
            SizedBox(height: 280, child: _buildRiskChart(analytics)),
          ],
        ],
      ),
    );
  }

  Widget _buildPreSessionReviewPanel() {
    final review = _preSessionReview;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Pre-session review',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
              IconButton(
                tooltip: 'Tải lại review',
                onPressed: _preSessionLoading ? null : _loadPreSessionReview,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Tóm tắt nhanh trước phiên: LSAS, tuần trị liệu, bài tập gần đây, check-in và cảnh báo an toàn.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          if (_preSessionLoading && review == null)
            const SizedBox(height: 180, child: Center(child: CircularProgressIndicator()))
          else if (_preSessionError != null)
            _ErrorBox(message: _preSessionError!)
          else if (review == null)
            const _EmptyBox(
              icon: Icons.fact_check_outlined,
              title: 'Chưa có packet pre-session review',
              message: 'Khi có đủ dữ liệu LSAS, check-in, thought record và bài tập, hệ thống sẽ tổng hợp tại đây.',
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _Badge(label: 'LSAS baseline: ${review.baselineLsasScore ?? '-'}', color: AppColors.secondary),
                    _Badge(label: 'LSAS hiện tại: ${review.currentLsasScore ?? '-'}', color: AppColors.primary),
                    if (review.programWeek != null)
                      _Badge(label: 'Tuần ${review.programWeek}', color: AppColors.primary),
                    if (review.programPhaseLabel.isNotEmpty)
                      _Badge(label: review.programPhaseLabel, color: AppColors.secondary),
                    _Badge(label: 'Homework xong: ${review.recentHomeworkCompleted}', color: AppColors.success),
                    _Badge(label: 'Check-in tuần qua: ${review.dailyCheckinsLastWeek}', color: AppColors.primary),
                  ],
                ),
                const SizedBox(height: 16),
                if (review.goalSummary.isNotEmpty)
                  Text(
                    'Mục tiêu hiện tại: ${review.goalSummary}',
                    style: const TextStyle(color: AppColors.textPrimary, height: 1.45),
                  ),
                const SizedBox(height: 14),
                _buildSummaryList('Behavioral experiments gần đây', review.recentBehavioralExperimentSummaries),
                const SizedBox(height: 10),
                _buildSummaryList('Thought records gần đây', review.recentThoughtRecordSummaries),
                const SizedBox(height: 10),
                _buildSummaryList('Daily check-in gần đây', review.recentDailyCheckinSummaries),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryList(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (items.isEmpty)
          const Text('Chưa có dữ liệu gần đây.', style: TextStyle(color: AppColors.textSecondary))
        else
          ...items.take(3).map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(item, style: const TextStyle(color: AppColors.textSecondary, height: 1.4)),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildRiskMetricRow(TherapistRiskAnalyticsModel analytics) {
    return Row(
      children: [
        Expanded(
          child: _MetricTile(
            label: 'Mới nhất',
            value: '${analytics.latestRiskScore ?? 0}',
            icon: Icons.monitor_heart_outlined,
            color: (analytics.latestRiskScore ?? 0) >= 70 ? AppColors.alert : AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricTile(
            label: 'Trung bình',
            value: analytics.averageRiskScore?.toStringAsFixed(1) ?? '-',
            icon: Icons.show_chart,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricTile(
            label: 'Red Flag',
            value: '${analytics.redFlagDays} ngày',
            icon: Icons.flag_outlined,
            color: AppColors.alert,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricTile(
            label: 'Xu hướng',
            value: _riskTrendText(analytics.trend),
            icon: Icons.trending_up,
            color: _riskTrendColor(analytics.trend),
          ),
        ),
      ],
    );
  }

  Widget _buildRiskChart(TherapistRiskAnalyticsModel analytics) {
    final points = analytics.points;
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (points.length - 1).toDouble(),
        minY: 0,
        maxY: 100,
        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 20),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              interval: 20,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: points.length <= 7 ? 1 : 2,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= points.length) return const Text('');
                final date = points[index].riskDate;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    date == null ? '' : DateFormat('dd/MM').format(date),
                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          _riskLine(_riskSpots(points, (point) => point.riskScore), AppColors.alert, width: 4),
          _riskLine(_riskSpots(points, (point) => point.scoreSafety), AppColors.primary),
          _riskLine(_riskSpots(points, (point) => point.scoreAi), Colors.purple),
          _riskLine(_riskSpots(points, (point) => point.scoreMood), Colors.teal),
        ],
      ),
    );
  }

  LineChartBarData _riskLine(List<FlSpot> spots, Color color, {double width = 2}) {
    return LineChartBarData(
      spots: spots,
      isCurved: false,
      color: color,
      barWidth: width,
      dotData: const FlDotData(show: true),
      belowBarData: BarAreaData(show: false),
    );
  }

  List<FlSpot> _riskSpots(List<TherapistRiskPointModel> points, int Function(TherapistRiskPointModel point) valueOf) {
    return List.generate(points.length, (index) => FlSpot(index.toDouble(), valueOf(points[index]).toDouble()));
  }

  Widget _buildActionPanel() {
    return _Card(
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Can thiệp CBT', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(
                  'Giao thêm bài cá nhân hóa từ Kho CBT. Ghi chú lâm sàng và chat bảo mật ở phase sau khi có API thật.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _patientId.isEmpty ? null : _assignQuest,
            icon: const Icon(Icons.assignment_add),
            label: const Text('Gán bài CBT'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
          ),
        ],
      ),
    );
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
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
            IconButton(
              tooltip: 'Tải lại tiến độ CBT',
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
          Expanded(child: _ErrorBox(message: _questProgressError!))
        else if (progress == null)
          const Expanded(
            child: _EmptyBox(
              icon: Icons.assignment_outlined,
              title: 'Chưa có dữ liệu CBT',
              message: 'Hãy tải lại hoặc kiểm tra quyền truy cập bệnh nhân.',
            ),
          )
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
                  const _EmptyBox(
                    icon: Icons.assignment_outlined,
                    title: 'Chưa có bài CBT nào',
                    message: 'Có thể bấm Gán bài CBT hoặc tạo bài hệ thống hôm nay từ Admin Demo Controls.',
                  )
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
            Expanded(child: _MetricTile(label: 'Tổng bài', value: '${progress.totalAssigned}', icon: Icons.assignment_outlined, color: AppColors.primary)),
            const SizedBox(width: 12),
            Expanded(child: _MetricTile(label: 'Hoàn thành', value: '${progress.completed}', icon: Icons.check_circle_outline, color: AppColors.success)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _MetricTile(label: 'Tỷ lệ', value: '${progress.completionRate.toStringAsFixed(0)}%', icon: Icons.trending_up, color: Colors.orange)),
            const SizedBox(width: 12),
            Expanded(child: _MetricTile(label: 'Bác sĩ giao', value: '${progress.therapistAssigned}', icon: Icons.medical_services_outlined, color: Colors.purple)),
          ],
        ),
        const SizedBox(height: 12),
        _MetricTile(label: 'Hệ thống giao', value: '${progress.systemAssigned}', icon: Icons.auto_awesome, color: Colors.teal),
      ],
    );
  }

  Widget _buildScoreSummary(TherapistQuestProgressModel progress) {
    return _Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Điểm tự đánh giá trung bình', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _ScoreChip(label: 'Mastery', value: progress.averageMastery)),
              const SizedBox(width: 8),
              Expanded(child: _ScoreChip(label: 'Pleasure', value: progress.averagePleasure)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestProgressCard(TherapistQuestProgressItemModel quest) {
    final done = quest.status == 'DONE';
    final sourceText = quest.sourceType == 'THERAPIST' ? 'Bác sĩ' : 'Hệ thống';
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
              _Badge(label: _questStatusText(quest.status), color: done ? AppColors.success : Colors.orange),
              _Badge(label: sourceText, color: quest.sourceType == 'THERAPIST' ? Colors.purple : Colors.teal),
              if (quest.category.isNotEmpty) _Badge(label: quest.category, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 10),
          Text('Giao: ${_formatDateTime(quest.assignedAt)}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          if (quest.completedAt != null)
            Text('Hoàn thành: ${_formatDateTime(quest.completedAt)}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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

  String _questStatusText(String status) {
    switch (status) {
      case 'DONE':
        return 'Đã hoàn thành';
      case 'AVAILABLE':
        return 'Đang mở';
      case 'LOCKED':
        return 'Đang khóa';
      default:
        return status.isEmpty ? 'Chưa rõ' : status;
    }
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
        return 'Chưa đủ dữ liệu';
    }
  }

  Color _riskTrendColor(String trend) {
    switch (trend) {
      case 'UP':
        return AppColors.alert;
      case 'DOWN':
        return AppColors.success;
      case 'STABLE':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return '-';
    return DateFormat('dd/MM/yyyy HH:mm').format(value);
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _Card({
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
}

class _ScoreChip extends StatelessWidget {
  final String label;
  final double? value;

  const _ScoreChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final text = value == null ? 'Chưa có' : '${value!.toStringAsFixed(1)}/10';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text('$label: $text', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? value;

  const _EmptyBox({
    required this.icon,
    required this.title,
    required this.message,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: AppColors.textSecondary)),
          if (value != null) ...[
            const SizedBox(height: 12),
            Text(value!, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          ],
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;

  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.alert.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.alert.withValues(alpha: 0.2)),
      ),
      child: Text(message, style: const TextStyle(color: AppColors.alert)),
    );
  }
}
