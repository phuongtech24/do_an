import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../shared/widgets/mindhealth_scaffold.dart';
import '../../../../theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/therapist_directory_item_model.dart';
import '../providers/onboarding_provider.dart';

class TherapistMatchingScreen extends StatefulWidget {
  const TherapistMatchingScreen({super.key});

  @override
  State<TherapistMatchingScreen> createState() => _TherapistMatchingScreenState();
}

class _TherapistMatchingScreenState extends State<TherapistMatchingScreen> {
  bool _loaded = false;
  String? _selectedTherapistId;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final onboarding = context.watch<OnboardingProvider>();
    final patientId = auth.loginResponse?.user.id ?? '';
    final token = auth.loginResponse?.token;

    if (!_loaded && patientId.isNotEmpty) {
      _loaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await onboarding.loadTherapists(token: token);
        await onboarding.loadOnboardingStatus(patientId, token: token);
        if (!mounted) return;
        setState(() => _selectedTherapistId = onboarding.selectedTherapistId);
      });
    }

    return MindHealthScaffold(
      title: 'Chọn chuyên gia',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ai là người bạn thấy phù hợp để đồng hành?',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Bạn được tự chọn chuyên gia đang hoạt động để tăng cảm giác phù hợp, an tâm và gắn kết khi bắt đầu CBT.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.45),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: onboarding.status == OnboardingStatus.loading && onboarding.therapists.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : onboarding.therapists.isEmpty
                    ? Center(
                        child: Text(
                          onboarding.errorMessage.isNotEmpty ? onboarding.errorMessage : 'Hiện chưa có chuyên gia phù hợp để chọn.',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.separated(
                        itemCount: onboarding.therapists.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final therapist = onboarding.therapists[index];
                          final selected = _selectedTherapistId == therapist.therapistId;
                          return _TherapistCard(
                            therapist: therapist,
                            selected: selected,
                            onTap: therapist.caseloadFull ? null : () => setState(() => _selectedTherapistId = therapist.therapistId),
                            onViewDetail: () => _showTherapistDetail(therapist, token: token),
                          );
                        },
                      ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onboarding.status != OnboardingStatus.loading && _selectedTherapistId != null
                  ? () async {
                      final ok = await onboarding.selectTherapist(
                        patientId,
                        _selectedTherapistId!,
                        token: token,
                      );
                      if (!mounted) return;
                      if (ok) {
                        final refreshed = await onboarding.loadOnboardingStatus(patientId, token: token);
                        if (!mounted) return;
                        if (!refreshed) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(onboarding.errorMessage)),
                          );
                          return;
                        }
                        context.go(onboarding.nextOnboardingRoute);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(onboarding.errorMessage)),
                        );
                      }
                    }
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: onboarding.status == OnboardingStatus.loading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Chọn chuyên gia này',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showTherapistDetail(TherapistDirectoryItemModel therapist, {String? token}) async {
    final onboarding = context.read<OnboardingProvider>();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return FutureBuilder<TherapistDirectoryItemModel?>(
          future: onboarding.loadTherapistDetail(therapist.therapistId, token: token),
          initialData: therapist,
          builder: (context, snapshot) {
            final detail = snapshot.data ?? therapist;
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              contentPadding: const EdgeInsets.all(0),
              content: Container(
                width: 540,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, Color(0xFF159489)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                      child: Row(
                        children: [
                          _buildAvatar(detail, radius: 36),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  detail.fullName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  detail.specialization ?? 'Chưa cập nhật chuyên môn',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: snapshot.connectionState == ConnectionState.waiting
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    _buildInfoChip('Quê quán', detail.hometown ?? 'Chưa cập nhật'),
                                    _buildInfoChip('Năm sinh', detail.birthYear?.toString() ?? 'Chưa cập nhật'),
                                    _buildInfoChip(
                                      'Chứng chỉ',
                                      detail.credentialCount > 0 ? 'Đã nộp ${detail.credentialCount} chứng chỉ' : 'Chưa cập nhật',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                _buildDetailBlock('Giọng nói', detail.voiceDescription ?? 'Chưa cập nhật'),
                                _buildDetailBlock('Phong cách trị liệu', detail.therapyStyle ?? 'Chưa cập nhật'),
                                _buildDetailBlock('Giới thiệu', detail.bio ?? 'Chưa cập nhật'),
                                const SizedBox(height: 8),
                                Text(
                                  detail.caseloadFull
                                      ? 'Hiện chuyên gia này đã đủ lịch tiếp nhận.'
                                      : 'Đang theo dõi ${detail.caseloadCount}/${detail.caseloadLimit} bệnh nhân.',
                                  style: TextStyle(
                                    color: detail.caseloadFull ? AppColors.alert : AppColors.textSecondary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Đóng'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: AppColors.textPrimary),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailBlock(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(TherapistDirectoryItemModel therapist, {double radius = 28}) {
    final avatarUrl = _publicUrl(therapist.avatarUrl);
    final initial = therapist.fullName.isNotEmpty ? therapist.fullName.substring(0, 1).toUpperCase() : 'C';
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white.withOpacity(0.18),
      backgroundImage: avatarUrl == null ? null : NetworkImage(avatarUrl),
      child: avatarUrl == null
          ? Text(
              initial,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: radius * 0.75,
              ),
            )
          : null,
    );
  }

  String? _publicUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final origin = ApiConstants.baseUrl.replaceFirst(RegExp(r'/api/?$'), '');
    return '$origin$path';
  }
}

class _TherapistCard extends StatelessWidget {
  const _TherapistCard({
    required this.therapist,
    required this.selected,
    required this.onTap,
    required this.onViewDetail,
  });

  final TherapistDirectoryItemModel therapist;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback onViewDetail;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = _publicUrl(therapist.avatarUrl);
    final accent = selected ? AppColors.primary : AppColors.secondary;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: selected ? AppColors.primary.withOpacity(0.06) : Colors.white,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.primary.withOpacity(0.08),
              width: selected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: accent.withOpacity(0.14),
                backgroundImage: avatarUrl == null ? null : NetworkImage(avatarUrl),
                child: avatarUrl == null
                    ? Text(
                        therapist.fullName.isNotEmpty ? therapist.fullName.substring(0, 1).toUpperCase() : 'C',
                        style: TextStyle(color: accent, fontWeight: FontWeight.w900, fontSize: 24),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            therapist.fullName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: therapist.caseloadFull ? AppColors.alert.withOpacity(0.1) : AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            therapist.caseloadFull ? 'Đã đủ lịch' : 'Đang nhận bệnh nhân',
                            style: TextStyle(
                              color: therapist.caseloadFull ? AppColors.alert : AppColors.success,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      therapist.specialization ?? 'Chưa cập nhật chuyên môn',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      therapist.bio ?? 'Chưa cập nhật phần giới thiệu.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      therapist.caseloadFull
                          ? 'Hiện chuyên gia đã kín lịch tiếp nhận.'
                          : 'Đang theo dõi ${therapist.caseloadCount}/${therapist.caseloadLimit} bệnh nhân',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: onViewDetail,
                          icon: const Icon(Icons.visibility_outlined, size: 18),
                          label: const Text('Xem chi tiết'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (selected)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.check_circle, color: AppColors.primary, size: 30),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String? _publicUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final origin = ApiConstants.baseUrl.replaceFirst(RegExp(r'/api/?$'), '');
    return '$origin$path';
  }
}
