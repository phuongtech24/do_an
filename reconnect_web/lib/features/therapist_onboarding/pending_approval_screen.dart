import 'package:flutter/material.dart';

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ đang chờ duyệt')),
      body: const Center(
        child: Text('Module 6: Trạng thái chờ Admin cấp phép (Pending State)'),
      ),
    );
  }
}
