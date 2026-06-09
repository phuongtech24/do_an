import 'package:flutter/material.dart';

class PatientAnalyticsScreen extends StatelessWidget {
  const PatientAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Phân tích Bệnh nhân', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Giả lập Sidebar trái của Web
          Container(
            width: 250,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                _buildSidebarItem(Icons.dashboard, 'Dashboard', isActive: false),
                _buildSidebarItem(Icons.people, 'Bệnh nhân', isActive: true),
                _buildSidebarItem(Icons.calendar_month, 'Lịch biểu', isActive: false),
              ],
            ),
          ),
          
          const VerticalDivider(width: 1, color: Colors.black12),
          
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tổng quan Hồ sơ: Cáo Bạc (Ẩn danh)',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  
                  // Khu vực Cảnh báo Đỏ (Emergency Alerts)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200, width: 2),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 40),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('CẢNH BÁO RỦI RO', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
                              SizedBox(height: 8),
                              Text('Máy học AI phát hiện bệnh nhân này liên tục duy trì trạng thái tiêu cực nghiêm trọng trong 3 ngày qua (Điểm Baseline < 15). Cần ưu tiên can thiệp sớm.', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                          icon: const Icon(Icons.chat),
                          label: const Text('Liên hệ Khẩn'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                          child: const Text('Đã xử lý (Tắt)'),
                        )
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Chia 2 cột: Biểu đồ và Thông tin Test
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cột trái: Biểu đồ
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 400,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Diễn biến Tâm lý AI (30 ngày)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              Expanded(
                                child: Center(
                                  // Giả lập chỗ đặt fl_chart
                                  child: Text('[Khu vực vẽ Line Chart bằng fl_chart]', style: TextStyle(color: Colors.grey.shade400, fontStyle: FontStyle.italic)),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 24),
                      
                      // Cột phải: Thông tin & Bài Test
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            _buildInfoCard('Giai đoạn hiện tại', 'Lộ trình CBT Cơ bản (Tuần 2)', Icons.route),
                            const SizedBox(height: 16),
                            _buildInfoCard('Bài Test Gần nhất', 'LSAS: cần re-rating', Icons.receipt_long),
                            const SizedBox(height: 16),
                            _buildInfoCard('Tỷ lệ hoàn thành nhiệm vụ', '45% (Hơi chậm)', Icons.checklist),
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, {bool isActive = false}) {
    return Container(
      color: isActive ? Colors.teal.shade50 : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: isActive ? Colors.teal : Colors.blueGrey),
        title: Text(title, style: TextStyle(color: isActive ? Colors.teal : Colors.blueGrey, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        onTap: () {},
      ),
    );
  }
  
  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.teal.shade50,
            child: Icon(icon, color: Colors.teal),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
