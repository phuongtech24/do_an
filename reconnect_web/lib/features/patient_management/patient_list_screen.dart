import 'package:flutter/material.dart';

class PatientListScreen extends StatelessWidget {
  const PatientListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách Bệnh nhân')),
      body: const Center(
        child: Text('Module 7: Quản lý bệnh nhân ẩn danh (Nickname, Avatar)'),
      ),
    );
  }
}
