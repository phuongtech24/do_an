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
  int _selectedIndex = 1; // Default to 'Duyệt Chuyên Gia'
  
  // Mock danh sách Bác sĩ chờ duyệt
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
        title: const Text('Kiểm duyệt Bằng cấp'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Đang xem xét hồ sơ của: ${_pendingTherapists[index]['title']} ${_pendingTherapists[index]['name']}'),
            const SizedBox(height: 16),
            Container(
              height: 200,
              width: 300,
              color: Colors.grey[200],
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('[Ảnh Demo Chứng chỉ Hành nghề]'),
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
                const SnackBar(content: Text('Đã TỪ CHỐI hồ sơ.'), backgroundColor: AppColors.alert),
              );
            },
            child: const Text('Từ Chối', style: TextStyle(color: AppColors.alert)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _pendingTherapists.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã DUYỆT hồ sơ thành công! Bác sĩ đã được public.'), backgroundColor: AppColors.success),
              );
            },
            child: const Text('Phê Duyệt (APPROVED)', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Re-Connect Admin Portal', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black87,
        actions: [
          const Center(child: Text('Xin chào, System Admin', style: TextStyle(fontWeight: FontWeight.bold))),
          const SizedBox(width: 24),
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
            width: 250,
            color: Colors.black87,
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.dashboard, color: Colors.white70),
                  title: const Text('Tổng quan', style: TextStyle(color: Colors.white70)),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.verified_user, color: Colors.white),
                  title: const Text('Duyệt Chuyên Gia', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  tileColor: _selectedIndex == 1 ? Colors.white12 : null,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.flag_rounded, color: Colors.white),
                  title: const Text('Quản lý Nhiệm vụ CBT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  tileColor: _selectedIndex == 2 ? Colors.white12 : null,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 2;
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.report_problem, color: Colors.white70),
                  title: const Text('Báo cáo vi phạm', style: TextStyle(color: Colors.white70)),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.white70),
                  title: const Text('Cài đặt hệ thống', style: TextStyle(color: Colors.white70)),
                  onTap: () {},
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: _selectedIndex == 1 ? _buildPendingTherapistsView() : const AdminQuestsScreen(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingTherapistsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Duyệt Hồ Sơ Chuyên Gia (Pending Approvals)', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
                  Text('Hiện có ${_pendingTherapists.length} hồ sơ đang chờ kiểm duyệt.', style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                  const SizedBox(height: 24),
                  
                  if (_pendingTherapists.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text('Không có hồ sơ nào đang chờ duyệt 🎉', style: TextStyle(color: Colors.grey, fontSize: 18)),
                      ),
                    )
                  else
                    Expanded(
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        child: ListView.separated(
                          itemCount: _pendingTherapists.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final therapist = _pendingTherapists[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              leading: const CircleAvatar(
                                backgroundColor: AppColors.warning,
                                child: Icon(Icons.hourglass_empty, color: Colors.white),
                              ),
                              title: Text('${therapist['title']} ${therapist['name']}'),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text('${therapist['specialty']} • ${therapist['hospital']}\nNgày tạo: ${therapist['date']}'),
                              ),
                              trailing: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                                icon: const Icon(Icons.visibility, size: 18),
                                label: const Text('Xem Hồ Sơ'),
                                onPressed: () => _reviewApplication(index),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
    );
  }
}
