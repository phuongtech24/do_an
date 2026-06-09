import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/mindhealth_scaffold.dart';
import '../../../../shared/widgets/therapy_guide_card.dart';
import '../../../../theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/journal_model.dart';
import '../providers/journal_provider.dart';

class CopingCardsScreen extends StatefulWidget {
  const CopingCardsScreen({super.key});

  @override
  State<CopingCardsScreen> createState() => _CopingCardsScreenState();
}

class _CopingCardsScreenState extends State<CopingCardsScreen> {
  final List<String> _staticCredits = [
    'Hôm nay mình đã tự nấu ăn.',
    'Mình đã hoàn thành bài đánh giá LSAS.',
    'Mình đã đứng lên đi dạo 10 phút.',
  ];

  final List<Map<String, dynamic>> _cards = [
    {
      'title': 'Khi cảm thấy bị từ chối',
      'content': 'Việc họ không trả lời tin nhắn ngay không có nghĩa là họ ghét mình. Họ có thể bận hoặc mệt.',
      'icon': Icons.mark_unread_chat_alt_outlined,
      'accent': const Color(0xFF5FA8F5),
      'background': const Color(0xFFEAF4FF),
    },
    {
      'title': 'Áp lực hoàn hảo',
      'content': 'Hoàn thành tốt hơn hoàn hảo. Mình đã cố gắng hết sức và điều đó là đủ.',
      'icon': Icons.workspace_premium_outlined,
      'accent': const Color(0xFF3FA67A),
      'background': const Color(0xFFEAF8F0),
    },
    {
      'title': 'Sự lo âu về tương lai',
      'content': 'Mình không thể kiểm soát tương lai, nhưng mình có thể kiểm soát hành động của mình lúc này.',
      'icon': Icons.wb_twilight_outlined,
      'accent': const Color(0xFFE5A24C),
      'background': const Color(0xFFFFF4E7),
    },
  ];

  final Map<String, dynamic> _relapsePlan = {
    'title': 'Kế hoạch phòng ngừa tái phát',
    'content':
        'Khi chững lại, mình có thể xem lại nhật ký, nhớ rằng setback là một phần bình thường của quá trình hồi phục, rồi chọn một bước nhỏ để quay lại nhịp trị liệu.',
    'icon': Icons.health_and_safety_outlined,
    'accent': AppColors.warning,
    'background': const Color(0xFFFFF7E8),
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final patientId = auth.loginResponse?.user.id ?? '';
      final token = auth.loginResponse?.token;

      if (patientId.isNotEmpty) {
        Provider.of<JournalProvider>(context, listen: false).loadJournals(patientId, token: token);
      }
    });
  }

  void _addCredit() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text(
            'Ghi nhận một điều tốt',
            style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Ví dụ: Hôm nay mình đã kiên nhẫn hơn với bản thân.',
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () async {
                final text = controller.text.trim();
                if (text.isEmpty) return;
                Navigator.pop(context);
                await _saveCreditToBackend(text);
              },
              child: const Text('Lưu ghi nhận'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveCreditToBackend(String contentText) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final patientId = auth.loginResponse?.user.id ?? '';

    if (patientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy phiên đăng nhập. Vui lòng đăng nhập lại.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );

    try {
      final journalProvider = Provider.of<JournalProvider>(context, listen: false);
      final model = JournalModel(
        patientId: patientId,
        journalType: 'CREDIT_LIST',
        content: contentText,
      );

      final success = await journalProvider.saveNewJournal(model, token: auth.loginResponse?.token);

      if (mounted) Navigator.pop(context);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Lưu thẻ ghi nhận thành công.' : 'Lỗi: ${journalProvider.errorMessage}'),
          backgroundColor: success ? AppColors.success : AppColors.alert,
        ),
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra: $e'),
          backgroundColor: AppColors.alert,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final journalProvider = Provider.of<JournalProvider>(context);

    final dbCredits = journalProvider.journals
        .where((j) => j.journalType == 'CREDIT_LIST')
        .map((j) => j.content ?? '')
        .where((text) => text.trim().isNotEmpty)
        .toList();

    final allCredits = [...dbCredits, ..._staticCredits];

    return MindHealthScaffold(
      title: 'Thẻ đối phó & ghi nhận',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCredit,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('Thêm ghi nhận'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 88),
        children: [
          _buildHeroSection(),
          const SizedBox(height: 18),
          const TherapyGuideCard(
            title: 'Dùng thẻ khi nào?',
            message:
                'Hãy đọc lại các phản hồi cân bằng khi bạn còn bình tĩnh, để lúc cảm xúc xấu quay lại bạn có điểm tựa nhanh hơn.',
            icon: Icons.lightbulb_outline_rounded,
            accentColor: AppColors.primary,
            dismissible: true,
          ),
          const SizedBox(height: 20),
          _buildSectionLabel('Thẻ đối phó nhanh'),
          const SizedBox(height: 12),
          ..._cards.map(_buildCard),
          const SizedBox(height: 10),
          _buildSectionLabel('Phòng ngừa tái phát'),
          const SizedBox(height: 12),
          _buildCard(_relapsePlan, isSpecial: true),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildSectionLabel('Danh sách ghi nhận')),
              if (journalProvider.status == JournalProviderStatus.loading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const TherapyGuideCard(
            title: 'Ghi nhận nỗ lực nhỏ',
            message:
                'Không cần là thành công lớn. Hãy ghi cả những việc nhỏ nhưng khó khi bạn đang mệt, như ra khỏi giường, tắm, nấu ăn hoặc trả lời một tin nhắn.',
            icon: Icons.favorite_border_rounded,
            accentColor: AppColors.success,
          ),
          const SizedBox(height: 12),
          if (allCredits.isEmpty)
            _buildEmptyCredits()
          else
            ...allCredits.map(_buildCreditItem),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF159489)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white24,
                child: Icon(Icons.shield_moon_outlined, color: Colors.white),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Kho vũ khí tinh thần',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Lưu lại những câu nhắc cân bằng và các ghi nhận tích cực để bạn tự đỡ mình nhanh hơn khi lo âu quay lại.',
            style: TextStyle(
              color: Colors.white70,
              height: 1.45,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: AppColors.textSecondary,
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> card, {bool isSpecial = false}) {
    final accent = card['accent'] as Color;
    final background = card['background'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSpecial ? accent.withOpacity(0.55) : accent.withOpacity(0.15),
          width: isSpecial ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(card['icon'] as IconData, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  card['title'] as String,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            card['content'] as String,
            style: const TextStyle(
              fontSize: 15,
              height: 1.55,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditItem(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.check_rounded, color: AppColors.success, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                height: 1.45,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCredits() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.08)),
      ),
      child: const Text(
        'Bạn chưa có ghi nhận nào. Hãy thêm một điều nhỏ bạn đã làm được hôm nay.',
        style: TextStyle(
          color: AppColors.textSecondary,
          height: 1.45,
        ),
      ),
    );
  }
}
