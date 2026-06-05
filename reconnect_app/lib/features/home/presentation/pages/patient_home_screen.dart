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
  String _selectedMoodLabel = 'Bình thường';
  bool _hasBoosterAlert = false;

  @override
  void initState() {
    super.initState();
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
            Text('Chúc mừng bạn!'),
          ],
        ),
        content: const Text(
          'Điểm LSAS/Fear Ladder của bạn đang cải thiện. Bạn có nhận thấy mình đã bớt né tránh và dám thử các tình huống xã hội hơn không?',
          style: TextStyle(height: 1.5),
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
                Text('Daily Check-in', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Hôm nay mức lo âu/né tránh của bạn đang ở đâu? Hãy chấm nhanh từ 0–100 để theo dõi tiến triển.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 12),
                const TherapyGuideCard(
                  title: 'Vì sao cần check-in?',
                  message:
                      'Check-in giúp bạn và chuyên gia nhận ra kiểu mẫu lo âu, né tránh, lo âu dự kiến và nhai lại sau sự kiện. Nếu chỉ số tăng cao, app sẽ gợi ý công cụ phù hợp trong ngày.',
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

                  if (patientId.isNotEmpty) {
                    final assessmentProvider = Provider.of<AssessmentProvider>(context, listen: false);
                    await assessmentProvider.submitUserMood(
                      patientId,
                      _moodValue.toInt(),
                      'Trạng thái cảm xúc: $_selectedMoodLabel',
                      token: token,
                    );
                  }

                  if (context.mounted) {
                    Navigator.pop(context);
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
    final isHighAnxiety = _moodValue < 45 || _selectedMoodLabel == 'Lo âu';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(isHighAnxiety ? Icons.auto_awesome : Icons.stars_rounded, color: const Color(0xFF6C63FF)),
            const SizedBox(width: 8),
            Text(isHighAnxiety ? 'AI đồng hành' : 'Ghi nhận tích cực'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isHighAnxiety
                  ? 'Bạn đang cảm thấy $_selectedMoodLabel. Đây là lúc phù hợp để viết Nhật ký Lo âu Xã hội, kiểm tra dự đoán và nhận diện hành vi an toàn.'
                  : 'Thật tốt khi bạn đang $_selectedMoodLabel. Bạn có muốn dành 1 phút ghi nhận những nỗ lực hoặc việc tích cực mình đã làm hôm nay không?',
              style: const TextStyle(height: 1.5),
            ),
            const SizedBox(height: 12),
            TherapyGuideCard(
              title: isHighAnxiety ? 'Gợi ý Nhật ký Lo âu Xã hội' : 'Gợi ý Credit List',
              message: isHighAnxiety
                  ? 'Khi lo âu tăng, CBT khuyến khích bắt dự đoán tồi tệ nhất, quan sát self-focus và thử giảm bớt safety behaviors.'
                  : 'Credit List giúp bạn nhìn lại cả những việc nhỏ nhưng khó khi đang mệt, thay vì chỉ chú ý điều tiêu cực.',
              icon: isHighAnxiety ? Icons.edit_note_outlined : Icons.playlist_add_check_circle_outlined,
              accentColor: const Color(0xFF6C63FF),
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
              if (isHighAnxiety) {
                context.push('/agenda-setting');
              } else {
                context.push('/coping-cards');
              }
            },
            child: Text(isHighAnxiety ? 'Đồng ý' : 'Ghi nhận ngay', style: const TextStyle(color: Colors.white)),
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
          tooltip: 'Demo: bật/tắt cảnh báo bác sĩ',
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
                      const Text('Check-in hôm nay', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 4),
                      Text(
                        '${_moodValue.toInt()}% - ${(_moodValue > 70) ? "Rất tích cực" : (_moodValue > 40) ? "Ổn định" : "Cần hỗ trợ"}',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
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
            title: 'Nhật ký Lo âu Xã hội',
            subtitle: 'Clark & Wells: dự đoán → self-focus → safety behaviors',
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
            title: 'Re-rating LSAS định kỳ',
            subtitle: 'Cập nhật mức sợ/né tránh mỗi 14 ngày',
            icon: Icons.analytics_outlined,
            onTap: () => context.go('/lsas'),
          ),
          FeatureCard(
            title: 'Tiến triển hồi phục',
            subtitle: 'Theo dõi LSAS/Fear Ladder theo thời gian',
            icon: Icons.trending_up,
            onTap: () => context.push('/progress'),
          ),
        ],
      ),
    );
  }
}
