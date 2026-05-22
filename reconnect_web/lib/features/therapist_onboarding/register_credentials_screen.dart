import 'package:flutter/material.dart';

class RegisterCredentialsScreen extends StatelessWidget {
  const RegisterCredentialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Khai báo Chuyên môn')),
      body: const Center(
        child: Text('Module 6: Nhập thông tin, Upload chứng chỉ y khoa'),
      ),
    );
  }
}
