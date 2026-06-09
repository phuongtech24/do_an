import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> _openMeetingLink(AppointmentModel appointment) async {
    final link = appointment.meetingLink;
    if (link == null || link.isEmpty) return;

    final uri = Uri.tryParse(link);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (opened) return;
    }

    await Clipboard.setData(ClipboardData(text: link));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Không mở được link tự động. Hệ thống đã copy link phòng tư vấn để bạn dán vào trình duyệt.')),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'COMPLETED':
        return 'Đã hoàn thành';
      case 'CANCELLED':
        return 'Đã hủy';
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
      default:
        return AppColors.primary;
    }
  }

  String _purposeLabel(AppointmentModel appointment) {
    final code = appointment.clinicalPurposeCode ?? appointment.purpose;
    switch (code) {
      case 'INITIAL_ASSESSMENT':
        return 'Phiên đánh giá ban đầu';
      case 'BEHAVIORAL_EXPERIMENT':
        return 'Thử nghiệm hành vi';
      case 'BOOSTER_3M':
        return 'Booster 3 tháng';
      case 'BOOSTER_6M':
        return 'Booster 6 tháng';
      case 'BOOSTER_12M':
        return 'Booster 12 tháng';
      case 'CRISIS':
        return 'Phiên hỗ trợ khẩn cấp';
      case 'INTENSIVE_EXPOSURE':
        return 'Can thiệp cường độ cao';
      default:
        return 'Phiên CBT';
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
            return Center(
              child: Text(
                'Lỗi: ${telehealth.errorMessage}',
                style: const TextStyle(color: AppColors.alert),
              ),
            );
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
                  purposeLabel: _purposeLabel(appointment),
                  statusColor: _statusColor(appointment.status),
                  onOpenMeetingLink: () => _openMeetingLink(appointment),
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
  const _AppointmentCard({
    required this.appointment,
    required this.statusLabel,
    required this.purposeLabel,
    required this.statusColor,
    required this.onOpenMeetingLink,
  });

  final AppointmentModel appointment;
  final String statusLabel;
  final String purposeLabel;
  final Color statusColor;
  final VoidCallback onOpenMeetingLink;

  @override
  Widget build(BuildContext context) {
    final startText = DateFormat('dd/MM/yyyy HH:mm').format(appointment.startAt);
    final endText = DateFormat('HH:mm').format(appointment.endAt);
    final therapistName = appointment.therapistDisplayName ?? 'Chuyên gia phụ trách';
    final hasMeetingLink = appointment.meetingLink != null && appointment.meetingLink!.isNotEmpty;
    final canJoin = hasMeetingLink && appointment.status == 'BOOKED';

    return Card(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
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
                      Text(
                        startText,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Kết thúc $endText • $therapistName',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Tag(
                  label: purposeLabel,
                  color: AppColors.primary,
                  background: AppColors.primary.withOpacity(0.1),
                ),
                if (appointment.carePhaseCode != null && appointment.carePhaseCode!.isNotEmpty)
                  _Tag(
                    label: _carePhaseLabel(appointment.carePhaseCode!),
                    color: AppColors.textPrimary,
                    background: const Color(0xFFF2FBFA),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              appointment.status == 'BOOKED'
                  ? 'Đến giờ hẹn, bấm vào phòng tư vấn để mở link họp của chuyên gia.'
                  : appointment.status == 'COMPLETED'
                      ? 'Buổi tư vấn đã hoàn thành.'
                      : 'Lịch hẹn đã bị hủy.',
              style: const TextStyle(color: AppColors.textSecondary, height: 1.45),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: canJoin ? onOpenMeetingLink : null,
                icon: const Icon(Icons.meeting_room_outlined),
                label: const Text('Vào phòng tư vấn'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _carePhaseLabel(String code) {
    switch (code) {
      case 'MAINTENANCE':
        return 'Duy trì';
      case 'TAPERING_BIWEEKLY':
        return 'Giãn cách 2 tuần / lần';
      case 'TAPERING_3_TO_4_WEEKS':
        return 'Giãn cách 3-4 tuần / lần';
      case 'RED_FLAG_OVERRIDE':
        return 'Ưu tiên an toàn';
      default:
        return 'Điều trị tiêu chuẩn';
    }
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
