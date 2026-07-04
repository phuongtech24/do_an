import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  bool _showHistoryTab = false;

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

    final openItems =
        provider.fearLadder.where((item) => item.unlocked && item.status != 'MASTERED').toList();
    final completedExperiments =
        provider.experimentHistory.where((item) => item.status.toUpperCase() == 'DONE').toList();

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
                    Row(
                      children: [
                        _HeaderChip(
                          label: 'Các bài đang mở',
                          selected: !_showHistoryTab,
                          onTap: () => setState(() => _showHistoryTab = false),
                        ),
                        const SizedBox(width: 10),
                        _HeaderChip(
                          label: 'Lịch sử',
                          selected: _showHistoryTab,
                          onTap: () => setState(() => _showHistoryTab = true),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_showHistoryTab)
                      _ExperimentHistorySection(
                        experiments: completedExperiments,
                        onView: (experiment) => _showDebriefDialog(context, experiment, token),
                      )
                    else
                      _OpenExercisesSection(
                        items: openItems,
                        currentExperiment: provider.todayExperiment,
                        completedExperiments: completedExperiments,
                        onSelect: (item) => _selectExercise(context, provider, patientId, item.id, token),
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
                      'Đi từ bước dễ hơn tới bước khó hơn. Bạn có thể chọn bất kỳ bài nào đang mở để làm trước, miễn là bài đó đã được mở khóa.',
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

  Future<void> _selectExercise(
    BuildContext context,
    RoadmapProvider provider,
    String patientId,
    String ladderItemId,
    String? token,
  ) async {
    final success = await provider.selectExercise(patientId, ladderItemId, token: token);
    if (!context.mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage), backgroundColor: AppColors.alert),
      );
      return;
    }

    final experiment = provider.todayExperiment;
    if (experiment == null) return;

    final status = experiment.status.toUpperCase();
    if (status == 'DONE') {
      await _showDebriefDialog(context, experiment, token);
    } else {
      await _showSetupDialog(context, experiment, token);
    }
  }

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

  bool _isSocialGoal(FearLadderItemModel item) => item.goalContextLabel.toUpperCase() == 'SOCIAL';

  bool _isBehavioralGoal(FearLadderItemModel item) =>
      item.goalContextLabel.toUpperCase() == 'BEHAVIORAL';

  bool _isEmotionalGoal(FearLadderItemModel item) => item.goalContextLabel.toUpperCase() == 'EMOTIONAL';

  String _goalGuidanceTitle(FearLadderItemModel item) {
    if (_isSocialGoal(item)) {
      return 'Gợi ý theo mục tiêu tương tác xã hội';
    }
    if (_isBehavioralGoal(item)) {
      return 'Gợi ý theo mục tiêu thực hành hành vi';
    }
    if (_isEmotionalGoal(item)) {
      return 'Gợi ý theo mục tiêu điều hòa cảm xúc';
    }
    return 'Gợi ý trước khi bắt đầu bài thực hành';
  }

  List<String> _goalGuidanceBullets(FearLadderItemModel item) {
    if (_isSocialGoal(item)) {
      return const [
        'Tạm bỏ việc nhẩm trước kịch bản hoặc tự kiểm duyệt câu nói trong đầu.',
        'Chuyển chú ý ra bên ngoài: lắng nghe người đối diện và quan sát tình huống thật.',
        'Ưu tiên tương tác tự nhiên hơn là cố kiểm soát hoàn hảo từng câu chữ.',
      ];
    }
    if (_isBehavioralGoal(item)) {
      return const [
        'Ghi rõ dự đoán ban đầu và so sánh lại với kết quả thực tế sau khi làm xong.',
        'Cam kết bỏ bớt các hành vi an toàn mang tính né tránh hoặc che giấu.',
        'Ưu tiên một hành động cụ thể, quan sát được và có thể đối chiếu bằng chứng.',
      ];
    }
    if (_isEmotionalGoal(item)) {
      return const [
        'Nếu đang quá căng, hãy hạ nhiệt cơ thể trước bằng thở ngắn hoặc grounding.',
        'Mục tiêu là giữ đủ bình tĩnh để tiếp cận tình huống, không phải làm hoàn hảo ngay.',
        'Bạn có thể mở Thẻ đối phó trước khi bắt đầu nếu cần tự trấn an.',
      ];
    }
    return const [
      'Giữ nhịp thực hành vừa sức và tập trung vào bằng chứng thực tế.',
      'So sánh dự đoán ban đầu với điều thực sự xảy ra sau bài tập.',
    ];
  }

  Widget _buildGoalGuidanceCard(BuildContext context, FearLadderItemModel item) {
    final bullets = _goalGuidanceBullets(item);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _goalGuidanceTitle(item),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          if (item.goalPriorityReason.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              item.goalPriorityReason,
              style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
          ],
          const SizedBox(height: 8),
          ...bullets.map(
            (bullet) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Icon(Icons.circle, size: 6, color: AppColors.primary),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      bullet,
                      style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isEmotionalGoal(item)) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/coping-cards'),
                icon: const Icon(Icons.favorite_border_rounded),
                label: const Text('Mở Thẻ đối phó'),
              ),
            ),
          ],
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
    double belief = (experiment.predictionBeliefBefore ?? experiment.predictionBelief ?? 50).toDouble();

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
                  const Text('1. Lời tiên tri tiêu cực', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  _buildGoalGuidanceCard(context, experiment.ladderItem),
                  const SizedBox(height: 14),
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
                  const Text('3. Hành vi an toàn bạn sẽ bỏ', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: safetyController,
                    decoration: const InputDecoration(
                      labelText: 'Mỗi dòng là một hành vi',
                      helperText: 'Ví dụ: nói lí nhí, cúi mặt, che miệng khi nói.',
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: dropWithoutSafetyBehaviors,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Lần này tôi sẽ làm bài mà không dùng hành vi an toàn'),
                    onChanged: (value) => setState(() => dropWithoutSafetyBehaviors = value ?? false),
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
    final learningController = TextEditingController(text: experiment.learning ?? experiment.debrief ?? '');
    double beliefAfter =
        (experiment.predictionBeliefAfter ?? experiment.predictionBeliefBefore ?? experiment.predictionBelief ?? 30)
            .toDouble();
    double fear = (experiment.postFearScore ?? experiment.ladderItem.currentFearScore).toDouble();
    double avoidance = (experiment.postAvoidanceScore ?? experiment.ladderItem.currentAvoidanceScore).toDouble();

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
                  const Text('1. Điều gì thực sự đã xảy ra?', style: TextStyle(fontWeight: FontWeight.w800)),
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
                    decoration: const InputDecoration(labelText: 'Bạn đã thực hiện như thế nào?'),
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
                  const Text('3. Bạn học được điều gì?', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: learningController,
                    decoration: const InputDecoration(
                      labelText: 'Bài học rút ra',
                      hintText: 'Ví dụ: Mình lo nhiều hơn thực tế và có thể tập trung ra bên ngoài tốt hơn.',
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
                      weekRange == null ? 'Tuần trị liệu ${state.programWeek}' : 'Tuần ${state.programWeek} ($weekRange)',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      state.programPhaseLabel,
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              _InfoPill(label: '${state.unlockedModules.length} module đã mở'),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            state.nextRecommendedIntervention,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.45),
          ),
          if (state.lockedModules.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.lockedModules.take(3).map((item) => _LockedModuleChip(module: item)).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _OpenExercisesSection extends StatelessWidget {
  const _OpenExercisesSection({
    required this.items,
    required this.currentExperiment,
    required this.completedExperiments,
    required this.onSelect,
    required this.onSetup,
    required this.onDebrief,
  });

  final List<FearLadderItemModel> items;
  final BehavioralExperimentModel? currentExperiment;
  final List<BehavioralExperimentModel> completedExperiments;
  final ValueChanged<FearLadderItemModel> onSelect;
  final VoidCallback? onSetup;
  final VoidCallback? onDebrief;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _SectionCard(
        child: Text(
          'Hiện chưa có bài thực hành nào đang mở. Hãy hoàn tất bước trước đó để hệ thống mở thêm bài phù hợp.',
          style: TextStyle(color: AppColors.textSecondary, height: 1.45),
        ),
      );
    }

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Các bài đang mở hôm nay',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          const Text(
            'Bạn có thể chọn bất kỳ bài nào đã mở để làm trước hoặc làm sau. Bài đã hoàn thành sẽ được chuyển sang tab Lịch sử.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.45),
          ),
          const SizedBox(height: 16),
          ...items.map(
            (item) {
              final linkedExperiment = _matchExperimentForItem(item);
              final itemState = _resolveItemState(linkedExperiment);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _OpenExerciseTile(
                  item: item,
                  experiment: linkedExperiment,
                  stateLabel: itemState.label,
                  stateColor: itemState.color,
                  actionLabel: itemState.actionLabel,
                  onAction: () {
                    if (linkedExperiment != null && linkedExperiment.status.toUpperCase() == 'IN_PROGRESS') {
                      onDebrief?.call();
                      return;
                    }
                    if (linkedExperiment != null && linkedExperiment.status.toUpperCase() == 'PLANNED') {
                      onSetup?.call();
                      return;
                    }
                    if (linkedExperiment != null && linkedExperiment.status.toUpperCase() == 'DONE') {
                      onDebrief?.call();
                      return;
                    }
                    onSelect(item);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  BehavioralExperimentModel? _matchExperimentForItem(FearLadderItemModel item) {
    if (currentExperiment != null && currentExperiment!.ladderItem.id == item.id) {
      return currentExperiment;
    }
    for (final experiment in completedExperiments) {
      if (experiment.ladderItem.id == item.id) {
        return experiment;
      }
    }
    return null;
  }

  _ItemVisualState _resolveItemState(BehavioralExperimentModel? experiment) {
    if (experiment != null) {
      final status = experiment.status.toUpperCase();
      if (status == 'IN_PROGRESS') {
        return const _ItemVisualState('Đang thực hành', AppColors.primary, 'Tổng kết');
      }
      if (status == 'DONE') {
        return const _ItemVisualState('Đã hoàn thành', AppColors.success, 'Xem lại');
      }
      if (status == 'PLANNED') {
        return const _ItemVisualState('Chưa thiết lập', AppColors.warning, 'Thiết lập');
      }
    }
    return const _ItemVisualState('Đang mở', AppColors.primary, 'Chọn bài này');
  }
}

class _ExperimentHistorySection extends StatelessWidget {
  const _ExperimentHistorySection({
    required this.experiments,
    required this.onView,
  });

  final List<BehavioralExperimentModel> experiments;
  final ValueChanged<BehavioralExperimentModel> onView;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: experiments.isEmpty
          ? const Text(
              'Chưa có bài thực hành nào hoàn thành. Sau khi tổng kết xong, bạn sẽ xem lại được tại đây.',
              style: TextStyle(color: AppColors.textSecondary, height: 1.45),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lịch sử bài thực hành',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 14),
                ...experiments.take(8).map(
                  (experiment) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () => onView(experiment),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.check_circle_outline_rounded, color: AppColors.success),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    experiment.ladderItem.situationText,
                                    style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _historySubtitle(experiment),
                                    style: const TextStyle(color: AppColors.textSecondary, height: 1.35),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  String _historySubtitle(BehavioralExperimentModel experiment) {
    final completedAt = _formatDate(experiment.completedAt);
    final before = experiment.predictionBeliefBefore ?? experiment.predictionBelief;
    final after = experiment.predictionBeliefAfter;
    final beliefPart = before != null && after != null ? 'Tin tưởng: $before% → $after%' : 'Đã hoàn thành';
    if (completedAt != null) {
      return '$beliefPart • $completedAt';
    }
    return beliefPart;
  }
}

class _OpenExerciseTile extends StatelessWidget {
  const _OpenExerciseTile({
    required this.item,
    required this.experiment,
    required this.stateLabel,
    required this.stateColor,
    required this.actionLabel,
    required this.onAction,
  });

  final FearLadderItemModel item;
  final BehavioralExperimentModel? experiment;
  final String stateLabel;
  final Color stateColor;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: stateColor.withOpacity(0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.situationText,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: 12),
              _InfoPill(label: stateLabel, color: stateColor),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SoftPill(label: _mapBucket(item.bucket)),
              _SoftPill(label: 'Mức sợ ${item.currentFearScore}/3'),
              _SoftPill(label: 'Né tránh ${item.currentAvoidanceScore}/3'),
              if (item.goalMatch) _SoftPill(label: 'Khớp mục tiêu'),
            ],
          ),
          if (item.goalPriorityReason.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              item.goalPriorityReason,
              style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
          ],
          if ((experiment?.learning ?? experiment?.debrief ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Bài học gần nhất: ${(experiment?.learning ?? experiment?.debrief ?? '').trim()}',
              style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
          ],
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              onPressed: onAction,
              child: Text(actionLabel),
            ),
          ),
        ],
      ),
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
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  'Đã mở $unlockedItems/$totalItems nấc. Bạn có thể tự chọn bài phù hợp trong các nấc đang mở.',
                  style: TextStyle(color: Colors.white.withOpacity(0.9), height: 1.45),
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
                      style: TextStyle(color: accent, fontWeight: FontWeight.w800, fontSize: 18),
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
                        _InfoPill(label: _statusLabel(item, current), color: accent),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _SoftPill(label: 'Mức sợ ${item.currentFearScore}/3'),
                        _SoftPill(label: 'Né tránh ${item.currentAvoidanceScore}/3'),
                        _SoftPill(label: _mapBucket(item.bucket)),
                        if (item.goalMatch) _SoftPill(label: 'Khớp mục tiêu'),
                        if (current) _SoftPill(label: 'Bậc hiện tại'),
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

  String _statusLabel(FearLadderItemModel item, bool current) {
    final locked = !item.unlocked;
    final mastered = item.status == 'MASTERED';
    if (locked) return 'Đang khóa';
    if (mastered) return 'Đã làm chủ';
    if (current) return 'Đang mở';
    return 'Có thể chọn';
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

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
      child: child,
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label, this.color = AppColors.primary});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _SoftPill extends StatelessWidget {
  const _SoftPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 12.5),
      ),
    );
  }
}

class _LockedModuleChip extends StatelessWidget {
  const _LockedModuleChip({required this.module});

  final RoadmapProgramModuleModel module;

  @override
  Widget build(BuildContext context) {
    final text = module.lockReason.isNotEmpty
        ? module.lockReason
        : module.expectedUnlockAt != null
            ? 'Dự kiến mở từ ${_formatDate(module.expectedUnlockAt)}'
            : 'Đang khóa';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '${module.title}: $text',
        style: const TextStyle(color: AppColors.textSecondary, height: 1.35),
      ),
    );
  }
}

class _ItemVisualState {
  const _ItemVisualState(this.label, this.color, this.actionLabel);

  final String label;
  final Color color;
  final String actionLabel;
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
