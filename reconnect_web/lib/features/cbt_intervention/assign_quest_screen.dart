import 'package:flutter/material.dart';

class AssignQuestScreen extends StatelessWidget {
  const AssignQuestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Gán Nhiệm vụ (CBT Intervention)', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Row(
        children: [
          // CỘT 1: Thư viện Thử thách (Nguồn kéo)
          Container(
            width: 350,
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Thư viện Thử thách CBT', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm nhiệm vụ...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      _buildDraggableQuestCard('10 phút đi bộ', 'Khuyến khích vận động ngoài trời', 'Dễ', Colors.green),
                      _buildDraggableQuestCard('Thiền chánh niệm', '5 phút nhắm mắt và thở sâu', 'Dễ', Colors.green),
                      _buildDraggableQuestCard('Ghi lời biết ơn', 'Viết ra 3 điều biết ơn hôm nay', 'Trung bình', Colors.orange),
                      _buildDraggableQuestCard('Thử nghiệm xã hội', chủ đề bắt chuyện với 1 người lạ', 'Khó', Colors.red),
                    ],
                  ),
                )
              ],
            ),
          ),
          
          const VerticalDivider(width: 1, color: Colors.black12),
          
          // CỘT 2: Bản đồ Lộ trình (Đích thả)
          Expanded(
            child: Container(
              color: Colors.blueGrey.shade50,
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Roadmap: Bệnh nhân [Cáo Bạc]', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.save),
                        label: const Text('Lưu Lộ trình'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                      )
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Vùng thả
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDragTargetMilestone('Chặng 1: Ổn định', [
                           // Các nhiệm vụ đã được thả vào đây
                           _buildAssignedQuestBlock('10 phút đi bộ'),
                        ]),
                        const SizedBox(width: 40),
                        _buildDragTargetMilestone('Chặng 2: Can thiệp', []),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDraggableQuestCard(String title, String desc, String level, Color levelColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      // Sử dụng Draggable của Flutter
      child: Draggable<String>(
        data: title,
        feedback: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(16),
            width: 310,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: _questCardContent(title, desc, level, levelColor),
        ),
        child: _questCardContent(title, desc, level, levelColor),
      ),
    );
  }
  
  Widget _questCardContent(String title, String desc, String level, Color levelColor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: levelColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(level, style: TextStyle(color: levelColor, fontSize: 12, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(desc, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildDragTargetMilestone(String title, List<Widget> existingChildren) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.teal.shade700,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
              ),
              child: Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            Expanded(
              child: DragTarget<String>(
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    color: candidateData.isNotEmpty ? Colors.teal.shade50 : Colors.transparent,
                    child: Column(
                      children: [
                        ...existingChildren,
                        if (candidateData.isNotEmpty)
                          Container(
                            height: 60,
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              border: Border.all(color: Colors.teal, style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(8)
                            ),
                            child: const Center(child: Text('Thả nhiệm vụ vào đây', style: TextStyle(color: Colors.teal))),
                          )
                      ],
                    ),
                  );
                },
                onAccept: (data) {
                  // TODO: Xử lý thêm nhiệm vụ vào List của Cột này
                },
              ),
            )
          ],
        ),
      ),
    );
  }
  
  Widget _buildAssignedQuestBlock(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.drag_indicator, color: Colors.blueGrey),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          IconButton(icon: const Icon(Icons.close, size: 20, color: Colors.red), onPressed: () {}),
        ],
      ),
    );
  }
}
