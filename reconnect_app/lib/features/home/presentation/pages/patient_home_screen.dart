import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:reconnect_app/features/assessment/presentation/providers/assessment_provider.dart';
import 'package:reconnect_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:reconnect_app/theme/app_colors.dart';
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
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
                Icon(Icons.face_retouching_natural, color: AppColors.primary),
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
                  accentColor: AppColors.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  '${_moodValue.toInt()}%',
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: AppColors.primary),
                ),
                Slider(
                  value: _moodValue,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  activeColor: AppColors.primary,
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
                      label: Text(
                        label,
                        style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : Colors.black87),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
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
                  backgroundColor: AppColors.primary,
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
            Icon(isHighAnxiety ? Icons.auto_awesome : Icons.stars_rounded, color: AppColors.primary),
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
              accentColor: AppColors.primary,
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
              backgroundColor: AppColors.primary,
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
    final checkInLabel = _moodValue > 70
        ? 'Rất tích cực'
        : (_moodValue > 40 ? 'Ổn định' : 'Cần hỗ trợ');

    return MindHealthScaffold(
      title: 'ReConnect MindHealth',
      actions: [
        IconButton(
          icon: const Icon(Icons.emoji_events_outlined, color: Colors.amber),
          tooltip: 'Demo: chúc mừng phục hồi',
          onPressed: _showRecoveryCongratsDialog,
        ),
        IconButton(
          icon: const Icon(Icons.bolt, color: Colors.amber),
          tooltip: 'Demo: bật/tắt cảnh báo bác sĩ',
          onPressed: () => setState(() => _hasBoosterAlert = !_hasBoosterAlert),
        ),
      ],
      body: ListView(
        children: [
          if (_hasBoosterAlert) _buildBoosterAlert(),
          _buildHeroCard(displayName: displayName, userEmail: user?.email ?? '', isAnonymous: isAnonymous, checkInLabel: checkInLabel),
          const SizedBox(height: 24),
          _buildSectionHeader(
            title: 'Hôm nay bạn muốn bắt đầu từ đâu?',
            subtitle: 'Các tính năng được nhóm theo hành trình CBT để bạn thao tác nhanh hơn.',
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.04,
            children: [
              _buildQuickActionCard(
                title: 'Nhật ký Lo âu Xã hội',
                subtitle: 'Ghi lại dự đoán, self-focus và safety behaviors.',
                icon: Icons.psychology_outlined,
                onTap: () => context.go('/journal'),
              ),
              _buildQuickActionCard(
                title: 'Fear Ladder hôm nay',
                subtitle: 'Xem nấc thang đang mở và bài thực hành gần nhất.',
                icon: Icons.alt_route_rounded,
                onTap: () => context.go('/roadmap'),
              ),
              _buildQuickActionCard(
                title: 'Thẻ đối phó',
                subtitle: 'Mở coping cards và credit list khi cần tự ổn định.',
                icon: Icons.style_outlined,
                onTap: () => context.push('/coping-cards'),
              ),
              _buildQuickActionCard(
                title: 'Tham vấn từ xa',
                subtitle: 'Đặt lịch với chuyên gia và theo dõi buổi hẹn sắp tới.',
                icon: Icons.video_camera_front_outlined,
                onTap: () => context.go('/telehealth'),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _buildSectionHeader(
            title: 'Theo dõi tiến triển',
            subtitle: 'Nhìn lại LSAS, Fear Ladder và các chỉ số hồi phục theo chu kỳ.',
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primary.withOpacity(0.08)),
            ),
            child: Column(
              children: [
                FeatureCard(
                  title: 'Re-rating LSAS định kỳ',
                  subtitle: 'Cập nhật mức sợ và né tránh mỗi 14 ngày',
                  icon: Icons.analytics_outlined,
                  onTap: () => context.go('/lsas'),
                ),
                const SizedBox(height: 12),
                FeatureCard(
                  title: 'Tiến triển hồi phục',
                  subtitle: 'Theo dõi LSAS và Fear Ladder theo thời gian',
                  icon: Icons.trending_up,
                  onTap: () => context.push('/progress'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TherapyGuideCard(
            title: 'Nhắc nhẹ hôm nay',
            message:
                'Bạn không cần làm mọi thứ cùng lúc. Hãy chọn một bước nhỏ nhất trong Fear Ladder hoặc hoàn thành một check-in trung thực.',
            icon: Icons.spa_outlined,
            accentColor: AppColors.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildBoosterAlert() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF6F5), Color(0xFFFFEEEE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.alert.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.notification_important, color: AppColors.alert),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Bác sĩ yêu cầu Booster Session',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.alert),
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
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.alert, foregroundColor: Colors.white),
              child: const Text('Bắt đầu ôn tập ngay'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard({
    required String displayName,
    required String userEmail,
    required bool isAnonymous,
    required String checkInLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF159489)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withOpacity(0.16),
                child: const Icon(Icons.person_outline, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xin chào, $displayName',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAnonymous ? 'Bạn đang ở chế độ ẩn danh an toàn' : 'Tài khoản chính thức ($userEmail)',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_outlined, size: 16, color: Colors.white),
                    SizedBox(width: 6),
                    Text('Bảo mật', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  label: 'Check-in hôm nay',
                  value: '${_moodValue.toInt()}%',
                  note: checkInLabel,
                  icon: Icons.favorite_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  label: 'Gợi ý hiện tại',
                  value: _selectedMoodLabel,
                  note: 'Cập nhật theo cảm xúc',
                  icon: Icons.auto_awesome_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: _showMoodCheckDialog,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white30),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Cập nhật check-in'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textSecondary,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required String note,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(note, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primary.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.04),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Text(
                    'Mở ngay',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, color: AppColors.primary, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
