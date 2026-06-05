import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/mindhealth_scaffold.dart';
import '../../../../theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/behavioral_experiment_model.dart';
import '../../data/models/fear_ladder_item_model.dart';
import '../providers/roadmap_provider.dart';

class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({super.key});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  bool _loaded = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<RoadmapProvider>();
    final patientId = auth.loginResponse?.user.id ?? '';
    final token = auth.loginResponse?.token;

    if (!_loaded && patientId.isNotEmpty) {
      _loaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<RoadmapProvider>().loadJourney(patientId, token: token);
      });
    }

    return MindHealthScaffold(
      title: 'Lộ trình tiếp xúc',
      body: provider.status == RoadmapStatus.loading && provider.fearLadder.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : provider.status == RoadmapStatus.error && provider.fearLadder.isEmpty
              ? Center(child: Text(provider.errorMessage))
              : ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    if (provider.safetyOverlay.active) ...[
                      _SafetyBanner(message: provider.safetyOverlay.message),
                      const SizedBox(height: 16),
                    ],
                    _ScreenHero(
                      totalItems: provider.fearLadder.length,
                      unlockedItems: provider.fearLadder.where((item) => item.unlocked).length,
                    ),
                    const SizedBox(height: 18),
                    _ExperimentCard(
                      experiment: provider.todayExperiment,
                      onStart: provider.todayExperiment == null
                          ? null
                          : () => _showStartDialog(context, provider.todayExperiment!, token),
                      onDebrief: provider.todayExperiment == null
                          ? null
                          : () => _showDebriefDialog(context, provider.todayExperiment!, token),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Thang sợ của bạn',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Đi từ bước dễ hơn tới bước khó hơn. Mỗi lần hoàn thành tốt, hệ thống sẽ mở dần nấc tiếp theo.',
                      style: TextStyle(color: AppColors.textSecondary, height: 1.45),
                    ),
                    const SizedBox(height: 14),
                    if (provider.fearLadder.isEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 28),
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.primary.withOpacity(0.08)),
                        ),
                        child: const Text(
                          'Chưa có thang sợ. Hãy hoàn tất LSAS baseline và chọn mục tiêu trị liệu để hệ thống tạo lộ trình phù hợp.',
                          style: TextStyle(color: AppColors.textSecondary, height: 1.45),
                        ),
                      )
                    else
                      ...provider.fearLadder.asMap().entries.map(
                            (entry) => _FearLadderCard(
                              item: entry.value,
                              showConnector: entry.key != provider.fearLadder.length - 1,
                            ),
                          ),
                  ],
                ),
    );
  }

  Future<void> _showStartDialog(BuildContext context, BehavioralExperimentModel experiment, String? token) async {
    final predictionController = TextEditingController(text: experiment.prediction ?? '');
    final safetyController = TextEditingController(text: experiment.safetyBehaviorsJson ?? '');
    double belief = (experiment.predictionBelief ?? 50).toDouble();

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Bắt đầu bài thực hành'),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: predictionController,
                  decoration: const InputDecoration(labelText: 'Dự đoán điều bạn lo sẽ xảy ra'),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: safetyController,
                  decoration: const InputDecoration(labelText: 'Hành vi an toàn bạn muốn giảm'),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                Text('Mức tin vào dự đoán: ${belief.round()}%'),
                Slider(
                  value: belief,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  activeColor: AppColors.primary,
                  onChanged: (value) => setState(() => belief = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Hủy')),
            FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Lưu và bắt đầu')),
          ],
        ),
      ),
    );

    if (ok != true) return;
    final provider = context.read<RoadmapProvider>();
    final success = await provider.startTodayExperiment(
      experimentId: experiment.id,
      prediction: predictionController.text.trim(),
      predictionBelief: belief.round(),
      safetyBehaviorsJson: safetyController.text.trim(),
      token: token,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Đã bắt đầu bài thực hành.' : provider.errorMessage)),
    );
  }

  Future<void> _showDebriefDialog(BuildContext context, BehavioralExperimentModel experiment, String? token) async {
    final executionController = TextEditingController(text: experiment.executionNotes ?? '');
    final debriefController = TextEditingController(text: experiment.debrief ?? '');
    double fear = (experiment.postFearScore ?? experiment.ladderItem.currentFearScore).toDouble();
    double avoidance = (experiment.postAvoidanceScore ?? experiment.ladderItem.currentAvoidanceScore).toDouble();

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Tổng kết bài thực hành'),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: executionController,
                  decoration: const InputDecoration(labelText: 'Bạn đã làm như thế nào?'),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: debriefController,
                  decoration: const InputDecoration(labelText: 'Điều thực sự xảy ra / bài học rút ra'),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                Text('Mức sợ sau bài: ${fear.round()}'),
                Slider(
                  value: fear,
                  min: 0,
                  max: 3,
                  divisions: 3,
                  activeColor: AppColors.primary,
                  onChanged: (value) => setState(() => fear = value),
                ),
                Text('Mức né tránh sau bài: ${avoidance.round()}'),
                Slider(
                  value: avoidance,
                  min: 0,
                  max: 3,
                  divisions: 3,
                  activeColor: AppColors.primary,
                  onChanged: (value) => setState(() => avoidance = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Hủy')),
            FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Lưu tổng kết')),
          ],
        ),
      ),
    );

    if (ok != true) return;
    final provider = context.read<RoadmapProvider>();
    final success = await provider.debriefTodayExperiment(
      experimentId: experiment.id,
      executionNotes: executionController.text.trim(),
      debrief: debriefController.text.trim(),
      postFearScore: fear.round(),
      postAvoidanceScore: avoidance.round(),
      token: token,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Đã lưu tổng kết và cập nhật thang sợ.' : provider.errorMessage)),
    );
  }
}

class _ScreenHero extends StatelessWidget {
  const _ScreenHero({
    required this.totalItems,
    required this.unlockedItems,
  });

  final int totalItems;
  final int unlockedItems;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF159489)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thang tiếp xúc cá nhân',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Đã mở $unlockedItems/$totalItems nấc. Hãy đi từng bước nhỏ, đều và thực tế.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.alt_route_rounded, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }
}

class _SafetyBanner extends StatelessWidget {
  const _SafetyBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.warning.withOpacity(0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.health_and_safety_outlined, color: AppColors.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.textPrimary, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExperimentCard extends StatelessWidget {
  const _ExperimentCard({
    required this.experiment,
    required this.onStart,
    required this.onDebrief,
  });

  final BehavioralExperimentModel? experiment;
  final VoidCallback? onStart;
  final VoidCallback? onDebrief;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.primary.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: experiment == null
          ? const Text(
              'Hôm nay chưa có bài thực hành hành vi. Khi có một nấc đang mở phù hợp, hệ thống sẽ gợi ý tại đây.',
              style: TextStyle(color: AppColors.textSecondary, height: 1.45),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bài thực hành hôm nay',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  experiment!.ladderItem.situationText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _pill(_mapExperimentStatus(experiment!.status)),
                    _pill(_mapBucket(experiment!.ladderItem.bucket)),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    FilledButton(onPressed: onStart, child: const Text('Bắt đầu')),
                    const SizedBox(width: 10),
                    OutlinedButton(onPressed: onDebrief, child: const Text('Tổng kết')),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _pill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FearLadderCard extends StatelessWidget {
  const _FearLadderCard({
    required this.item,
    required this.showConnector,
  });

  final FearLadderItemModel item;
  final bool showConnector;

  @override
  Widget build(BuildContext context) {
    final locked = !item.unlocked;
    final mastered = item.status == 'MASTERED';
    final accent = mastered
        ? AppColors.success
        : locked
            ? AppColors.textSecondary
            : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 62,
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: accent.withOpacity(0.18)),
                  ),
                  child: Center(
                    child: Text(
                      '${item.ladderOrder}',
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                if (showConnector)
                  Container(
                    width: 3,
                    height: 52,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: locked ? Colors.white.withOpacity(0.85) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: accent.withOpacity(0.12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Opacity(
                opacity: locked ? 0.68 : 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.situationText,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              height: 1.35,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _statusBadge(item),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _metaChip('Mức sợ ${item.currentFearScore}/3'),
                        _metaChip('Né tránh ${item.currentAvoidanceScore}/3'),
                        _metaChip(_mapBucket(item.bucket)),
                        if (item.goalMatch) _metaChip('Khớp mục tiêu'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(FearLadderItemModel item) {
    final locked = !item.unlocked;
    final mastered = item.status == 'MASTERED';
    final label = locked
        ? 'Đang khóa'
        : mastered
            ? 'Đã làm chủ'
            : 'Đang mở';
    final color = locked
        ? AppColors.textSecondary
        : mastered
            ? AppColors.success
            : AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _metaChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 12.5,
        ),
      ),
    );
  }
}

String _mapBucket(String bucket) {
  switch (bucket.toUpperCase()) {
    case 'EASY':
      return 'Mức dễ';
    case 'MEDIUM':
      return 'Mức vừa';
    case 'HARD':
      return 'Mức khó';
    default:
      return bucket;
  }
}

String _mapExperimentStatus(String status) {
  switch (status.toUpperCase()) {
    case 'PLANNED':
      return 'Đã lên kế hoạch';
    case 'STARTED':
      return 'Đang thực hành';
    case 'COMPLETED':
      return 'Đã hoàn tất';
    default:
      return status;
  }
}
