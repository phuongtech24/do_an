import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/auth/auth_provider.dart';
import '../../features/admin/data/models/quest_template_model.dart';
import '../../features/therapist/data/repositories/therapist_patient_repository.dart';
import '../../theme/app_colors.dart';

class AssignQuestScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const AssignQuestScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<AssignQuestScreen> createState() => _AssignQuestScreenState();
}

class _AssignQuestScreenState extends State<AssignQuestScreen> {
  final TherapistPatientRepository _repo = TherapistPatientRepository();
  List<QuestTemplateModel> _templates = [];
  String _query = '';
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTemplates());
  }

  Future<void> _loadTemplates() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null || token.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _repo.listQuestTemplates(token: token);
      if (!mounted) return;
      setState(() => _templates = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _assign(QuestTemplateModel quest) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null || token.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _repo.assignQuest(
        token: token,
        patientId: widget.patientId,
        questTemplateId: quest.id,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã gán bài tập "${quest.title}" cho ${widget.patientName}.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _templates.where((quest) {
      final keyword = _query.trim().toLowerCase();
      if (keyword.isEmpty) return true;
      return quest.title.toLowerCase().contains(keyword) ||
          quest.description.toLowerCase().contains(keyword) ||
          quest.category.toLowerCase().contains(keyword) ||
          quest.difficulty.toLowerCase().contains(keyword);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Gán bài tập CBT - ${widget.patientName}', style: const TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(onPressed: _loading ? null : _loadTemplates, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kho bài tập CBT', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 8),
            const Text('Chọn bài tập phù hợp để gán trực tiếp cho bệnh nhân. Bệnh nhân sẽ thấy bài tập trong Roadmap.', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Tìm theo tiêu đề / mô tả / category / difficulty...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            if (_error != null && _error!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: AppColors.alert)),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: _loading && _templates.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? const Center(child: Text('Không có bài tập phù hợp.'))
                      : ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final quest = filtered[index];
                            return _QuestTemplateCard(
                              quest: quest,
                              loading: _loading,
                              onAssign: () => _assign(quest),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestTemplateCard extends StatelessWidget {
  final QuestTemplateModel quest;
  final bool loading;
  final VoidCallback onAssign;

  const _QuestTemplateCard({
    required this.quest,
    required this.loading,
    required this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.12),
              child: const Icon(Icons.assignment_outlined, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(quest.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(quest.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _pill(quest.category),
                      _pill(quest.difficulty),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: loading ? null : onAssign,
              icon: const Icon(Icons.send, size: 18),
              label: const Text('Gán bài'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
