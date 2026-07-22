import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/auth/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../auth/therapist_login_screen.dart';
import 'admin_patient_profiles_screen.dart';
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 1080;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: isCompact ? _buildCompactLayout(context) : _buildWideLayout(context),
          ),
        );
      },
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Row(
      children: [
        _buildSidebar(context, compact: false),
        Expanded(
          child: Column(
            children: [
              _buildTopBar(compact: false),
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
    );
  }

  Widget _buildCompactLayout(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _buildSidebar(context, compact: true),
              const SizedBox(height: 16),
              _buildTopBar(compact: true),
              const SizedBox(height: 16),
              SizedBox(
                height: 720,
                child: _buildMainContent(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar(BuildContext context, {required bool compact}) {
    final width = compact ? double.infinity : 290.0;

    return Container(
      width: width,
      margin: compact ? EdgeInsets.zero : const EdgeInsets.all(20),
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
        padding: EdgeInsets.all(compact ? 20 : 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              'Quản trị ReConnect',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22),
            ),
            const SizedBox(height: 8),
            const Text(
              'Quản trị hồ sơ bệnh nhân và điều phối chuyên gia trong cùng một không gian làm việc.',
              style: TextStyle(color: Colors.white70, height: 1.45),
            ),
            const SizedBox(height: 24),
            _menuItem(
              icon: Icons.people_outline,
              label: 'Hồ sơ bệnh nhân',
              subtitle: 'Theo dõi hồ sơ và điều phối',
              index: 0,
            ),
            const SizedBox(height: 12),
            _menuItem(
              icon: Icons.manage_accounts_outlined,
              label: 'Quản lý chuyên gia',
              subtitle: 'Duyệt và theo dõi chuyên gia',
              index: 1,
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.verified_user_outlined, color: Colors.white),
                  ),
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
            const SizedBox(height: 10),
            ListTile(
              contentPadding: EdgeInsets.zero,
              minLeadingWidth: 20,
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
                    Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar({required bool compact}) {
    const labels = ['Hồ sơ bệnh nhân', 'Quản lý chuyên gia'];

    return Container(
      margin: compact ? EdgeInsets.zero : const EdgeInsets.fromLTRB(0, 20, 20, 0),
      padding: EdgeInsets.symmetric(horizontal: compact ? 18 : 24, vertical: compact ? 16 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.08)),
      ),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  labels[_selectedIndex],
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 22),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Giữ nguyên chức năng hiện tại, tối ưu hiển thị để dễ vận hành hơn.',
                  style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 14),
                _buildStatusChip(),
              ],
            )
          : Row(
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
                _buildStatusChip(),
              ],
            ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
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
            'Hệ thống ổn định',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    final child = switch (_selectedIndex) {
      1 => const AdminVerifyDoctorScreen(),
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
