import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/mindhealth_scaffold.dart';

class AgendaSettingScreen extends StatefulWidget {
  const AgendaSettingScreen({super.key});

  @override
  State<AgendaSettingScreen> createState() => _AgendaSettingScreenState();
}

class _AgendaSettingScreenState extends State<AgendaSettingScreen> {
  final List<String> _commonIssues = [
    'Lo lắng về công việc/học tập',
    'Mâu thuẫn với người thân',
    'Cảm thấy cô đơn/trống trải',
    'Áp lực đồng lứa',
    'Mất ngủ/Sức khỏe kém',
    'Tự ti về bản thân',
  ];

  String? _selectedIssue;
  final TextEditingController _customIssueController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MindHealthScaffold(
      title: 'Thiết lập Ưu tiên',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hôm nay bạn muốn giải quyết vấn đề gì?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Việc tập trung vào một vấn đề ưu tiên giúp phiên trị liệu hiệu quả hơn.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: ListView(
              children: [
                ..._commonIssues.map((issue) {
                  final isSelected = _selectedIssue == issue;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: InkWell(
                      onTap: () => setState(() => _selectedIssue = issue),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF6C63FF).withOpacity(0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF6C63FF) : Colors.grey[200]!,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.check_circle : Icons.circle_outlined,
                              color: isSelected ? const Color(0xFF6C63FF) : Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              issue,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? const Color(0xFF6C63FF) : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                TextField(
                  controller: _customIssueController,
                  decoration: InputDecoration(
                    labelText: 'Hoặc nhập vấn đề khác...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.edit_note),
                  ),
                  onChanged: (v) {
                    if (v.isNotEmpty) setState(() => _selectedIssue = null);
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: (_selectedIssue != null || _customIssueController.text.isNotEmpty)
                  ? () {
                      // Pass the selected agenda to the Thought Record
                      context.push('/thought-record', extra: {'agenda': _selectedIssue ?? _customIssueController.text});
                    }
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Tiếp tục viết Nhật ký'),
            ),
          ),
        ],
      ),
    );
  }
}
