import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/onboarding_provider.dart';

class PsychoeducationScreen extends StatefulWidget {
  const PsychoeducationScreen({super.key});

  @override
  State<PsychoeducationScreen> createState() => _PsychoeducationScreenState();
}

class _PsychoeducationScreenState extends State<PsychoeducationScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isSubmitting = false;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Mô hình Nhận thức',
      'description': 'Bạn có biết? Không phải sự kiện gây ra cảm xúc của bạn, mà là cách bạn SUY NGHĨ về nó.',
      'image': 'assets/images/cbt_model.png', // Placeholder
      'icon': '🧠',
    },
    {
      'title': 'Vòng lặp tiêu cực',
      'description': 'Suy nghĩ tiêu cực dẫn đến Cảm xúc tệ, khiến bạn thu mình lại (Hành vi) và gây ra các Triệu chứng cơ thể.',
      'image': 'assets/images/loop.png',
      'icon': '🔄',
    },
    {
      'title': 'Chúng ta sẽ làm gì?',
      'description': 'MindHealth sẽ giúp bạn nhận diện các "Lỗi tư duy" và thay thế chúng bằng những suy nghĩ khách quan hơn.',
      'image': 'assets/images/solution.png',
      'icon': '💡',
    },
    {
      'title': 'Kích hoạt hành vi',
      'description': 'Bằng cách thực hiện các nhiệm vụ nhỏ mỗi ngày, bạn sẽ dần lấy lại niềm vui và sự tự tin.',
      'image': 'assets/images/roadmap.png',
      'icon': '🚀',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final patientId = auth.loginResponse?.user.id ?? '';
    final token = auth.loginResponse?.token;
    final onboardingProvider = Provider.of<OnboardingProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          page['icon']!,
                          style: const TextStyle(fontSize: 80),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          page['title']!,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6C63FF),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          page['description']!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? const Color(0xFF6C63FF) : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            
            const SizedBox(height: 40),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      if (patientId.isEmpty) {
                        context.go('/auth');
                        return;
                      }
                      setState(() => _isSubmitting = true);
                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                        final ok = await onboardingProvider.completePsychoeducation(patientId, token: token);
                        if (!mounted) return;
                        setState(() => _isSubmitting = false);
                        if (ok) {
                          context.go('/home');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Lỗi: ${onboardingProvider.errorMessage}')),
                          );
                        }
                      });
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: (_currentPage == _pages.length - 1 && _isSubmitting)
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(_currentPage == _pages.length - 1 ? 'Bắt đầu ngay' : 'Tiếp theo'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
