import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import 'ai_journal_screen.dart';
import 'assessment_test_screen.dart';
import 'profile_screen.dart';
import 'quest_list_screen.dart';
import 'therapist_booking_screen.dart';
import 'therapist_chat_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _streak = 7; // Mock streak data

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Re-Connect'),
        actions: [
          IconButton(
            icon: const Badge(
              label: Text('1'),
              child: Icon(Icons.chat_bubble_outline, size: 26),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TherapistChatScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle, size: 28),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Virtual Tree / Pet Area
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.park_rounded, // Placeholder for Lottie tree
                      size: 150,
                      color: AppColors.success,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Năng lượng: $_streak ☀️',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Assessment Test Banner
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AssessmentTestScreen(testType: 'PHQ-9')));
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.assignment_rounded, color: AppColors.primary, size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Kiểm tra sức khỏe tinh thần', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                            SizedBox(height: 4),
                            Text('Làm bài test định kỳ ngắn để Chuyên gia theo dõi tiến độ của bạn nhé!', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              const Text(
                'Hôm nay cậu muốn làm gì?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildFeatureCard(
                title: 'Nhật ký AI thấu cảm',
                subtitle: 'Trò chuyện và xả stress với AI',
                icon: Icons.auto_awesome,
                color: const Color(0xFFF3E8FF), // Soft Purple
                iconColor: const Color(0xFFA855F7),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AiJournalScreen()));
                },
              ),
              const SizedBox(height: 16),
              
              _buildFeatureCard(
                title: 'Danh sách Thử thách (CBT)',
                subtitle: 'Các nhiệm vụ từ Bác sĩ',
                icon: Icons.checklist_rounded,
                color: const Color(0xFFE0F2FE), // Soft Blue
                iconColor: const Color(0xFF38BDF8),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const QuestListScreen()));
                },
              ),
              const SizedBox(height: 16),
              
              _buildFeatureCard(
                title: 'Chuyên gia Tâm lý',
                subtitle: 'Đặt lịch Khám trực tuyến',
                icon: Icons.personal_video_rounded,
                color: const Color(0xFFFEF08A).withValues(alpha: 0.4), // Soft Yellow
                iconColor: const Color(0xFFEAB308),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const TherapistBookingScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textPrimary.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}
