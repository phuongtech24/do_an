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
  int _selectedIndex = 0; // default: Patient Profiles (BRD)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          Container(
            width: 260,
            color: const Color(0xFF2A2D3E),
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                const Icon(Icons.admin_panel_settings, size: 48, color: Colors.white),
                const SizedBox(height: 8),
                const Text(
                  'HỆ THỐNG QUẢN TRỊ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                ),
                const Divider(height: 48, color: Colors.white24),
                _menuItem(
                  icon: Icons.people_outline,
                  label: 'Hồ sơ Bệnh nhân',
                  index: 0,
                ),
                _menuItem(
                  icon: Icons.library_books,
                  label: 'Kho Nội dung CBT',
                  index: 1,
                ),
                _menuItem(
                  icon: Icons.manage_accounts,
                  label: 'Quản lý Bác sĩ',
                  index: 2,
                ),
                const Spacer(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white54),
                  title: const Text('Đăng xuất', style: TextStyle(color: Colors.white54)),
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
          Expanded(child: _buildMainContent()),
        ],
      ),
    );
  }

  Widget _menuItem({required IconData icon, required String label, required int index}) {
    final selected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      selected: selected,
      iconColor: selected ? AppColors.secondary : Colors.white70,
      textColor: selected ? AppColors.secondary : Colors.white70,
      onTap: () => setState(() => _selectedIndex = index),
      selectedTileColor: Colors.white10,
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 1:
        return const Padding(
          padding: EdgeInsets.all(32),
          child: AdminQuestsScreen(),
        );
      case 2:
        return const Padding(
          padding: EdgeInsets.all(32),
          child: AdminVerifyDoctorScreen(),
        );
      case 0:
      default:
        return const Padding(
          padding: EdgeInsets.all(32),
          child: AdminPatientProfilesScreen(),
        );
    }
  }
}

