import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:reconnect_app/features/assessment/presentation/providers/assessment_provider.dart';
import 'package:reconnect_app/features/auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/feature_card.dart';
import '../../../../shared/widgets/mindhealth_scaffold.dart';


class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  double _moodValue = 50.0;
  String _selectedMoodLabel = 'Bình thường';
  bool _hasBoosterAlert = false; // Mock flag for demo

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to show the dialog after the first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showMoodCheckDialog();
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
            Text('Chúc mừng bạn!'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Chỉ số PHQ-9 của bạn đã giảm xuống mức an toàn. Bạn có nhận thấy rằng tâm trạng bạn cải thiện là do bạn đã thay đổi cách suy nghĩ và hành vi trong thời gian qua không?',
              style: TextStyle(height: 1.5),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
            child: const Text('Tôi đã làm được!', style: TextStyle(color: Colors.white)),
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
                  'Hôm nay bạn cảm thấy thế nào? Hãy đánh giá mức độ tâm trạng từ 0 - 100.',
                  style: TextStyle(color: Colors.black54),
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
                const Text('Bạn đang cảm thấy thế nào?', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Vui vẻ', 'Bình thường', 'Buồn bã', 'Lo âu', 'Giận dữ'].map((label) {
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
                child: const Text('Bỏ qua', style: TextStyle(color: Colors.grey)),
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
                      'Trạng thái cảm xúc: $_selectedMoodLabel',
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
                child: const Text('Tiếp tục', style: TextStyle(color: Colors.white)),
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
            Text(isNegative ? 'AI đồng hành' : 'Ghi nhận tích cực'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isNegative 
                ? 'Bạn đang cảm thấy $_selectedMoodLabel. Đây là cơ hội tốt để cùng AI ghi lại những gì đang diễn ra trong đầu và tìm cách cân bằng lại. Bạn sẵn lòng chứ?'
                : 'Thật tuyệt vời khi thấy bạn đang $_selectedMoodLabel! Để củng cố năng lượng tích cực này, bạn có muốn dành 1 phút ghi nhận những việc tốt mình đã làm hôm nay không?',
              style: const TextStyle(height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Để sau', style: TextStyle(color: Colors.grey)),
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
            child: Text(isNegative ? 'Đồng ý' : 'Ghi nhận ngay', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.loginResponse?.user;
    final displayName = user?.username ?? 'Cáo Nhỏ';
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
                          'Bác sĩ yêu cầu Booster Session',
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
                    'Hệ thống nhận thấy chỉ số rủi ro của bạn tăng nhẹ. Bác sĩ khuyên bạn nên ôn tập lại kỹ năng Nhật ký suy nghĩ ngay hôm nay.',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push('/agenda-setting'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                      child: const Text('Bắt đầu ôn tập ngay'),
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
                    'Xin chào, $displayName!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    isAnonymous ? 'Bạn đang ở chế độ ẩn danh' : 'Tài khoản chính thức (${user?.email ?? ""})',
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
                      const Text('Tâm trạng hôm nay', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 4),
                      Text('${_moodValue.toInt()}% - ${(_moodValue > 70) ? "Rất tích cực" : (_moodValue > 40) ? "Ổn định" : "Cần hỗ trợ"}', 
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
          const Text('HOẠT ĐỘNG CHÍNH', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey, fontSize: 12, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          
          FeatureCard(
            title: 'Nhật ký Suy nghĩ 6 bước',
            subtitle: 'AI Guided Discovery (Tình huống -> Phản ứng)',
            icon: Icons.psychology_outlined,
            onTap: () => context.go('/journal'),
          ),
          FeatureCard(
            title: 'Lộ trình CBT Roadmap',
            subtitle: 'Kích hoạt hành vi & Phác đồ tự động',
            icon: Icons.explore_outlined,
            onTap: () => context.go('/roadmap'),
          ),
          FeatureCard(
            title: 'Thẻ đối phó & Ghi nhận',
            subtitle: 'Coping Cards & Credit Lists',
            icon: Icons.style_outlined,
            onTap: () => context.push('/coping-cards'),
          ),
          FeatureCard(
            title: 'Tham vấn từ xa',
            subtitle: 'Đặt lịch hẹn ẩn danh với Bác sĩ',
            icon: Icons.video_camera_front_outlined,
            onTap: () => context.go('/telehealth'),
          ),
          
          const SizedBox(height: 24),
          FeatureCard(
            title: 'Kiểm tra PHQ-9 định kỳ',
            subtitle: 'Đánh giá lại mức độ Lo âu/Trầm cảm',
            icon: Icons.analytics_outlined,
            onTap: () => context.go('/phq9'),
          ),
          FeatureCard(
            title: 'Tiến triển hồi phục',
            subtitle: 'Biểu đồ PHQ-9 & Phân tích phục hồi',
            icon: Icons.trending_up,
            onTap: () => context.push('/progress'),
          ),
        ],
      ),
    );
  }
}

