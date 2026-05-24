import 'package:flutter/material.dart';
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

  bool _loadingSchedule = false;
  bool _loadingAppointments = false;
  String? _error;

  DateTime _selectedDate = DateTime.now();
  List<TherapistScheduleSlotModel> _slots = [];
  List<AppointmentModel> _appointments = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAll();
  }

  String _formatDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
  String _formatHumanDate(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

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
      final list = await _repo.getSchedule(
        token: token,
        therapistId: therapistId,
        date: _formatDate(_selectedDate),
      );
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lịch hẹn (Telehealth)',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bác sĩ mở/đóng các slot rảnh; bệnh nhân chỉ đặt được slot đang mở.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 16),
          if (_error != null && _error!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
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
          const SizedBox(height: 12),
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
            Text('Ngày: ${_formatHumanDate(_selectedDate)}', style: const TextStyle(fontWeight: FontWeight.bold)),
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
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Tải lại',
              onPressed: _loadingSchedule ? null : _loadSchedule,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _loadingSchedule
              ? const Center(child: CircularProgressIndicator())
              : Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                  child: ListView.separated(
                    itemCount: _slots.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final slot = _slots[index];
                      final timeLabel = slot.startTime.length >= 5 ? slot.startTime.substring(0, 5) : slot.startTime;
                      final isBooked = slot.isBooked;
                      final isOpen = slot.isOpen;

                      Color chipColor;
                      String chipText;
                      if (isBooked) {
                        chipColor = AppColors.alert;
                        chipText = 'ĐÃ ĐẶT';
                      } else if (isOpen) {
                        chipColor = AppColors.success;
                        chipText = 'MỞ';
                      } else {
                        chipColor = Colors.grey;
                        chipText = 'ĐÓNG';
                      }

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        leading: const Icon(Icons.access_time, color: AppColors.primary),
                        title: Text('Khung giờ $timeLabel', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: slot.patientNickname != null
                            ? Text('Bệnh nhân: ${slot.patientNickname}')
                            : const Text(''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: chipColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(chipText, style: TextStyle(color: chipColor, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 12),
                            Switch(
                              value: isOpen,
                              onChanged: isBooked || _loadingSchedule ? null : (v) => _toggleSlot(slot, v),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildAppointmentsTab() {
    if (_loadingAppointments) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_appointments.isEmpty) {
      return Center(
        child: Text('Chưa có lịch hẹn nào.', style: TextStyle(color: Colors.grey[600])),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            const Spacer(),
            IconButton(
              tooltip: 'Tải lại',
              onPressed: _loadingAppointments ? null : _loadAppointments,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        Expanded(
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey[300]!),
            ),
            child: ListView.separated(
              itemCount: _appointments.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final appt = _appointments[index];
                final when = DateFormat('dd/MM/yyyy HH:mm').format(appt.startAt.toLocal());
                final status = appt.status.isNotEmpty ? appt.status : 'UNKNOWN';
                final title = appt.isAnonymous ? 'Bệnh nhân ẩn danh' : 'Bệnh nhân';

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  leading: CircleAvatar(
                    backgroundColor: appt.isAnonymous ? AppColors.secondary.withOpacity(0.2) : AppColors.primary.withOpacity(0.2),
                    child: Icon(appt.isAnonymous ? Icons.masks_rounded : Icons.person, color: appt.isAnonymous ? AppColors.secondary : AppColors.primary),
                  ),
                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('$when • $status'),
                  trailing: appt.meetingLink == null || appt.meetingLink!.isEmpty
                      ? null
                      : OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Link meeting được cấu hình từ hồ sơ bác sĩ (meetingLink).')),
                            );
                          },
                          icon: const Icon(Icons.link, size: 16),
                          label: const Text('Link'),
                        ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

