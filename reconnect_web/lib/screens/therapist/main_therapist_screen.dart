import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'patient_detail_screen.dart';
import 'therapist_appointments_screen.dart';
import 'therapist_profile_screen.dart';

class MainTherapistScreen extends StatefulWidget {
  const MainTherapistScreen({super.key});

  @override
  State<MainTherapistScreen> createState() => _MainTherapistScreenState();
}

class _MainTherapistScreenState extends State<MainTherapistScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Sidebar Menu
          Container(
            width: 250,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                const Icon(Icons.spa, size: 48, color: AppColors.primary),
                const SizedBox(height: 8),
                const Text('Hi, Lê Anh Thư', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Divider(height: 48),
                ListTile(
                  leading: const Icon(Icons.psychology),
                  title: const Text('Bảng điều khiển Trị liệu'),
                  selected: _selectedIndex == 0,
                  iconColor: _selectedIndex == 0 ? AppColors.primary : AppColors.textSecondary,
                  textColor: _selectedIndex == 0 ? AppColors.primary : AppColors.textPrimary,
                  onTap: () => setState(() => _selectedIndex = 0),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: const Text('Lịch hẹn & Tham vấn'),
                  selected: _selectedIndex == 1,
                  iconColor: _selectedIndex == 1 ? AppColors.primary : AppColors.textSecondary,
                  textColor: _selectedIndex == 1 ? AppColors.primary : AppColors.textPrimary,
                  onTap: () => setState(() => _selectedIndex = 1),
                ),
                ListTile(
                  leading: const Icon(Icons.account_circle_outlined),
                  title: const Text('Hồ sơ Chuyên gia'),
                  selected: _selectedIndex == 2,
                  iconColor: _selectedIndex == 2 ? AppColors.primary : AppColors.textSecondary,
                  textColor: _selectedIndex == 2 ? AppColors.primary : AppColors.textPrimary,
                  onTap: () => setState(() => _selectedIndex = 2),
                ),
                const Spacer(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.grey),
                  title: const Text('Đăng xuất'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          // Main Content
          Expanded(
            child: _selectedIndex == 0 
              ? const Padding(padding: EdgeInsets.all(40.0), child: PatientDashboard()) 
              : _selectedIndex == 1 
                  ? const Padding(padding: EdgeInsets.all(40.0), child: TherapistAppointmentsScreen())
                  : const TherapistProfileScreen(),
          ),
        ],
      ),
    );
  }
}

class PatientDashboard extends StatelessWidget {
  const PatientDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final patients = [
      {'name': 'Cáo Nhỏ', 'status': 'ACTIVE', 'score': 45},
      {'name': 'Gấu Trắng', 'status': 'RED ALERT', 'score': 85}, // Danger
      {'name': 'Mèo Lười', 'status': 'GRADUATED', 'score': 12},
    ];

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bảng Giám sát Bệnh nhân (CBT Dashboard)', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text('Theo dõi Lỗi tư duy và Chỉ số tâm trạng được tổng hợp tự động bởi AI Gemini.', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 32),
          
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                ],
              ),
              child: ListView.separated(
                itemCount: patients.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final p = patients[index];
                  final isRedAlert = p['status'] == 'RED ALERT';
                  
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    leading: CircleAvatar(
                      backgroundColor: isRedAlert ? AppColors.alert.withOpacity(0.2) : AppColors.primary.withOpacity(0.2),
                      child: Text(p['name'].toString().substring(0, 1), style: TextStyle(color: isRedAlert ? AppColors.alert : AppColors.primary, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(p['name'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isRedAlert ? AppColors.alert : (p['status'] == 'GRADUATED' ? Colors.grey : AppColors.success),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(p['status'].toString(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 16),
                          Text('Mood Index: ${p['score']}/100', style: TextStyle(color: isRedAlert ? AppColors.alert : AppColors.textSecondary, fontWeight: isRedAlert ? FontWeight.bold : FontWeight.normal)),
                          const SizedBox(width: 16),
                          if (isRedAlert) const Icon(Icons.psychology_alt, color: AppColors.alert, size: 16),
                        ],
                      ),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                         Navigator.push(context, MaterialPageRoute(builder: (context) => PatientDetailScreen(
                           patient: {
                             'name': p['name'],
                             'status': p['status'],
                             'isAnonymous': p['name'] == 'Cáo Nhỏ' || p['name'] == 'Gấu Trắng',
                             'color': isRedAlert ? Colors.red : Colors.blue,
                             'avatar': p['name'] == 'Cáo Nhỏ' ? Icons.pets : Icons.person,
                           }
                         )));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRedAlert ? AppColors.alert : AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('XEM CHI TIẾT & CAN THIỆP'),
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
