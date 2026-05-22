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
  final List<String> _suggestedGoals = [
    'Bớt lo lắng về tương lai',
    'Cải thiện chất lượng giấc ngủ',
    'Gặp gỡ bạn bè nhiều hơn',
    'Hoàn thành công việc đúng hạn',
    'Kiểm soát cơn nóng giận',
    'Dành thời gian chăm sóc bản thân',
    'Giảm bớt suy nghĩ tiêu cực'
  ];

  final Set<String> _selectedGoals = {};
  final TextEditingController _customGoalController = TextEditingController();
  bool _loadedFromServer = false;

  void _toggleGoal(String goal) {
    if (_isLocked) return;
    setState(() {
      if (_selectedGoals.contains(goal)) {
        _selectedGoals.remove(goal);
      } else if (_selectedGoals.length < 5) {
        _selectedGoals.add(goal);
      }
    });
  }

  void _addCustomGoal() {
    if (_isLocked) return;
    final text = _customGoalController.text.trim();
    if (text.isNotEmpty && _selectedGoals.length < 5) {
      setState(() {
        _selectedGoals.add(text);
        _customGoalController.clear();
      });
    }
  }

  bool get _isLocked {
    final onboardingProvider = Provider.of<OnboardingProvider>(context, listen: false);
    return onboardingProvider.savedGoals.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final patientId = auth.loginResponse?.user.id ?? '';
    final token = auth.loginResponse?.token;
    final onboardingProvider = Provider.of<OnboardingProvider>(context);
    final isLocked = onboardingProvider.savedGoals.isNotEmpty;

    if (!_loadedFromServer && patientId.isNotEmpty) {
      _loadedFromServer = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final ok = await onboardingProvider.loadGoals(patientId, token: token);
        if (!mounted) return;
        if (ok) {
          setState(() {
            _selectedGoals
              ..clear()
              ..addAll(onboardingProvider.savedGoals.take(5));
          });
        }
      });
    }

    return MindHealthScaffold(
      title: 'Thiết lập Mục tiêu',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLocked)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.25)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock, color: Colors.green),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Bạn đã thiết lập mục tiêu trị liệu rồi. Màn hình này chỉ để xem lại.',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          const Text(
            'Bạn muốn đạt được điều gì?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hãy chọn từ 3 đến 5 mục tiêu cụ thể để AI thiết kế lộ trình phù hợp nhất cho bạn.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestedGoals.map((goal) {
              final isSelected = _selectedGoals.contains(goal);
              return FilterChip(
                label: Text(goal),
                selected: isSelected,
                onSelected: isLocked ? null : (val) => _toggleGoal(goal),
                selectedColor: const Color(0xFF6C63FF).withOpacity(0.2),
                checkmarkColor: const Color(0xFF6C63FF),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          if (!isLocked)
            TextField(
              controller: _customGoalController,
              decoration: InputDecoration(
                hintText: 'Nhập mục tiêu riêng của bạn...',
                suffixIcon: IconButton(
                  onPressed: _addCustomGoal,
                  icon: const Icon(Icons.add_circle, color: Color(0xFF6C63FF)),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (_) => _addCustomGoal(),
            ),
          
          const Spacer(),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Đã chọn: ${_selectedGoals.length}/5 mục tiêu',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: (onboardingProvider.status != OnboardingStatus.loading) &&
                      (isLocked || _selectedGoals.length >= 3)
                  ? () async {
                      if (patientId.isEmpty) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Không tìm thấy phiên đăng nhập. Vui lòng đăng nhập lại.')),
                          );
                        }
                        return;
                      }

                      if (isLocked) {
                        context.go('/home');
                        return;
                      }

                      final goalsList = _selectedGoals.toList(growable: false);
                      final ok = await onboardingProvider.saveGoals(patientId, goalsList, token: token);
                      if (!mounted) return;

                      if (ok) {
                        context.go('/psycho-education');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Lỗi: ${onboardingProvider.errorMessage}')),
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
                  : Text(isLocked ? 'Về Trang chủ' : 'Tiếp tục'),
            ),
          ),
        ],
      ),
    );
  }
}
