import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../theme/app_colors.dart';
import '../auth/presentation/providers/auth_provider.dart';
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
        const SnackBar(content: Text('Vui lòng chọn khung giờ trống!')),
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
        SnackBar(content: Text(telehealth.assignmentMessage.isNotEmpty ? telehealth.assignmentMessage : 'Bạn chưa được gán bác sĩ phụ trách.')),
      );
      return;
    }

    final appt = await telehealth.book(patientId, _selectedSlotStartAt!, _isAnonymous, token: token);
    if (!mounted) return;

    if (appt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${telehealth.errorMessage}')),
      );
      return;
    }

    final timeText = DateFormat('dd/MM/yyyy HH:mm').format(appt.startAt);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đặt lịch thành công'),
        content: Text(
          'Ca khám của bạn đã được chốt vào thời gian:\n$timeText.\n\nChế độ ẩn danh: ${_isAnonymous ? "BẬT" : "TẮT"}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('XONG'),
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
      appBar: AppBar(
        title: const Text('Chọn Lịch Khám'),
        elevation: 0,
      ),
      body: Consumer<TelehealthProvider>(
        builder: (context, telehealth, _) {
          if (telehealth.status == TelehealthStatus.loading && telehealth.assignmentStatus == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!telehealth.isAssigned) {
            final msg = telehealth.assignmentMessage.isNotEmpty
                ? telehealth.assignmentMessage
                : 'Bạn chưa được gán bác sĩ phụ trách. Vui lòng chờ Admin gán bác sĩ để đặt lịch.';
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.info_outline, size: 48, color: AppColors.alert),
                    const SizedBox(height: 12),
                    Text(msg, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.alert, fontSize: 16)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Quay lại'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: patientId.isEmpty
                              ? null
                              : () async {
                                  await telehealth.loadAssignmentStatus(patientId, token: token);
                                  if (!mounted) return;
                                  if (telehealth.isAssigned) {
                                    await telehealth.loadSlots(patientId, _selectedDate, token: token);
                                  }
                                },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tải lại'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }

          final therapistName = telehealth.therapistName.isNotEmpty ? telehealth.therapistName : 'Bác sĩ/Therapist';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  color: AppColors.primary,
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=32'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              therapistName,
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            const Text('Lịch sẽ đặt theo therapist đã được gán', style: TextStyle(color: Colors.white70)),
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
                      Text('Khung giờ trống (Hôm nay)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      if (telehealth.status == TelehealthStatus.loading && telehealth.slots.isEmpty)
                        const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
                      else if (telehealth.status == TelehealthStatus.error)
                        Text('Lỗi: ${telehealth.errorMessage}', style: const TextStyle(color: AppColors.alert))
                      else if (telehealth.slots.where((e) => e.isAvailable).isEmpty)
                        const Text('Hôm nay không còn slot trống.')
                      else
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: telehealth.slots.map((slot) {
                            final timeText = DateFormat('HH:mm').format(slot.startAt);
                            final selected = _selectedSlotStartAt != null && slot.startAt.isAtSameMomentAs(_selectedSlotStartAt!);
                            final disabled = !slot.isAvailable;
                            return ChoiceChip(
                              label: Text(timeText),
                              selected: selected,
                              onSelected: disabled
                                  ? null
                                  : (_) {
                                      setState(() => _selectedSlotStartAt = slot.startAt);
                                    },
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 20),
                      const Text('Quyền Riêng Tư', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        child: SwitchListTile(
                          value: _isAnonymous,
                          onChanged: (v) => setState(() => _isAnonymous = v),
                          title: const Text('Giao tiếp ẩn danh'),
                          subtitle: Text(
                            _isAnonymous
                                ? 'Therapist chỉ thấy nickname; thông tin thật được giữ kín.'
                                : 'Therapist có thể thấy thông tin thật (nếu hệ thống cho phép).',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: telehealth.status == TelehealthStatus.loading ? null : _confirmBooking,
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.alert, foregroundColor: Colors.white),
                          child: const Text('XÁC NHẬN ĐẶT CA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
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

