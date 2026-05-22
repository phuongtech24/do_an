import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class InterventionDetailScreen extends StatelessWidget {
  final String patientName;
  const InterventionDetailScreen({super.key, required this.patientName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Hồ sơ điều trị: $patientName'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Chart and Progress
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Biến động Cảm xúc AI (30 ngày)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    height: 300,
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Center(child: Text('[Biểu đồ Line Chart hiển thị tại đây - Dữ liệu thực tế sẽ được vẽ bằng fl_chart]', style: TextStyle(color: AppColors.textSecondary))),
                  ),
                  
                  const SizedBox(height: 32),
                  const Text('Tiến độ Roadmap', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                     padding: const EdgeInsets.all(24),
                     decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                     ),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         const Text('Đang ở Trạm 4: 45%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                         const SizedBox(height: 8),
                         LinearProgressIndicator(value: 0.45, minHeight: 10, borderRadius: BorderRadius.circular(5), backgroundColor: Colors.grey.shade200, color: AppColors.primary),
                       ],
                     ),
                  )
                ],
              ),
            ),
          ),
          
          // Right: Intervention Tools (Side Quests / Booster)
          Container(
            width: 400,
            color: Colors.white,
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Công cụ Can Thiệp', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                const Divider(height: 32),
                
                const Text('Giao Side Quest', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                const Text('Chèn thêm thử thách vào lộ trình hiện tại của bệnh nhân.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Nhập tên nhiệm vụ (VD: Tập thở 5 phút)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã gán Side Quest thành công!')));
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('GÁN NHIỆM VỤ'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: Colors.white),
                  ),
                ),
                
                const SizedBox(height: 48),
                
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.alert.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.alert),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.alert, size: 48),
                      const SizedBox(height: 16),
                      const Text('KÍCH HOẠT BOOSTER COURSE', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.alert)),
                      const SizedBox(height: 8),
                      const Text('Dành cho bệnh nhân tái phát hoặc có nguy cơ cao. Xóa roadmap cũ và tạo lộ trình 14 ngày khẩn cấp.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã chuyển bệnh nhân sang chế độ Booster!')));
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.alert, foregroundColor: Colors.white),
                        child: const Text('KÍCH HOẠT NGAY'),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
