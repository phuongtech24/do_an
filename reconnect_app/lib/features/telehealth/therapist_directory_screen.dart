import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';

class TherapistDirectoryScreen extends StatelessWidget {
  const TherapistDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Therapist List
    final List<Map<String, dynamic>> therapists = [
      {
        'id': 1,
        'name': 'ThS. Tâm lý Lê Anh Thư',
        'specialty': 'Chuyên gia CBT - Rối loạn lo âu',
        'experience': '8 năm',
        'rating': 4.9,
        'reviews': 120,
        'image': 'https://i.pravatar.cc/150?img=32',
      },
      {
        'id': 2,
        'name': 'BS. Trần Phúc Lộc',
        'specialty': 'Trầm cảm, Sang chấn tâm lý',
        'experience': '12 năm',
        'rating': 4.8,
        'reviews': 85,
        'image': 'https://i.pravatar.cc/150?img=11',
      },
      {
        'id': 3,
        'name': 'Chuyên gia Nguyễn Linh',
        'specialty': 'Giải quyết xung đột gia đình',
        'experience': '5 năm',
        'rating': 5.0,
        'reviews': 42,
        'image': 'https://i.pravatar.cc/150?img=5',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Khoa Trị Liệu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Lịch sử đặt khám',
            onPressed: () => context.push('/telehealth/my-appointments'),
          )
        ],
      ),
      body: Column(
        children: [
          // Filter / Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primary,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm Bác sĩ / Vấn đề...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: therapists.length,
              itemBuilder: (context, index) {
                final doctor = therapists[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  color: Colors.white,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      context.push('/telehealth/booking');
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundImage: NetworkImage(doctor['image']),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doctor['name'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  doctor['specialty'],
                                  style: const TextStyle(color: AppColors.primary, fontSize: 13),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 16),
                                    const SizedBox(width: 4),
                                    Text('${doctor['rating']} (${doctor['reviews']} Đánh giá)', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                    const Spacer(),
                                    Text('Kinh nghiệm: ${doctor['experience']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
