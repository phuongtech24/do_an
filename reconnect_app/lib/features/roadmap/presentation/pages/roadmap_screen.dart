import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/mindhealth_scaffold.dart';
import '../../../../theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/behavioral_experiment_model.dart';
import '../../data/models/fear_ladder_item_model.dart';
import '../../data/models/roadmap_program_module_model.dart';
import '../providers/roadmap_provider.dart';

class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({super.key});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  bool _loaded = false;

  String _decodeSafetyBehaviorsToText(String? rawValue) {
    if (rawValue == null || rawValue.trim().isEmpty) {
      return '';
    }

    final trimmed = rawValue.trim();
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is List) {
        return decoded
            .map((item) => item?.toString().trim() ?? '')
            .where((item) => item.isNotEmpty)
            .join('\n');
      }
      if (decoded is String) {
        return decoded;
      }
    } catch (_) {
      return trimmed;
    }
    return trimmed;
  }

  List<String> _parseSafetyBehaviorsInput(String rawValue) {
    return rawValue
        .split(RegExp(r'[\r\n,]+'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

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
                    if (provider.programState.programWeek != null) ...[
                      const SizedBox(height: 18),
                      _ProgramStateCard(provider: provider),
                    ],
                    const SizedBox(height: 18),
                    _ExperimentCard(
                      experiment: provider.todayExperiment,
                      onSetup: provider.todayExperiment == null
                          ? null
                          : () => _showSetupDialog(context, provider.todayExperiment!, token),
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
                      'Đi từ bước dễ hơn tới bước khó hơn. Mỗi lần làm chủ một nấc, hệ thống sẽ mở dần nấc tiếp theo.',
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
                          'Chưa có thang sợ. Hãy hoàn tất LSAS và chọn mục tiêu trị liệu để hệ thống tạo lộ trình phù hợp.',
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

  Future<void> _showSetupDialog(
    BuildContext context,
    BehavioralExperimentModel experiment,
    String? token,
  ) async {
    final predictionController = TextEditingController(text: experiment.prediction ?? '');
    final safetyController = TextEditingController(
      text: _decodeSafetyBehaviorsToText(experiment.safetyBehaviorsJson),
    );
    var dropWithoutSafetyBehaviors = false;
    double belief = (experiment.predictionBeliefBefore ?? experiment.predictionBelief ?? 50)
        .toDouble();

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Thiết lập bài thực hành'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 460,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '1. Lời tiên tri tiêu cực',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: predictionController,
                    decoration: const InputDecoration(
                      labelText: 'Điều tồi tệ nhất bạn lo sẽ xảy ra',
                      hintText: 'Ví dụ: Mọi người sẽ nhìn chằm chằm và nghĩ mình kỳ quặc.',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '2. Mức bạn tin vào dự đoán này: ${belief.round()}%',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Slider(
                    value: belief,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    activeColor: AppColors.primary,
                    onChanged: (value) => setState(() => belief = value),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '3. Hành vi an toàn bạn sẽ bỏ',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: safetyController,
                    decoration: const InputDecoration(
                      labelText: 'Mỗi dòng là một hành vi',
                      helperText:
                          'Ví dụ: nói lí nhí, cúi mặt, quay đi chỗ khác, che miệng khi nói.',
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: dropWithoutSafetyBehaviors,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Lần này tôi sẽ làm bài mà không dùng hành vi an toàn'),
                    onChanged: (value) {
                      setState(() => dropWithoutSafetyBehaviors = value ?? false);
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Lưu thiết lập'),
            ),
          ],
        ),
      ),
    );

    if (ok != true) return;
    final provider = context.read<RoadmapProvider>();
    final safetyBehaviors = _parseSafetyBehaviorsInput(safetyController.text);
    final success = await provider.startTodayExperiment(
      experimentId: experiment.id,
      prediction: predictionController.text.trim(),
      predictionBeliefBefore: belief.round(),
      safetyBehaviors: safetyBehaviors,
      dropWithoutSafetyBehaviors: dropWithoutSafetyBehaviors,
      token: token,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Đã lưu thiết lập. Hãy bắt đầu bài thực hành và hướng sự chú ý ra bên ngoài.'
              : provider.errorMessage,
        ),
      ),
    );
  }

  Future<void> _showDebriefDialog(
    BuildContext context,
    BehavioralExperimentModel experiment,
    String? token,
  ) async {
    final executionController = TextEditingController(text: experiment.executionNotes ?? '');
    final outcomeController = TextEditingController(text: experiment.outcome ?? '');
    final learningController = TextEditingController(
      text: experiment.learning ?? experiment.debrief ?? '',
    );
    double beliefAfter = (experiment.predictionBeliefAfter ??
            experiment.predictionBeliefBefore ??
            experiment.predictionBelief ??
            30)
        .toDouble();
    double fear = (experiment.postFearScore ?? experiment.ladderItem.currentFearScore).toDouble();
    double avoidance =
        (experiment.postAvoidanceScore ?? experiment.ladderItem.currentAvoidanceScore).toDouble();

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Tổng kết bài thực hành'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 460,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '1. Điều gì thực sự đã xảy ra?',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: outcomeController,
                    decoration: const InputDecoration(
                      labelText: 'Kết quả thực tế',
                      hintText: 'Ví dụ: Không ai chú ý, mọi người vẫn tiếp tục việc của họ.',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: executionController,
                    decoration: const InputDecoration(
                      labelText: 'Bạn đã thực hiện như thế nào?',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '2. Sau bài này, bạn còn tin vào dự đoán cũ bao nhiêu: ${beliefAfter.round()}%',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Slider(
                    value: beliefAfter,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    activeColor: AppColors.primary,
                    onChanged: (value) => setState(() => beliefAfter = value),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '3. Bạn học được điều gì?',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: learningController,
                    decoration: const InputDecoration(
                      labelText: 'Bài học rút ra',
                      hintText: 'Ví dụ: Mình lo nhiều hơn thực tế, và có thể tập trung ra bên ngoài tốt hơn.',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  Text('Mức sợ sau bài: ${fear.round()}/3'),
                  Slider(
                    value: fear,
                    min: 0,
                    max: 3,
                    divisions: 3,
                    activeColor: AppColors.primary,
                    onChanged: (value) => setState(() => fear = value),
                  ),
                  Text('Mức né tránh sau bài: ${avoidance.round()}/3'),
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
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Lưu tổng kết'),
            ),
          ],
        ),
      ),
    );

    if (ok != true) return;
    final provider = context.read<RoadmapProvider>();
    final success = await provider.debriefTodayExperiment(
      experimentId: experiment.id,
      executionNotes: executionController.text.trim(),
      outcome: outcomeController.text.trim(),
      learning: learningController.text.trim(),
      predictionBeliefAfter: beliefAfter.round(),
      postFearScore: fear.round(),
      postAvoidanceScore: avoidance.round(),
      token: token,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Đã lưu tổng kết và cập nhật thang sợ.' : provider.errorMessage,
        ),
      ),
    );
  }
}

class _ProgramStateCard extends StatelessWidget {
  const _ProgramStateCard({required this.provider});

  final RoadmapProvider provider;

  @override
  Widget build(BuildContext context) {
    final state = provider.programState;
    final weekRange = _formatWeekRange(state.weekStartDate, state.weekEndDate);

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weekRange == null
                          ? 'Tuần trị liệu ${state.programWeek}'
                          : 'Tuần ${state.programWeek} ($weekRange)',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      state.programPhaseLabel,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _phasePill('${state.unlockedModules.length} module đã mở'),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            state.nextRecommendedIntervention,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.45),
          ),
          if (state.nextRerateAt != null && state.nextRerateAt!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Lần đánh giá lại gần nhất dự kiến: ${_formatDate(state.nextRerateAt)}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 14),
          if (state.todayAssignments.isNotEmpty) ...[
            const Text(
              'Bài đang hiển thị hôm nay',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            ...state.todayAssignments.take(2).map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _assignmentRow(
                      title: item.title,
                      subtitle: item.sourceType == 'THERAPIST'
                          ? 'Bác sĩ giao • ${item.programPhaseCode}'
                          : 'Hệ thống gợi ý • ${item.programPhaseCode}',
                    ),
                  ),
                ),
          ],
          const SizedBox(height: 10),
          const Text(
            'Module theo phase',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ...state.unlockedModules.take(4).map((item) => _moduleChip(item)),
              ...state.lockedModules.take(3).map((item) => _moduleChip(item, locked: true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _phasePill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _assignmentRow({required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _moduleChip(RoadmapProgramModuleModel module, {bool locked = false}) {
    final color = locked ? AppColors.textSecondary : AppColors.primary;
    final subtitle = locked ? _resolveLockedModuleText(module) : _resolveUnlockedModuleText(module);

    return Container(
      constraints: const BoxConstraints(minWidth: 160, maxWidth: 230),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            module.title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  String _resolveUnlockedModuleText(RoadmapProgramModuleModel module) {
    final weekText = module.weekFrom == null
        ? 'Đã mở'
        : module.weekTo != null && module.weekTo != module.weekFrom
            ? 'Mở ở tuần ${module.weekFrom}-${module.weekTo}'
            : 'Mở từ tuần ${module.weekFrom}';
    if (module.therapistOnlyAssignable) {
      return '$weekText • Chờ bác sĩ giao';
    }
    return weekText;
  }

  String _resolveLockedModuleText(RoadmapProgramModuleModel module) {
    if (module.lockReason.isNotEmpty) {
      return module.lockReason;
    }
    if (module.unlockType == 'TIME' && module.expectedUnlockAt != null) {
      return 'Dự kiến mở từ ${_formatDate(module.expectedUnlockAt)}';
    }
    if (module.unlockType == 'PREREQUISITE') {
      return 'Cần hoàn thành bài tiên quyết';
    }
    if (module.unlockType == 'THERAPIST_ASSIGNMENT') {
      return 'Chờ bác sĩ giao';
    }
    if (module.unlockType == 'HARD_LOCK') {
      return 'Đang khóa cứng theo phase';
    }
    return 'Đang khóa';
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
    required this.onSetup,
    required this.onDebrief,
  });

  final BehavioralExperimentModel? experiment;
  final VoidCallback? onSetup;
  final VoidCallback? onDebrief;

  @override
  Widget build(BuildContext context) {
    final safetyText = experiment == null ? '' : _decodeSafety(experiment!.safetyBehaviorsJson);

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
                    _pill(_mapExperimentStage(experiment!)),
                    _pill(_mapBucket(experiment!.ladderItem.bucket)),
                  ],
                ),
                if ((experiment!.prediction ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _infoLine('Dự đoán trước bài', experiment!.prediction!.trim()),
                ],
                if (experiment!.predictionBeliefBefore != null ||
                    experiment!.predictionBeliefAfter != null) ...[
                  const SizedBox(height: 8),
                  _infoLine(
                    'Mức tin tưởng',
                    _buildBeliefSummary(experiment!),
                  ),
                ],
                if (safetyText.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _infoLine('Hành vi an toàn sẽ bỏ', safetyText),
                ],
                if ((experiment!.outcome ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _infoLine('Kết quả thực tế', experiment!.outcome!.trim()),
                ],
                if ((experiment!.learning ?? experiment!.debrief ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _infoLine(
                    'Bài học rút ra',
                    (experiment!.learning ?? experiment!.debrief!).trim(),
                  ),
                ],
                if (experiment!.status.toUpperCase() == 'IN_PROGRESS') ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Text(
                      'Hãy hướng sự chú ý ra bên ngoài. Tập trung quan sát điều gì thực sự đang diễn ra, thay vì chỉ theo dõi cảm giác lo âu bên trong cơ thể.',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    FilledButton(
                      onPressed: onSetup,
                      child: Text(_resolvePrimaryButtonLabel(experiment!)),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: _canOpenDebrief(experiment!) ? onDebrief : null,
                      child: const Text('Tổng kết'),
                    ),
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

  Widget _infoLine(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: AppColors.textSecondary,
            height: 1.45,
            fontSize: 14,
          ),
          children: [
            TextSpan(
              text: '$title: ',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(text: content),
          ],
        ),
      ),
    );
  }

  String _decodeSafety(String? rawValue) {
    if (rawValue == null || rawValue.trim().isEmpty) {
      return '';
    }
    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is List) {
        return decoded.map((item) => '• ${item.toString()}').join('\n');
      }
    } catch (_) {
      return rawValue;
    }
    return rawValue;
  }

  String _buildBeliefSummary(BehavioralExperimentModel experiment) {
    final before = experiment.predictionBeliefBefore ?? experiment.predictionBelief;
    final after = experiment.predictionBeliefAfter;
    if (before != null && after != null) {
      return 'Trước bài $before% • Sau bài $after%';
    }
    if (before != null) {
      return 'Trước bài $before%';
    }
    if (after != null) {
      return 'Sau bài $after%';
    }
    return 'Chưa có dữ liệu';
  }

  bool _canOpenDebrief(BehavioralExperimentModel experiment) {
    final status = experiment.status.toUpperCase();
    return status == 'IN_PROGRESS' || status == 'DONE';
  }

  String _resolvePrimaryButtonLabel(BehavioralExperimentModel experiment) {
    final status = experiment.status.toUpperCase();
    if (status == 'PLANNED') {
      return 'Thiết lập';
    }
    if (status == 'IN_PROGRESS') {
      return 'Xem lại thiết lập';
    }
    return 'Xem lại';
  }

  String _mapExperimentStage(BehavioralExperimentModel experiment) {
    final status = experiment.status.toUpperCase();
    if (status == 'DONE') {
      return 'Đã hoàn thành';
    }
    if (status == 'IN_PROGRESS') {
      return 'Đang thực hành';
    }
    if (experiment.setupCompletedAt != null && experiment.setupCompletedAt!.isNotEmpty) {
      return 'Đã thiết lập';
    }
    return 'Chưa thiết lập';
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
    final current = item.status == 'ACTIVE' && item.unlocked && !mastered;
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
                        _statusBadge(item, current: current),
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
                        if (current) _metaChip('Bậc hiện tại'),
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

  Widget _statusBadge(FearLadderItemModel item, {required bool current}) {
    final locked = !item.unlocked;
    final mastered = item.status == 'MASTERED';
    final label = locked
        ? 'Đang khóa'
        : mastered
            ? 'Đã làm chủ'
            : current
                ? 'Đang thực hành'
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

String? _formatWeekRange(String? start, String? end) {
  final startText = _formatDate(start);
  final endText = _formatDate(end);
  if (startText == null || endText == null) {
    return null;
  }
  return '$startText - $endText';
}

String? _formatDate(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return null;
  }
  try {
    final date = DateTime.parse(raw).toLocal();
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month';
  } catch (_) {
    return raw;
  }
}
