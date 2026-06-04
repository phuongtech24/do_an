import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:reconnect_app/features/assessment/presentation/providers/assessment_provider.dart';
import 'package:reconnect_app/features/auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/feature_card.dart';
import '../../../../shared/widgets/mindhealth_scaffold.dart';
import '../../../../shared/widgets/therapy_guide_card.dart';


class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  static bool _moodDialogShownThisSession = false;

  double _moodValue = 50.0;
  String _selectedMoodLabel = 'BÃ¬nh thÆ°á»ng';
  bool _hasBoosterAlert = false; // Mock flag for demo

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to show the dialog after the first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_moodDialogShownThisSession) {
        _moodDialogShownThisSession = true;
        _showMoodCheckDialog();
      }
    });
  }

  void _showRecoveryCongratsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber),
            SizedBox(width: 8),
            Text('ChÃºc má»«ng báº¡n!'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Điểm LSAS/Fear Ladder của bạn đang cải thiện. Bạn có nhận thấy mình đã bớt né tránh và dám thử các tình huống xã hội hơn không?',
              style: TextStyle(height: 1.5),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
            child: const Text('TÃ´i Ä‘Ã£ lÃ m Ä‘Æ°á»£c!', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showMoodCheckDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.face_retouching_natural, color: Color(0xFF6C63FF)),
                SizedBox(width: 8),
                Text('Mood Check-in', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'HÃ´m nay báº¡n cáº£m tháº¥y tháº¿ nÃ o? HÃ£y Ä‘Ã¡nh giÃ¡ má»©c Ä‘á»™ tÃ¢m tráº¡ng tá»« 0 - 100.',
                  style: TextStyle(color: Colors.black54),
                ),
                const TherapyGuideCard(
                  title: 'VÃ¬ sao cáº§n check-in?',
                  message:
                      'Theo dÃµi mood giÃºp báº¡n vÃ  chuyÃªn gia nháº­n ra kiá»ƒu máº«u cáº£m xÃºc, Ä‘o tiáº¿n bá»™ vÃ  chá»n cÃ´ng cá»¥ phÃ¹ há»£p trong ngÃ y.',
                  icon: Icons.insights_outlined,
                  accentColor: Color(0xFF6C63FF),
                ),
                const SizedBox(height: 24),
                Text(
                  '${_moodValue.toInt()}%',
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Color(0xFF6C63FF)),
                ),
                Slider(
                  value: _moodValue,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  activeColor: const Color(0xFF6C63FF),
                  onChanged: (value) {
                    setDialogState(() => _moodValue = value);
                    setState(() => _moodValue = value);
                  },
                ),
                const SizedBox(height: 16),
                const Text('Báº¡n Ä‘ang cáº£m tháº¥y tháº¿ nÃ o?', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Vui váº»', 'BÃ¬nh thÆ°á»ng', 'Buá»“n bÃ£', 'Lo Ã¢u', 'Giáº­n dá»¯'].map((label) {
                    final isSelected = _selectedMoodLabel == label;
                    return ChoiceChip(
                      label: Text(label, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : Colors.black87)),
                      selected: isSelected,
                      selectedColor: const Color(0xFF6C63FF),
                      onSelected: (selected) {
                        if (selected) {
                          setDialogState(() => _selectedMoodLabel = label);
                          setState(() => _selectedMoodLabel = label);
                        }
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Bá» qua', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final patientId = authProvider.loginResponse?.user.id ?? '';
                  final token = authProvider.loginResponse?.token;

                  debugPrint('--- MOOD CHECK-IN DEBUG ---');
                  debugPrint('Patient ID from AuthProvider: "$patientId"');

                  if (patientId.isNotEmpty) {
                    final assessmentProvider = Provider.of<AssessmentProvider>(context, listen: false);
                    debugPrint('Submitting mood score: ${_moodValue.toInt()} with label: $_selectedMoodLabel');

                    final success = await assessmentProvider.submitUserMood(
                      patientId,
                      _moodValue.toInt(),
                      'Tráº¡ng thÃ¡i cáº£m xÃºc: $_selectedMoodLabel',
                      token: token,
                    );

                    debugPrint('Submission Success: $success');
                    if (!success) {
                      debugPrint('Submission Error: ${assessmentProvider.errorMessage}');
                    }
                  } else {
                    debugPrint('WARNING: Cannot submit mood because patientId is EMPTY. Are you logged in?');
                  }
                  debugPrint('---------------------------');

                  if (context.mounted) {
                    Navigator.pop(context); // close first dialog
                    _showAISuggestionDialog();
                  }
                },
                child: const Text('Tiáº¿p tá»¥c', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAISuggestionDialog() {
    final isNegative = _moodValue < 45;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isNegative ? Icons.auto_awesome : Icons.stars_rounded,
              color: const Color(0xFF6C63FF)
            ),
            const SizedBox(width: 8),
            Text(isNegative ? 'AI Ä‘á»“ng hÃ nh' : 'Ghi nháº­n tÃ­ch cá»±c'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isNegative
                  ? 'Báº¡n Ä‘ang cáº£m tháº¥y $_selectedMoodLabel. ÄÃ¢y lÃ  lÃºc phÃ¹ há»£p Ä‘á»ƒ ghi láº¡i suy nghÄ© Ä‘ang diá»…n ra vÃ  tÃ¬m cÃ¡ch cÃ¢n báº±ng hÆ¡n. Báº¡n sáºµn lÃ²ng thá»­ khÃ´ng?'
                  : 'Tháº­t tá»‘t khi báº¡n Ä‘ang $_selectedMoodLabel. Báº¡n cÃ³ muá»‘n dÃ nh 1 phÃºt ghi nháº­n nhá»¯ng ná»— lá»±c hoáº·c viá»‡c tÃ­ch cá»±c mÃ¬nh Ä‘Ã£ lÃ m hÃ´m nay khÃ´ng?',
              style: const TextStyle(height: 1.5),
            ),
            TherapyGuideCard(
              title: isNegative ? 'Gá»£i Ã½ Nháº­t kÃ½ suy nghÄ©' : 'Gá»£i Ã½ Credit List',
              message: isNegative
                  ? 'Khi mood tháº¥p, CBT khuyáº¿n khÃ­ch báº¯t â€œsuy nghÄ© tá»± Ä‘á»™ngâ€ Ä‘á»ƒ kiá»ƒm tra xem suy nghÄ© Ä‘Ã³ cÃ³ Ä‘ang kÃ©o cáº£m xÃºc Ä‘i xuá»‘ng khÃ´ng.'
                  : 'Credit List giÃºp báº¡n nhÃ¬n láº¡i cáº£ nhá»¯ng viá»‡c nhá» nhÆ°ng khÃ³ khi Ä‘ang má»‡t, thay vÃ¬ chá»‰ chÃº Ã½ Ä‘iá»u tiÃªu cá»±c.',
              icon: isNegative
                  ? Icons.edit_note_outlined
                  : Icons.playlist_add_check_circle_outlined,
              accentColor: const Color(0xFF6C63FF),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Äá»ƒ sau', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
              if (isNegative) {
                context.push('/agenda-setting');
              } else {
                context.push('/coping-cards'); // Credit Lists are here
              }
            },
            child: Text(isNegative ? 'Äá»“ng Ã½' : 'Ghi nháº­n ngay', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.loginResponse?.user;
    final displayName = user?.username ?? 'CÃ¡o Nhá»';
    final isAnonymous = user?.isAnonymous ?? true;

    return MindHealthScaffold(
      title: 'MindHealth Home',
      actions: [
        IconButton(
          icon: const Icon(Icons.bolt, color: Colors.amber),
          tooltip: 'Demo: Trigger Doctor Alert',
          onPressed: () => setState(() => _hasBoosterAlert = !_hasBoosterAlert),
        ),
      ],
      body: ListView(
        children: [
          if (_hasBoosterAlert)
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notification_important, color: Colors.red),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'BÃ¡c sÄ© yÃªu cáº§u Booster Session',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () => setState(() => _hasBoosterAlert = false),
                      ),
                    ],
                  ),
                  const Text(
                    'Há»‡ thá»‘ng nháº­n tháº¥y chá»‰ sá»‘ rá»§i ro cá»§a báº¡n tÄƒng nháº¹. BÃ¡c sÄ© khuyÃªn báº¡n nÃªn Ã´n táº­p láº¡i ká»¹ nÄƒng Nháº­t kÃ½ suy nghÄ© ngay hÃ´m nay.',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push('/agenda-setting'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                      child: const Text('Báº¯t Ä‘áº§u Ã´n táº­p ngay'),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF6C63FF).withOpacity(0.1),
                child: const Icon(Icons.person_outline, color: Color(0xFF6C63FF)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Xin chÃ o, $displayName!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    isAnonymous ? 'Báº¡n Ä‘ang á»Ÿ cháº¿ Ä‘á»™ áº©n danh' : 'TÃ i khoáº£n chÃ­nh thá»©c (${user?.email ?? ""})',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Mood Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF6C63FF), const Color(0xFF6C63FF).withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('TÃ¢m tráº¡ng hÃ´m nay', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 4),
                      Text('${_moodValue.toInt()}% - ${(_moodValue > 70) ? "Ráº¥t tÃ­ch cá»±c" : (_moodValue > 40) ? "á»”n Ä‘á»‹nh" : "Cáº§n há»— trá»£"}',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _showMoodCheckDialog,
                  icon: const Icon(Icons.edit, color: Colors.white),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          const Text('HOáº T Äá»˜NG CHÃNH', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey, fontSize: 12, letterSpacing: 1.2)),
          const SizedBox(height: 12),

          FeatureCard(
            title: 'Nháº­t kÃ½ Suy nghÄ© 6 bÆ°á»›c',
            subtitle: 'AI Guided Discovery (TÃ¬nh huá»‘ng -> Pháº£n á»©ng)',
            icon: Icons.psychology_outlined,
            onTap: () => context.go('/journal'),
          ),
          FeatureCard(
            title: 'Fear Ladder & thực hành hành vi',
            subtitle: 'Luyện tình huống xã hội từ dễ đến khó',
            icon: Icons.explore_outlined,
            onTap: () => context.go('/roadmap'),
          ),
          FeatureCard(
            title: 'Tháº» Ä‘á»‘i phÃ³ & Ghi nháº­n',
            subtitle: 'Coping Cards & Credit Lists',
            icon: Icons.style_outlined,
            onTap: () => context.push('/coping-cards'),
          ),
          FeatureCard(
            title: 'Tham váº¥n tá»« xa',
            subtitle: 'Äáº·t lá»‹ch háº¹n áº©n danh vá»›i BÃ¡c sÄ©',
            icon: Icons.video_camera_front_outlined,
            onTap: () => context.go('/telehealth'),
          ),

          const SizedBox(height: 24),
          FeatureCard(
            title: 'Re-rating LSAS định kỳ',
            subtitle: 'Cập nhật mức sợ/né tránh mỗi 14 ngày',
            icon: Icons.analytics_outlined,
            onTap: () => context.go('/lsas'),
          ),
          FeatureCard(
            title: 'Tiáº¿n triá»ƒn há»“i phá»¥c',
            subtitle: 'Re-rating LSAS định kỳ',
            icon: Icons.trending_up,
            onTap: () => context.push('/progress'),
          ),
        ],
      ),
    );
  }
}
