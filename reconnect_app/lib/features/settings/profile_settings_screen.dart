import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Hồ sơ & Cài đặt'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: const Center(
                      child: Text('🦊', style: TextStyle(fontSize: 40)), // Mock Avatar
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cáo Nhỏ',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Trạng thái: Ẩn danh',
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.edit, color: Colors.white),
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Stats Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  _buildStatCard('Ngày tham gia', '14', Icons.calendar_today, Colors.blue),
                  const SizedBox(width: 16),
                  _buildStatCard('Cấp độ Node', 'Trạm 4', Icons.flag, Colors.orange),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Settings List
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                children: [
                  _buildSectionHeader('Tùy chỉnh Trải nghiệm'),
                  SwitchListTile(
                    activeColor: AppColors.primary,
                    title: const Text('Giao diện Tối (Dark Mode)'),
                    secondary: const Icon(Icons.dark_mode_outlined, color: AppColors.textPrimary),
                    value: _darkModeEnabled,
                    onChanged: (val) {
                      setState(() {
                        _darkModeEnabled = val;
                      });
                    },
                  ),
                  const Divider(height: 1, indent: 64),
                  SwitchListTile(
                    activeColor: AppColors.primary,
                    title: const Text('Nhắc nhở làm CBT hàng ngày'),
                    secondary: const Icon(Icons.notifications_active_outlined, color: AppColors.textPrimary),
                    value: _notificationsEnabled,
                    onChanged: (val) {
                      setState(() {
                        _notificationsEnabled = val;
                      });
                    },
                  ),
                  
                  const Divider(height: 32, thickness: 8, color: AppColors.background),
                  
                  _buildSectionHeader('Tài khoản & Riêng tư'),
                  ListTile(
                    leading: const Icon(Icons.shield_outlined, color: AppColors.textPrimary),
                    title: const Text('Quyền riêng tư & Mật khẩu'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 64),
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: AppColors.alert),
                    title: const Text('Xóa toàn bộ dữ liệu (Delete Account)', style: TextStyle(color: AppColors.alert)),
                    onTap: () {
                      _showDeleteWarning();
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                     // Go back to login screen
                     context.go('/');
                  },
                  icon: const Icon(Icons.logout, color: AppColors.textSecondary),
                  label: const Text('ĐĂNG XUẤT', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
  
  void _showDeleteWarning() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cảnh báo nguy hiểm'),
        content: const Text('Hành động này sẽ xóa vĩnh viễn toàn bộ nhật ký AI, điểm LSAS và lộ trình Fear Ladder của bạn. Bạn có chắc chắn không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('HỦY'),
          ),
          ElevatedButton(
            onPressed: () {
               Navigator.pop(context);
               context.go('/'); 
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.alert),
            child: const Text('XÓA DỮ LIỆU'),
          ),
        ],
      ),
    );
  }
}
