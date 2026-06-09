import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/auth/auth_provider.dart';
import '../../features/therapist/data/models/appointment_model.dart';
import '../../features/therapist/data/models/therapist_schedule_slot_model.dart';
import '../../features/therapist/data/models/therapist_weekly_schedule_slot_model.dart';
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
  bool _loadingWeekly = false;
  String? _error;

  DateTime _selectedDate = DateTime.now();
  List<TherapistScheduleSlotModel> _slots = [];
  List<TherapistWeeklyScheduleSlotModel> _weeklySlots = [];
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
    await Future.wait([_loadWeeklySchedule(), _loadSchedule(), _loadAppointments()]);
  }

  String? _token() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    return token == null || token.isEmpty ? null : token;
  }

  String? _therapistId() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final therapistId = auth.userId;
    return therapistId == null || therapistId.isEmpty ? null : therapistId;
  }

  Future<void> _loadWeeklySchedule() async {
    final token = _token();
    final therapistId = _therapistId();
    if (token == null || therapistId == null) return;
    setState(() {
      _loadingWeekly = true;
      _error = null;
    });
    try {
      final list = await _repo.getWeeklySchedule(token: token, therapistId: therapistId);
      if (!mounted) return;
      setState(() => _weeklySlots = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() => _loadingWeekly = false);
    }
  }

  Future<void> _loadSchedule() async {
    final token = _token();
    final therapistId = _therapistId();
    if (token == null || therapistId == null) return;
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
    final token = _token();
    final therapistId = _therapistId();
    if (token == null || therapistId == null) return;
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
    final token = _token();
    final therapistId = _therapistId();
    if (token == null || therapistId == null) return;
    setState(() {
      _error = null;
      _loadingSchedule = true;
    });
    try {
      await _repo.toggleSlot(token: token, therapistId: therapistId, slotDate: slot.slotDate, startTime: slot.startTime, open: open);
      await _loadSchedule();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() => _loadingSchedule = false);
    }
  }

  Future<void> _toggleWeeklySlot(TherapistWeeklyScheduleSlotModel slot, bool open) async {
    final token = _token();
    final therapistId = _therapistId();
    if (token == null || therapistId == null) return;
    setState(() {
      _error = null;
      _loadingWeekly = true;
    });
    try {
      await _repo.toggleWeeklySlot(
        token: token,
        therapistId: therapistId,
        dayOfWeek: slot.dayOfWeek,
        startTime: slot.startTime,
        open: open,
      );
      await _loadWeeklySchedule();
      await _loadSchedule();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() => _loadingWeekly = false);
    }
  }

  Future<void> _updateStatus(AppointmentModel appointment, String status) async {
    final token = _token();
    if (token == null) return;
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

  Future<void> _editNotes(AppointmentModel appointment) async {
    final controller = TextEditingController(text: appointment.therapistNotes ?? '');
    final notes = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ghi chú sau buổi tư vấn'),
        content: SizedBox(
          width: 520,
          child: TextField(
            controller: controller,
            maxLines: 8,
            decoration: const InputDecoration(
              hintText: 'Nội dung đã trao đổi, bài tập cần theo dõi, kế hoạch buổi sau...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Đóng')),
          ElevatedButton(onPressed: () => Navigator.pop(dialogContext, controller.text), child: const Text('Lưu ghi chú')),
        ],
      ),
    );
    controller.dispose();
    if (notes == null) return;

    final token = _token();
    if (token == null) return;
    setState(() {
      _error = null;
      _loadingAppointments = true;
    });
    try {
      await _repo.updateAppointmentNotes(token: token, appointmentId: appointment.id, notes: notes);
      await _loadAppointments();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() => _loadingAppointments = false);
    }
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
                    Text('Thiết lập lịch tuần cố định, chỉnh ngoại lệ từng ngày và quản lý lịch đã đặt.', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Tải lại',
                onPressed: _loadingSchedule || _loadingAppointments || _loadingWeekly ? null : _loadAll,
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
    return ListView(
      children: [
        _WeeklySchedulePanel(slots: _weeklySlots, loading: _loadingWeekly, onToggle: _toggleWeeklySlot),
        const SizedBox(height: 16),
        Row(
          children: [
            Text('Ngoại lệ ngày ${_formatHumanDate(_selectedDate)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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
        const SizedBox(height: 10),
        if (_loadingSchedule)
          const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
        else
          ..._slots.map(
            (slot) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ScheduleSlotCard(slot: slot, onToggle: (open) => _toggleSlot(slot, open)),
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
      return Center(child: Text('Chưa có lịch hẹn nào.', style: TextStyle(color: Colors.grey[600])));
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
          onEditNotes: () => _editNotes(appointment),
          onComplete: () => _updateStatus(appointment, 'COMPLETED'),
          onCancel: () => _updateStatus(appointment, 'CANCELLED'),
        );
      },
    );
  }
}

class _WeeklySchedulePanel extends StatelessWidget {
  final List<TherapistWeeklyScheduleSlotModel> slots;
  final bool loading;
  final void Function(TherapistWeeklyScheduleSlotModel slot, bool open) onToggle;

  const _WeeklySchedulePanel({required this.slots, required this.loading, required this.onToggle});

  static const _dayLabels = {
    'MONDAY': 'Thứ 2',
    'TUESDAY': 'Thứ 3',
    'WEDNESDAY': 'Thứ 4',
    'THURSDAY': 'Thứ 5',
    'FRIDAY': 'Thứ 6',
    'SATURDAY': 'Thứ 7',
    'SUNDAY': 'CN',
  };

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<TherapistWeeklyScheduleSlotModel>>{};
    for (final slot in slots) {
      grouped.putIfAbsent(slot.dayOfWeek, () => []).add(slot);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Lịch tuần cố định', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text('Bật/tắt slot một lần để áp dụng lặp lại hằng tuần. Phần ngoại lệ theo ngày có thể ghi đè lịch này.', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          if (loading)
            const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
          else
            ..._dayLabels.entries.map((entry) {
              final daySlots = grouped[entry.key] ?? const [];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(width: 58, child: Text(entry.value, style: const TextStyle(fontWeight: FontWeight.bold))),
                    ...daySlots.map((slot) {
                      final label = slot.startTime.length >= 5 ? slot.startTime.substring(0, 5) : slot.startTime;
                      return FilterChip(
                        selected: slot.isOpen,
                        label: Text(label),
                        selectedColor: AppColors.success.withOpacity(0.18),
                        onSelected: (selected) => onToggle(slot, selected),
                      );
                    }),
                  ],
                ),
              );
            }),
        ],
      ),
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
          CircleAvatar(backgroundColor: color.withOpacity(0.12), child: Icon(slot.isBooked ? Icons.event_available : Icons.access_time, color: color)),
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
  final VoidCallback onEditNotes;
  final VoidCallback onComplete;
  final VoidCallback onCancel;

  const _AppointmentCard({
    required this.appointment,
    required this.statusLabel,
    required this.statusColor,
    required this.onCopyMeetingLink,
    required this.onEditNotes,
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
    final canEditNotes = appointment.status != 'CANCELLED';

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
          if (appointment.therapistNotes != null && appointment.therapistNotes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.06), borderRadius: BorderRadius.circular(10)),
              child: Text('Ghi chú: ${appointment.therapistNotes}', style: const TextStyle(color: AppColors.textPrimary)),
            ),
          ],
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
              OutlinedButton.icon(
                onPressed: canEditNotes ? onEditNotes : null,
                icon: const Icon(Icons.note_alt_outlined, size: 18),
                label: const Text('Ghi chú'),
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
