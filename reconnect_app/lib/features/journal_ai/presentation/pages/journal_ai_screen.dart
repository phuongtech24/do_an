import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../shared/widgets/mindhealth_scaffold.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/journal_model.dart';
import '../providers/journal_provider.dart';

class JournalAiScreen extends StatefulWidget {
  const JournalAiScreen({super.key});

  @override
  State<JournalAiScreen> createState() => _JournalAiScreenState();
}

class _JournalAiScreenState extends State<JournalAiScreen> {
  @override
  void initState() {
    super.initState();
    // Tự động tải danh sách nhật ký của bệnh nhân khi mở màn hình
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

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final journalProvider = Provider.of<JournalProvider>(context);
    final patientId = auth.loginResponse?.user.id ?? '';
    final token = auth.loginResponse?.token;

    return MindHealthScaffold(
      title: 'Nhật ký & Trợ lý AI CBT',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/agenda-setting');
        },
        icon: const Icon(Icons.edit_note, size: 24),
        label: const Text(
          'Viết nhật ký mới',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (patientId.isNotEmpty) {
            await journalProvider.loadJournals(patientId, token: token);
          }
        },
        color: const Color(0xFF6C63FF),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            const _JournalRiskBanner(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Lịch sử Nhật ký CBT',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    if (patientId.isNotEmpty) {
                      journalProvider.loadJournals(patientId, token: token);
                    }
                  },
                  icon: const Icon(Icons.refresh, size: 16, color: Color(0xFF6C63FF)),
                  label: const Text(
                    'Tải lại',
                    style: TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // PHẦN HIỂN THỊ DANH SÁCH LỊCH SỬ NHẬT KÝ
            if (journalProvider.status == JournalProviderStatus.loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                  ),
                ),
              )
            else if (journalProvider.status == JournalProviderStatus.error)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                    const SizedBox(height: 12),
                    Text(
                      'Lỗi: ${journalProvider.errorMessage}',
                      style: const TextStyle(color: Colors.redAccent),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else if (journalProvider.journals.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.menu_book_outlined,
                      size: 64,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Chưa có bài nhật ký nào',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hãy bấm nút "Viết nhật ký mới" để ghi lại và phản biện cảm xúc tiêu cực cùng AI.',
                      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: journalProvider.journals.length,
                itemBuilder: (context, index) {
                  final j = journalProvider.journals[index];
                  return _buildJournalCard(context, j);
                },
              ),
            const SizedBox(height: 80), // Cách khoảng trống cho FAB
          ],
        ),
      ),
    );
  }

  // ======================================================
  // VẼ THẺ NHẬT KÝ (RẼ NHÁNH GIAO DIỆN)
  // ======================================================
  Widget _buildJournalCard(BuildContext context, JournalModel journal) {
    final isThoughtRecord = journal.journalType == 'THOUGHT_RECORD';
    final dateStr = _formatDateTime(journal.createDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isThoughtRecord 
              ? const Color(0xFFFFF3CD) // Màu vàng ấm cho Thought Record
              : const Color(0xFFD1E7DD), // Màu xanh mát cho Credit List
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showJournalDetails(context, journal),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon rẽ nhánh đại diện
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isThoughtRecord 
                        ? const Color(0xFFFFF8E1) 
                        : const Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isThoughtRecord ? Icons.psychology : Icons.star_rounded,
                    color: isThoughtRecord 
                        ? const Color(0xFFFFB300) 
                        : const Color(0xFF2E7D32),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Nội dung tóm tắt
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isThoughtRecord ? 'Nhật ký Suy nghĩ' : 'Ghi nhận Tiến bộ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isThoughtRecord 
                                  ? const Color(0xFFB78103) 
                                  : const Color(0xFF1E4620),
                            ),
                          ),
                          Text(
                            dateStr,
                            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isThoughtRecord 
                            ? (journal.situation ?? 'Không có tình huống')
                            : (journal.content ?? 'Không có nội dung'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),
                      if (isThoughtRecord) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildMiniBadge(
                              'Cảm xúc: ${journal.emotion ?? "Lo âu"} (${journal.emotionScore ?? 0}%)',
                              const Color(0xFFF8D7DA),
                              const Color(0xFF842029),
                            ),
                            const SizedBox(width: 8),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  // ======================================================
  // HIỂN THỊ HỘP THOẠI CHI TIẾT NHẬT KÝ (Stunning Custom Dialog)
  // ======================================================
  void _showJournalDetails(BuildContext context, JournalModel journal) {
    final isThoughtRecord = journal.journalType == 'THOUGHT_RECORD';
    final dateStr = _formatDateTime(journal.createDate);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    isThoughtRecord ? Icons.psychology : Icons.star_rounded,
                    color: isThoughtRecord ? const Color(0xFFFFB300) : const Color(0xFF2E7D32),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isThoughtRecord ? 'Chi tiết Nhật ký 6 bước' : 'Chi tiết Ghi nhận nỗ lực',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          dateStr,
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(height: 24, thickness: 1),

              // Body content
              Expanded(
                child: SingleChildScrollView(
                  child: isThoughtRecord 
                      ? _buildThoughtRecordDetailBody(journal)
                      : _buildCreditListDetailBody(journal),
                ),
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Đóng lại',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Giao diện chi tiết Nhật ký 6 bước (CBT Workflow)
  Widget _buildThoughtRecordDetailBody(JournalModel j) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailStepItem('1', 'Tình huống thực tế', j.situation ?? 'Không rõ'),
        _buildDetailStepItem('2', 'Suy nghĩ tự động tiêu cực', j.automaticThought ?? 'Không rõ'),
        _buildDetailStepItem('3', 'Cảm xúc ban đầu', '${j.emotion ?? "Lo âu"} - ${j.emotionScore ?? 0}%'),
        _buildDetailStepItem('4', 'Lỗi tư duy được nhận diện', 'Nhân viên AI Gemini đã hỗ trợ phân tích và chỉ ra các khuôn mẫu tư duy tiêu cực.'),
        _buildDetailStepItem('5', 'Suy nghĩ phản biện thực tế', j.adaptiveResponse ?? 'Chưa lập luận phản biện'),
        _buildDetailStepItem('6', 'Đánh giá lại cảm xúc', 'Cường độ cảm xúc tiêu cực giảm xuống chỉ còn: ${j.reRatedScore ?? 0}%', isLast: true),
      ],
    );
  }

  // Giao diện chi tiết Ghi nhận nỗ lực
  Widget _buildCreditListDetailBody(JournalModel j) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFC8E6C9)),
          ),
          child: Column(
            children: [
              const Icon(Icons.emoji_events, size: 48, color: Colors.amber),
              const SizedBox(height: 16),
              const Text(
                'Chúc mừng bạn đã ghi nhận nỗ lực!',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                j.content ?? 'Không có nội dung',
                style: const TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.w500, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDetailStepItem(String num, String stepTitle, String content, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFF6C63FF),
                shape: BoxShape.circle,
              ),
              child: Text(
                num,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 48,
                color: const Color(0xFF6C63FF).withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stepTitle,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  // Hàm chuyển đổi DateTime sang định dạng dễ đọc tiếng Việt
  String _formatDateTime(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final dateTime = DateTime.parse(dateStr).toLocal();
      return DateFormat('HH:mm - dd/MM/yyyy').format(dateTime);
    } catch (e) {
      return dateStr;
    }
  }
}

class _JournalRiskBanner extends StatelessWidget {
  const _JournalRiskBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF8B84FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                  'Nhật ký Trị liệu Nhận thức',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Cố vấn AI đồng hành cùng bạn nhận diện Lỗi tư duy và phản biện thực tế theo chuẩn CBT quốc tế.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.auto_awesome,
            size: 40,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
