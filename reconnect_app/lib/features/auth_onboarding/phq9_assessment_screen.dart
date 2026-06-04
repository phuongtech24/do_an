import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';

class PHQ9AssessmentScreen extends StatefulWidget {
  const PHQ9AssessmentScreen({super.key});

  @override
  State<PHQ9AssessmentScreen> createState() => _PHQ9AssessmentScreenState();
}

class _PHQ9AssessmentScreenState extends State<PHQ9AssessmentScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  List<int?> _answers = List.filled(9, null);

  final List<String> _questions = [
    "Ãt há»©ng thÃº hoáº·c niá»m vui trong viá»‡c lÃ m má»i thá»©.",
    "Cáº£m tháº¥y buá»“n ráº§u, chÃ¡n náº£n hoáº·c tuyá»‡t vá»ng.",
    "KhÃ³ Ä‘i vÃ o giáº¥c ngá»§ hoáº·c ngá»§ khÃ´ng yÃªn, hoáº·c ngá»§ quÃ¡ nhiá»u.",
    "Cáº£m tháº¥y má»‡t má»i hoáº·c cÃ³ Ã­t nÄƒng lÆ°á»£ng.",
    "Ä‚n kÃ©m ngon miá»‡ng hoáº·c Äƒn quÃ¡ nhiá»u.",
    "Cáº£m tháº¥y tá»“i tá»‡ vá» báº£n thÃ¢n, hoáº·c cho ráº±ng mÃ¬nh lÃ  ngÆ°á»i tháº¥t báº¡i.",
    "KhÃ³ táº­p trung vÃ o má»i viá»‡c, cháº³ng háº¡n nhÆ° Ä‘á»c bÃ¡o hoáº·c xem tivi.",
    "Di chuyá»ƒn hoáº·c nÃ³i nÄƒng cháº­m cháº¡p Ä‘áº¿n má»©c ngÆ°á»i khÃ¡c cÃ³ thá»ƒ nháº­n tháº¥y.",
    "CÃ³ Ã½ nghÄ© ráº±ng báº¡n thÃ  cháº¿t Ä‘i cho xong hoáº·c muá»‘n lÃ m tá»•n thÆ°Æ¡ng báº£n thÃ¢n theo cÃ¡ch nÃ o Ä‘Ã³."
  ];

  final List<String> _options = [
    "HoÃ n toÃ n khÃ´ng (0)",
    "VÃ i ngÃ y (1)",
    "HÆ¡n má»™t ná»­a sá»‘ ngÃ y (2)",
    "Gáº§n nhÆ° má»—i ngÃ y (3)"
  ];

  void _answerQuestion(int score) {
    setState(() {
      _answers[_currentIndex] = score;
    });
    
    if (_currentIndex < _questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      // Calculate total and mock
      int total = _answers.map((e) => e ?? 0).reduce((a, b) => a + b);
      _showResultDialog(total);
    }
  }

  void _showResultDialog(int score) {
    String severity = "";
    if (score <= 4) severity = "BÃ¬nh thÆ°á»ng";
    else if (score <= 9) severity = "Nháº¹";
    else if (score <= 14) severity = "Vá»«a";
    else if (score <= 19) severity = "Náº·ng";
    else severity = "Ráº¥t náº·ng";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('HoÃ n táº¥t Ä‘Ã¡nh giÃ¡ Baseline'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Äiá»ƒm LSAS cá»§a báº¡n: $score/144', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text('Má»©c Ä‘á»™: $severity', style: const TextStyle(color: AppColors.secondary, fontSize: 16)),
            const SizedBox(height: 16),
            const Text('Há»‡ thá»‘ng Ä‘Ã£ lÆ°u láº¡i má»©c Ä‘á»™ nÃ y. ChÃºng tÃ´i sáº½ thiáº¿t káº¿ Fear Ladder phÃ¹ há»£p riÃªng cho báº¡n!'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              context.go('/chat'); // Go to Main App (Chat tab)
            },
            child: const Text('Báº®T Äáº¦U HÃ€NH TRÃŒNH'),
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
        title: Text('ÄÃ¡nh giÃ¡ LSAS (${_currentIndex + 1}/${_questions.length})'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _questions.length,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
              minHeight: 8,
            ),
            
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Disable swipe
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Trong 2 tuáº§n qua, báº¡n cÃ³ thÆ°á»ng xuyÃªn bá»‹ lÃ m phiá»n bá»Ÿi váº¥n Ä‘á» sau Ä‘Ã¢y khÃ´ng?",
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Text(
                            _questions[index],
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 22),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 48),
                        
                        ...List.generate(_options.length, (optIndex) {
                          bool isSelected = _answers[index] == optIndex;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: OutlinedButton(
                              onPressed: () => _answerQuestion(optIndex),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
                                side: BorderSide(
                                  color: isSelected ? AppColors.primary : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                _options[optIndex],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
