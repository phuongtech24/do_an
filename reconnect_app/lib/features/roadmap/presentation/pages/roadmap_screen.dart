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
        .map((q) => _QuestItem(
              id: q.id,
              title: q.title,
              description: q.description,
              category: _toVietnameseCategory(q.category),
              sourceLabel: q.sourceType == 'THERAPIST' ? 'Bác sĩ giao' : 'Tự động',
              categoryColor: _categoryColor(q.category),
              icon: _categoryIcon(q.category),
              isCompleted: q.status == 'DONE',
              isLocked: q.status == 'LOCKED',
            ))
        .toList();

    return MindHealthScaffold(
      title: 'Lộ trình Kích hoạt hành vi',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Clinical justification banner
          Container(
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
                )
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Nguyên tắc: "Thà quá dễ còn hơn quá khó"',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 14),
                      ),
                      Text(
                        'CBT khuyến nghị bắt đầu bằng những việc siêu nhỏ (5-10 phút) để tránh cảm giác quá tải và củng cố niềm tin vào bản thân.',
                        style: TextStyle(color: Colors.black87, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
        ],
      ),
    );
  }

  Widget _buildRoadmapNode(BuildContext context, _QuestItem quest, int index, {required bool isLast}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline indicator
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
                        : quest.isLocked ? Colors.grey[300] : Colors.white,
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
          // Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Opacity(
                opacity: quest.isLocked ? 0.6 : 1.0,
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
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
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
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: quest.sourceLabel == 'Bác sĩ giao'
                                  ? Colors.teal.withOpacity(0.12)
                                  : Colors.grey.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              quest.sourceLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: quest.sourceLabel == 'Bác sĩ giao' ? Colors.teal : Colors.grey[700],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (quest.isLocked)
                            const Icon(Icons.lock_outline, size: 16, color: Colors.grey),
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
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
