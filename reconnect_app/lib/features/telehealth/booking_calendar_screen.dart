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
    if (patientId.isNotEmpty) {
      Provider.of<TelehealthProvider>(context, listen: false).loadSlots(patientId, _selectedDate, token: token);
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chọn Lịch Khám'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
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
                      children: const [
                        Text(
                          'Bác sĩ/Therapist',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text('Lịch sẽ đặt theo therapist đã được gán', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Khung giờ trống (Hôm nay)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  Consumer<TelehealthProvider>(
                    builder: (context, telehealth, _) {
                      if (telehealth.status == TelehealthStatus.loading && telehealth.slots.isEmpty) {
                        return const Center(child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ));
                      }
                      if (telehealth.status == TelehealthStatus.error && telehealth.slots.isEmpty) {
                        return Text('Lỗi: ${telehealth.errorMessage}', style: const TextStyle(color: Colors.red));
                      }

                      final slots = telehealth.slots;
                      if (slots.isEmpty) {
                        return const Text('Hôm nay không còn slot trống.');
                      }

                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: slots.map((slot) {
                          final isSelected = _selectedSlotStartAt != null && slot.startAt.isAtSameMomentAs(_selectedSlotStartAt!);
                          final label = DateFormat('HH:mm').format(slot.startAt);
                          return ChoiceChip(
                            label: Text(label),
                            selected: isSelected,
                            onSelected: slot.available
                                ? (selected) => setState(() => _selectedSlotStartAt = selected ? slot.startAt : null)
                                : null,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : (slot.available ? AppColors.textPrimary : Colors.grey),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.all(12),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Quyền Riêng Tư', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Giao tiếp Ẩn Danh', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            _isAnonymous
                                ? 'Therapist chỉ thấy nickname; thông tin thật được giữ kín.'
                                : 'Therapist có thể thấy thông tin thật (nếu hệ thống cho phép).',
                          ),
                          activeColor: AppColors.primary,
                          value: _isAnonymous,
                          onChanged: (val) => setState(() => _isAnonymous = val),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _confirmBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('XÁC NHẬN ĐẶT CA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }
}

