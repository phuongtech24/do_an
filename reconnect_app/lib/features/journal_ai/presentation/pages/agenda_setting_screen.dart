import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:reconnect_app/shared/widgets/mindhealth_scaffold.dart';
import 'package:reconnect_app/theme/app_colors.dart';

class AgendaSettingScreen extends StatefulWidget {
  final int? initialAnxietyScore;
  final int? initialAvoidanceUrgeScore;
  final int? initialAnticipatoryAnxietyScore;
  final int? initialPostEventRuminationScore;

  const AgendaSettingScreen({
    super.key,
    this.initialAnxietyScore,
    this.initialAvoidanceUrgeScore,
    this.initialAnticipatoryAnxietyScore,
    this.initialPostEventRuminationScore,
  });

  @override
  State<AgendaSettingScreen> createState() => _AgendaSettingScreenState();
}

class _AgendaSettingScreenState extends State<AgendaSettingScreen> {
  final List<String> _commonIssues = const [
    'Sợ bị đánh giá khi nói trước người khác',
    'Lo lắng khi nhắn tin hoặc gọi điện trước',
    'Ngại bắt chuyện với người lạ hoặc nhóm mới',
    'Căng thẳng khi gặp người có thẩm quyền',
    'Lo bị từ chối hoặc bị nghĩ xấu sau một cuộc gặp',
    'Né tránh tham gia lớp học, họp hoặc hoạt động chung',
  ];

  String? _selectedIssue;
  final TextEditingController _customIssueController = TextEditingController();

  @override
  void dispose() {
    _customIssueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summary = _buildCheckinSummary();

    return MindHealthScaffold(
      title: 'Chọn tình huống cần xem lại',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE8F7F5), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primary.withOpacity(0.12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bạn muốn bóc tách tình huống lo âu xã hội nào hôm nay?',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Chọn 1 tình huống gần nhất để viết Thought Record. Hệ thống sẽ dùng tình huống này để gợi ý câu hỏi phản biện phù hợp hơn.',
                  style: TextStyle(height: 1.45, color: AppColors.textSecondary),
                ),
                if (summary != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.insights_outlined, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            summary,
                            style: const TextStyle(color: AppColors.textPrimary, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                ..._commonIssues.map((issue) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _AgendaOptionCard(
                        label: issue,
                        selected: _selectedIssue == issue,
                        onTap: () => setState(() => _selectedIssue = issue),
                      ),
                    )),
                const SizedBox(height: 10),
                TextField(
                  controller: _customIssueController,
                  decoration: InputDecoration(
                    labelText: 'Hoặc nhập tình huống riêng của bạn',
                    hintText: 'Ví dụ: Mình sợ mọi người chê khi phát biểu trong buổi họp...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                    prefixIcon: const Icon(Icons.edit_note_rounded),
                  ),
                  onChanged: (value) {
                    if (value.trim().isNotEmpty) {
                      setState(() => _selectedIssue = null);
                    } else {
                      setState(() {});
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: (_selectedIssue != null || _customIssueController.text.trim().isNotEmpty)
                  ? () {
                      context.push(
                        '/thought-record',
                        extra: {
                          'agenda': _selectedIssue ?? _customIssueController.text.trim(),
                          'anxietyScore': widget.initialAnxietyScore,
                          'avoidanceUrgeScore': widget.initialAvoidanceUrgeScore,
                          'anticipatoryAnxietyScore': widget.initialAnticipatoryAnxietyScore,
                          'postEventRuminationScore': widget.initialPostEventRuminationScore,
                        },
                      );
                    }
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: const Text('Tiếp tục viết nhật ký', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  String? _buildCheckinSummary() {
    final values = [
      widget.initialAnxietyScore,
      widget.initialAvoidanceUrgeScore,
      widget.initialAnticipatoryAnxietyScore,
      widget.initialPostEventRuminationScore,
    ];
    if (values.every((value) => value == null)) {
      return null;
    }
    return 'Check-in gần nhất: Lo âu ${widget.initialAnxietyScore ?? 0}/100 • '
        'Né tránh ${widget.initialAvoidanceUrgeScore ?? 0}/100 • '
        'Lo âu dự kiến ${widget.initialAnticipatoryAnxietyScore ?? 0}/8 • '
        'Nhai lại ${widget.initialPostEventRuminationScore ?? 0}/8.';
  }
}

class _AgendaOptionCard extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AgendaOptionCard({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.primary.withOpacity(0.12),
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
