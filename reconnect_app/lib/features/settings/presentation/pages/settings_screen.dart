import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/mindhealth_scaffold.dart';
import '../../../../theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool pushEnabled = true;
  bool vietnameseLanguage = true;
  bool biometricLock = false;
  bool weeklySummary = true;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.loginResponse?.user;
    final profile = auth.patientProfile;

    final nickname = profile?.nickname.isNotEmpty == true
        ? profile!.nickname
        : (user?.username?.trim().isNotEmpty == true ? user!.username!.trim() : 'Người dùng ReConnect');
    final email = user?.email ?? 'Chưa cập nhật';
    final isAnonymousMode = profile?.anonymousModeEnabled ?? (user?.isAnonymous ?? true);
    final roleLabel = isAnonymousMode ? 'Đang bật ẩn danh' : 'Đang hiển thị tên thật';
    final realName = profile?.realFullName?.isNotEmpty == true ? profile!.realFullName! : 'Chưa cập nhật';
    final phoneNumber = profile?.phoneNumber?.isNotEmpty == true ? profile!.phoneNumber! : 'Chưa cập nhật';

    return MindHealthScaffold(
      title: 'Cài đặt tài khoản',
      body: ListView(
        padding: const EdgeInsets.only(bottom: 20),
        children: [
          _ProfileHero(
            nickname: nickname,
            email: email,
            roleLabel: roleLabel,
          ),
          const SizedBox(height: 18),
          const _SectionTitle('Tài khoản & bảo mật'),
          const SizedBox(height: 10),
          _InfoCard(
            icon: Icons.badge_outlined,
            title: 'Danh tính hiển thị',
            subtitle: 'Biệt danh: $nickname',
            trailingText: isAnonymousMode ? 'Ẩn danh' : 'Tên thật',
          ),
          const SizedBox(height: 12),
          _InfoCard(
            icon: Icons.person_outline,
            title: 'Hồ sơ thật',
            subtitle: '$realName • $phoneNumber',
            trailingText: profile?.medicalProfileCompleted == true ? 'Đã đủ hồ sơ' : 'Chưa đủ hồ sơ',
          ),
          const SizedBox(height: 12),
          _SettingTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Giữ chế độ ẩn danh',
            subtitle: 'Khi bật, app sẽ ưu tiên biệt danh và avatar hệ thống ở các bề mặt giao tiếp với chuyên gia.',
            value: isAnonymousMode,
            onChanged: (value) async {
              final ok = await auth.updatePatientProfile({'anonymousModeEnabled': value});
              if (!mounted) return;
              if (!ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(auth.errorMessage)),
                );
              }
            },
          ),
          const SizedBox(height: 12),
          _SettingTile(
            icon: Icons.notifications_active_outlined,
            title: 'Nhận thông báo nhắc lịch',
            subtitle: 'Nhận nhắc lịch tư vấn, bài thực hành trong ngày và cập nhật quan trọng.',
            value: pushEnabled,
            onChanged: (value) => setState(() => pushEnabled = value),
          ),
          const SizedBox(height: 12),
          _SettingTile(
            icon: Icons.fingerprint_outlined,
            title: 'Khóa ứng dụng nhanh',
            subtitle: 'Yêu cầu xác nhận lại khi mở ứng dụng sau một thời gian không sử dụng.',
            value: biometricLock,
            onChanged: (value) => setState(() => biometricLock = value),
          ),
          const SizedBox(height: 18),
          const _SectionTitle('Trải nghiệm sử dụng'),
          const SizedBox(height: 10),
          _SettingTile(
            icon: Icons.translate_rounded,
            title: 'Sử dụng tiếng Việt',
            subtitle: 'Giữ toàn bộ nội dung, nhãn và hướng dẫn hiển thị bằng tiếng Việt có dấu.',
            value: vietnameseLanguage,
            onChanged: (value) => setState(() => vietnameseLanguage = value),
          ),
          const SizedBox(height: 12),
          _SettingTile(
            icon: Icons.summarize_outlined,
            title: 'Nhận tổng kết hằng tuần',
            subtitle: 'Nhắc bạn xem lại LSAS, thang sợ và tiến triển trị liệu mỗi tuần.',
            value: weeklySummary,
            onChanged: (value) => setState(() => weeklySummary = value),
          ),
          const SizedBox(height: 18),
          const _SectionTitle('Hỗ trợ tài khoản'),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.edit_note_outlined,
            title: 'Cập nhật hồ sơ y tế',
            subtitle: 'Bổ sung họ tên thật, số điện thoại, học vấn, nghề nghiệp và tiền sử bệnh lý/thuốc đang dùng.',
            accent: AppColors.primary,
            onTap: () => context.go('/profile-setup?mode=medical-profile&after=/settings'),
          ),
          const SizedBox(height: 12),
          _ActionTile(
            icon: Icons.lock_reset_outlined,
            title: 'Khôi phục mật khẩu',
            subtitle: 'Dùng khi bạn quên mật khẩu hoặc muốn đặt lại mật khẩu mới an toàn hơn.',
            accent: AppColors.primary,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tính năng khôi phục mật khẩu sẽ được kết nối ở batch sau.')),
              );
            },
          ),
          const SizedBox(height: 12),
          _ActionTile(
            icon: Icons.support_agent_outlined,
            title: 'Liên hệ hỗ trợ',
            subtitle: 'Gửi phản hồi khi bạn gặp lỗi giao diện, mất dữ liệu hoặc cần hỗ trợ khẩn.',
            accent: AppColors.secondary,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Hiện chưa kết nối kênh hỗ trợ trực tiếp trong app.')),
              );
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
                context.go('/auth');
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Đăng xuất an toàn'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEAF5F4),
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.nickname,
    required this.email,
    required this.roleLabel,
  });

  final String nickname;
  final String email;
  final String roleLabel;

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
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Center(
              child: Text(
                nickname.isNotEmpty ? nickname.characters.first.toUpperCase() : 'R',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hồ sơ cá nhân',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  nickname,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(color: Colors.white.withOpacity(0.92)),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    roleLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: AppColors.textSecondary,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailingText,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String trailingText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _boxDecoration(),
      child: Row(
        children: [
          _LeadingIcon(icon: icon),
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
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              trailingText,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _boxDecoration(),
      child: Row(
        children: [
          _LeadingIcon(icon: icon),
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

class _ActionTile extends StatelessWidget {
  const _ActionTile({
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
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: _boxDecoration(borderColor: accent.withOpacity(0.12)),
          child: Row(
            children: [
              _LeadingIcon(icon: icon, color: accent),
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
              Icon(Icons.chevron_right_rounded, color: accent, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({
    required this.icon,
    this.color = AppColors.primary,
  });

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }
}

BoxDecoration _boxDecoration({Color? borderColor}) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: borderColor ?? AppColors.primary.withOpacity(0.08)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 16,
        offset: const Offset(0, 8),
      ),
    ],
  );
}
