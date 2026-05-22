import 'package:flutter/material.dart';

class ApprovalQueueScreen extends StatelessWidget {
  const ApprovalQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hàng đợi Kiểm duyệt')),
      body: const Center(
        child: Text('Module 10: Admin duyệt Bác sĩ, Khám xét chứng chỉ'),
      ),
    );
  }
}
