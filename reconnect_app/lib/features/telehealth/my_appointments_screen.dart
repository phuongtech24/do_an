import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../auth/presentation/providers/auth_provider.dart';
import 'presentation/providers/telehealth_provider.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final patientId = auth.loginResponse?.user.id ?? '';
    final token = auth.loginResponse?.token;
    if (patientId.isNotEmpty) {
      Provider.of<TelehealthProvider>(context, listen: false).loadMyAppointments(patientId, token: token);
    }
    _loaded = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cuộc hẹn của tôi')),
      body: Consumer<TelehealthProvider>(
        builder: (context, telehealth, _) {
          if (telehealth.status == TelehealthStatus.loading && telehealth.myAppointments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (telehealth.status == TelehealthStatus.error && telehealth.myAppointments.isEmpty) {
            return Center(child: Text('Lỗi: ${telehealth.errorMessage}'));
          }
          if (telehealth.myAppointments.isEmpty) {
            return const Center(child: Text('Bạn chưa có lịch hẹn nào.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: telehealth.myAppointments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final a = telehealth.myAppointments[index];
              final timeText = DateFormat('dd/MM/yyyy HH:mm').format(a.startAt);
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.video_call_outlined),
                  title: Text(timeText),
                  subtitle: Text('Trạng thái: ${a.status} • Ẩn danh: ${a.isAnonymous ? "BẬT" : "TẮT"}'),
                  trailing: a.meetingLink == null || a.meetingLink!.isEmpty
                      ? null
                      : const Icon(Icons.link),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

