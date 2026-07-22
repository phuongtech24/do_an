import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:reconnect_app/features/assessment/presentation/providers/assessment_provider.dart';
import 'package:reconnect_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:reconnect_app/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:reconnect_app/features/onboarding/presentation/utils/onboarding_route_resolver.dart';
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
  bool _isCheckingHomeGate = true;

  double _anxietyScore = 45.0;
  double _avoidanceUrgeScore = 35.0;
  double _sadnessScore = 20.0;
  double _anticipatoryAnxietyScore = 3.0;
  double _postEventRuminationScore = 2.0;
  bool _hasBoosterAlert = false;

  bool get _shouldTriggerSafetyGate => _anxietyScore >= 90 || _sadnessScore >= 90;

  bool get _shouldSuggestThoughtRecord =>
      _anxietyScore >= 70 || _postEventRuminationScore >= 5;

  bool get _shouldSuggestBehavioralExposure =>
      _avoidanceUrgeScore >= 70 || _anticipatoryAnxietyScore >= 5;

  bool get _shouldSuggestEmotionalSoothing => _sadnessScore >= 70;

  bool get _isStableProgress =>
      _anxietyScore < 50 &&
      _avoidanceUrgeScore < 50 &&
      _sadnessScore < 50 &&
      _anticipatoryAnxietyScore < 4 &&
      _postEventRuminationScore < 4;

  String get _dailyCheckInSummary =>
      'Lo âu ${_anxietyScore.toInt()}/100 • '
      'Né tránh ${_avoidanceUrgeScore.toInt()}/100 • '
      'Buồn bã ${_sadnessScore.toInt()}/100 • '
      'Lo âu dự kiến ${_anticipatoryAnxietyScore.toInt()}/8 • '
      'Nhai lại ${_postEventRuminationScore.toInt()}/8 • '
      'Cảm xúc: ${_resolveMoodLabel()}';

  String get _checkInLabel {
    if (_anxietyScore >= 90 || _sadnessScore >= 90) {
      return 'Cần ưu tiên an toàn';
    }
    if (_shouldSuggestThoughtRecord) {
      return 'Cần tháo gỡ nhận thức';
    }
    if (_shouldSuggestBehavioralExposure) {
      return 'Cần phá vỡ né tránh';
    }
    if (_shouldSuggestEmotionalSoothing) {
      return 'Cần điều hòa cảm xúc';
    }
    if (!_isStableProgress) {
      return 'Đang theo dõi';
    }
    return 'Ổn định';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _guardHomeEntry());
  }

  Future<void> _guardHomeEntry() async {
    final decision = await OnboardingRouteResolver.resolve(context);
    if (!mounted) return;

    if (decision.route != '/home') {
      context.go(decision.route);
      return;
    }

    setState(() => _isCheckingHomeGate = false);
    final isReassuranceFlow =
        context.read<OnboardingProvider>().onboardingStatus?.lsasClinicalRoute == 'REASSURANCE';
    if (isReassuranceFlow) {
      return;
    }
    final auth = context.read<AuthProvider>();
    if (auth.pendingDailyCheckinAfterLogin) {
      _showMoodCheckDialog();
    }
  }

  String _resolveMoodLabel() {
    if (_sadnessScore >= 60 && _sadnessScore >= _anxietyScore) {
      return 'Buồn bã';
    }
    if (_avoidanceUrgeScore >= 60 && _avoidanceUrgeScore > _anxietyScore) {
      return 'Muốn né tránh';
    }
    if (_anxietyScore >= 50 || _anticipatoryAnxietyScore >= 4 || _postEventRuminationScore >= 4) {
      return 'Lo âu';
    }
    return 'Ổn định';
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
          'Kết quả kiểm tra và bài thực hành tiếp xúc của bạn đang cải thiện. Bạn có nhận thấy mình đã bớt né tránh và dám thử các tình huống xã hội hơn không?',
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
            scrollable: true,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            title: const Row(
              children: [
                Icon(Icons.face_retouching_natural, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Điểm danh cảm xúc hôm nay', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: SizedBox(
              width: 520,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Hãy ghi nhanh 5 chỉ số để theo dõi cảm xúc hôm nay. Nếu hệ thống thấy mức căng thẳng quá cao, app sẽ ưu tiên hỏi về an toàn trước khi gợi ý bài tập CBT.',
                    style: TextStyle(color: Colors.black54, height: 1.45),
                  ),
                  const SizedBox(height: 12),
                  const TherapyGuideCard(
                    title: 'Vì sao cần điểm danh?',
                    message:
                        'Check-in giúp nhận ra nhanh lo âu, né tránh, buồn bã, lo âu dự kiến và nhai lại sau sự kiện. Khi Anxiety hoặc Sadness quá cao, hệ thống sẽ ưu tiên hỏi về mức độ an toàn của bạn trước.',
                    icon: Icons.insights_outlined,
                    accentColor: AppColors.primary,
                  ),
                  const SizedBox(height: 20),
                  _buildDialogMetricSlider(
                    title: 'Mức lo âu hiện tại',
                    subtitle: '0 = rất nhẹ • 100 = rất cao',
                    value: _anxietyScore,
                    max: 100,
                    divisions: 100,
                    valueLabel: '${_anxietyScore.toInt()}/100',
                    onChanged: (value) {
                      setDialogState(() => _anxietyScore = value);
                      setState(() => _anxietyScore = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildDialogMetricSlider(
                    title: 'Mức thôi thúc né tránh',
                    subtitle: 'Bạn muốn tránh tình huống đó đến mức nào?',
                    value: _avoidanceUrgeScore,
                    max: 100,
                    divisions: 100,
                    valueLabel: '${_avoidanceUrgeScore.toInt()}/100',
                    onChanged: (value) {
                      setDialogState(() => _avoidanceUrgeScore = value);
                      setState(() => _avoidanceUrgeScore = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildDialogMetricSlider(
                    title: 'Mức buồn bã / trầm uất',
                    subtitle: '0 = không buồn • 100 = rất nặng',
                    value: _sadnessScore,
                    max: 100,
                    divisions: 100,
                    valueLabel: '${_sadnessScore.toInt()}/100',
                    onChanged: (value) {
                      setDialogState(() => _sadnessScore = value);
                      setState(() => _sadnessScore = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildDialogMetricSlider(
                    title: 'Lo âu dự kiến trước sự kiện',
                    subtitle: '0 = không có • 8 = rất nhiều',
                    value: _anticipatoryAnxietyScore,
                    max: 8,
                    divisions: 8,
                    valueLabel: '${_anticipatoryAnxietyScore.toInt()}/8',
                    onChanged: (value) {
                      setDialogState(() => _anticipatoryAnxietyScore = value);
                      setState(() => _anticipatoryAnxietyScore = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildDialogMetricSlider(
                    title: 'Nhai lại sau sự kiện',
                    subtitle: '0 = không có • 8 = rất nhiều',
                    value: _postEventRuminationScore,
                    max: 8,
                    divisions: 8,
                    valueLabel: '${_postEventRuminationScore.toInt()}/8',
                    onChanged: (value) {
                      setDialogState(() => _postEventRuminationScore = value);
                      setState(() => _postEventRuminationScore = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'Nhãn cảm xúc hôm nay sẽ được hệ thống tự gán: ${_resolveMoodLabel()}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            actions: [
              TextButton(
                onPressed: () {
                  context.read<AuthProvider>().consumePendingDailyCheckinFlag();
                  Navigator.pop(context);
                },
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
                    String? safetyResponse;
                    if (_shouldTriggerSafetyGate) {
                      safetyResponse = await _showSafetyGateDialog();
                      if (!context.mounted || safetyResponse == null) {
                        return;
                      }
                    }

                    final assessmentProvider = Provider.of<AssessmentProvider>(context, listen: false);
                    await assessmentProvider.submitUserMood(
                      patientId,
                      anxietyScore: _anxietyScore.toInt(),
                      avoidanceUrgeScore: _avoidanceUrgeScore.toInt(),
                      sadnessScore: _sadnessScore.toInt(),
                      anticipatoryAnxietyScore: _anticipatoryAnxietyScore.toInt(),
                      postEventRuminationScore: _postEventRuminationScore.toInt(),
                      dailyAgenda: _dailyCheckInSummary,
                      safetyCheckRequired: _shouldTriggerSafetyGate,
                      safetyResponse: safetyResponse,
                      token: token,
                    );

                    if (!context.mounted) {
                      return;
                    }

                    Navigator.pop(context);
                    authProvider.consumePendingDailyCheckinFlag();
                    if (safetyResponse == 'UNSAFE') {
                      context.go('/safety-support');
                      return;
                    }
                  }

                  if (context.mounted) {
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

  Widget _buildDialogMetricSlider({
    required String title,
    required String subtitle,
    required double value,
    required double max,
    required int divisions,
    required String valueLabel,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Text(
                valueLabel,
                style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
            ],
          ),
          Slider(
            value: value,
            min: 0,
            max: max,
            divisions: divisions,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Future<String?> _showSafetyGateDialog() async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.health_and_safety_outlined, color: AppColors.warning),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Kiểm tra an toàn',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: const Text(
          'Chúng tôi nhận thấy cảm xúc của bạn đang rất căng thẳng. Hiện tại bạn có đang cảm thấy an toàn không, hay đang có những suy nghĩ muốn bỏ cuộc/làm hại bản thân?',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'SAFE'),
            child: const Text('Tôi đang an toàn'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'UNSAFE'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.alert,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tôi không an toàn'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAISuggestionDialog() async {
    final shouldOpenThoughtRecord = _shouldSuggestThoughtRecord;
    final shouldOpenBehavioralExposure =
        !shouldOpenThoughtRecord && _shouldSuggestBehavioralExposure;
    final shouldOpenEmotionalSoothing =
        !shouldOpenThoughtRecord &&
        !shouldOpenBehavioralExposure &&
        _shouldSuggestEmotionalSoothing;
    final isStableProgress =
        !shouldOpenThoughtRecord &&
        !shouldOpenBehavioralExposure &&
        !shouldOpenEmotionalSoothing &&
        _isStableProgress;

    IconData dialogIcon;
    String dialogTitle;
    String dialogMessage;
    String guideTitle;
    String guideMessage;
    String primaryLabel;
    String? targetRoute;
    Map<String, dynamic>? targetExtra;

    if (shouldOpenThoughtRecord) {
      dialogIcon = Icons.psychology_alt_outlined;
      dialogTitle = 'Bạn đang có xu hướng lo âu hoặc nhai lại';
      dialogMessage =
          'Điểm điểm danh cho thấy bạn đang có xu hướng lo âu cao hoặc nhai lại sự việc sau giao tiếp. Đây là thời điểm phù hợp để chuyển thẳng sang Nhật ký suy nghĩ CBT 6 bước.';
      guideTitle = 'Gợi ý Nhật ký suy nghĩ';
      guideMessage =
          'Nhật ký 6 bước sẽ giúp bạn bóc tách suy nghĩ tự động, nhận diện méo mó nhận thức và viết phản hồi thích nghi dựa trên bằng chứng.';
      primaryLabel = 'Mở Nhật ký suy nghĩ';
      targetRoute = '/thought-record';
      targetExtra = {
        'anxietyScore': _anxietyScore.toInt(),
        'avoidanceUrgeScore': _avoidanceUrgeScore.toInt(),
        'anticipatoryAnxietyScore': _anticipatoryAnxietyScore.toInt(),
        'postEventRuminationScore': _postEventRuminationScore.toInt(),
      };
    } else if (shouldOpenBehavioralExposure) {
      dialogIcon = Icons.directions_run_outlined;
      dialogTitle = 'Bạn đang có xu hướng né tránh';
      dialogMessage =
          'Hệ thống ghi nhận mức né tránh hoặc lo âu dự đoán đang cao. Đây là lúc phù hợp để chuyển sang nấc tiếp theo trên Thang sợ hãi và thực hành đối mặt có kiểm soát.';
      guideTitle = 'Gợi ý thực hành tiếp xúc';
      guideMessage =
          'Fear Ladder giúp bạn đi từ bước dễ tới bước khó hơn, phá vỡ khuynh hướng né tránh bằng những trải nghiệm thực tế có cấu trúc.';
      primaryLabel = 'Đi tới Thang sợ hãi';
      targetRoute = '/roadmap';
    } else if (shouldOpenEmotionalSoothing) {
      dialogIcon = Icons.spa_outlined;
      dialogTitle = 'Bạn cần điều hòa cảm xúc trước';
      dialogMessage =
          'Mức buồn bã của bạn hôm nay đang khá cao. Hệ thống ưu tiên các công cụ làm dịu nhanh như thư giãn ngắn và Thẻ đối phó trước khi mở bài tập sâu hơn.';
      guideTitle = 'Thư giãn ngay';
      guideMessage =
          'Bạn có thể đọc nhanh Thẻ đối phó hoặc dùng bài tập điều hòa để hạ nhiệt cảm xúc trước, rồi quay lại lộ trình khi đã ổn định hơn.';
      primaryLabel = 'Mở Thẻ đối phó';
      targetRoute = '/coping-cards';
    } else if (isStableProgress) {
      dialogIcon = Icons.favorite_outline;
      dialogTitle = 'Tiến trình hôm nay đang ổn định';
      dialogMessage =
          'Các chỉ số cảm xúc của bạn hôm nay khá cân bằng. Hãy tiếp tục duy trì các thói quen tự lực hằng ngày để củng cố tiến bộ này.';
      guideTitle = 'Thông điệp khích lệ';
      guideMessage =
          'Hôm nay hệ thống chưa mở thêm nhánh can thiệp mới. Bạn có thể tiếp tục lộ trình hiện tại hoặc đọc lại các công cụ đã lưu.';
      primaryLabel = 'Xem lộ trình';
      targetRoute = '/roadmap';
    } else {
      dialogIcon = Icons.insights_outlined;
      dialogTitle = 'Tiếp tục theo dõi thêm';
      dialogMessage =
          'Hôm nay bạn đang ở vùng theo dõi. Hệ thống sẽ lưu lại dữ liệu cảm xúc và chờ thêm các lần check-in tiếp theo để điều hướng chính xác hơn.';
      guideTitle = 'Theo dõi liên tục';
      guideMessage =
          'Bạn vẫn có thể chủ động mở lộ trình, nhật ký suy nghĩ hoặc Thẻ đối phó nếu muốn tự hỗ trợ ngay lúc này.';
      primaryLabel = 'Đóng';
      targetRoute = null;
    }

    final shouldNavigate = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(dialogIcon, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(dialogTitle)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dialogMessage,
              style: const TextStyle(height: 1.5),
            ),
            const SizedBox(height: 12),
            TherapyGuideCard(
              title: guideTitle,
              message: guideMessage,
              icon: dialogIcon,
              accentColor: AppColors.primary,
            ),
            if (shouldOpenEmotionalSoothing)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  'Nếu bạn muốn, sau khi thư giãn xong có thể quay lại viết Nhật ký suy nghĩ hoặc tiếp tục lộ trình Fear Ladder.',
                  style: TextStyle(color: AppColors.textSecondary, height: 1.45),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Để sau', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(primaryLabel, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldNavigate == true && mounted && targetRoute != null) {
      context.push(targetRoute, extra: targetExtra);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingHomeGate) {
      return const MindHealthScaffold(
        title: 'Trang chủ',
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final auth = Provider.of<AuthProvider>(context);
    final user = auth.loginResponse?.user;
    final profile = auth.patientProfile;
    final displayName = profile?.nickname.isNotEmpty == true
        ? profile!.nickname
        : (user?.username ?? 'Cáo Nhỏ');
    final isAnonymous = profile?.anonymousModeEnabled ?? (user?.isAnonymous ?? true);
    final checkInLabel = _checkInLabel;

    return MindHealthScaffold(
      title: 'ReConnect MindHealth',
      actions: [
        IconButton(
          icon: const Icon(Icons.emoji_events_outlined, color: Colors.amber),
          tooltip: 'Chúc mừng tiến bộ',
          onPressed: _showRecoveryCongratsDialog,
        ),
        IconButton(
          icon: const Icon(Icons.bolt, color: Colors.amber),
          tooltip: 'Cảnh báo từ bác sĩ',
          onPressed: () => setState(() => _hasBoosterAlert = !_hasBoosterAlert),
        ),
        IconButton(
          icon: const Icon(Icons.smart_toy_rounded, color: AppColors.primary),
          tooltip: 'Trợ lý đồng hành',
          onPressed: () => context.push('/cbt-chat?screen=home'),
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
                subtitle: 'Vào thẳng nhật ký 6 bước để gỡ vòng lặp lo âu xã hội.',
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
            subtitle: 'Nhìn lại bài kiểm tra, bài thực hành tiếp xúc và các chỉ số hồi phục theo chu kỳ.',
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
                  title: 'Đánh giá lại lo âu định kỳ',
                  subtitle: 'Cập nhật mức sợ và né tránh mỗi 14 ngày',
                  icon: Icons.analytics_outlined,
                  onTap: () => context.go('/lsas'),
                ),
                const SizedBox(height: 12),
                FeatureCard(
                  title: 'Tiến trình Phục hồi LSAS',
                  subtitle: 'Theo dõi mức độ Lo âu xã hội của bạn giảm dần qua các tuần trị liệu',
                  icon: Icons.trending_up,
                  onTap: () => context.push('/progress'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TherapyGuideCard(
            title: 'Nhắc nhở hôm nay',
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
                  'Bác sĩ yêu cầu buổi ôn tập',
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
              onPressed: () => context.push('/thought-record'),
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
                  label: 'Lo âu hôm nay',
                  value: '${_anxietyScore.toInt()}/100',
                  note: checkInLabel,
                  icon: Icons.favorite_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  label: 'Buồn bã hôm nay',
                  value: '${_sadnessScore.toInt()}/100',
                  note: 'Theo dõi an toàn',
                  icon: Icons.cloud_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.insights_outlined, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _dailyCheckInSummary,
                    style: const TextStyle(color: Colors.white, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  label: 'Lo âu dự kiến',
                  value: '${_anticipatoryAnxietyScore.toInt()}/8',
                  note: 'Nhai lại ${_postEventRuminationScore.toInt()}/8',
                  icon: Icons.auto_graph_rounded,
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
            label: const Text('Cập nhật cảm xúc hôm nay'),
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

