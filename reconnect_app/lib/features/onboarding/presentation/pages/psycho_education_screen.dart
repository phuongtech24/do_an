import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/therapy_guide_card.dart';
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
      'title': 'Mô hình nhận thức',
      'description':
          'Không chỉ sự kiện làm bạn thay đổi cảm xúc, mà còn là cách bạn diễn giải sự kiện đó.',
      'guide':
          'CBT luyện bạn nhìn lại chuỗi: tình huống → suy nghĩ → cảm xúc → hành vi. Khi nhận ra mắt xích “suy nghĩ”, bạn có thêm lựa chọn để phản ứng khác đi.',
      'icon': '🧠',
    },
    {
      'title': 'Vòng lặp tiêu cực',
      'description':
          'Suy nghĩ tiêu cực có thể kéo cảm xúc đi xuống, khiến bạn thu mình lại và mệt hơn.',
      'guide':
          'MindHealth không thay chuyên gia. App giúp bạn luyện kỹ năng nhỏ mỗi ngày để theo dõi cảm xúc và phá vòng lặp tiêu cực từng bước.',
      'icon': '🔄',
    },
    {
      'title': 'Nhật ký suy nghĩ',
      'description':
          'Bạn sẽ học cách nhận diện lỗi tư duy và viết phản hồi cân bằng hơn cho suy nghĩ tự động.',
      'guide':
          'Nhật ký suy nghĩ là nơi bạn thực hành bắt suy nghĩ tự động, kiểm tra bằng chứng và viết phản hồi thích nghi.',
      'icon': '💡',
    },
    {
      'title': 'Kích hoạt hành vi',
      'description':
          'Các nhiệm vụ nhỏ mỗi ngày giúp bạn bắt đầu hành động, ghi nhận nỗ lực và xây lại sự tự tin.',
      'guide':
          'Roadmap giao bài tập vừa sức. Mục tiêu là bắt đầu bằng hành động nhỏ, không phải làm hoàn hảo.',
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
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 36),
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
                        const SizedBox(height: 18),
                        TherapyGuideCard(
                          title: 'Gợi ý sử dụng',
                          message: page['guide']!,
                          icon: Icons.psychology_alt_outlined,
                          accentColor: const Color(0xFF6C63FF),
                          dismissible: true,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? const Color(0xFF6C63FF)
                        : Colors.grey[300],
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
                      return;
                    }

                    if (patientId.isEmpty) {
                      context.go('/auth');
                      return;
                    }

                    setState(() => _isSubmitting = true);
                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                      final ok = await onboardingProvider.completePsychoeducation(
                        patientId,
                        token: token,
                      );
                      if (!mounted) return;
                      setState(() => _isSubmitting = false);
                      if (ok) {
                        context.go('/therapist-matching');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Lỗi: ${onboardingProvider.errorMessage}',
                            ),
                          ),
                        );
                      }
                    });
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: (_currentPage == _pages.length - 1 && _isSubmitting)
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _currentPage == _pages.length - 1
                              ? 'Bắt đầu ngay'
                              : 'Tiếp theo',
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
