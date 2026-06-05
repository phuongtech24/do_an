import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/mindhealth_scaffold.dart';
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
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bạn được tự chọn therapist ACTIVE để tăng sự phù hợp và cảm giác an tâm khi bắt đầu CBT.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: onboarding.status == OnboardingStatus.loading && onboarding.therapists.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : onboarding.therapists.isEmpty
                    ? Center(
                        child: Text(
                          onboarding.errorMessage.isNotEmpty
                              ? onboarding.errorMessage
                              : 'Hiện chưa có therapist phù hợp để chọn.',
                        ),
                      )
                    : ListView.separated(
                        itemCount: onboarding.therapists.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final therapist = onboarding.therapists[index];
                          final selected = _selectedTherapistId == therapist.therapistId;
                          return _TherapistCard(
                            therapist: therapist,
                            selected: selected,
                            onTap: therapist.caseloadFull
                                ? null
                                : () => setState(() => _selectedTherapistId = therapist.therapistId),
                          );
                        },
                      ),
          ),
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
                        context.go('/home');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(onboarding.errorMessage)),
                        );
                      }
                    }
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: onboarding.status == OnboardingStatus.loading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Chọn chuyên gia này'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TherapistCard extends StatelessWidget {
  const _TherapistCard({
    required this.therapist,
    required this.selected,
    required this.onTap,
  });

  final TherapistDirectoryItemModel therapist;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF6C63FF).withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? const Color(0xFF6C63FF) : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFF6C63FF).withOpacity(0.12),
              child: Text(
                therapist.fullName.isNotEmpty ? therapist.fullName.substring(0, 1).toUpperCase() : 'T',
                style: const TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(therapist.fullName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      ),
                      if (therapist.caseloadFull)
                        const Text('FULL', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if ((therapist.specialization ?? '').isNotEmpty)
                    Text(therapist.specialization!, style: const TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.w600)),
                  if ((therapist.bio ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(therapist.bio!, style: const TextStyle(color: Colors.black54, height: 1.4)),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Caseload: ${therapist.caseloadCount}/${therapist.caseloadLimit}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            if (selected) const Icon(Icons.check_circle, color: Color(0xFF6C63FF)),
          ],
        ),
      ),
    );
  }
}
