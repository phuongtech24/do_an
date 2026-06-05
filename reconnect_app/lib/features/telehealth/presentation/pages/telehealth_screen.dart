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
  bool _shareRealIdentity = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final patientId = auth.loginResponse?.user.id ?? '';
    final token = auth.loginResponse?.token;
    if (patientId.isNotEmpty) {
      Provider.of<TelehealthProvider>(context, listen: false).loadAssignmentStatus(patientId, token: token);
    }
    _loaded = true;
  }

  @override
  Widget build(BuildContext context) {
    return MindHealthScaffold(
      title: 'Tư vấn CBT từ xa',
      body: Consumer<TelehealthProvider>(
        builder: (context, telehealth, _) {
          final assigned = telehealth.isAssigned;
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
                therapistName: therapistName,
                message: bannerText,
              ),
              const SizedBox(height: 18),
              if (!assigned) ...[
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
                    ? 'Chọn khung giờ CBT còn trống để bắt đầu buổi tư vấn.'
                    : 'Bạn cần chọn chuyên gia trước khi xem lịch trống.',
                accent: AppColors.primary,
                onTap: assigned
                    ? () => context.push('/telehealth/booking')
                    : () => _showBlockedSnackBar(context, bannerText),
              ),
              const SizedBox(height: 14),
              _ActionCard(
                icon: Icons.history_rounded,
                title: 'Lịch sử đặt lịch',
                subtitle: 'Xem các buổi hẹn đã đặt và theo dõi lịch tư vấn sắp tới.',
                accent: AppColors.secondary,
                onTap: () => context.push('/telehealth/my-appointments'),
              ),
              const SizedBox(height: 14),
              _IdentityCard(
                value: _shareRealIdentity,
                onChanged: (value) => setState(() => _shareRealIdentity = value),
              ),
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
    required this.therapistName,
    required this.message,
  });

  final bool assigned;
  final String therapistName;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: assigned
              ? const [AppColors.primary, Color(0xFF159489)]
              : const [Color(0xFFF2FBFA), Color(0xFFE5F5F3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: assigned ? null : Border.all(color: AppColors.primary.withOpacity(0.14)),
        boxShadow: assigned
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
              color: assigned ? Colors.white.withOpacity(0.16) : AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              assigned ? Icons.verified_user_outlined : Icons.support_agent_outlined,
              color: assigned ? Colors.white : AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assigned ? 'Telehealth đã sẵn sàng' : 'Sẵn sàng chọn chuyên gia',
                  style: TextStyle(
                    color: assigned ? Colors.white : AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(
                    color: assigned ? Colors.white.withOpacity(0.92) : AppColors.textSecondary,
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
              children: const [
                Text(
                  'Chế độ danh tính',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Bật để chia sẻ danh tính thật khi vào buổi CBT. Tắt nếu bạn muốn chuyên gia nhìn nickname ẩn danh.',
                  style: TextStyle(
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
