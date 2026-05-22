import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class TherapistAppointmentsScreen extends StatefulWidget {
  const TherapistAppointmentsScreen({super.key});

  @override
  State<TherapistAppointmentsScreen> createState() => _TherapistAppointmentsScreenState();
}

class _TherapistAppointmentsScreenState extends State<TherapistAppointmentsScreen> {
  // Mock Data for Appointments
  final List<Map<String, dynamic>> _appointments = [
    {
      'date': 'Hôm nay, 24/10',
      'time': '14:00 - 14:30',
      'name': 'Mây Trắng',
      'isAnonymous': true,
      'status': 'Upcoming',
      'type': 'Video Call'
    },
    {
      'date': 'Hôm nay, 24/10',
      'time': '15:30 - 16:00',
      'name': 'Hoàng Văn Cường',
      'isAnonymous': false,
      'status': 'Pending',
      'type': 'Voice Call'
    },
    {
      'date': 'Ngày mai, 25/10',
      'time': '09:00 - 09:45',
      'name': 'User_202',
      'isAnonymous': true,
      'status': 'Upcoming',
      'type': 'Video Call'
    },
    {
      'date': 'Đã kết thúc, 22/10',
      'time': '10:00 - 10:45',
      'name': 'Trần Thị B',
      'isAnonymous': false,
      'status': 'Completed',
      'type': 'Chat'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quản lý Lịch hẹn (Booster Sessions)',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Quản lý các yêu cầu phiên củng cố kỹ năng từ bệnh nhân hoặc AI gợi ý.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 24),
          const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            isScrollable: true,
            tabs: [
              Tab(text: 'Chờ xác nhận (Pending)'),
              Tab(text: 'Sắp tới (Upcoming)'),
              Tab(text: 'Đã hoàn thành (Completed)'),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              children: [
                _buildAppointmentList('Pending'),
                _buildAppointmentList('Upcoming'),
                _buildAppointmentList('Completed'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentList(String status) {
    final filteredList = _appointments.where((a) => a['status'] == status).toList();
    
    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('Không có lịch hẹn nào trong mục này.', style: TextStyle(color: Colors.grey[400])),
          ],
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: ListView.separated(
        itemCount: filteredList.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final appt = filteredList[index];
          final bool isPending = appt['status'] == 'Pending';
          
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            leading: CircleAvatar(
              backgroundColor: appt['isAnonymous'] ? AppColors.secondary.withOpacity(0.2) : AppColors.primary.withOpacity(0.2),
              child: Icon(
                appt['isAnonymous'] ? Icons.masks_rounded : Icons.person,
                color: appt['isAnonymous'] ? AppColors.secondary : AppColors.primary,
              ),
            ),
            title: Row(
              children: [
                Text(appt['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (appt['isAnonymous'])
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Tooltip(message: 'Ẩn danh', child: Icon(Icons.shield, color: AppColors.success, size: 16)),
                  ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('${appt['date']} | ${appt['time']}'),
                  const SizedBox(width: 16),
                  Icon(
                    appt['type'] == 'Video Call' ? Icons.videocam : (appt['type'] == 'Voice Call' ? Icons.call : Icons.chat),
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(appt['type']),
                ],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isPending)
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã xác nhận lịch hẹn. Link Google Meet đã được gửi tới bệnh nhân.')),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                    child: const Text('XÁC NHẬN'),
                  )
                else if (appt['status'] == 'Upcoming')
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.videocam, size: 16),
                    label: const Text('VÀO PHÒNG HỌP'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  )
                else
                  const Text('Hoàn tất', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
      ),
    );
  }
}
