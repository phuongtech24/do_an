import 'package:flutter/material.dart';

class QuestLibraryScreen extends StatelessWidget {
  const QuestLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thư viện Thử thách')),
      body: const Center(
        child: Text('Module 8: Quests CBT (Dễ, Trung bình, Khó)'),
      ),
    );
  }
}
