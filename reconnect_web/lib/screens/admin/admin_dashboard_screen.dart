import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../auth/therapist_login_screen.dart';
import 'admin_quests_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 1;

  final List<Map<String, dynamic>> _pendingTherapists = [
    {
      'id': 'T_001',
      'name': 'Nguyễn Văn A',
      'title': 'ThS. BS',
      'specialty': 'Rối loạn lo âu, Trầm cảm',
      'hospital': 'Bệnh viện Tâm thần TW',
      'date': '24/10/2023',
      'status': 'PENDING',
    },
    {
      'id': 'T_002',
      'name': 'Trần Thị B',
      'title': 'PGS. TS',
      'specialty': 'Trị liệu nhận thức hành vi',
      'hospital': 'Đại học Y Hà Nội',
      'date': '25/10/2023',
      'status': 'PENDING',
    }
  ];

  void _reviewApplication(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Kiểm duyệt bằng cấp'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Đang xem xét hồ sơ của: ${_pendingTherapists[index]['title']} ${_pendingTherapists[index]['name']}'),
            const SizedBox(height: 16),
            Container(
              height: 200,
              width: 320,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_outlined, size: 48, color: AppColors.textSecondary),
                    SizedBox(height: 8),
                    Text('[Ảnh demo chứng chỉ hành nghề]'),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _pendingTherapists.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã từ chối hồ sơ.'), backgroundColor: AppColors.alert),
              );
            },
            child: const Text('Từ chối', style: TextStyle(color: AppColors.alert)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _pendingTherapists.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã duyệt hồ sơ thành công. Chuyên gia đã được public.'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Phê duyệt', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ReConnect Admin Portal', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Center(
              child: Text(
                'Xin chào, System Admin',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const TherapistLoginScreen()),
                (route) => false,
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 280,
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0E7A73), Color(0xFF159489)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: ListView(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Điều phối quản trị',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildNavItem(Icons.dashboard_outlined, 'Tổng quan', 0),
                  _buildNavItem(Icons.verified_user_outlined, 'Duyệt chuyên gia', 1),
                  _buildNavItem(Icons.flag_outlined, 'Quản lý nhiệm vụ CBT', 2),
                  _buildNavItem(Icons.report_problem_outlined, 'Báo cáo vi phạm', 3),
                  _buildNavItem(Icons.settings_outlined, 'Cài đặt hệ thống', 4),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 20, 20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.primary.withOpacity(0.08)),
                ),
                child: _selectedIndex == 1 ? _buildPendingTherapistsView() : const AdminQuestsScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final selected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: selected ? Colors.white.withOpacity(0.16) : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        onTap: () => setState(() => _selectedIndex = index),
      ),
    );
  }

  Widget _buildPendingTherapistsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildSummaryCard(
              icon: Icons.pending_actions_outlined,
              title: 'Hồ sơ chờ duyệt',
              value: '${_pendingTherapists.length}',
              tint: AppColors.warning,
            ),
            _buildSummaryCard(
              icon: Icons.verified_outlined,
              title: 'Mục tiêu',
              value: 'Kiểm duyệt nhanh',
              tint: AppColors.primary,
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Duyệt hồ sơ chuyên gia',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        Text(
          'Hiện có ${_pendingTherapists.length} hồ sơ đang chờ kiểm duyệt.',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
        ),
        const SizedBox(height: 24),
        if (_pendingTherapists.isEmpty)
          const Expanded(
            child: Center(
              child: Text(
                'Không có hồ sơ nào đang chờ duyệt.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 18),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              itemCount: _pendingTherapists.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final therapist = _pendingTherapists[index];
                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.primary.withOpacity(0.08)),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 26,
                        backgroundColor: Color(0xFFFFF1D9),
                        child: Icon(Icons.hourglass_empty, color: AppColors.warning),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${therapist['title']} ${therapist['name']}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${therapist['specialty']} • ${therapist['hospital']}',
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Ngày tạo: ${therapist['date']}',
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.visibility_outlined, size: 18),
                        label: const Text('Xem hồ sơ'),
                        onPressed: () => _reviewApplication(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color tint,
  }) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: tint.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: tint),
          ),
          const SizedBox(height: 14),
          Text(title, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }
}
