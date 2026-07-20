import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/mindhealth_scaffold.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/lsas_progress_model.dart';
import '../../data/repositories/assessment_repository.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final AssessmentRepository _repository = AssessmentRepository();
  Future<LsasProgressResponseModel>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final patientId = auth.loginResponse?.user.id ?? '';
    _future ??= _repository.getLsasProgress(
      patientId: patientId,
      token: auth.loginResponse?.token,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MindHealthScaffold(
      title: 'Tiến trình Phục hồi LSAS',
      body: FutureBuilder<LsasProgressResponseModel>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Không tải được dữ liệu tiến trình phục hồi LSAS.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final progress = snapshot.data;
          if (progress == null || progress.chartData.isEmpty) {
            return const Center(
              child: Text('Chưa có dữ liệu tiến trình phục hồi LSAS để hiển thị.'),
            );
          }

          final dataPoints = _toChartSpots(progress.chartData);
          final maxX = progress.chartData.length <= 1 ? 1.0 : (progress.chartData.length - 1).toDouble();

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'Tiến trình Phục hồi LSAS',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Biểu đồ thể hiện sự thay đổi mức độ lo âu xã hội qua các lần đánh giá LSAS.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SizedBox(
                  height: 280,
                  child: LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: maxX,
                      minY: 0,
                      maxY: 144,
                      gridData: FlGridData(
                        show: true,
                        horizontalInterval: 30,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.shade200,
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 34,
                            interval: 30,
                            getTitlesWidget: (value, meta) {
                              const allowed = {0, 30, 60, 90, 120};
                              if (!allowed.contains(value.toInt())) {
                                return const SizedBox.shrink();
                              }
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 11),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= progress.chartData.length || value != index.toDouble()) {
                                return const SizedBox.shrink();
                              }
                              return Text(
                                progress.chartData[index].weekLabel,
                                style: const TextStyle(fontSize: 11),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      lineBarsData: [
                        _buildLineChart(dataPoints),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildScoreChip('Điểm ban đầu', progress.startScore),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildScoreChip('Điểm hiện tại', progress.currentScore),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF8EC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFB9E2C0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.celebration_outlined, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        progress.insightMessage,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: Color(0xFF1B5E20),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<FlSpot> _toChartSpots(List<LsasProgressPointModel> chartData) {
    return List.generate(
      chartData.length,
      (index) => FlSpot(index.toDouble(), chartData[index].totalScore.toDouble()),
    );
  }

  LineChartBarData _buildLineChart(List<FlSpot> spots) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: const Color(0xFF6C63FF),
      barWidth: 4,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: true),
      belowBarData: BarAreaData(
        show: true,
        color: const Color(0xFF6C63FF).withOpacity(0.12),
      ),
    );
  }

  Widget _buildScoreChip(String label, int score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 4),
          Text(
            '$score điểm',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
