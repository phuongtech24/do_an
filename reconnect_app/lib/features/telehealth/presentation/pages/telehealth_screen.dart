import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/mindhealth_scaffold.dart';
import '../../../../theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/telehealth_provider.dart';

class TelehealthScreen extends StatefulWidget {
  const TelehealthScreen({super.key});

  @override
  State<TelehealthScreen> createState() => _TelehealthScreenState();
}

class _TelehealthScreenState extends State<TelehealthScreen> {
  bool _loaded = false;
  bool _anonymousModeEnabled = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final patientId = auth.loginResponse?.user.id ?? '';
    final token = auth.loginResponse?.token;
    _anonymousModeEnabled = auth.patientProfile?.anonymousModeEnabled ?? true;
    if (patientId.isNotEmpty) {
      Provider.of<TelehealthProvider>(context, listen: false).loadAssignmentStatus(patientId, token: token);
    }
    _loaded = true;
  }

  @override
  Widget build(BuildContext context) {
    return MindHealthScaffold(
      title: 'Không gian CBT',
      body: Consumer<TelehealthProvider>(
        builder: (context, telehealth, _) {
          final assigned = telehealth.isAssigned;
          final isSelfHelpMode = telehealth.isSelfHelpMode;
          final isReassuranceMode = telehealth.isReassuranceMode;
          final isTriageMode = telehealth.carePhaseCode == 'RED_FLAG_OVERRIDE' && !assigned;
          final therapistName = telehealth.therapistName.isNotEmpty ? telehealth.therapistName : 'Chưa cập nhật';
          final bannerText = assigned
              ? 'Chuyên gia đồng hành hiện tại: $therapistName'
              : (telehealth.assignmentMessage.isNotEmpty
                    ? telehealth.assignmentMessage
                    : 'Bạn cần chọn chuyên gia trước khi đặt lịch CBT.');

          return ListView(
            padding: const EdgeInsets.only(bottom: 20),
            children: [
              _TelehealthHero(
                assigned: assigned,
                selfHelpMode: isSelfHelpMode,
                reassuranceMode: isReassuranceMode,
                message: bannerText,
              ),
              const SizedBox(height: 18),
              _GuidanceCard(
                carePhaseLabel: telehealth.carePhaseLabel,
                frequencyLabel: telehealth.recommendedFrequencyLabel,
                summary: telehealth.recommendedPlanSummary,
                durationGuidance: telehealth.durationGuidance,
                allowOverride: telehealth.allowOverride,
              ),
              const SizedBox(height: 14),
              if (isSelfHelpMode || isReassuranceMode) ...[
                _ActionCard(
                  icon: Icons.menu_book_rounded,
                  title: 'Viết nhật ký suy nghĩ',
                  subtitle: 'Đi thẳng vào Thought Record 6 bước để bóc tách suy nghĩ tự động và tự điều chỉnh.',
                  accent: AppColors.primary,
                  onTap: () => context.push('/thought-record'),
                ),
                const SizedBox(height: 14),
                _ActionCard(
                  icon: Icons.alt_route_rounded,
                  title: 'Thực hành Fear Ladder',
                  subtitle: 'Xem các bậc sợ hãi từ dễ đến khó và bài thực hành hôm nay phù hợp với LSAS của bạn.',
                  accent: AppColors.secondary,
                  onTap: () => context.push('/roadmap'),
                ),
                const SizedBox(height: 14),
                _ActionCard(
                  icon: Icons.style_outlined,
                  title: 'Mở thẻ đối phó',
                  subtitle: 'Đọc lại các suy nghĩ cân bằng, nhắc nhở tích cực và công cụ bình ổn nhanh trước tình huống căng thẳng.',
                  accent: const Color(0xFF6EA883),
                  onTap: () => context.push('/coping-cards'),
                ),
                const SizedBox(height: 14),
                _ActionCard(
                  icon: Icons.wb_sunny_outlined,
                  title: 'Check-in hôm nay',
                  subtitle: 'Quay về Trang chủ để làm Daily Check-in, theo dõi lo âu và nhận điều hướng CBT phù hợp.',
                  accent: const Color(0xFFF0A34A),
                  onTap: () => context.go('/home'),
                ),
              ] else ...[
                if (!assigned && !isTriageMode) ...[
                  _ActionCard(
                    icon: Icons.people_alt_outlined,
                    title: 'Chọn chuyên gia phù hợp',
                    subtitle: 'Xem danh sách chuyên gia đang hoạt động và chọn người bạn thấy phù hợp nhất.',
                    accent: AppColors.primary,
                    onTap: () => context.push('/therapist-matching'),
                  ),
                  const SizedBox(height: 14),
                ],
                _ActionCard(
                  icon: Icons.schedule_outlined,
                  title: 'Đặt lịch tư vấn',
                  subtitle: assigned
                      ? 'Chọn khung giờ CBT còn trống theo đúng giai đoạn điều trị hiện tại.'
                      : (isTriageMode
                          ? 'Ca của bạn đang được admin lâm sàng điều phối. Khi gán xong bác sĩ, lịch phù hợp sẽ được mở.'
                          : 'Bạn cần chọn chuyên gia trước khi xem lịch trống.'),
                  accent: AppColors.primary,
                  onTap: assigned
                      ? () => context.push('/telehealth/booking')
                      : () => _showBlockedSnackBar(context, bannerText),
                ),
                const SizedBox(height: 14),
                _ActionCard(
                  icon: Icons.history_rounded,
                  title: 'Lịch hẹn của tôi',
                  subtitle: 'Xem các buổi hẹn đã đặt và theo dõi lịch tư vấn sắp tới.',
                  accent: AppColors.secondary,
                  onTap: () => context.push('/telehealth/my-appointments'),
                ),
                const SizedBox(height: 14),
                _IdentityCard(
                  value: _anonymousModeEnabled,
                  onChanged: (value) async {
                    setState(() => _anonymousModeEnabled = value);
                    await context.read<AuthProvider>().updatePatientProfile({
                      'anonymousModeEnabled': value,
                    });
                  },
                ),
              ],
              if (telehealth.status == TelehealthStatus.loading) ...[
                const SizedBox(height: 16),
                const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              ],
              if (telehealth.status == TelehealthStatus.error && telehealth.errorMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4E8),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.warning.withOpacity(0.28)),
                  ),
                  child: Text(
                    telehealth.errorMessage,
                    style: const TextStyle(color: AppColors.textPrimary, height: 1.45),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  void _showBlockedSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _TelehealthHero extends StatelessWidget {
  const _TelehealthHero({
    required this.assigned,
    required this.selfHelpMode,
    required this.reassuranceMode,
    required this.message,
  });

  final bool assigned;
  final bool selfHelpMode;
  final bool reassuranceMode;
  final String message;

  @override
  Widget build(BuildContext context) {
    final bool highlighted = assigned || selfHelpMode;
    final IconData icon = selfHelpMode
        ? Icons.self_improvement_rounded
        : reassuranceMode
            ? Icons.favorite_border_rounded
            : assigned
                ? Icons.verified_user_outlined
                : Icons.support_agent_outlined;
    final String title = selfHelpMode
        ? 'Tự trị liệu có hướng dẫn'
        : reassuranceMode
            ? 'Theo dõi và an tâm'
            : assigned
                ? 'Telehealth đã sẵn sàng'
                : 'Sẵn sàng chọn chuyên gia';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: highlighted
              ? const [AppColors.primary, Color(0xFF159489)]
              : const [Color(0xFFF2FBFA), Color(0xFFE5F5F3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: highlighted ? null : Border.all(color: AppColors.primary.withOpacity(0.14)),
        boxShadow: highlighted
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: highlighted ? Colors.white.withOpacity(0.16) : AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: highlighted ? Colors.white : AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: highlighted ? Colors.white : AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(
                    color: highlighted ? Colors.white.withOpacity(0.92) : AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GuidanceCard extends StatelessWidget {
  const _GuidanceCard({
    required this.carePhaseLabel,
    required this.frequencyLabel,
    required this.summary,
    required this.durationGuidance,
    required this.allowOverride,
  });

  final String carePhaseLabel;
  final String frequencyLabel;
  final String summary;
  final String durationGuidance;
  final bool allowOverride;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoPill(label: carePhaseLabel, color: AppColors.primary, background: AppColors.primary.withOpacity(0.12)),
              if (allowOverride)
                const _InfoPill(label: 'Bác sĩ có thể ghi đè lịch', color: AppColors.alert, background: Color(0xFFFFE9E8)),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            frequencyLabel,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(summary, style: const TextStyle(color: AppColors.textSecondary, height: 1.45)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF2FBFA),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              'Gợi ý thời lượng / hành động: $durationGuidance',
              style: const TextStyle(color: AppColors.textPrimary, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: accent.withOpacity(0.12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, color: accent, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: accent, size: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.verified_user_outlined, color: AppColors.primary, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chế độ danh tính',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value
                      ? 'Hiện tại app đang ưu tiên biệt danh và avatar hệ thống khi giao tiếp với chuyên gia.'
                      : 'Bạn cho phép hiển thị tên thật rõ hơn khi tham vấn. Bác sĩ vẫn luôn xem được hồ sơ y tế thật trong portal.',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
