import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../theme/app_colors.dart';
import '../auth/presentation/providers/auth_provider.dart';
import 'data/models/appointment_model.dart';
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

  Future<void> _copyMeetingLink(AppointmentModel appointment) async {
    final link = appointment.meetingLink;
    if (link == null || link.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: link));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã copy link phòng tư vấn. Mở link này trên trình duyệt để vào buổi hẹn.')),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'COMPLETED':
        return 'Đã hoàn thành';
      case 'CANCELLED':
        return 'Đã hủy';
      case 'BOOKED':
      default:
        return 'Đã đặt';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'COMPLETED':
        return AppColors.success;
      case 'CANCELLED':
        return AppColors.alert;
      case 'BOOKED':
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Lịch hẹn của tôi')),
      body: Consumer<TelehealthProvider>(
        builder: (context, telehealth, _) {
          if (telehealth.status == TelehealthStatus.loading && telehealth.myAppointments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (telehealth.status == TelehealthStatus.error && telehealth.myAppointments.isEmpty) {
            return Center(child: Text('Lỗi: ${telehealth.errorMessage}', style: const TextStyle(color: AppColors.alert)));
          }
          if (telehealth.myAppointments.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Bạn chưa có lịch hẹn nào.', textAlign: TextAlign.center),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              final patientId = auth.loginResponse?.user.id ?? '';
              final token = auth.loginResponse?.token;
              if (patientId.isNotEmpty) {
                await telehealth.loadMyAppointments(patientId, token: token);
              }
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: telehealth.myAppointments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final appointment = telehealth.myAppointments[index];
                return _AppointmentCard(
                  appointment: appointment,
                  statusLabel: _statusLabel(appointment.status),
                  statusColor: _statusColor(appointment.status),
                  onCopyMeetingLink: () => _copyMeetingLink(appointment),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final String statusLabel;
  final Color statusColor;
  final VoidCallback onCopyMeetingLink;

  const _AppointmentCard({
    required this.appointment,
    required this.statusLabel,
    required this.statusColor,
    required this.onCopyMeetingLink,
  });

  @override
  Widget build(BuildContext context) {
    final startText = DateFormat('dd/MM/yyyy HH:mm').format(appointment.startAt);
    final endText = DateFormat('HH:mm').format(appointment.endAt);
    final therapistName = appointment.therapistDisplayName ?? 'Bác sĩ phụ trách';
    final hasMeetingLink = appointment.meetingLink != null && appointment.meetingLink!.isNotEmpty;
    final canJoin = hasMeetingLink && appointment.status == 'BOOKED';

    return Card(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.textSecondary.withOpacity(0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.14),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.video_call_outlined, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(startText, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text('Kết thúc $endText • $therapistName', style: const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(statusLabel, style: TextStyle(color: statusColor, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              appointment.status == 'BOOKED'
                  ? 'Đến giờ hẹn, bấm vào phòng tư vấn để mở link Meet của bác sĩ.'
                  : appointment.status == 'COMPLETED'
                      ? 'Buổi tư vấn đã hoàn thành.'
                      : 'Lịch hẹn đã bị hủy.',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: canJoin ? onCopyMeetingLink : null,
                icon: const Icon(Icons.meeting_room_outlined),
                label: const Text('Vào phòng tư vấn'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

