import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/mindhealth_scaffold.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/roadmap_provider.dart';

class RoadmapScreen extends StatelessWidget {
  const RoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final patientId = auth.loginResponse?.user.id ?? '';
    final token = auth.loginResponse?.token;
    final roadmapProvider = Provider.of<RoadmapProvider>(context);

    if (patientId.isNotEmpty && roadmapProvider.status == RoadmapStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<RoadmapProvider>(context, listen: false).loadDailyQuests(patientId, token: token);
      });
    }

    final quests = roadmapProvider.dailyQuests
        .map((quest) => _QuestItem(
              id: quest.id,
              title: quest.title,
              description: quest.description,
              category: _toVietnameseCategory(quest.category),
              sourceLabel: quest.sourceType == 'THERAPIST' ? 'Bác sĩ giao' : 'Tự động',
              categoryColor: _categoryColor(quest.category),
              icon: _categoryIcon(quest.category),
              isCompleted: quest.status == 'DONE',
              isLocked: quest.status == 'LOCKED',
            ))
        .toList();

    return MindHealthScaffold(
      title: 'Lộ trình Kích hoạt hành vi',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (roadmapProvider.safetyOverlay.active) ...[
            _SafetyOverlayBanner(
              message: roadmapProvider.safetyOverlay.message,
              riskScore: roadmapProvider.safetyOverlay.riskScore,
            ),
            const SizedBox(height: 16),
          ],
          const _RoadmapPrincipleBanner(),
          const SizedBox(height: 24),
          Expanded(
            child: Builder(
              builder: (context) {
                if (roadmapProvider.status == RoadmapStatus.loading && quests.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (roadmapProvider.status == RoadmapStatus.error) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                          const SizedBox(height: 8),
                          Text('Lỗi: ${roadmapProvider.errorMessage}', textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: patientId.isEmpty
                                ? null
                                : () => roadmapProvider.loadDailyQuests(patientId, token: token),
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (quests.isEmpty) {
                  return const Center(child: Text('Hôm nay chưa có nhiệm vụ nào.'));
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    if (patientId.isNotEmpty) {
                      await roadmapProvider.loadDailyQuests(patientId, token: token);
                    }
                  },
                  child: ListView.builder(
                    itemCount: quests.length,
                    itemBuilder: (context, index) {
                      final quest = quests[index];
                      return _buildRoadmapNode(context, quest, index, isLast: index == quests.length - 1);
                    },
                  ),
                );
              },
            ),
          ),
          _CbtHistorySection(
            history: roadmapProvider.questHistory,
            loading: roadmapProvider.historyLoading,
            onRefresh: () => roadmapProvider.loadQuestHistory(patientId, token: token),
          ),
        ],
      ),
    );
  }

  Widget _buildRoadmapNode(BuildContext context, _QuestItem quest, int index, {required bool isLast}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 48,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: quest.isCompleted
                        ? quest.categoryColor
                        : quest.isLocked
                            ? Colors.grey[300]
                            : Colors.white,
                    border: Border.all(
                      color: quest.isLocked ? Colors.grey[400]! : quest.categoryColor,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: quest.isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: quest.isLocked ? Colors.grey : quest.categoryColor,
                            ),
                          ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: quest.isCompleted ? quest.categoryColor : Colors.grey[300],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Opacity(
                opacity: quest.isLocked ? 0.6 : 1,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: quest.isLocked ? Colors.transparent : quest.categoryColor.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _CategoryChip(quest: quest),
                          const Spacer(),
                          _SourceChip(quest: quest),
                          const SizedBox(width: 8),
                          if (quest.isLocked) const Icon(Icons.lock_outline, size: 16, color: Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        quest.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        quest.description,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      if (!quest.isLocked && !quest.isCompleted)
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.push(
                                '/quest-detail',
                                extra: {
                                  'id': quest.id,
                                  'title': quest.title,
                                  'category': quest.category,
                                  'categoryColor': quest.categoryColor,
                                  'icon': quest.icon,
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: quest.categoryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            icon: const Icon(Icons.photo_camera_outlined, size: 18),
                            label: const Text('Nộp minh chứng', style: TextStyle(fontSize: 12)),
                          ),
                        ),
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
}

class _CbtHistorySection extends StatelessWidget {
  const _CbtHistorySection({
    required this.history,
    required this.loading,
    required this.onRefresh,
  });

  final List<dynamic> history;
  final bool loading;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(top: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.history_rounded, color: Color(0xFF0F8B7F)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Lịch sử bài CBT',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Tải lại',
                  ),
                ],
              ),
              if (loading)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (history.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('Chưa có bài CBT nào trong lịch sử.', style: TextStyle(color: Colors.black54)),
                )
              else
                ...history.take(4).map((quest) {
                  final isDone = quest.status == 'DONE';
                  final sourceText = quest.sourceType == 'THERAPIST' ? 'Bác sĩ giao' : 'Hệ thống giao';
                  return Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                          color: isDone ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(quest.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(
                                '$sourceText • ${_toVietnameseCategory(quest.category)} • ${_questStatusText(quest.status)}',
                                style: const TextStyle(color: Colors.black54, fontSize: 12),
                              ),
                              Text(
                                'Giao: ${_formatQuestDateTime(quest.assignedAt)}'
                                '${quest.completedAt != null ? ' • Xong: ${_formatQuestDateTime(quest.completedAt)}' : ''}',
                                style: const TextStyle(color: Colors.black54, fontSize: 12),
                              ),
                              if (quest.masteryScore != null || quest.pleasureScore != null)
                                Text(
                                  'Mastery: ${quest.masteryScore ?? '-'} • Pleasure: ${quest.pleasureScore ?? '-'}',
                                  style: const TextStyle(color: Colors.black87, fontSize: 12),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

/*
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.history_rounded, color: Color(0xFF0F8B7F)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Lịch sử bài CBT',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Tải lại',
                ),
              ],
            ),
            if (loading)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (history.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Chưa có bài CBT nào trong lịch sử.', style: TextStyle(color: Colors.black54)),
              )
            else
              ...history.take(4).map((quest) {
                final isDone = quest.status == 'DONE';
                final sourceText = quest.sourceType == 'THERAPIST' ? 'Bác sĩ giao' : 'Hệ thống giao';
                return Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        color: isDone ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(quest.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(
                              '$sourceText • ${_toVietnameseCategory(quest.category)} • ${_questStatusText(quest.status)}',
                              style: const TextStyle(color: Colors.black54, fontSize: 12),
                            ),
                            Text(
                              'Giao: ${_formatQuestDateTime(quest.assignedAt)}'
                              '${quest.completedAt != null ? ' • Xong: ${_formatQuestDateTime(quest.completedAt)}' : ''}',
                              style: const TextStyle(color: Colors.black54, fontSize: 12),
                            ),
                            if (quest.masteryScore != null || quest.pleasureScore != null)
                              Text(
                                'Mastery: ${quest.masteryScore ?? '-'} • Pleasure: ${quest.pleasureScore ?? '-'}',
                                style: const TextStyle(color: Colors.black87, fontSize: 12),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );*/

String _formatQuestDateTime(String? value) {
  if (value == null || value.isEmpty) return 'Không rõ ngày';
  final normalized = value.length >= 16 ? value.substring(0, 16) : value;
  return normalized.replaceFirst('T', ' ');
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
      return status;
  }
}

class _SafetyOverlayBanner extends StatelessWidget {
  const _SafetyOverlayBanner({required this.message, required this.riskScore});

  final String message;
  final int riskScore;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFB74D)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.health_and_safety_outlined, color: Color(0xFFE65100)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cần hỗ trợ thêm${riskScore > 0 ? ' • Risk $riskScore' : ''}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
                ),
                const SizedBox(height: 4),
                Text(
                  message.isNotEmpty
                      ? message
                      : 'Bạn đang có dấu hiệu cần hỗ trợ thêm. Hãy đặt lịch với chuyên gia.',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: () => context.go('/telehealth'),
                  icon: const Icon(Icons.video_call_outlined, size: 18),
                  label: const Text('Đặt lịch tư vấn'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoadmapPrincipleBanner extends StatelessWidget {
  const _RoadmapPrincipleBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nguyên tắc: "Thà quá dễ còn hơn quá khó"',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 14),
                ),
                Text(
                  'CBT khuyến nghị bắt đầu bằng những việc nhỏ (5-10 phút) để tránh quá tải và củng cố niềm tin vào bản thân.',
                  style: TextStyle(color: Colors.black87, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.quest});

  final _QuestItem quest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: quest.categoryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(quest.icon, size: 14, color: quest.categoryColor),
          const SizedBox(width: 4),
          Text(
            quest.category,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: quest.categoryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceChip extends StatelessWidget {
  const _SourceChip({required this.quest});

  final _QuestItem quest;

  @override
  Widget build(BuildContext context) {
    final isTherapistQuest = quest.sourceLabel == 'Bác sĩ giao';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isTherapistQuest ? Colors.teal.withOpacity(0.12) : Colors.grey.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        quest.sourceLabel,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isTherapistQuest ? Colors.teal : Colors.grey[700],
        ),
      ),
    );
  }
}

class _QuestItem {
  const _QuestItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.sourceLabel,
    required this.categoryColor,
    required this.icon,
    required this.isCompleted,
    required this.isLocked,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final String sourceLabel;
  final Color categoryColor;
  final IconData icon;
  final bool isCompleted;
  final bool isLocked;
}

String _toVietnameseCategory(String category) {
  switch (category) {
    case 'BEHAVIORAL':
      return 'Hành vi';
    case 'SOCIAL':
      return 'Xã hội';
    case 'EMOTIONAL':
      return 'Cảm xúc';
    case 'COGNITIVE':
    default:
      return 'Nhận thức';
  }
}

Color _categoryColor(String category) {
  switch (category) {
    case 'BEHAVIORAL':
      return const Color(0xFF2DC653);
    case 'SOCIAL':
      return const Color(0xFFFF9E00);
    case 'EMOTIONAL':
      return const Color(0xFF00B4D8);
    case 'COGNITIVE':
    default:
      return const Color(0xFF9D4EDD);
  }
}

IconData _categoryIcon(String category) {
  switch (category) {
    case 'BEHAVIORAL':
      return Icons.directions_run_outlined;
    case 'SOCIAL':
      return Icons.people_outline;
    case 'EMOTIONAL':
      return Icons.water_drop_outlined;
    case 'COGNITIVE':
    default:
      return Icons.psychology_outlined;
  }
}
