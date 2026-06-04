import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/mindhealth_scaffold.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/patient_quest_model.dart';
import '../providers/roadmap_provider.dart';

class RoadmapScreen extends StatelessWidget {
  const RoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final patientId = auth.loginResponse?.user.id ?? '';
    final token = auth.loginResponse?.token;
    final provider = Provider.of<RoadmapProvider>(context);

    if (patientId.isNotEmpty && provider.status == RoadmapStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<RoadmapProvider>(context, listen: false).loadDailyQuests(patientId, token: token);
      });
    }

    return MindHealthScaffold(
      title: 'Lộ trình Kích hoạt hành vi',
      body: DefaultTabController(
        length: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (provider.safetyOverlay.active) ...[
              _SafetyOverlayBanner(
                message: provider.safetyOverlay.message,
                riskScore: provider.safetyOverlay.riskScore,
              ),
              const SizedBox(height: 12),
            ],
            const _RoadmapPrincipleBanner(),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const TabBar(
                labelColor: Color(0xFF0F8B7F),
                unselectedLabelColor: Colors.black54,
                indicatorColor: Color(0xFF0F8B7F),
                tabs: [
                  Tab(icon: Icon(Icons.today_rounded), text: 'Hôm nay'),
                  Tab(icon: Icon(Icons.history_rounded), text: 'Lịch sử'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TabBarView(
                children: [
                  _TodayQuestTab(
                    provider: provider,
                    patientId: patientId,
                    token: token,
                  ),
                  _CbtHistoryTab(
                    provider: provider,
                    patientId: patientId,
                    token: token,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayQuestTab extends StatelessWidget {
  const _TodayQuestTab({
    required this.provider,
    required this.patientId,
    required this.token,
  });

  final RoadmapProvider provider;
  final String patientId;
  final String? token;

  @override
  Widget build(BuildContext context) {
    if (provider.status == RoadmapStatus.loading && provider.dailyQuests.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.status == RoadmapStatus.error) {
      return _RoadmapErrorState(
        message: provider.errorMessage,
        onRetry: patientId.isEmpty ? null : () => provider.loadDailyQuests(patientId, token: token),
      );
    }

    if (provider.dailyQuests.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => provider.loadDailyQuests(patientId, token: token),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            _EmptyState(
              icon: Icons.task_alt_rounded,
              title: 'Hôm nay chưa có nhiệm vụ',
              message: 'Sau khi làm LSAS baseline, hệ thống sẽ tạo Fear Ladder và bài thực hành hành vi tại đây.',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadDailyQuests(patientId, token: token),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 4),
        itemCount: provider.dailyQuests.length,
        itemBuilder: (context, index) {
          final quest = provider.dailyQuests[index];
          return _QuestTimelineCard(
            quest: quest,
            index: index,
            isLast: index == provider.dailyQuests.length - 1,
            onOpen: quest.status == 'AVAILABLE'
                ? () {
                    context.push(
                      '/quest-detail',
                      extra: {
                        'id': quest.id,
                        'title': quest.title,
                        'category': _toVietnameseCategory(quest.category),
                        'categoryColor': _categoryColor(quest.category),
                        'icon': _categoryIcon(quest.category),
                      },
                    );
                  }
                : null,
          );
        },
      ),
    );
  }
}

class _CbtHistoryTab extends StatelessWidget {
  const _CbtHistoryTab({
    required this.provider,
    required this.patientId,
    required this.token,
  });

  final RoadmapProvider provider;
  final String patientId;
  final String? token;

  @override
  Widget build(BuildContext context) {
    if (provider.historyLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.questHistory.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => provider.loadQuestHistory(patientId, token: token),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            _EmptyState(
              icon: Icons.history_rounded,
              title: 'Chưa có lịch sử CBT',
              message: 'Các bài hệ thống giao và bác sĩ giao sẽ được lưu ở đây.',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadQuestHistory(patientId, token: token),
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 4, bottom: 16),
        itemCount: provider.questHistory.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          return _QuestHistoryCard(quest: provider.questHistory[index]);
        },
      ),
    );
  }
}

class _QuestTimelineCard extends StatelessWidget {
  const _QuestTimelineCard({
    required this.quest,
    required this.index,
    required this.isLast,
    required this.onOpen,
  });

  final PatientQuestModel quest;
  final int index;
  final bool isLast;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final categoryColor = _categoryColor(quest.category);
    final isDone = quest.status == 'DONE';
    final isLocked = quest.status == 'LOCKED';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 48,
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone
                        ? categoryColor
                        : isLocked
                            ? Colors.grey.shade200
                            : Colors.white,
                    border: Border.all(color: isLocked ? Colors.grey.shade400 : categoryColor, width: 2),
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check, size: 18, color: Colors.white)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isLocked ? Colors.grey : categoryColor,
                            ),
                          ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: isDone ? categoryColor : Colors.grey.shade300),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Opacity(
                opacity: isLocked ? 0.62 : 1,
                child: _QuestSurfaceCard(
                  quest: quest,
                  trailing: isLocked
                      ? const Icon(Icons.lock_outline, color: Colors.grey)
                      : isDone
                          ? const Icon(Icons.check_circle_rounded, color: Colors.green)
                          : FilledButton.icon(
                              onPressed: onOpen,
                              icon: const Icon(Icons.photo_camera_outlined, size: 18),
                              label: const Text('Nộp minh chứng'),
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

class _QuestHistoryCard extends StatelessWidget {
  const _QuestHistoryCard({required this.quest});

  final PatientQuestModel quest;

  @override
  Widget build(BuildContext context) {
    return _QuestSurfaceCard(
      quest: quest,
      showDates: true,
      trailing: _StatusPill(status: quest.status),
    );
  }
}

class _QuestSurfaceCard extends StatelessWidget {
  const _QuestSurfaceCard({
    required this.quest,
    this.trailing,
    this.showDates = false,
  });

  final PatientQuestModel quest;
  final Widget? trailing;
  final bool showDates;

  @override
  Widget build(BuildContext context) {
    final categoryColor = _categoryColor(quest.category);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CategoryChip(category: quest.category),
              const SizedBox(width: 8),
              _SourceChip(sourceType: quest.sourceType),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          Text(
            quest.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            quest.description,
            style: TextStyle(fontSize: 13, height: 1.4, color: Colors.grey.shade700),
          ),
          if (showDates) ...[
            const SizedBox(height: 10),
            Text(
              'Giao: ${_formatQuestDateTime(quest.assignedAt)}'
              '${quest.completedAt != null ? ' • Xong: ${_formatQuestDateTime(quest.completedAt)}' : ''}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
          if (quest.masteryScore != null || quest.pleasureScore != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                _ScoreMiniChip(label: 'Mastery', value: quest.masteryScore),
                const SizedBox(width: 8),
                _ScoreMiniChip(label: 'Pleasure', value: quest.pleasureScore),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_categoryIcon(category), size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            _toVietnameseCategory(category),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

class _SourceChip extends StatelessWidget {
  const _SourceChip({required this.sourceType});

  final String sourceType;

  @override
  Widget build(BuildContext context) {
    final isTherapistQuest = sourceType == 'THERAPIST';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isTherapistQuest ? Colors.teal.withOpacity(0.12) : Colors.grey.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isTherapistQuest ? 'Bác sĩ giao' : 'Hệ thống giao',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isTherapistQuest ? Colors.teal : Colors.grey.shade700,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final isDone = status == 'DONE';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDone ? Colors.green.withOpacity(0.12) : Colors.orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _questStatusText(status),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isDone ? Colors.green.shade700 : Colors.orange.shade700,
        ),
      ),
    );
  }
}

class _ScoreMiniChip extends StatelessWidget {
  const _ScoreMiniChip({required this.label, required this.value});

  final String label;
  final int? value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text('$label: ${value ?? '-'}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
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
                  'CBT khuyến nghị bắt đầu bằng những việc nhỏ để tránh quá tải và củng cố niềm tin vào bản thân.',
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

class _RoadmapErrorState extends StatelessWidget {
  const _RoadmapErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 8),
            Text('Lỗi: $message', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Icon(icon, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}

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
