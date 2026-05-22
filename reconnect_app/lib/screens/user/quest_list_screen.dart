import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'quest_camera_screen.dart';

class QuestListScreen extends StatelessWidget {
  const QuestListScreen({super.key});

  final List<Map<String, dynamic>> _quests = const [
    {
      'title': 'Uống 1 cốc nước ấm',
      'level': 1,
      'category': 'Tương tác bản thân',
      'description': 'Mở đầu ngày mới nhẹ nhàng. Chụp ảnh cốc nước để AI xác nhận.',
      'color': Color(0xFFE0F2FE), // Light Blue
      'iconColor': Color(0xFF38BDF8),
      'icon': Icons.local_drink_rounded,
    },
    {
      'title': 'Ra khỏi giường & Mở rèm',
      'level': 1,
      'category': 'Tương tác bản thân',
      'description': 'Đón ánh nắng vào phòng. Chụp ảnh bầu trời hoặc cửa sổ ngập nắng.',
      'color': Color(0xFFFEF3C7), // Light Yellow
      'iconColor': Color(0xFFF59E0B),
      'icon': Icons.wb_sunny_rounded,
    },
    {
      'title': 'Đi dạo 5 phút',
      'level': 2,
      'category': 'Tương tác môi trường',
      'description': 'Bước ra khỏi nhà làm Không khí lưu thông. Chụp ảnh một cái cây xanh.',
      'color': Color(0xFFDCFCE7), // Light Green
      'iconColor': Color(0xFF22C55E),
      'icon': Icons.park_rounded,
    },
    {
      'title': 'Mua đồ ở Cửa hàng Tiện lợi',
      'level': 3,
      'category': 'Tương tác xã hội',
      'description': 'Đi bộ ra Konbini và mua một món đồ nhỏ. Chụp ảnh biên lai hoặc lon nước.',
      'color': Color(0xFFF3E8FF), // Light Purple
      'iconColor': Color(0xFFA855F7),
      'icon': Icons.storefront_rounded,
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thử Thách Trị Liệu (CBT)'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            color: AppColors.primary.withValues(alpha: 0.1),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nhiệm vụ từ Bác sĩ 📝',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Dưới đây là các thử thách Kích hoạt Hành vi được tuỳ chỉnh riêng cho bạn. Hãy làm thử từng bước nhỏ một nhé!',
                  style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _quests.length,
              itemBuilder: (context, index) {
                final quest = _quests[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const QuestCameraScreen()));
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: quest['color'] as Color,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: (quest['color'] as Color).withValues(alpha: 0.5), width: 2),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(quest['icon'] as IconData, color: quest['iconColor'] as Color, size: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Lv.${quest['level']}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: quest['iconColor'] as Color,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        quest['category'] as String,
                                        style: TextStyle(
                                          color: AppColors.textPrimary.withValues(alpha: 0.7),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  quest['title'] as String,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  quest['description'] as String,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textPrimary.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.camera_alt_rounded, color: quest['iconColor'] as Color),
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
