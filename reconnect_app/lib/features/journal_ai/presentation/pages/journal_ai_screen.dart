import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/mindhealth_scaffold.dart';
import '../../../../theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/journal_model.dart';
import '../providers/journal_provider.dart';

class JournalAiScreen extends StatefulWidget {
  const JournalAiScreen({super.key});

  @override
  State<JournalAiScreen> createState() => _JournalAiScreenState();
}

class _JournalAiScreenState extends State<JournalAiScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final journalProvider = Provider.of<JournalProvider>(context);
    final patientId = auth.loginResponse?.user.id ?? '';
    final token = auth.loginResponse?.token;

    return MindHealthScaffold(
      title: 'Nhật ký & Trợ lý AI CBT',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/thought-record'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_note_rounded),
        label: const Text(
          'Viết nhật ký mới',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          if (patientId.isNotEmpty) {
            await journalProvider.loadJournals(patientId, token: token);
          }
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 88),
          children: [
            const _JournalHeroBanner(),
            const SizedBox(height: 22),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Lịch sử nhật ký CBT',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    if (patientId.isNotEmpty) {
                      journalProvider.loadJournals(patientId, token: token);
                    }
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 18, color: AppColors.primary),
                  label: const Text(
                    'Tải lại',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm theo tình huống, suy nghĩ, phản hồi...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: AppColors.primary.withOpacity(0.08)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: AppColors.primary.withOpacity(0.08)),
                ),
              ),
              onSubmitted: (value) {
                if (patientId.isNotEmpty) {
                  journalProvider.loadJournalsPaged(
                    patientId,
                    token: token,
                    keyword: value,
                    pageIndex: 1,
                  );
                }
              },
            ),
            const SizedBox(height: 14),
            if (journalProvider.status == JournalProviderStatus.loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              )
            else if (journalProvider.status == JournalProviderStatus.error)
              _buildErrorState(journalProvider.errorMessage)
            else if (journalProvider.journals.isEmpty)
              _buildEmptyState()
            else
              ...journalProvider.journals.map((journal) => _buildJournalCard(context, journal)),
            if (journalProvider.journals.isNotEmpty) ...[
              const SizedBox(height: 18),
              _PaginationSection(
                pageIndex: journalProvider.pageIndex,
                totalPages: journalProvider.totalPages,
                totalElements: journalProvider.totalElements,
                onPageChanged: (page) {
                  if (patientId.isNotEmpty) {
                    journalProvider.loadJournalsPaged(
                      patientId,
                      token: token,
                      pageIndex: page,
                    );
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.alert.withOpacity(0.18)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, size: 44, color: AppColors.alert),
          const SizedBox(height: 12),
          Text(
            'Không tải được nhật ký.\n$message',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.alert, height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.primary.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(Icons.menu_book_outlined, color: AppColors.primary, size: 34),
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có bài nhật ký nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hãy bấm “Viết nhật ký mới” để vào thẳng Bước 1 và ghi lại tình huống, cảm xúc, hành vi an toàn cùng phản hồi cân bằng.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalCard(BuildContext context, JournalModel journal) {
    final isThoughtRecord = journal.journalType == 'THOUGHT_RECORD';
    final accent = isThoughtRecord ? AppColors.warning : AppColors.success;
    final background = isThoughtRecord ? const Color(0xFFFFF7EA) : const Color(0xFFEAF8F0);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _showJournalDetails(context, journal),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    isThoughtRecord ? Icons.psychology_alt_outlined : Icons.favorite_border_rounded,
                    color: accent,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              isThoughtRecord ? 'Nhật ký suy nghĩ' : 'Ghi nhận tiến bộ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: accent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _formatDateTime(journal.createDate),
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isThoughtRecord
                            ? (journal.situation ?? 'Không có tình huống')
                            : (journal.content ?? 'Không có nội dung'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                      if (isThoughtRecord) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildMiniBadge(
                              'Cảm xúc: ${journal.emotion ?? "Lo âu"} (${journal.emotionScore ?? 0}%)',
                              const Color(0xFFF8D7DA),
                              const Color(0xFF842029),
                            ),
                            _buildMiniBadge(
                              'Chấm lại: ${journal.reRatedScore ?? 0}%',
                              const Color(0xFFD1E7DD),
                              const Color(0xFF0F5132),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  void _showJournalDetails(BuildContext context, JournalModel journal) {
    final isThoughtRecord = journal.journalType == 'THOUGHT_RECORD';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 640, maxHeight: 720),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isThoughtRecord ? AppColors.warning.withOpacity(0.14) : AppColors.success.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      isThoughtRecord ? Icons.psychology_alt_outlined : Icons.favorite_border_rounded,
                      color: isThoughtRecord ? AppColors.warning : AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isThoughtRecord ? 'Chi tiết nhật ký suy nghĩ 6 bước' : 'Chi tiết ghi nhận nỗ lực',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDateTime(journal.createDate),
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Divider(height: 1),
              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  child: isThoughtRecord ? _buildThoughtRecordDetailBody(journal) : _buildCreditListDetailBody(journal),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Đóng lại'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThoughtRecordDetailBody(JournalModel journal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailStepItem(
          '1',
          'Tình huống',
          _joinDetailParts([
            journal.situation,
            if (journal.worstPrediction != null && journal.worstPrediction!.trim().isNotEmpty)
              'Dự đoán tệ nhất: ${journal.worstPrediction}',
          ]),
        ),
        _buildDetailStepItem(
          '2',
          'Cảm xúc',
          _joinDetailParts([
            '${journal.emotion ?? "Lo âu"} - ${journal.emotionScore ?? 0}%',
            if (journal.bodySymptoms != null && journal.bodySymptoms!.isNotEmpty)
              'Phản ứng cơ thể: ${journal.bodySymptoms!.join(", ")}',
          ]),
        ),
        _buildDetailStepItem(
          '3',
          'Hành vi an toàn',
          _joinDetailParts([
            if (journal.safetyBehaviors != null && journal.safetyBehaviors!.isNotEmpty)
              journal.safetyBehaviors!.join(', '),
            if (journal.selfFocusThought != null && journal.selfFocusThought!.trim().isNotEmpty)
              'Tự chú ý: ${journal.selfFocusThought}',
            if (journal.negativeSelfImage != null && journal.negativeSelfImage!.trim().isNotEmpty)
              'Hình ảnh bản thân: ${journal.negativeSelfImage}',
          ]),
        ),
        _buildDetailStepItem(
          '4',
          'Suy nghĩ tự động',
          _joinDetailParts([
            journal.automaticThought,
            'Niềm tin ban đầu được ghi trong phiên viết và dùng để AI gợi mở thêm.',
          ]),
        ),
        _buildDetailStepItem(
          '5',
          'Lỗi tư duy',
          (journal.distortions != null && journal.distortions!.isNotEmpty)
              ? journal.distortions!.join(', ')
              : 'Chưa gắn nhãn lỗi tư duy.',
        ),
        _buildDetailStepItem(
          '6',
          'Phản hồi thích nghi',
          _joinDetailParts([
            journal.adaptiveResponse ?? 'Chưa có phản hồi cân bằng',
            if (journal.safetyBehaviorCommitment != null && journal.safetyBehaviorCommitment!.trim().isNotEmpty)
              'Cam kết hành động: ${journal.safetyBehaviorCommitment}',
            'Lo âu sau phiên: ${journal.reRatedScore ?? 0}%',
          ]),
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildCreditListDetailBody(JournalModel journal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8F0),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.success.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.emoji_events_outlined, size: 48, color: AppColors.success),
          const SizedBox(height: 14),
          const Text(
            'Bạn đã ghi nhận một nỗ lực đáng quý',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            journal.content ?? 'Không có nội dung',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailStepItem(String number, String title, String content, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 52,
                color: AppColors.primary.withOpacity(0.22),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(dateStr).toLocal();
      return DateFormat('HH:mm - dd/MM/yyyy').format(dateTime);
    } catch (_) {
      return dateStr;
    }
  }

  String _joinDetailParts(List<String?> parts) {
    return parts
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .join('\n');
  }
}

class _PaginationSection extends StatelessWidget {
  const _PaginationSection({
    required this.pageIndex,
    required this.totalPages,
    required this.totalElements,
    required this.onPageChanged,
  });

  final int pageIndex;
  final int totalPages;
  final int totalElements;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final hasPrev = pageIndex > 1;
    final hasNext = totalPages > 0 && pageIndex < totalPages;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Text(
            '$totalElements bản ghi',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            'Trang ${totalPages == 0 ? 0 : pageIndex}/$totalPages',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: hasPrev ? () => onPageChanged(pageIndex - 1) : null,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          IconButton(
            onPressed: hasNext ? () => onPageChanged(pageIndex + 1) : null,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

class _JournalHeroBanner extends StatelessWidget {
  const _JournalHeroBanner();

  @override
  Widget build(BuildContext context) {
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
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nhật ký trị liệu nhận thức',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'AI đồng hành cùng bạn nhận diện lỗi tư duy và phản biện thực tế theo chuẩn CBT quốc tế.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }
}
