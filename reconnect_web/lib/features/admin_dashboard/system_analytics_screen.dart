import 'package:flutter/material.dart';

class SystemAnalyticsScreen extends StatelessWidget {
  const SystemAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tổng quan Hệ thống')),
      body: const Center(
        child: Text('Module 10: Biểu đồ người dùng, Bác sĩ, Tổng số ca tham vấn'),
      ),
    );
  }
}
