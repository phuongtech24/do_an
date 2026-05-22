import 'package:flutter/material.dart';

class AppointmentManagerScreen extends StatelessWidget {
  const AppointmentManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Lịch hẹn')),
      body: const Center(
        child: Text('Module 9: Xem danh sách, Hủy ca khẩn cấp + Xin lỗi tự động'),
      ),
    );
  }
}
