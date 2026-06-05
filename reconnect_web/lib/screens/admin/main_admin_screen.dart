import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/auth/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../auth/therapist_login_screen.dart';
import 'admin_patient_profiles_screen.dart';
import 'admin_quests_screen.dart';
import 'admin_verify_doctor_screen.dart';

class MainAdminScreen extends StatefulWidget {
  const MainAdminScreen({super.key});

  @override
  State<MainAdminScreen> createState() => _MainAdminScreenState();
}

class _MainAdminScreenState extends State<MainAdminScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          _buildSidebar(context),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: _buildMainContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 290,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0E7A73), Color(0xFF159489)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.16),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.admin_panel_settings_outlined, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 16),
            const Text(
              'ReConnect Admin',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Quản trị hồ sơ bệnh nhân, nội dung CBT và điều phối chuyên gia trong cùng một workspace.',
              style: TextStyle(color: Colors.white70, height: 1.45),
            ),
            const SizedBox(height: 28),
            _menuItem(
              icon: Icons.people_outline,
              label: 'Hồ sơ bệnh nhân',
              subtitle: 'Theo dõi hồ sơ và điều phối',
              index: 0,
            ),
            const SizedBox(height: 12),
            _menuItem(
              icon: Icons.library_books_outlined,
              label: 'Kho nội dung CBT',
              subtitle: 'Quản lý nội dung và flow',
              index: 1,
            ),
            const SizedBox(height: 12),
            _menuItem(
              icon: Icons.manage_accounts_outlined,
              label: 'Quản lý chuyên gia',
              subtitle: 'Duyệt và theo dõi therapist',
              index: 2,
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_user_outlined, color: Colors.white),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Admin override chỉ dùng cho ngoại lệ và kiểm soát an toàn.',
                      style: TextStyle(color: Colors.white, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.logout, color: Colors.white70),
              title: const Text('Đăng xuất', style: TextStyle(color: Colors.white70)),
              onTap: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const TherapistLoginScreen()),
                  (_) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    required String subtitle,
    required int index,
  }) {
    final selected = _selectedIndex == index;
    return Material(
      color: selected ? Colors.white.withOpacity(0.16) : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(selected ? 0.22 : 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final labels = ['Hồ sơ bệnh nhân', 'Kho nội dung CBT', 'Quản lý chuyên gia'];
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 20, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  labels[_selectedIndex],
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Giữ nguyên nghiệp vụ hiện tại, chỉ tối ưu giao diện để dễ vận hành và đồng nhất hơn.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 10, color: AppColors.success),
                SizedBox(width: 8),
                Text(
                  'System stable',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    final child = switch (_selectedIndex) {
      1 => const AdminQuestsScreen(),
      2 => const AdminVerifyDoctorScreen(),
      _ => const AdminPatientProfilesScreen(),
    };

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.primary.withOpacity(0.08)),
      ),
      child: child,
    );
  }
}
