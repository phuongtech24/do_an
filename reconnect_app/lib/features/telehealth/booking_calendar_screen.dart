import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../theme/app_colors.dart';
import '../auth/presentation/providers/auth_provider.dart';
import 'data/models/available_slot_model.dart';
import 'presentation/providers/telehealth_provider.dart';

class BookingCalendarScreen extends StatefulWidget {
  const BookingCalendarScreen({super.key});

  @override
  State<BookingCalendarScreen> createState() => _BookingCalendarScreenState();
}

class _BookingCalendarScreenState extends State<BookingCalendarScreen> {
  final DateTime _selectedDate = DateTime.now();
  DateTime? _selectedSlotStartAt;
  bool _isAnonymous = true;
  int _durationMinutes = 50;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final patientId = auth.loginResponse?.user.id ?? '';
    final token = auth.loginResponse?.token;
    final telehealth = Provider.of<TelehealthProvider>(context, listen: false);

    if (patientId.isNotEmpty) {
      () async {
        await telehealth.loadAssignmentStatus(patientId, token: token);
        if (!mounted) return;
        if (telehealth.isAssigned) {
          await telehealth.loadSlots(patientId, _selectedDate, token: token);
        }
      }();
    }

    _loaded = true;
  }

  Future<void> _confirmBooking() async {
    if (_selectedSlotStartAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn khung giờ trống.')),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final patientId = auth.loginResponse?.user.id ?? '';
    final token = auth.loginResponse?.token;
    if (patientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn cần đăng nhập trước khi đặt lịch.')),
      );
      return;
    }

    final telehealth = Provider.of<TelehealthProvider>(context, listen: false);
    if (!telehealth.isAssigned) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(telehealth.assignmentMessage.isNotEmpty ? telehealth.assignmentMessage : 'Bạn chưa chọn chuyên gia phù hợp.')),
      );
      return;
    }

    final appointment = await telehealth.book(
      patientId,
      _selectedSlotStartAt!,
      _isAnonymous,
      durationMinutes: _durationMinutes,
      purpose: _durationMinutes == 60 ? 'INITIAL_ASSESSMENT' : (_durationMinutes == 90 ? 'BEHAVIORAL_EXPERIMENT' : 'CBT_SESSION'),
      token: token,
    );
    if (!mounted) return;

    if (appointment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${telehealth.errorMessage}')),
      );
      return;
    }

    final timeText = DateFormat('dd/MM/yyyy HH:mm').format(appointment.startAt);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đặt lịch thành công'),
        content: Text(
          'Buổi CBT của bạn đã được chốt vào:\n$timeText.\n\nDuration: $_durationMinutes phút.\nLink phòng tư vấn sẽ hiển thị trong Lịch hẹn của tôi.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.go('/telehealth/my-appointments');
            },
            child: const Text('Xem lịch hẹn'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final patientId = auth.loginResponse?.user.id ?? '';
    final token = auth.loginResponse?.token;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Đặt lịch CBT')),
      body: Consumer<TelehealthProvider>(
        builder: (context, telehealth, _) {
          if (telehealth.status == TelehealthStatus.loading && telehealth.assignmentStatus == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!telehealth.isAssigned) {
            final message = telehealth.assignmentMessage.isNotEmpty
                ? telehealth.assignmentMessage
                : 'Bạn chưa chọn chuyên gia phù hợp để bắt đầu đặt lịch CBT.';
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.info_outline, size: 48, color: AppColors.alert),
                    const SizedBox(height: 12),
                    Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.alert, fontSize: 16)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/therapist-matching'),
                      icon: const Icon(Icons.people_outline),
                      label: const Text('Chọn chuyên gia'),
                    ),
                  ],
                ),
              ),
            );
          }

          final therapistName = telehealth.therapistName.isNotEmpty ? telehealth.therapistName : 'Chuyên gia đồng hành';
          final availableSlots = telehealth.slots.where((slot) => slot.isAvailable).toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  color: AppColors.primary,
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(color: Color(0xFF9BE7DD), shape: BoxShape.circle),
                        child: const Icon(Icons.psychology_alt_outlined, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(therapistName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            const Text('Chọn khung giờ và duration phù hợp cho buổi CBT của bạn.', style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Khung giờ trống hôm nay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 10),
                      if (telehealth.status == TelehealthStatus.loading && telehealth.slots.isEmpty)
                        const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
                      else if (telehealth.status == TelehealthStatus.error)
                        Text('Lỗi: ${telehealth.errorMessage}', style: const TextStyle(color: AppColors.alert))
                      else if (availableSlots.isEmpty)
                        const Text('Hôm nay không còn slot trống.', style: TextStyle(color: AppColors.textSecondary))
                      else
                        _SlotGrid(
                          slots: telehealth.slots,
                          selectedSlotStartAt: _selectedSlotStartAt,
                          onSelected: (slot) => setState(() => _selectedSlotStartAt = slot.startAt),
                        ),
                      const SizedBox(height: 22),
                      const Text('Duration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [45, 50, 60, 90].map((minutes) {
                          final selected = _durationMinutes == minutes;
                          return ChoiceChip(
                            label: Text('$minutes phút'),
                            selected: selected,
                            onSelected: (_) => setState(() => _durationMinutes = minutes),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 22),
                      Card(
                        elevation: 0,
                        color: AppColors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: AppColors.textSecondary.withOpacity(0.18)),
                        ),
                        child: SwitchListTile(
                          value: _isAnonymous,
                          onChanged: (value) => setState(() => _isAnonymous = value),
                          title: const Text('Giữ nickname/ẩn danh'),
                          subtitle: Text(
                            _isAnonymous
                                ? 'Therapist ưu tiên nickname để bạn thoải mái hơn khi bắt đầu.'
                                : 'Therapist có thể thấy thêm thông tin thật nếu hệ thống cho phép.',
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: telehealth.status == TelehealthStatus.loading || _selectedSlotStartAt == null ? null : _confirmBooking,
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.alert, foregroundColor: Colors.white),
                          child: const Text('XÁC NHẬN ĐẶT CA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: patientId.isEmpty
                            ? null
                            : () async {
                                await telehealth.loadAssignmentStatus(patientId, token: token);
                                if (!mounted || !telehealth.isAssigned) return;
                                await telehealth.loadSlots(patientId, _selectedDate, token: token);
                              },
                        child: const Text('Tải lại slot'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SlotGrid extends StatelessWidget {
  final List<AvailableSlotModel> slots;
  final DateTime? selectedSlotStartAt;
  final ValueChanged<AvailableSlotModel> onSelected;

  const _SlotGrid({
    required this.slots,
    required this.selectedSlotStartAt,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: slots.map((slot) {
        final timeText = DateFormat('HH:mm').format(slot.startAt);
        final selected = selectedSlotStartAt != null && slot.startAt.isAtSameMomentAs(selectedSlotStartAt!);
        return ChoiceChip(
          label: Text(timeText),
          selected: selected,
          onSelected: slot.isAvailable ? (_) => onSelected(slot) : null,
          disabledColor: Colors.grey.shade200,
          selectedColor: AppColors.primary.withOpacity(0.22),
          labelStyle: TextStyle(
            color: slot.isAvailable ? AppColors.textPrimary : AppColors.textSecondary.withOpacity(0.5),
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        );
      }).toList(),
    );
  }
}
