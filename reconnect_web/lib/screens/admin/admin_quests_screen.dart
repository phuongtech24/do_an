import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/auth/auth_provider.dart';
import '../../features/admin/data/models/quest_template_model.dart';
import '../../features/admin/data/repositories/admin_quest_template_repository.dart';
import '../../theme/app_colors.dart';

class AdminQuestsScreen extends StatefulWidget {
  const AdminQuestsScreen({super.key});

  @override
  State<AdminQuestsScreen> createState() => _AdminQuestsScreenState();
}

class _AdminQuestsScreenState extends State<AdminQuestsScreen> {
  final AdminQuestTemplateRepository _repo = AdminQuestTemplateRepository();

  bool _loading = false;
  String _error = '';
  String _query = '';
  List<QuestTemplateModel> _items = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    if (token == null || token.isEmpty) {
      setState(() => _error = 'Chưa đăng nhập.');
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final list = await _repo.list(token: token);
      if (!mounted) return;
      setState(() => _items = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  List<QuestTemplateModel> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _items;
    return _items.where((it) {
      return it.title.toLowerCase().contains(q) ||
          it.description.toLowerCase().contains(q) ||
          it.category.toLowerCase().contains(q) ||
          it.difficulty.toLowerCase().contains(q) ||
          it.moduleCode.toLowerCase().contains(q) ||
          it.programPhaseCode.toLowerCase().contains(q) ||
          it.interventionType.toLowerCase().contains(q) ||
          it.id.toLowerCase().contains(q);
    }).toList();
  }

  String _cat(String c) {
    if (c == 'BEHAVIORAL') return 'Hành vi';
    if (c == 'COGNITIVE') return 'Nhận thức';
    if (c == 'EMOTIONAL') return 'Cảm xúc';
    if (c == 'SOCIAL') return 'Xã hội';
    return c;
  }

  String _diff(String d) {
    if (d == 'EASY') return 'Dễ';
    if (d == 'MEDIUM') return 'Trung bình';
    if (d == 'HARD') return 'Khó';
    return d;
  }

  String _phase(String p) {
    if (p == 'MAP_AND_BELIEF_BREAK') return 'GĐ1: Bản đồ vòng lặp';
    if (p == 'REAL_WORLD_EXPERIMENTS') return 'GĐ2: Thử nghiệm thực tế';
    if (p == 'DEEP_COGNITIVE_MEMORY') return 'GĐ3: Tái cấu trúc';
    return p;
  }

  String _interv(String i) {
    if (i == 'BEHAVIORAL_EXPERIMENT') return 'Thử nghiệm hành vi';
    if (i == 'VICIOUS_CYCLE_MAP') return 'Bản đồ vòng lặp';
    if (i == 'VIDEO_FEEDBACK') return 'Phản hồi qua video';
    if (i == 'SURVEY') return 'Khảo sát';
    if (i == 'THEN_VS_NOW') return 'Kỹ thuật Xưa & Nay';
    if (i == 'IMAGERY_RESCRIPTING') return 'Kịch bản tưởng tượng';
    if (i == 'THOUGHT_RECORD') return 'Nhật ký suy nghĩ';
    return i;
  }

  Future<void> _openEditor({required QuestTemplateModel item}) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    if (token == null || token.isEmpty) return;

    final titleCtrl = TextEditingController(text: item.title);
    final descCtrl = TextEditingController(text: item.description);
    final moduleCodeCtrl = TextEditingController(text: item.moduleCode);
    final programWeekCtrl = TextEditingController(
      text: item.programWeek != null ? '${item.programWeek}' : '',
    );

    String category = item.category;
    String difficulty = item.difficulty;
    String programPhaseCode = item.programPhaseCode.isNotEmpty
        ? item.programPhaseCode
        : 'MAP_AND_BELIEF_BREAK';
    String interventionType = item.interventionType.isNotEmpty
        ? item.interventionType
        : 'BEHAVIORAL_EXPERIMENT';
    bool therapistOnlyAssignable = item.therapistOnlyAssignable;
    bool hardLocked = item.hardLocked;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Chỉnh sửa module CBT'),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Tên module',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    minLines: 3,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: 'Mô tả',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: moduleCodeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Mã module',
                      hintText: 'Ví dụ: SAFETY_BEHAVIOR_DROP',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: category,
                          decoration: const InputDecoration(
                            labelText: 'Nhóm nội dung',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'BEHAVIORAL',
                              child: Text('Hành vi'),
                            ),
                            DropdownMenuItem(
                              value: 'COGNITIVE',
                              child: Text('Nhận thức'),
                            ),
                            DropdownMenuItem(
                              value: 'EMOTIONAL',
                              child: Text('Cảm xúc'),
                            ),
                            DropdownMenuItem(
                              value: 'SOCIAL',
                              child: Text('Xã hội'),
                            ),
                          ],
                          onChanged: (val) => setDialogState(
                            () => category = val ?? category,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: difficulty,
                          decoration: const InputDecoration(
                            labelText: 'Mức độ',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'EASY', child: Text('Dễ')),
                            DropdownMenuItem(
                              value: 'MEDIUM',
                              child: Text('Trung bình'),
                            ),
                            DropdownMenuItem(value: 'HARD', child: Text('Khó')),
                          ],
                          onChanged: (val) => setDialogState(
                            () => difficulty = val ?? difficulty,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: programWeekCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Tuần trị liệu',
                            hintText: 'Ví dụ: 3',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: programPhaseCode,
                          decoration: const InputDecoration(
                            labelText: 'Phase trị liệu',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'MAP_AND_BELIEF_BREAK',
                              child: Text('GĐ1: Bản đồ vòng lặp'),
                            ),
                            DropdownMenuItem(
                              value: 'REAL_WORLD_EXPERIMENTS',
                              child: Text('GĐ2: Thử nghiệm thực tế'),
                            ),
                            DropdownMenuItem(
                              value: 'DEEP_COGNITIVE_MEMORY',
                              child: Text('GĐ3: Tái cấu trúc'),
                            ),
                          ],
                          onChanged: (val) => setDialogState(
                            () =>
                                programPhaseCode = val ?? programPhaseCode,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: interventionType,
                    decoration: const InputDecoration(
                      labelText: 'Loại can thiệp',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'BEHAVIORAL_EXPERIMENT',
                        child: Text('Thử nghiệm hành vi'),
                      ),
                      DropdownMenuItem(
                        value: 'VICIOUS_CYCLE_MAP',
                        child: Text('Bản đồ vòng lặp'),
                      ),
                      DropdownMenuItem(
                        value: 'VIDEO_FEEDBACK',
                        child: Text('Phản hồi qua video'),
                      ),
                      DropdownMenuItem(value: 'SURVEY', child: Text('Khảo sát')),
                      DropdownMenuItem(
                        value: 'THEN_VS_NOW',
                        child: Text('Kỹ thuật Xưa & Nay'),
                      ),
                      DropdownMenuItem(
                        value: 'IMAGERY_RESCRIPTING',
                        child: Text('Kịch bản tưởng tượng'),
                      ),
                      DropdownMenuItem(
                        value: 'THOUGHT_RECORD',
                        child: Text('Nhật ký suy nghĩ'),
                      ),
                    ],
                    onChanged: (val) => setDialogState(
                      () => interventionType = val ?? interventionType,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Chỉ bác sĩ được giao'),
                    subtitle: const Text(
                      'Dùng cho module chỉ nên xuất hiện khi therapist chủ động giao bài.',
                    ),
                    value: therapistOnlyAssignable,
                    onChanged: (val) => setDialogState(
                      () => therapistOnlyAssignable = val,
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Khóa cứng theo phase'),
                    subtitle: const Text(
                      'Chỉ mở khi đúng phase hoặc đủ điều kiện tiên quyết lâm sàng.',
                    ),
                    value: hardLocked,
                    onChanged: (val) => setDialogState(() => hardLocked = val),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Lưu',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );

    if (ok != true) return;

    final title = titleCtrl.text.trim();
    final description = descCtrl.text.trim();
    final moduleCode = moduleCodeCtrl.text.trim();
    final weekRaw = programWeekCtrl.text.trim();
    final programWeek = weekRaw.isEmpty ? null : int.tryParse(weekRaw);
    if (title.isEmpty || description.isEmpty) return;

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final updated = await _repo.update(
        token: token,
        id: item.id,
        input: item.copyWith(
          title: title,
          description: description,
          category: category,
          difficulty: difficulty,
          moduleCode: moduleCode,
          programWeek: programWeek,
          programPhaseCode: programPhaseCode,
          interventionType: interventionType,
          therapistOnlyAssignable: therapistOnlyAssignable,
          hardLocked: hardLocked,
        ),
      );
      if (!mounted) return;
      setState(() {
        _items = _items.map((x) => x.id == item.id ? updated : x).toList();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
      await _load();
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Kho mẫu Thử nghiệm hành vi',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              onPressed: _loading ? null : _load,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Quản lý danh sách các kịch bản thực hành và thử nghiệm hành vi ở mức hệ thống.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        const Text(
          'Chuyên gia sẽ sử dụng kho mẫu này để cá nhân hóa và giao bài tập phù hợp cho từng bệnh nhân.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            hintText:
                'Tìm theo tên module, mã module, phase, loại can thiệp...',
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
        const SizedBox(height: 12),
        if (_error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(_error, style: const TextStyle(color: Colors.red)),
          ),
        Expanded(
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey[300]!),
            ),
            child: _loading && _items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final it = _filtered[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Text(
                          it.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${_cat(it.category)} • ${_diff(it.difficulty)}'
                          '${it.moduleCode.isNotEmpty ? ' • ${it.moduleCode}' : ''}'
                          '${it.programWeek != null ? ' • Tuần ${it.programWeek}' : ''}'
                          '${it.programPhaseCode.isNotEmpty ? ' • ${_phase(it.programPhaseCode)}' : ''}'
                          '\n${it.description}'
                          '${it.interventionType.isNotEmpty ? '\nCan thiệp: ${_interv(it.interventionType)}' : ''}'
                          '${it.therapistOnlyAssignable ? '\nChỉ bác sĩ giao' : ''}'
                          '${it.hardLocked ? ' • Khóa cứng' : ''}',
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          tooltip: 'Sửa',
                          icon: const Icon(
                            Icons.edit,
                            color: AppColors.primary,
                          ),
                          onPressed: _loading
                              ? null
                              : () => _openEditor(item: it),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
