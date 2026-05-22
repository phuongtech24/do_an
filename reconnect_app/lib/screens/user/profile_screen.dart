import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _anonymityEnabled = true;
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ tĩnh lặng', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.face_retouching_natural, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Mây Trắng ☁️',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Bảo vệ danh tính Cấp độ 1', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
            ),
            const SizedBox(height: 48),
            
            _buildSettingsSection(
              title: 'CÀI ĐẶT RIÊNG TƯ',
              children: [
                SwitchListTile(
                  title: const Text('Bật Chế độ Ẩn Danh mặc định'),
                  subtitle: const Text('Bác sĩ sẽ không thấy tên thật của bạn khi đặt lịch'),
                  value: _anonymityEnabled,
                  activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                  onChanged: (val) => setState(() => _anonymityEnabled = val),
                  secondary: const Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            _buildSettingsSection(
              title: 'TÀI KHOẢN',
              children: [
                ListTile(
                  leading: const Icon(Icons.edit, color: AppColors.textSecondary),
                  title: const Text('Đổi Nickname / Avatar ảo'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
                  title: const Text('Đổi Mật khẩu'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Thông báo nhắc nhở Nhiệm vụ'),
                  value: _notificationsEnabled,
                  activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                  onChanged: (val) => setState(() => _notificationsEnabled = val),
                  secondary: const Icon(Icons.notifications_active_outlined, color: AppColors.textSecondary),
                ),
              ],
            ),
            
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  side: const BorderSide(color: AppColors.alert),
                  foregroundColor: AppColors.alert,
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Đăng xuất'),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}
