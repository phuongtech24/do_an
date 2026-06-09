import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/mindhealth_scaffold.dart';
import '../../../../theme/app_colors.dart';

class LsasLightTipsScreen extends StatelessWidget {
  const LsasLightTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MindHealthScaffold(
      title: 'Mẹo chăm sóc tinh thần',
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF159489)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.favorite_border_rounded, color: Colors.white, size: 30),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Bạn đang ở mức nhẹ và có thể tự chăm sóc tốt',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  'Ở mức hiện tại, bạn chưa cần đi vào lộ trình trị liệu chuyên sâu. App sẽ gợi ý các mẹo đơn giản để giúp bạn hiểu cảm xúc, thư giãn và giữ nhịp sinh hoạt ổn định.',
                  style: TextStyle(color: Colors.white, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _TipsSection(
            icon: Icons.menu_book_rounded,
            title: '1. An tâm và hiểu rõ cảm xúc',
            items: [
              'Những lo âu bạn đang gặp có thể là phản ứng bình thường trước áp lực xã hội hoặc công việc.',
              'Bạn chưa ở mức cần trị liệu chuyên sâu; mục tiêu lúc này là hiểu mình hơn và tự chăm sóc đều đặn.',
              'Ưu tiên đọc các bài viết ngắn, sổ tay hoặc nội dung giáo dục tâm lý giúp bạn hiểu cảm xúc và cách trấn an bản thân.',
            ],
          ),
          const SizedBox(height: 14),
          const _TipsSection(
            icon: Icons.spa_outlined,
            title: '2. Phút giây chánh niệm và thư giãn',
            items: [
              'Thực hành hít thở chậm 3–5 phút để làm dịu nhịp tim khi thấy căng thẳng.',
              'Dùng kỹ thuật nối đất như nhìn 5 vật xung quanh, nghe 4 âm thanh, cảm nhận 3 bề mặt để kéo tâm trí về hiện tại.',
              'Nghe thiền ngắn, thư giãn cơ bắp hoặc tưởng tượng một khung cảnh bình yên trước khi ngủ hoặc trước tình huống áp lực.',
            ],
          ),
          const SizedBox(height: 14),
          const _TipsSection(
            icon: Icons.psychology_alt_outlined,
            title: '3. Mẹo tự quan sát suy nghĩ',
            items: [
              'Nếu thấy một suy nghĩ tiêu cực lặp lại, hãy ghi ra giấy để nhìn nó rõ hơn thay vì giữ trong đầu.',
              'Bạn có thể tự nhắc: “Mình đang lo điều gì?”, “Điều này có chắc chắn xảy ra không?”, “Có cách nhìn cân bằng hơn không?”.',
              'Nếu có vài tình huống làm bạn ngại, hãy nghĩ theo thứ tự từ dễ đến khó để đối diện dần, không cần ép mình làm ngay tất cả.',
            ],
          ),
          const SizedBox(height: 14),
          const _TipsSection(
            icon: Icons.event_available_outlined,
            title: '4. Lập lịch hoạt động mỗi ngày',
            items: [
              'Mỗi ngày chọn ít nhất 1 việc mang lại niềm vui nhỏ và 1 việc tạo cảm giác hoàn thành.',
              'Những việc rất nhỏ như đi bộ, dọn góc bàn, nhắn tin cho bạn bè hoặc ra ngoài mua đồ cũng có giá trị.',
              'Giữ cơ thể hoạt động và kết nối với người khác giúp giảm vòng lặp lo âu và tránh tự cô lập mình.',
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primary.withOpacity(0.12)),
            ),
            child: const Text(
              'Bạn không cần làm hết mọi thứ cùng lúc. Chỉ cần chọn 1 mẹo nhỏ phù hợp nhất với hôm nay và thử thực hiện thật nhẹ nhàng.',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            child: const Text('Đã hiểu, về trang chủ', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.go('/home'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: AppColors.primary.withOpacity(0.4)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            child: const Text('Xem lại sau'),
          ),
        ],
      ),
    );
  }
}

class _TipsSection extends StatelessWidget {
  const _TipsSection({
    required this.icon,
    required this.title,
    required this.items,
  });

  final IconData icon;
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(Icons.circle, size: 8, color: AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
