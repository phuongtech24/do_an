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

  bool get _shouldSuggestThoughtRecord => _anticipatoryAnxietyScore >= 6 || _postEventRuminationScore >= 6;

  bool get _shouldSuggestCopingCards => _anticipatoryAnxietyScore <= 3 && _postEventRuminationScore <= 3;

  bool get _shouldOfferChoice =>
      !_shouldSuggestThoughtRecord &&
      !_shouldSuggestCopingCards &&
      (_anticipatoryAnxietyScore >= 4 || _postEventRuminationScore >= 4);

  String get _dailyCheckInSummary =>
      'Lo Ã¢u ${_anxietyScore.toInt()}/100 â€¢ '
      'NÃ© trÃ¡nh ${_avoidanceUrgeScore.toInt()}/100 â€¢ '
      'Buá»“n bÃ£ ${_sadnessScore.toInt()}/100 â€¢ '
      'Lo Ã¢u dá»± kiáº¿n ${_anticipatoryAnxietyScore.toInt()}/8 â€¢ '
      'Nhai láº¡i ${_postEventRuminationScore.toInt()}/8 â€¢ '
      'Cáº£m xÃºc: ${_resolveMoodLabel()}';

  String get _checkInLabel {
    if (_anxietyScore >= 90 || _sadnessScore >= 90) {
      return 'Cáº§n Æ°u tiÃªn an toÃ n';
    }
    if (_anxietyScore >= 70 || _sadnessScore >= 70 || _avoidanceUrgeScore >= 70) {
      return 'Cáº§n há»— trá»£';
    }
    if (_anxietyScore >= 40 || _sadnessScore >= 40 || _avoidanceUrgeScore >= 40) {
      return 'Äang theo dÃµi';
    }
    return 'á»”n Ä‘á»‹nh';
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
      return 'Buá»“n bÃ£';
    }
    if (_avoidanceUrgeScore >= 60 && _avoidanceUrgeScore > _anxietyScore) {
      return 'Muá»‘n nÃ© trÃ¡nh';
    }
    if (_anxietyScore >= 50 || _anticipatoryAnxietyScore >= 4 || _postEventRuminationScore >= 4) {
      return 'Lo Ã¢u';
    }
    return 'á»”n Ä‘á»‹nh';
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
        content: const Text(
          'Káº¿t quáº£ kiá»ƒm tra vÃ  bÃ i thá»±c hÃ nh tiáº¿p xÃºc cá»§a báº¡n Ä‘ang cáº£i thiá»‡n. Báº¡n cÃ³ nháº­n tháº¥y mÃ¬nh Ä‘Ã£ bá»›t nÃ© trÃ¡nh vÃ  dÃ¡m thá»­ cÃ¡c tÃ¬nh huá»‘ng xÃ£ há»™i hÆ¡n khÃ´ng?',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
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
            scrollable: true,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            title: const Row(
              children: [
                Icon(Icons.face_retouching_natural, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Äiá»ƒm danh cáº£m xÃºc hÃ´m nay', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: SizedBox(
              width: 520,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'HÃ£y ghi nhanh 5 chá»‰ sá»‘ Ä‘á»ƒ theo dÃµi cáº£m xÃºc hÃ´m nay. Náº¿u há»‡ thá»‘ng tháº¥y má»©c cÄƒng tháº³ng quÃ¡ cao, app sáº½ Æ°u tiÃªn há»i vá» an toÃ n trÆ°á»›c khi gá»£i Ã½ bÃ i táº­p CBT.',
                    style: TextStyle(color: Colors.black54, height: 1.45),
                  ),
                  const SizedBox(height: 12),
                  const TherapyGuideCard(
                    title: 'VÃ¬ sao cáº§n Ä‘iá»ƒm danh?',
                    message:
                        'Check-in giÃºp nháº­n ra nhanh lo Ã¢u, nÃ© trÃ¡nh, buá»“n bÃ£, lo Ã¢u dá»± kiáº¿n vÃ  nhai láº¡i sau sá»± kiá»‡n. Khi Anxiety hoáº·c Sadness quÃ¡ cao, há»‡ thá»‘ng sáº½ Æ°u tiÃªn há»i vá» má»©c Ä‘á»™ an toÃ n cá»§a báº¡n trÆ°á»›c.',
                    icon: Icons.insights_outlined,
                    accentColor: AppColors.primary,
                  ),
                  const SizedBox(height: 20),
                  _buildDialogMetricSlider(
                    title: 'Má»©c lo Ã¢u hiá»‡n táº¡i',
                    subtitle: '0 = ráº¥t nháº¹ â€¢ 100 = ráº¥t cao',
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
                    title: 'Má»©c thÃ´i thÃºc nÃ© trÃ¡nh',
                    subtitle: 'Báº¡n muá»‘n trÃ¡nh tÃ¬nh huá»‘ng Ä‘Ã³ Ä‘áº¿n má»©c nÃ o?',
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
                    title: 'Má»©c buá»“n bÃ£ / tráº§m uáº¥t',
                    subtitle: '0 = khÃ´ng buá»“n â€¢ 100 = ráº¥t náº·ng',
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
                    title: 'Lo Ã¢u dá»± kiáº¿n trÆ°á»›c sá»± kiá»‡n',
                    subtitle: '0 = khÃ´ng cÃ³ â€¢ 8 = ráº¥t nhiá»u',
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
                    title: 'Nhai láº¡i sau sá»± kiá»‡n',
                    subtitle: '0 = khÃ´ng cÃ³ â€¢ 8 = ráº¥t nhiá»u',
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
                      'NhÃ£n cáº£m xÃºc hÃ´m nay sáº½ Ä‘Æ°á»£c há»‡ thá»‘ng tá»± gÃ¡n: ${_resolveMoodLabel()}',
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
                child: const Text('Bá» qua', style: TextStyle(color: Colors.grey)),
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
                    if (_shouldSuggestThoughtRecord || _shouldSuggestCopingCards || _shouldOfferChoice) {
                      _showAISuggestionDialog();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('HÃ´m nay báº¡n Ä‘ang á»Ÿ má»©c theo dÃµi. Há»‡ thá»‘ng sáº½ chÆ°a má»Ÿ bÃ i táº­p má»›i.'),
                        ),
                      );
                    }
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
                'Kiá»ƒm tra an toÃ n',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: const Text(
          'ChÃºng tÃ´i nháº­n tháº¥y cáº£m xÃºc cá»§a báº¡n Ä‘ang ráº¥t cÄƒng tháº³ng. Hiá»‡n táº¡i báº¡n cÃ³ Ä‘ang cáº£m tháº¥y an toÃ n khÃ´ng, hay Ä‘ang cÃ³ nhá»¯ng suy nghÄ© muá»‘n bá» cuá»™c/lÃ m háº¡i báº£n thÃ¢n?',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'SAFE'),
            child: const Text('TÃ´i Ä‘ang an toÃ n'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'UNSAFE'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.alert,
              foregroundColor: Colors.white,
            ),
            child: const Text('TÃ´i khÃ´ng an toÃ n'),
          ),
        ],
      ),
    );
  }

  void _showAISuggestionDialog() {
    final shouldOpenThoughtRecord = _shouldSuggestThoughtRecord;
    final shouldOpenCopingCards = _shouldSuggestCopingCards;
    final shouldOfferChoice = _shouldOfferChoice;
    final isChoiceMode = shouldOfferChoice && !shouldOpenThoughtRecord && !shouldOpenCopingCards;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              shouldOpenThoughtRecord ? Icons.auto_awesome : (isChoiceMode ? Icons.balance_rounded : Icons.stars_rounded),
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              shouldOpenThoughtRecord
                  ? 'AI Ä‘iá»u hÆ°á»›ng trá»‹ liá»‡u'
                  : (isChoiceMode ? 'Báº¡n muá»‘n chá»n cÃ¡ch nÃ o?' : 'Báº£o dÆ°á»¡ng & cá»§ng cá»‘'),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              shouldOpenThoughtRecord
                  ? 'Ghi nháº­n cho tháº¥y lo Ã¢u dá»± kiáº¿n hoáº·c nhai láº¡i cá»§a báº¡n Ä‘ang khÃ¡ cao. ÄÃ¢y lÃ  lÃºc phÃ¹ há»£p Ä‘á»ƒ vÃ o tháº³ng nháº­t kÃ½ suy nghÄ© 6 bÆ°á»›c.'
                  : (isChoiceMode
                      ? 'MindHealth nháº­n tháº¥y báº¡n Ä‘ang cÃ³ chÃºt báº­n tÃ¢m vÃ  lo Ã¢u nháº¹. Báº¡n muá»‘n Ä‘á»c nhanh má»™t Tháº» Ä‘á»‘i phÃ³ Ä‘á»ƒ cá»§ng cá»‘ tinh tháº§n, hay muá»‘n dÃ nh 3 phÃºt viáº¿t Nháº­t kÃ½ suy nghÄ© Ä‘á»ƒ giáº£i tá»a sÃ¢u hÆ¡n?'
                      : 'Ghi nháº­n cá»§a báº¡n Ä‘ang á»Ÿ má»©c á»•n Ä‘á»‹nh 0-3. Há»‡ thá»‘ng sáº½ khÃ´ng má»Ÿ nháº­t kÃ½ suy nghÄ© lÃºc nÃ y mÃ  chuyá»ƒn sang cháº¿ Ä‘á»™ báº£o dÆ°á»¡ng Ä‘á»ƒ báº¡n lÆ°u láº¡i cÃ¡c suy nghÄ© cÃ¢n báº±ng khi Ä‘áº§u Ã³c cÃ²n sÃ¡ng rÃµ.'),
              style: const TextStyle(height: 1.5),
            ),
            const SizedBox(height: 12),
            TherapyGuideCard(
              title: shouldOpenThoughtRecord
                  ? 'Gá»£i Ã½ Nháº­t kÃ½ suy nghÄ©'
                  : (isChoiceMode ? 'Cháº¿ Ä‘á»™ cáº£nh giÃ¡c nháº¹' : 'ThÆ° viá»‡n Tháº» Äá»‘i PhÃ³'),
              message: shouldOpenThoughtRecord
                  ? 'Nháº­t kÃ½ 6 bÆ°á»›c sáº½ giÃºp báº¡n Ä‘i tá»« tÃ¬nh huá»‘ng, cáº£m xÃºc, hÃ nh vi an toÃ n Ä‘áº¿n pháº£n há»“i cÃ¢n báº±ng vÃ  cam káº¿t hÃ nh Ä‘á»™ng.'
                  : (isChoiceMode
                      ? 'Báº¡n cÃ³ thá»ƒ tá»± chá»n cÃ¡ch há»— trá»£ phÃ¹ há»£p vá»›i má»©c sáºµn sÃ ng lÃºc nÃ y: cáº¯t nhanh cÆ¡n lo Ã¢u nháº¹ báº±ng Tháº» Ä‘á»‘i phÃ³, hoáº·c Ä‘i sÃ¢u hÆ¡n báº±ng Nháº­t kÃ½ suy nghÄ©.'
                      : 'Tháº» Ä‘á»‘i phÃ³ lÃ  â€œtÃºi sÆ¡ cá»©u cáº£m xÃºcâ€ cá»§a báº¡n: nÆ¡i lÆ°u láº¡i cÃ¡c suy nghÄ© cÃ¢n báº±ng, tÃ­ch cá»±c Ä‘á»ƒ má»Ÿ ra Ä‘á»c nhanh trÆ°á»›c nhá»¯ng tÃ¬nh huá»‘ng giao tiáº¿p cÄƒng tháº³ng.'),
              icon: shouldOpenThoughtRecord ? Icons.edit_note_outlined : (isChoiceMode ? Icons.tune_rounded : Icons.style_outlined),
              accentColor: AppColors.primary,
            ),
            if (shouldOpenCopingCards)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  'Báº¡n cÃ³ thá»ƒ lÆ°u sáºµn pháº£n há»“i tÃ­ch cá»±c lÃºc tÃ¢m trÃ­ cÃ²n sÃ¡ng suá»‘t nháº¥t Ä‘á»ƒ dÃ¹ng láº¡i khi cáº§n.',
                  style: TextStyle(color: AppColors.textSecondary, height: 1.45),
                ),
              ),
          ],
        ),
        actions: isChoiceMode
            ? [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Äá»ƒ sau', style: TextStyle(color: Colors.grey)),
                ),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/coping-cards');
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Äá»c tháº» Ä‘á»‘i phÃ³'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/thought-record', extra: {
                      'anxietyScore': _anxietyScore.toInt(),
                      'avoidanceUrgeScore': _avoidanceUrgeScore.toInt(),
                      'anticipatoryAnxietyScore': _anticipatoryAnxietyScore.toInt(),
                      'postEventRuminationScore': _postEventRuminationScore.toInt(),
                    });
                  },
                  child: const Text('Viáº¿t nháº­t kÃ½ suy nghÄ©', style: TextStyle(color: Colors.white)),
                ),
              ]
            : [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Äá»ƒ sau', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    if (shouldOpenThoughtRecord) {
                      context.push('/thought-record', extra: {
                        'anxietyScore': _anxietyScore.toInt(),
                        'avoidanceUrgeScore': _avoidanceUrgeScore.toInt(),
                        'anticipatoryAnxietyScore': _anticipatoryAnxietyScore.toInt(),
                        'postEventRuminationScore': _postEventRuminationScore.toInt(),
                      });
                    } else {
                      context.push('/coping-cards');
                    }
                  },
                  child: Text(
                    shouldOpenThoughtRecord ? 'Viáº¿t nháº­t kÃ½ suy nghÄ©' : 'Má»Ÿ thÆ° viá»‡n tháº» Ä‘á»‘i phÃ³',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingHomeGate) {
      return const MindHealthScaffold(
        title: 'Trang chá»§',
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final auth = Provider.of<AuthProvider>(context);
    final user = auth.loginResponse?.user;
    final profile = auth.patientProfile;
    final displayName = profile?.nickname.isNotEmpty == true
        ? profile!.nickname
        : (user?.username ?? 'CÃ¡o Nhá»');
    final isAnonymous = profile?.anonymousModeEnabled ?? (user?.isAnonymous ?? true);
    final checkInLabel = _checkInLabel;

    return MindHealthScaffold(
      title: 'ReConnect MindHealth',
      actions: [
        IconButton(
          icon: const Icon(Icons.emoji_events_outlined, color: Colors.amber),
          tooltip: 'ChÃºc má»«ng tiáº¿n bá»™',
          onPressed: _showRecoveryCongratsDialog,
        ),
        IconButton(
          icon: const Icon(Icons.bolt, color: Colors.amber),
          tooltip: 'Cáº£nh bÃ¡o tá»« bÃ¡c sÄ©',
          onPressed: () => setState(() => _hasBoosterAlert = !_hasBoosterAlert),
        ),
        IconButton(
          icon: const Icon(Icons.smart_toy_rounded, color: AppColors.primary),
          tooltip: 'Trá»£ lÃ½ Ä‘á»“ng hÃ nh',
          onPressed: () => context.push('/cbt-chat?screen=home'),
        ),
      ],
      body: ListView(
        children: [
          if (_hasBoosterAlert) _buildBoosterAlert(),
          _buildHeroCard(displayName: displayName, userEmail: user?.email ?? '', isAnonymous: isAnonymous, checkInLabel: checkInLabel),
          const SizedBox(height: 24),
          _buildSectionHeader(
            title: 'HÃ´m nay báº¡n muá»‘n báº¯t Ä‘áº§u tá»« Ä‘Ã¢u?',
            subtitle: 'CÃ¡c tÃ­nh nÄƒng Ä‘Æ°á»£c nhÃ³m theo hÃ nh trÃ¬nh CBT Ä‘á»ƒ báº¡n thao tÃ¡c nhanh hÆ¡n.',
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
                title: 'Nháº­t kÃ½ Lo Ã¢u XÃ£ há»™i',
                subtitle: 'VÃ o tháº³ng nháº­t kÃ½ 6 bÆ°á»›c Ä‘á»ƒ gá»¡ vÃ²ng láº·p lo Ã¢u xÃ£ há»™i.',
                icon: Icons.psychology_outlined,
                onTap: () => context.go('/journal'),
              ),
              _buildQuickActionCard(
                title: 'Fear Ladder hÃ´m nay',
                subtitle: 'Xem náº¥c thang Ä‘ang má»Ÿ vÃ  bÃ i thá»±c hÃ nh gáº§n nháº¥t.',
                icon: Icons.alt_route_rounded,
                onTap: () => context.go('/roadmap'),
              ),
              _buildQuickActionCard(
                title: 'Tháº» Ä‘á»‘i phÃ³',
                subtitle: 'Má»Ÿ coping cards vÃ  credit list khi cáº§n tá»± á»•n Ä‘á»‹nh.',
                icon: Icons.style_outlined,
                onTap: () => context.push('/coping-cards'),
              ),
              _buildQuickActionCard(
                title: 'Tham váº¥n tá»« xa',
                subtitle: 'Äáº·t lá»‹ch vá»›i chuyÃªn gia vÃ  theo dÃµi buá»•i háº¹n sáº¯p tá»›i.',
                icon: Icons.video_camera_front_outlined,
                onTap: () => context.go('/telehealth'),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _buildSectionHeader(
            title: 'Theo dÃµi tiáº¿n triá»ƒn',
            subtitle: 'NhÃ¬n láº¡i bÃ i kiá»ƒm tra, bÃ i thá»±c hÃ nh tiáº¿p xÃºc vÃ  cÃ¡c chá»‰ sá»‘ há»“i phá»¥c theo chu ká»³.',
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
                  title: 'ÄÃ¡nh giÃ¡ láº¡i lo Ã¢u Ä‘á»‹nh ká»³',
                  subtitle: 'Cáº­p nháº­t má»©c sá»£ vÃ  nÃ© trÃ¡nh má»—i 14 ngÃ y',
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
            title: 'Nháº¯c nhá»Ÿ hÃ´m nay',
            message:
                'Báº¡n khÃ´ng cáº§n lÃ m má»i thá»© cÃ¹ng lÃºc. HÃ£y chá»n má»™t bÆ°á»›c nhá» nháº¥t trong Fear Ladder hoáº·c hoÃ n thÃ nh má»™t check-in trung thá»±c.',
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
                  'BÃ¡c sÄ© yÃªu cáº§u buá»•i Ã´n táº­p',
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
            'Há»‡ thá»‘ng nháº­n tháº¥y chá»‰ sá»‘ rá»§i ro cá»§a báº¡n tÄƒng nháº¹. BÃ¡c sÄ© khuyÃªn báº¡n nÃªn Ã´n táº­p láº¡i ká»¹ nÄƒng Nháº­t kÃ½ suy nghÄ© ngay hÃ´m nay.',
            style: TextStyle(fontSize: 12, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/thought-record'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.alert, foregroundColor: Colors.white),
              child: const Text('Báº¯t Ä‘áº§u Ã´n táº­p ngay'),
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
                      'Xin chÃ o, $displayName',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAnonymous ? 'Báº¡n Ä‘ang á»Ÿ cháº¿ Ä‘á»™ áº©n danh an toÃ n' : 'TÃ i khoáº£n chÃ­nh thá»©c ($userEmail)',
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
                    Text('Báº£o máº­t', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
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
                  label: 'Lo Ã¢u hÃ´m nay',
                  value: '${_anxietyScore.toInt()}/100',
                  note: checkInLabel,
                  icon: Icons.favorite_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  label: 'Buá»“n bÃ£ hÃ´m nay',
                  value: '${_sadnessScore.toInt()}/100',
                  note: 'Theo dÃµi an toÃ n',
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
                  label: 'Lo Ã¢u dá»± kiáº¿n',
                  value: '${_anticipatoryAnxietyScore.toInt()}/8',
                  note: 'Nhai láº¡i ${_postEventRuminationScore.toInt()}/8',
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
            label: const Text('Cáº­p nháº­t cáº£m xÃºc hÃ´m nay'),
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
                    'Má»Ÿ ngay',
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

