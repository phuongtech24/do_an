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
          it.id.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _openEditor({QuestTemplateModel? item}) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    if (token == null || token.isEmpty) return;

    final titleCtrl = TextEditingController(text: item?.title ?? '');
    final descCtrl = TextEditingController(text: item?.description ?? '');
    String category = item?.category ?? 'BEHAVIORAL';
    String difficulty = item?.difficulty ?? 'EASY';

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(item == null ? 'Thêm Quest Template' : 'Chỉnh sửa Quest Template'),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: category,
                        decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(value: 'BEHAVIORAL', child: Text('BEHAVIORAL')),
                          DropdownMenuItem(value: 'COGNITIVE', child: Text('COGNITIVE')),
                          DropdownMenuItem(value: 'EMOTIONAL', child: Text('EMOTIONAL')),
                          DropdownMenuItem(value: 'SOCIAL', child: Text('SOCIAL')),
                        ],
                        onChanged: (val) => setDialogState(() => category = val ?? category),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: difficulty,
                        decoration: const InputDecoration(labelText: 'Difficulty', border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(value: 'EASY', child: Text('EASY')),
                          DropdownMenuItem(value: 'MEDIUM', child: Text('MEDIUM')),
                          DropdownMenuItem(value: 'HARD', child: Text('HARD')),
                        ],
                        onChanged: (val) => setDialogState(() => difficulty = val ?? difficulty),
                      ),
                    ),
                  ],
                ),
              ],
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
              child: const Text('Lưu', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (ok != true) return;

    final title = titleCtrl.text.trim();
    final description = descCtrl.text.trim();
    if (title.isEmpty || description.isEmpty) return;

    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      if (item == null) {
        final created = await _repo.create(
          token: token,
          input: QuestTemplateModel(
            id: '',
            title: title,
            description: description,
            category: category,
            difficulty: difficulty,
          ),
        );
        if (!mounted) return;
        setState(() => _items = [created, ..._items]);
      } else {
        final updated = await _repo.update(
          token: token,
          id: item.id,
          input: item.copyWith(title: title, description: description, category: category, difficulty: difficulty),
        );
        if (!mounted) return;
        setState(() => _items = _items.map((x) => x.id == item.id ? updated : x).toList());
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
      await _load();
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteItem(QuestTemplateModel item) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    if (token == null || token.isEmpty) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa Quest Template?'),
        content: Text('Bạn chắc chắn muốn xóa: "${item.title}"'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.alert),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      await _repo.delete(token: token, id: item.id);
      if (!mounted) return;
      setState(() => _items = _items.where((x) => x.id != item.id).toList());
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
                'Kho Nội dung CBT (Quest Templates)',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('THÊM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: _loading ? null : () => _openEditor(),
            ),
            const SizedBox(width: 8),
            IconButton(onPressed: _loading ? null : _load, icon: const Icon(Icons.refresh)),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'CRUD quest templates dùng cho Roadmap assign.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            hintText: 'Tìm theo title/description/category/difficulty...',
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(it.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${it.category} • ${it.difficulty}\n${it.description}'),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Sửa',
                              icon: const Icon(Icons.edit, color: AppColors.primary),
                              onPressed: _loading ? null : () => _openEditor(item: it),
                            ),
                            IconButton(
                              tooltip: 'Xóa',
                              icon: const Icon(Icons.delete_outline, color: AppColors.alert),
                              onPressed: _loading ? null : () => _deleteItem(it),
                            ),
                          ],
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

