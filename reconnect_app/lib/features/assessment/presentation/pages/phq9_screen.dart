import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/mindhealth_scaffold.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../data/models/lsas_situation_model.dart';
import '../../data/models/lsas_submission_model.dart';
import '../providers/assessment_provider.dart';

class Phq9Screen extends StatelessWidget {
  const Phq9Screen({super.key});

  @override
  Widget build(BuildContext context) => const LsasAssessmentScreen();
}

class LsasAssessmentScreen extends StatefulWidget {
  const LsasAssessmentScreen({super.key});

  @override
  State<LsasAssessmentScreen> createState() => _LsasAssessmentScreenState();
}

class _LsasAssessmentScreenState extends State<LsasAssessmentScreen> {
  final Map<String, int> _fearScores = {};
  final Map<String, int> _avoidanceScores = {};
  bool _bootstrapped = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bootstrapped) return;
    _bootstrapped = true;
    final auth = context.read<AuthProvider>();
    final patientId = auth.loginResponse?.user.id ?? '';
    final token = auth.token;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AssessmentProvider>();
      provider.loadSituations(token: token);
      if (patientId.isNotEmpty) {
        provider.checkCooldown(patientId, token: token);
        provider.loadLsasHistory(patientId, token: token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<AssessmentProvider>();
    final patientId = auth.loginResponse?.user.id ?? '';
    final token = auth.token;

    return MindHealthScaffold(
      title: 'Đánh giá lo âu xã hội (LSAS)',
      body: patientId.isEmpty
          ? const _LsasEmptyState(
              icon: Icons.lock_outline_rounded,
              title: 'Vui lòng đăng nhập',
              message: 'Bạn cần đăng nhập để làm LSAS và tạo Fear Ladder cá nhân.',
            )
          : provider.status == AssessmentStatus.loading && provider.situations.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : provider.status == AssessmentStatus.error && provider.situations.isEmpty
                  ? _LsasErrorState(
                      message: provider.errorMessage,
                      onRetry: () => provider.loadSituations(token: token),
                    )
                  : provider.isCooldown
                      ? _LsasCooldownView(
                          history: provider.lsasHistory,
                          loading: provider.historyLoading,
                          onRefresh: () => provider.loadLsasHistory(patientId, token: token),
                          onBackHome: () => context.go('/home'),
                        )
                      : _LsasForm(
                          situations: provider.situations,
                          fearScores: _fearScores,
                          avoidanceScores: _avoidanceScores,
                          loading: provider.status == AssessmentStatus.loading,
                          onChanged: () => setState(() {}),
                          onSubmit: () => _submit(context, patientId, token),
                        ),
    );
  }

  Future<void> _submit(BuildContext context, String patientId, String? token) async {
    final provider = context.read<AssessmentProvider>();
    final situations = provider.situations;
    final missing = situations.where((item) {
      return !_fearScores.containsKey(item.id) || !_avoidanceScores.containsKey(item.id);
    }).toList();

    if (missing.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bạn còn ${missing.length} tình huống chưa chấm đủ Fear/Avoidance.')),
      );
      return;
    }

    final answers = situations.map((item) {
      return LsasAnswerInput(
        situationId: item.id,
        fearScore: _fearScores[item.id]!,
        avoidanceScore: _avoidanceScores[item.id]!,
      );
    }).toList();

    final hasHistory = provider.lsasHistory.isNotEmpty;
    final ok = await provider.submitLsas(
      patientId,
      answers,
      token: token,
      submissionType: hasHistory ? 'PERIODIC' : 'BASELINE',
    );

    if (!context.mounted) return;
    if (ok) {
      final score = provider.lastSubmission?.totalScore ?? 0;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Đã lưu LSAS'),
          content: Text(
            'Tổng điểm LSAS của bạn là $score/144.\n\nBaseline và re-rating định kỳ đều dùng cùng 24 tình huống để so sánh tiến triển theo thời gian. Hệ thống sẽ dùng kết quả này để tạo Fear Ladder và bài thực hành hành vi theo mức dễ → khó.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tiếp tục'),
            ),
          ],
        ),
      );
      await context.read<OnboardingProvider>().loadOnboardingStatus(patientId, token: token);
      if (context.mounted) {
        context.go(context.read<OnboardingProvider>().nextOnboardingRoute);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage)),
      );
    }
  }
}

class _LsasForm extends StatefulWidget {
  const _LsasForm({
    required this.situations,
    required this.fearScores,
    required this.avoidanceScores,
    required this.loading,
    required this.onChanged,
    required this.onSubmit,
  });

  final List<LsasSituationModel> situations;
  final Map<String, int> fearScores;
  final Map<String, int> avoidanceScores;
  final bool loading;
  final VoidCallback onChanged;
  final VoidCallback onSubmit;

  @override
  State<_LsasForm> createState() => _LsasFormState();
}

class _LsasFormState extends State<_LsasForm> {
  late final ScrollController _scrollController;
  late List<GlobalKey> _itemKeys;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _itemKeys = List.generate(widget.situations.length, (_) => GlobalKey());
  }

  @override
  void didUpdateWidget(covariant _LsasForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.situations.length != widget.situations.length) {
      _itemKeys = List.generate(widget.situations.length, (_) => GlobalKey());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completed = widget.situations.where((item) {
      return widget.fearScores.containsKey(item.id) && widget.avoidanceScores.containsKey(item.id);
    }).length;
    final progress = widget.situations.isEmpty ? 0.0 : completed / widget.situations.length;

    return Column(
      children: [
        const _GuideCard(
          icon: Icons.psychology_alt_rounded,
          title: 'LSAS là gì?',
          message:
              'Bạn sẽ chấm 24 tình huống xã hội theo 2 trục: mức sợ/hồi hộp và mức né tránh. Cả baseline và re-rating đều dùng đúng 24 tình huống này để đo tiến triển.',
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(value: progress, minHeight: 8, borderRadius: BorderRadius.circular(999)),
        const SizedBox(height: 8),
        Text(
          '$completed/${widget.situations.length} tình huống đã hoàn tất',
          style: const TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 12),
        _LsasQuestionOverviewButton(
          situations: widget.situations,
          fearScores: widget.fearScores,
          avoidanceScores: widget.avoidanceScores,
          onTapItem: (index) async {
            Navigator.pop(context);
            await _scrollToItem(index);
          },
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            controller: _scrollController,
            itemCount: widget.situations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = widget.situations[index];
              return Container(
                key: _itemKeys[index],
                child: _SituationCard(
                  situation: item,
                  fearScore: widget.fearScores[item.id],
                  avoidanceScore: widget.avoidanceScores[item.id],
                  onFearChanged: (value) {
                    widget.fearScores[item.id] = value;
                    widget.onChanged();
                  },
                  onAvoidanceChanged: (value) {
                    widget.avoidanceScores[item.id] = value;
                    widget.onChanged();
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: widget.loading ? null : widget.onSubmit,
            icon: widget.loading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.check_circle_outline_rounded),
            label: const Text('Lưu LSAS và tạo Fear Ladder'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F8B7F),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _scrollToItem(int index) async {
    if (index < 0 || index >= _itemKeys.length) return;
    final context = _itemKeys[index].currentContext;
    if (context == null) return;
    await Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
      alignment: 0.08,
    );
  }
}

class _LsasQuestionOverviewButton extends StatelessWidget {
  const _LsasQuestionOverviewButton({
    required this.situations,
    required this.fearScores,
    required this.avoidanceScores,
    required this.onTapItem,
  });

  final List<LsasSituationModel> situations;
  final Map<String, int> fearScores;
  final Map<String, int> avoidanceScores;
  final ValueChanged<int> onTapItem;

  @override
  Widget build(BuildContext context) {
    final completedCount = situations.where((item) {
      return fearScores.containsKey(item.id) && avoidanceScores.containsKey(item.id);
    }).length;
    final missingCount = situations.length - completedCount;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _showOverviewDialog(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF0F8B7F).withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE6F7F4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.grid_view_rounded, color: Color(0xFF0F8B7F)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tổng quan 24 câu hỏi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Đã xong $completedCount/24 • Còn thiếu $missingCount câu',
                    style: const TextStyle(color: Colors.black54, height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFF0F8B7F),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Xem',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showOverviewDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720, maxHeight: 680),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Tổng quan 24 câu hỏi LSAS',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Chạm vào số câu để nhảy tới đúng câu đó. Màu xanh là đã chấm đủ Fear và Né tránh.',
                  style: TextStyle(color: Colors.black54, height: 1.4),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: _LsasQuestionOverviewGrid(
                      situations: situations,
                      fearScores: fearScores,
                      avoidanceScores: avoidanceScores,
                      onTapItem: onTapItem,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LsasQuestionOverviewGrid extends StatelessWidget {
  const _LsasQuestionOverviewGrid({
    required this.situations,
    required this.fearScores,
    required this.avoidanceScores,
    required this.onTapItem,
  });

  final List<LsasSituationModel> situations;
  final Map<String, int> fearScores;
  final Map<String, int> avoidanceScores;
  final ValueChanged<int> onTapItem;

  @override
  Widget build(BuildContext context) {
    final completedCount = situations.where((item) {
      return fearScores.containsKey(item.id) && avoidanceScores.containsKey(item.id);
    }).length;
    final missingCount = situations.length - completedCount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.grid_view_rounded, color: Color(0xFF0F8B7F)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Tiến độ hiện tại',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                'Còn thiếu $missingCount câu',
                style: const TextStyle(
                  color: Color(0xFF0F8B7F),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Chạm vào số câu để nhảy tới đúng câu đó. Màu xanh là đã chấm đủ Fear và Né tránh.',
            style: TextStyle(color: Colors.black54, height: 1.4),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(situations.length, (index) {
              final item = situations[index];
              final hasFear = fearScores.containsKey(item.id);
              final hasAvoidance = avoidanceScores.containsKey(item.id);
              final completed = hasFear && hasAvoidance;
              final partial = hasFear || hasAvoidance;

              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => onTapItem(index),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: completed
                        ? const Color(0xFFD7F5EF)
                        : partial
                            ? const Color(0xFFFFF1CF)
                            : const Color(0xFFF2F4F5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: completed
                          ? const Color(0xFF0F8B7F)
                          : partial
                              ? const Color(0xFFE7A95B)
                              : Colors.grey.shade300,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${item.situationNumber}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: completed
                            ? const Color(0xFF0F8B7F)
                            : partial
                                ? const Color(0xFF9B6A19)
                                : Colors.black54,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _LegendChip(
                color: const Color(0xFFD7F5EF),
                borderColor: const Color(0xFF0F8B7F),
                label: 'Đã chấm đủ',
              ),
              _LegendChip(
                color: const Color(0xFFFFF1CF),
                borderColor: const Color(0xFFE7A95B),
                label: 'Đã chấm một phần',
              ),
              _LegendChip(
                color: const Color(0xFFF2F4F5),
                borderColor: Colors.grey.shade300,
                label: 'Chưa chấm',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.color,
    required this.borderColor,
    required this.label,
  });

  final Color color;
  final Color borderColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _SituationCard extends StatelessWidget {
  const _SituationCard({
    required this.situation,
    required this.fearScore,
    required this.avoidanceScore,
    required this.onFearChanged,
    required this.onAvoidanceChanged,
  });

  final LsasSituationModel situation;
  final int? fearScore;
  final int? avoidanceScore;
  final ValueChanged<int> onFearChanged;
  final ValueChanged<int> onAvoidanceChanged;

  @override
  Widget build(BuildContext context) {
    final isPerformance = situation.group == 'PERFORMANCE';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFE0F2F1),
                child: Text('${situation.situationNumber}', style: const TextStyle(color: Color(0xFF0F8B7F))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(situation.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(
                      isPerformance ? 'Hiệu suất/biểu diễn' : 'Tương tác xã hội',
                      style: TextStyle(color: isPerformance ? Colors.deepPurple : const Color(0xFF0F8B7F)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ScoreSelector(
            title: 'Mức độ sợ hãi / lo âu (Fear)',
            value: fearScore,
            labels: const ['Không có', 'Nhẹ', 'Vừa phải / Trung bình', 'Nghiêm trọng'],
            onChanged: onFearChanged,
          ),
          const SizedBox(height: 14),
          _ScoreSelector(
            title: 'Mức độ né tránh (Avoidance)',
            value: avoidanceScore,
            labels: const ['Không bao giờ', 'Thỉnh thoảng', 'Thường xuyên', 'Hầu như luôn luôn'],
            onChanged: onAvoidanceChanged,
          ),
        ],
      ),
    );
  }
}

class _ScoreSelector extends StatelessWidget {
  const _ScoreSelector({
    required this.title,
    required this.value,
    required this.labels,
    required this.onChanged,
  });

  final String title;
  final int? value;
  final List<String> labels;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(4, (index) {
            final selected = value == index;
            return ChoiceChip(
              label: Text('$index - ${labels[index]}'),
              selected: selected,
              onSelected: (_) => onChanged(index),
              selectedColor: const Color(0xFFD7F5EF),
              labelStyle: TextStyle(
                color: selected ? const Color(0xFF0F8B7F) : Colors.black87,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _LsasCooldownView extends StatelessWidget {
  const _LsasCooldownView({
    required this.history,
    required this.loading,
    required this.onRefresh,
    required this.onBackHome,
  });

  final List<LsasSubmissionModel> history;
  final bool loading;
  final Future<void> Function() onRefresh;
  final VoidCallback onBackHome;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 28),
          const Icon(Icons.lock_clock_rounded, size: 96, color: Color(0xFFFFB300)),
          const SizedBox(height: 20),
          const Text(
            'Đang trong chu kỳ 14 ngày',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          const Text(
            'Bạn đã làm LSAS gần đây. Sau 14 ngày, hệ thống sẽ mở re-rating để cập nhật Fear Ladder. Bài định kỳ vẫn dùng đủ 24 tình huống giống baseline.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
          ),
          const SizedBox(height: 24),
          _LsasHistorySection(history: history, loading: loading),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onBackHome,
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Quay lại trang chủ'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F8B7F),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
          ),
        ],
      ),
    );
  }
}

class _LsasHistorySection extends StatelessWidget {
  const _LsasHistorySection({required this.history, required this.loading});

  final List<LsasSubmissionModel> history;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.history_rounded, color: Color(0xFF0F8B7F)),
              SizedBox(width: 10),
              Text('Lịch sử LSAS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 12),
          if (loading)
            const Center(child: CircularProgressIndicator())
          else if (history.isEmpty)
            const Text('Chưa có lần đánh giá LSAS nào.', style: TextStyle(color: Colors.black54))
          else
            ...history.map((item) {
              final score = item.totalScore;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: _lsasColor(score).withOpacity(0.14),
                      child: Text('$score', style: TextStyle(color: _lsasColor(score), fontWeight: FontWeight.w900)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${item.createDate ?? ''} • ${item.submissionType}\nFear ${item.fearTotal}/72 • Avoidance ${item.avoidanceTotal}/72',
                        style: const TextStyle(height: 1.35),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({required this.icon, required this.title, required this.message});

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F7F4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF0F8B7F)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(message, style: const TextStyle(color: Colors.black87, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LsasErrorState extends StatelessWidget {
  const _LsasErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _LsasEmptyState(
      icon: Icons.error_outline_rounded,
      title: 'Không tải được LSAS',
      message: message,
      actionLabel: 'Tải lại',
      onAction: onRetry,
    );
  }
}

class _LsasEmptyState extends StatelessWidget {
  const _LsasEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 72, color: const Color(0xFF0F8B7F)),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54, height: 1.4)),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

Color _lsasColor(int score) {
  if (score >= 95) return Colors.red;
  if (score >= 65) return Colors.deepOrange;
  if (score >= 35) return Colors.orange;
  return const Color(0xFF0F8B7F);
}
