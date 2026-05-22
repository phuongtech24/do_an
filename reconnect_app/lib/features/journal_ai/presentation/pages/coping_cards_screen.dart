import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/mindhealth_scaffold.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/journal_model.dart';
import '../providers/journal_provider.dart';

class CopingCardsScreen extends StatefulWidget {
  const CopingCardsScreen({super.key});

  @override
  State<CopingCardsScreen> createState() => _CopingCardsScreenState();
}

class _CopingCardsScreenState extends State<CopingCardsScreen> {
  // Bản ghi tĩnh làm mẫu ban đầu
  final List<String> _staticCredits = [
    'Hôm nay mình đã tự nấu ăn.',
    'Mình đã hoàn thành bài tập PHQ-9.',
    'Mình đã đứng lên đi dạo 10 phút.',
  ];

  final List<Map<String, dynamic>> _cards = [
    {
      'title': 'Khi cảm thấy bị từ chối',
      'content': 'Việc họ không trả lời tin nhắn ngay không có nghĩa là họ ghét mình. Họ có thể bận hoặc mệt.',
      'color': const Color(0xFFE3F2FD),
    },
    {
      'title': 'Áp lực hoàn hảo',
      'content': 'Hoàn thành tốt hơn hoàn hảo. Mình đã cố gắng hết sức và điều đó là đủ.',
      'color': const Color(0xFFE8F5E9),
    },
    {
      'title': 'Sự lo âu về tương lai',
      'content': 'Mình không thể kiểm soát tương lai, nhưng mình có thể kiểm soát hành động của mình lúc này.',
      'color': const Color(0xFFFFF3E0),
    },
  ];

  final Map<String, dynamic> _relapsePlan = {
    'title': 'Kế hoạch Phòng ngừa Tái phát',
    'content': 'Tôi có quyền lựa chọn: Tôi có thể làm quá vấn đề lên và cảm thấy tồi tệ hơn. Hoặc tôi có thể xem lại nhật ký, nhớ rằng thụt lùi (setback) là một phần bình thường của quá trình phục hồi, và tự làm một phiên trị liệu cho chính mình.',
    'color': const Color(0xFFFFFDE7),
  };

  @override
  void initState() {
    super.initState();
    // Tự động tải danh sách nhật ký để nạp Credit List từ Backend
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final patientId = auth.loginResponse?.user.id ?? '';
      final token = auth.loginResponse?.token;

      if (patientId.isNotEmpty) {
        Provider.of<JournalProvider>(context, listen: false)
            .loadJournals(patientId, token: token);
      }
    });
  }

  void _addCredit() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Ghi nhận việc tốt', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'VD: Mình đã kiên nhẫn với bản thân hôm nay...',
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
            autofocus: true,
            maxLines: 2,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () async {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  Navigator.pop(context); // Đóng hộp thoại nhập
                  _saveCreditToBackend(text);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Lưu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // Gửi Ghi nhận việc tốt lên Backend
  Future<void> _saveCreditToBackend(String contentText) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final patientId = auth.loginResponse?.user.id ?? '';

    if (patientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy phiên đăng nhập! Vui lòng quay lại Trang chủ hoặc Đăng nhập lại.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Hiển thị vòng xoay Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
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

      if (mounted) Navigator.pop(context); // Đóng vòng xoay Loading

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lưu thẻ ghi nhận thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${journalProvider.errorMessage}'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Đóng vòng xoay Loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final journalProvider = Provider.of<JournalProvider>(context);

    // Lấy các thẻ Credit List thật từ database
    final dbCredits = journalProvider.journals
        .where((j) => j.journalType == 'CREDIT_LIST')
        .map((j) => j.content ?? '')
        .toList();

    // Gộp dữ liệu database lên trước, dữ liệu tĩnh làm mẫu phía dưới
    final allCredits = [...dbCredits, ..._staticCredits];

    return MindHealthScaffold(
      title: 'Thẻ Đối phó & Ghi nhận',
      floatingActionButton: FloatingActionButton(
        onPressed: _addCredit,
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.add_task, color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          const Text(
            'Kho vũ khí tinh thần',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Đọc các thẻ này mỗi khi bạn cảm thấy những suy nghĩ tiêu cực quay trở lại.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          ..._cards.map((card) => _buildCard(card)),
          
          const SizedBox(height: 24),
          const Text(
            'PHÒNG NGỪA TÁI PHÁT (RELAPSE PREVENTION)',
            style: TextStyle(fontWeight: FontWeight.w900, color: Colors.amber, fontSize: 12, letterSpacing: 1.2),
          ),
          const SizedBox(height: 12),
          _buildCard(_relapsePlan, isSpecial: true),
          
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'DANH SÁCH GHI NHẬN (CREDIT LISTS)',
                style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey, fontSize: 12, letterSpacing: 1.2),
              ),
              if (journalProvider.status == JournalProviderStatus.loading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF))),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          ...allCredits.map((text) => _buildCreditItem(text)),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> card, {bool isSpecial = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: card['color'] as Color,
        borderRadius: BorderRadius.circular(20),
        border: isSpecial ? Border.all(color: Colors.orange, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: (card['color'] as Color).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isSpecial ? Icons.warning_amber_rounded : Icons.style, size: 20, color: isSpecial ? Colors.orange[800] : Colors.black54),
              const SizedBox(width: 8),
              Text(
                card['title'] as String,
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 16,
                  color: isSpecial ? Colors.orange[900] : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            card['content'] as String,
            style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditItem(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14))),
        ],
      ),
    );
  }
}
