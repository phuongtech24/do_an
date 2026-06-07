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
  String _selectedPurpose = 'CBT_SESSION';
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
        _selectedPurpose = _defaultPurposeForPhase(telehealth);
        _durationMinutes = _defaultDurationForPurpose(_selectedPurpose);
        if (telehealth.isAssigned) {
          await telehealth.loadSlots(patientId, _selectedDate, token: token);
        }
        if (mounted) {
          setState(() {});
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
      purpose: _selectedPurpose,
      carePhaseCode: telehealth.carePhaseCode,
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
          'Buổi hẹn của bạn đã được xác nhận vào:\n$timeText.\n\nLoại buổi: ${_purposeLabel(_selectedPurpose)}.\nThời lượng: $_durationMinutes phút.',
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

  List<_BookingPurposeOption> _purposeOptions(TelehealthProvider telehealth) {
    if (telehealth.carePhaseCode == 'MAINTENANCE') {
      return const [
        _BookingPurposeOption(code: 'BOOSTER_3M', label: 'Booster 3 tháng', subtitle: 'Buổi củng cố sau điều trị'),
        _BookingPurposeOption(code: 'BOOSTER_6M', label: 'Booster 6 tháng', subtitle: 'Theo dõi tái phát giữa kỳ'),
        _BookingPurposeOption(code: 'BOOSTER_12M', label: 'Booster 12 tháng', subtitle: 'Tổng kiểm tra duy trì dài hạn'),
      ];
    }
    return const [
      _BookingPurposeOption(code: 'CBT_SESSION', label: 'Phiên CBT chuẩn', subtitle: 'Buổi trị liệu hàng tuần hoặc tapering'),
      _BookingPurposeOption(code: 'INITIAL_ASSESSMENT', label: 'Phiên khởi đầu', subtitle: 'Dùng cho buổi đánh giá / rà soát kỹ hơn'),
      _BookingPurposeOption(code: 'BEHAVIORAL_EXPERIMENT', label: 'Thử nghiệm hành vi', subtitle: 'Phiên dài hơn để thực hành trực tiếp'),
    ];
  }

  String _defaultPurposeForPhase(TelehealthProvider telehealth) {
    if (telehealth.carePhaseCode == 'MAINTENANCE') {
      return telehealth.recommendedPurposeCode.startsWith('BOOSTER_') ? telehealth.recommendedPurposeCode : 'BOOSTER_3M';
    }
    return 'CBT_SESSION';
  }

  int _defaultDurationForPurpose(String purpose) {
    switch (purpose) {
      case 'INITIAL_ASSESSMENT':
        return 60;
      case 'BEHAVIORAL_EXPERIMENT':
        return 90;
      case 'BOOSTER_3M':
      case 'BOOSTER_6M':
      case 'BOOSTER_12M':
        return 50;
      default:
        return 50;
    }
  }

  List<int> _durationsForPurpose(String purpose) {
    switch (purpose) {
      case 'INITIAL_ASSESSMENT':
        return const [60];
      case 'BEHAVIORAL_EXPERIMENT':
        return const [90];
      case 'BOOSTER_3M':
      case 'BOOSTER_6M':
      case 'BOOSTER_12M':
        return const [45, 50, 60];
      default:
        return const [45, 50];
    }
  }

  String _purposeLabel(String purpose) {
    switch (purpose) {
      case 'INITIAL_ASSESSMENT':
        return 'Phiên khởi đầu';
      case 'BEHAVIORAL_EXPERIMENT':
        return 'Thử nghiệm hành vi';
      case 'BOOSTER_3M':
        return 'Booster 3 tháng';
      case 'BOOSTER_6M':
        return 'Booster 6 tháng';
      case 'BOOSTER_12M':
        return 'Booster 12 tháng';
      default:
        return 'Phiên CBT chuẩn';
    }
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
          final options = _purposeOptions(telehealth);
          final allowedDurations = _durationsForPurpose(_selectedPurpose);
          if (!allowedDurations.contains(_durationMinutes)) {
            _durationMinutes = allowedDurations.first;
          }

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
                            Text(
                              '${telehealth.carePhaseLabel} • ${telehealth.recommendedFrequencyLabel}',
                              style: const TextStyle(color: Colors.white70),
                            ),
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
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withOpacity(0.12)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(telehealth.recommendedPlanSummary, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.45)),
                            const SizedBox(height: 8),
                            Text('Gợi ý thời lượng: ${telehealth.durationGuidance}', style: const TextStyle(color: AppColors.textSecondary, height: 1.45)),
                            if (telehealth.allowOverride) ...[
                              const SizedBox(height: 10),
                              const Text(
                                'Lưu ý an toàn: nếu đây là ca cờ đỏ, bác sĩ có thể chủ động ghi đè lịch chuẩn để sắp buổi khẩn cấp hoặc can thiệp dày hơn.',
                                style: TextStyle(color: AppColors.alert, fontWeight: FontWeight.w700, height: 1.45),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text('Loại buổi hẹn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 10),
                      Column(
                        children: options.map((option) {
                          final selected = _selectedPurpose == option.code;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () => setState(() {
                                _selectedPurpose = option.code;
                                _durationMinutes = _defaultDurationForPurpose(option.code);
                              }),
                              child: Ink(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: selected ? AppColors.primary.withOpacity(0.08) : Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: selected ? AppColors.primary : AppColors.textSecondary.withOpacity(0.18),
                                    width: selected ? 1.8 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      selected ? Icons.check_circle : Icons.radio_button_unchecked,
                                      color: selected ? AppColors.primary : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(option.label, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                          const SizedBox(height: 4),
                                          Text(option.subtitle, style: const TextStyle(color: AppColors.textSecondary, height: 1.35)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
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
                      const Text('Thời lượng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: allowedDurations.map((minutes) {
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
                          title: const Text('Giữ nickname / ẩn danh'),
                          subtitle: Text(
                            _isAnonymous
                                ? 'Chuyên gia sẽ ưu tiên nickname để bạn thấy an toàn và thoải mái hơn khi bắt đầu.'
                                : 'Chuyên gia có thể nhìn thêm danh tính thật nếu hệ thống cho phép và bạn đồng ý chia sẻ.',
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
                          child: const Text('XÁC NHẬN ĐẶT LỊCH', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

class _BookingPurposeOption {
  final String code;
  final String label;
  final String subtitle;

  const _BookingPurposeOption({
    required this.code,
    required this.label,
    required this.subtitle,
  });
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
