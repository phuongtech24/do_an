import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:reconnect_app/shared/widgets/mindhealth_scaffold.dart';
import 'package:reconnect_app/theme/app_colors.dart';

class SafetySupportScreen extends StatelessWidget {
  const SafetySupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MindHealthScaffold(
      title: 'Hỗ trợ an toàn khẩn cấp',
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF5F5), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.alert.withOpacity(0.14)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.health_and_safety_outlined, color: AppColors.alert, size: 32),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ưu tiên an toàn của bạn lúc này',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Bạn không cần tự xử lý một mình. Nếu đang thấy không an toàn, hãy dừng phần tự trị liệu và liên hệ ngay với người có thể hỗ trợ trực tiếp cho bạn.',
                  style: TextStyle(height: 1.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                _SupportStep(
                  index: '1',
                  title: 'Liên hệ người tin cậy ngay bây giờ',
                  description: 'Hãy gọi hoặc nhắn cho người thân, bạn bè, hoặc chuyên gia mà bạn tin tưởng để họ ở cạnh bạn.',
                ),
                _SupportStep(
                  index: '2',
                  title: 'Tìm hỗ trợ chuyên môn khẩn cấp',
                  description: 'Nếu cảm giác mất an toàn tăng lên, hãy tới cơ sở y tế gần nhất hoặc dùng số hỗ trợ khẩn cấp tại khu vực của bạn.',
                ),
                _SupportStep(
                  index: '3',
                  title: 'Dùng thông tin hotline đã cấu hình',
                  description:
                      'Khu vực hotline khẩn cấp sẽ được đội triển khai cập nhật số xác minh sau. Hiện tại, vui lòng ưu tiên người thân/chuyên gia/cơ sở y tế gần nhất.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primary.withOpacity(0.08)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thông tin hỗ trợ khẩn cấp',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                SizedBox(height: 10),
                Text(
                  'Hotline khẩn cấp: sẽ cấu hình sau',
                  style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                SizedBox(height: 8),
                Text(
                  'Trong lúc chờ cấu hình chính thức, vui lòng dùng số cấp cứu/y tế tâm thần tại địa phương hoặc liên hệ người hỗ trợ trực tiếp gần bạn nhất.',
                  style: TextStyle(height: 1.45, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('Về trang chủ'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/telehealth'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.alert,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.support_agent_outlined),
                  label: const Text('Mở hỗ trợ'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SupportStep extends StatelessWidget {
  final String index;
  final String title;
  final String description;

  const _SupportStep({
    required this.index,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.alert,
              shape: BoxShape.circle,
            ),
            child: Text(
              index,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(height: 1.45, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
