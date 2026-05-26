import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/auth/auth_provider.dart';
import '../../features/therapist/data/models/appointment_model.dart';
import '../../features/therapist/data/models/therapist_schedule_slot_model.dart';
import '../../features/therapist/data/repositories/therapist_booster_repository.dart';
import '../../theme/app_colors.dart';

class TherapistAppointmentsScreen extends StatefulWidget {
  const TherapistAppointmentsScreen({super.key});

  @override
  State<TherapistAppointmentsScreen> createState() => _TherapistAppointmentsScreenState();
}

class _TherapistAppointmentsScreenState extends State<TherapistAppointmentsScreen> {
  final TherapistBoosterRepository _repo = TherapistBoosterRepository();

  bool _loaded = false;
  bool _loadingSchedule = false;
  bool _loadingAppointments = false;
  String? _error;

  DateTime _selectedDate = DateTime.now();
  List<TherapistScheduleSlotModel> _slots = [];
  List<AppointmentModel> _appointments = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _loadAll();
  }

  String _formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
  String _formatHumanDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

  Future<void> _loadAll() async {
    await Future.wait([_loadSchedule(), _loadAppointments()]);
  }

  Future<void> _loadSchedule() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    final therapistId = auth.userId;
    if (token == null || token.isEmpty || therapistId == null || therapistId.isEmpty) return;

    setState(() {
      _loadingSchedule = true;
      _error = null;
    });
    try {
      final list = await _repo.getSchedule(token: token, therapistId: therapistId, date: _formatDate(_selectedDate));
      if (!mounted) return;
      setState(() => _slots = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() => _loadingSchedule = false);
    }
  }

  Future<void> _loadAppointments() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    final therapistId = auth.userId;
    if (token == null || token.isEmpty || therapistId == null || therapistId.isEmpty) return;

    setState(() {
      _loadingAppointments = true;
      _error = null;
    });
    try {
      final list = await _repo.getAppointments(token: token, therapistId: therapistId);
      if (!mounted) return;
      setState(() => _appointments = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() => _loadingAppointments = false);
    }
  }

  Future<void> _toggleSlot(TherapistScheduleSlotModel slot, bool open) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    final therapistId = auth.userId;
    if (token == null || token.isEmpty || therapistId == null || therapistId.isEmpty) return;

    setState(() {
      _error = null;
      _loadingSchedule = true;
    });
    try {
      await _repo.toggleSlot(
        token: token,
        therapistId: therapistId,
        slotDate: slot.slotDate,
        startTime: slot.startTime,
        open: open,
      );
      await _loadSchedule();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() => _loadingSchedule = false);
    }
  }

  Future<void> _updateStatus(AppointmentModel appointment, String status) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    if (token == null || token.isEmpty) return;

    setState(() {
      _error = null;
      _loadingAppointments = true;
    });
    try {
      await _repo.updateAppointmentStatus(token: token, appointmentId: appointment.id, status: status);
      await _loadAppointments();
      await _loadSchedule();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() => _loadingAppointments = false);
    }
  }

  Future<void> _copyMeetingLink(AppointmentModel appointment) async {
    final link = appointment.meetingLink;
    if (link == null || link.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: link));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã copy link phòng họp. Mở link này trên trình duyệt để vào buổi hẹn.')),
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
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Lịch hẹn Telehealth', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    SizedBox(height: 6),
                    Text('Quản lý slot rảnh, lịch đã đặt và link phòng tư vấn.', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Tải lại',
                onPressed: _loadingSchedule || _loadingAppointments ? null : _loadAll,
                icon: const Icon(Icons.refresh, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_error != null && _error!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_error!, style: const TextStyle(color: AppColors.alert)),
            ),
          const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Lịch làm việc'),
              Tab(text: 'Lịch đã đặt'),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: TabBarView(
              children: [
                _buildScheduleTab(),
                _buildAppointmentsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTab() {
    return Column(
      children: [
        Row(
          children: [
            Text('Ngày ${_formatHumanDate(_selectedDate)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: _loadingSchedule
                  ? null
                  : () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked == null) return;
                      setState(() => _selectedDate = picked);
                      await _loadSchedule();
                    },
              icon: const Icon(Icons.calendar_today_outlined, size: 18),
              label: const Text('Chọn ngày'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _loadingSchedule
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  itemCount: _slots.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _ScheduleSlotCard(
                    slot: _slots[index],
                    onToggle: (open) => _toggleSlot(_slots[index], open),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildAppointmentsTab() {
    if (_loadingAppointments && _appointments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_appointments.isEmpty) {
      return Center(
        child: Text('Chưa có lịch hẹn nào.', style: TextStyle(color: Colors.grey[600])),
      );
    }

    return ListView.separated(
      itemCount: _appointments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final appointment = _appointments[index];
        return _AppointmentCard(
          appointment: appointment,
          statusLabel: _statusLabel(appointment.status),
          statusColor: _statusColor(appointment.status),
          onCopyMeetingLink: () => _copyMeetingLink(appointment),
          onComplete: () => _updateStatus(appointment, 'COMPLETED'),
          onCancel: () => _updateStatus(appointment, 'CANCELLED'),
        );
      },
    );
  }
}

class _ScheduleSlotCard extends StatelessWidget {
  final TherapistScheduleSlotModel slot;
  final ValueChanged<bool> onToggle;

  const _ScheduleSlotCard({required this.slot, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final timeLabel = slot.startTime.length >= 5 ? slot.startTime.substring(0, 5) : slot.startTime;
    final color = slot.isBooked ? AppColors.warning : (slot.isOpen ? AppColors.success : AppColors.textSecondary);
    final label = slot.isBooked ? 'Đã đặt' : (slot.isOpen ? 'Mở' : 'Đóng');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.12),
            child: Icon(slot.isBooked ? Icons.event_available : Icons.access_time, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Khung giờ $timeLabel', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                if (slot.patientNickname != null) Text('Bệnh nhân: ${slot.patientNickname}', style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
            child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Switch(value: slot.isOpen, onChanged: slot.isBooked ? null : onToggle),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final String statusLabel;
  final Color statusColor;
  final VoidCallback onCopyMeetingLink;
  final VoidCallback onComplete;
  final VoidCallback onCancel;

  const _AppointmentCard({
    required this.appointment,
    required this.statusLabel,
    required this.statusColor,
    required this.onCopyMeetingLink,
    required this.onComplete,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final when = DateFormat('dd/MM/yyyy HH:mm').format(appointment.startAt.toLocal());
    final end = DateFormat('HH:mm').format(appointment.endAt.toLocal());
    final patientName = appointment.isAnonymous ? 'Bệnh nhân ẩn danh' : (appointment.patientDisplayName ?? 'Bệnh nhân');
    final hasMeetingLink = appointment.meetingLink != null && appointment.meetingLink!.isNotEmpty;
    final isBooked = appointment.status == 'BOOKED';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.10),
                child: Icon(appointment.isAnonymous ? Icons.masks_rounded : Icons.person, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(patientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text('$when - $end', style: const TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
                child: Text(statusLabel, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: hasMeetingLink && isBooked ? onCopyMeetingLink : null,
                icon: const Icon(Icons.meeting_room_outlined, size: 18),
                label: const Text('Vào phòng họp'),
              ),
              ElevatedButton.icon(
                onPressed: isBooked ? onComplete : null,
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Hoàn thành'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
              ),
              TextButton.icon(
                onPressed: isBooked ? onCancel : null,
                icon: const Icon(Icons.cancel_outlined, size: 18),
                label: const Text('Hủy lịch'),
                style: TextButton.styleFrom(foregroundColor: AppColors.alert),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

