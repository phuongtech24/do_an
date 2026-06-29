import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/mindhealth_scaffold.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/onboarding_provider.dart';

class GoalSettingScreen extends StatefulWidget {
  const GoalSettingScreen({super.key});

  @override
  State<GoalSettingScreen> createState() => _GoalSettingScreenState();
}

class _GoalSettingScreenState extends State<GoalSettingScreen> {
  static const List<_GoalOption> _goalOptions = [
    _GoalOption(
      goalType: 'SOCIAL',
      title: 'Tự tin kết bạn, mở rộng quan hệ',
      subtitle: 'Ưu tiên các tình huống giao tiếp, làm quen, trò chuyện và duy trì kết nối.',
      icon: Icons.people_outline,
    ),
    _GoalOption(
      goalType: 'BEHAVIORAL',
      title: 'Thể hiện tốt hơn trong công việc / học tập',
      subtitle: 'Ưu tiên thuyết trình, phát biểu, trả lời trước đám đông và các tình huống áp lực hiệu suất.',
      icon: Icons.campaign_outlined,
    ),
    _GoalOption(
      goalType: 'EMOTIONAL',
      title: 'Tự tin trong mọi tình huống hằng ngày',
      subtitle: 'Ưu tiên ổn định cảm xúc và giảm phản ứng lo âu trong các tình huống hằng ngày.',
      icon: Icons.self_improvement_outlined,
    ),
  ];

  String? _selectedGoalType;
  bool _loadedFromServer = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final patientId = auth.loginResponse?.user.id ?? '';
    final token = auth.loginResponse?.token;
    final onboardingProvider = Provider.of<OnboardingProvider>(context);
    final isLocked = onboardingProvider.savedGoalType != null;

    if (!_loadedFromServer && patientId.isNotEmpty) {
      _loadedFromServer = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final ok = await onboardingProvider.loadGoals(patientId, token: token);
        if (!mounted || !ok) return;
        setState(() => _selectedGoalType = onboardingProvider.savedGoalType);
      });
    }

    return MindHealthScaffold(
      title: 'Mục tiêu trị liệu',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Điều gì bạn muốn cải thiện nhất?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Chọn 1 mục tiêu thân thiện để hệ thống ưu tiên Fear Ladder và bài Behavioral Experiment phù hợp.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          if (isLocked)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.24)),
              ),
              child: const Text(
                'Mục tiêu đã được lưu. Bạn vẫn có thể xem lại trước khi tiếp tục.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          Expanded(
            child: ListView.separated(
              itemCount: _goalOptions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final option = _goalOptions[index];
                final selected = _selectedGoalType == option.goalType;
                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: isLocked ? null : () => setState(() => _selectedGoalType = option.goalType),
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
                          backgroundColor: const Color(0xFF6C63FF).withOpacity(0.12),
                          child: Icon(option.icon, color: const Color(0xFF6C63FF)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(option.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                              const SizedBox(height: 6),
                              Text(option.subtitle, style: const TextStyle(color: Colors.black54, height: 1.4)),
                            ],
                          ),
                        ),
                        if (selected) const Icon(Icons.check_circle, color: Color(0xFF6C63FF)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onboardingProvider.status != OnboardingStatus.loading && (isLocked || _selectedGoalType != null)
                  ? () async {
                      if (patientId.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Không tìm thấy phiên đăng nhập.')),
                        );
                        return;
                      }

                      if (isLocked) {
                        final ok = await onboardingProvider.loadOnboardingStatus(patientId, token: token);
                        if (!mounted) return;
                        if (!ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(onboardingProvider.errorMessage)),
                          );
                          return;
                        }

                        context.go(onboardingProvider.nextOnboardingRoute);
                        return;
                      }

                      final selected = _goalOptions.firstWhere((goal) => goal.goalType == _selectedGoalType);
                      final ok = await onboardingProvider.saveGoal(
                        patientId,
                        selected.goalType,
                        selected.title,
                        token: token,
                      );
                      if (!mounted) return;
                      if (ok) {
                        context.go(onboardingProvider.nextOnboardingRoute);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(onboardingProvider.errorMessage)),
                        );
                      }
                    }
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: onboardingProvider.status == OnboardingStatus.loading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(isLocked ? 'Tiếp tục' : 'Lưu mục tiêu'),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalOption {
  final String goalType;
  final String title;
  final String subtitle;
  final IconData icon;

  const _GoalOption({
    required this.goalType,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
