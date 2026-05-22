import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';

class TherapistBookingScreen extends StatefulWidget {
  const TherapistBookingScreen({super.key});

  @override
  State<TherapistBookingScreen> createState() => _TherapistBookingScreenState();
}

class _TherapistBookingScreenState extends State<TherapistBookingScreen> {
  // Mock data cho danh sách bác sĩ
  final List<Map<String, dynamic>> _therapists = [
    {
      'name': 'ThS. BS. Nguyễn Văn A',
      'specialty': 'Chuyên khoa Rối loạn lo âu, Trầm cảm',
      'rating': 4.9,
      'reviews': 128,
      'slots': ['14:00 - Hôm nay', '15:30 - Ngày mai'],
      'avatarUrl': 'https://i.pravatar.cc/150?img=11', // Placeholder avatar
    },
    {
      'name': 'PGS. TS. Trần Thị B',
      'specialty': 'Trị liệu nhận thức hành vi (CBT)',
      'rating': 5.0,
      'reviews': 342,
      'slots': ['09:00 - Thứ 4', '10:00 - Thứ 5'],
      'avatarUrl': 'https://i.pravatar.cc/150?img=5',
    },
  ];

  void _showBookingDialog(BuildContext context, String therapistName) {
    bool shareIdentity = false;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text(
                'Quyền Riêng Tư',
                style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bạn đang đặt lịch với $therapistName.',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Mặc định, bạn sẽ tham vấn dưới chế độ Ẩn danh (Nickname).',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: shareIdentity ? AppColors.success.withValues(alpha: 0.1) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: shareIdentity ? AppColors.success : Colors.grey[300]!),
                    ),
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Tôi đồng ý chia sẻ Tên thật và SĐT với chuyên gia để được hỗ trợ tốt nhất.',
                        style: TextStyle(fontSize: 14),
                      ),
                      value: shareIdentity,
                      activeColor: AppColors.success,
                      onChanged: (bool value) {
                        setState(() {
                          shareIdentity = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Hủy', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          shareIdentity 
                              ? 'Đã đặt lịch CÔNG KHAI thành công!' 
                              : 'Đã đặt lịch ẨN DANH thành công!',
                        ),
                        backgroundColor: shareIdentity ? AppColors.success : AppColors.secondary,
                      ),
                    );
                  },
                  child: Text(shareIdentity ? 'Đặt Lịch (Công Khai)' : 'Đặt Lịch (Ẩn Danh)', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chuyên gia Tâm lý'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _therapists.length,
        itemBuilder: (context, index) {
          final therapist = _therapists[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundImage: NetworkImage(therapist['avatarUrl']),
                        backgroundColor: AppColors.background,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              therapist['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              therapist['specialty'],
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  '${therapist['rating']} (${therapist['reviews']} đánh giá)',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text('Lịch hẹn trống:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (therapist['slots'] as List<String>).map((slot) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary),
                        ),
                        child: Text(
                          slot,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Đặt lịch 30 phút',
                      onPressed: () => _showBookingDialog(context, therapist['name']),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
