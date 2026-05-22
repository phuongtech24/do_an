import 'package:flutter/material.dart';

class RiskIndexScreen extends StatelessWidget {
  const RiskIndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phân tích Risk Index'),
        centerTitle: true,
        backgroundColor: const Color(0xFFD3F3EE),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chỉ số rủi ro trong 7 ngày qua',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  )
                ],
              ),
              child: const Center(
                child: Text(
                  '(Biểu đồ dạng đường - Line Chart hiển thị Index từ 0 đến 100)',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                // In a real app with fl_chart, we would put LineChart here
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Từ khóa tiêu cực phát hiện',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildKeywordChip('áp lực', Colors.orange),
                _buildKeywordChip('mất ngủ', Colors.red),
                _buildKeywordChip('lo âu', Colors.orange),
                _buildKeywordChip('chán nản', Colors.red),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red[400], size: 32),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cảnh báo rủi ro cao',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Chỉ số rủi ro của bạn đã vượt mức cho phép trong 3 ngày liên tiếp. Trợ lý AI khuyên bạn nên yêu cầu tham vấn cùng Bác sĩ.',
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeywordChip(String label, Color color) {
    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
