import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/mindhealth_scaffold.dart';
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
      title: 'Fear Ladder',
      body: provider.status == RoadmapStatus.loading && provider.fearLadder.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : provider.status == RoadmapStatus.error && provider.fearLadder.isEmpty
              ? Center(child: Text(provider.errorMessage))
              : ListView(
                  children: [
                    if (provider.safetyOverlay.active)
                      Card(
                        color: const Color(0xFFFFF4E5),
                        child: ListTile(
                          leading: const Icon(Icons.health_and_safety_outlined, color: Colors.deepOrange),
                          title: const Text('Cần thêm hỗ trợ an toàn'),
                          subtitle: Text(provider.safetyOverlay.message),
                        ),
                      ),
                    _ExperimentCard(
                      experiment: provider.todayExperiment,
                      onStart: provider.todayExperiment == null
                          ? null
                          : () => _showStartDialog(context, provider.todayExperiment!, token),
                      onDebrief: provider.todayExperiment == null
                          ? null
                          : () => _showDebriefDialog(context, provider.todayExperiment!, token),
                    ),
                    const SizedBox(height: 16),
                    const Text('Fear Ladder của bạn', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    if (provider.fearLadder.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Center(child: Text('Chưa có Fear Ladder. Hãy hoàn tất LSAS baseline và mục tiêu trị liệu.')),
                      )
                    else
                      ...provider.fearLadder.map(_FearLadderCard.new),
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
          title: const Text('Bắt đầu Behavioral Experiment'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: predictionController,
                  decoration: const InputDecoration(labelText: 'Prediction'),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: safetyController,
                  decoration: const InputDecoration(labelText: 'Safety behaviors cần giảm'),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                Text('Mức tin tưởng: ${belief.round()}%'),
                Slider(
                  value: belief,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  onChanged: (value) => setState(() => belief = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Hủy')),
            FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Lưu')),
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
          title: const Text('Debrief bài thực hành'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: executionController,
                  decoration: const InputDecoration(labelText: 'Execution notes'),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: debriefController,
                  decoration: const InputDecoration(labelText: 'Điều thực sự xảy ra / bài học'),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                Text('Fear sau bài: ${fear.round()}'),
                Slider(value: fear, min: 0, max: 3, divisions: 3, onChanged: (value) => setState(() => fear = value)),
                Text('Avoidance sau bài: ${avoidance.round()}'),
                Slider(value: avoidance, min: 0, max: 3, divisions: 3, onChanged: (value) => setState(() => avoidance = value)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Hủy')),
            FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Lưu')),
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
      SnackBar(content: Text(success ? 'Đã lưu debrief và cập nhật Fear Ladder.' : provider.errorMessage)),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: experiment == null
            ? const Text('Hôm nay chưa có bài Behavioral Experiment.')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bài thực hành hôm nay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(experiment!.ladderItem.situationText),
                  const SizedBox(height: 8),
                  Text('Trạng thái: ${experiment!.status} • Bucket: ${experiment!.ladderItem.bucket}'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      FilledButton(onPressed: onStart, child: const Text('Bắt đầu')),
                      const SizedBox(width: 8),
                      OutlinedButton(onPressed: onDebrief, child: const Text('Debrief')),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

class _FearLadderCard extends StatelessWidget {
  const _FearLadderCard(this.item);

  final FearLadderItemModel item;

  @override
  Widget build(BuildContext context) {
    final locked = !item.unlocked;
    final mastered = item.status == 'MASTERED';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Opacity(
        opacity: locked ? 0.6 : 1,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: mastered ? Colors.green.withOpacity(0.15) : Colors.blue.withOpacity(0.15),
            child: Text('${item.ladderOrder}'),
          ),
          title: Text(item.situationText),
          subtitle: Text(
            'Fear ${item.currentFearScore}/3 • Avoidance ${item.currentAvoidanceScore}/3 • Bucket ${item.bucket}${item.goalMatch ? ' • Khớp mục tiêu' : ''}',
          ),
          trailing: Text(locked ? 'LOCKED' : item.status),
        ),
      ),
    );
  }
}
