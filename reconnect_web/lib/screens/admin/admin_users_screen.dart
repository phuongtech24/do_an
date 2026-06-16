import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/auth/auth_provider.dart';
import '../../features/admin/data/models/admin_user_model.dart';
import '../../features/admin/data/repositories/admin_user_repository.dart';
import '../../shared/widgets/pagination_bar.dart';
import '../../theme/app_colors.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final AdminUserRepository _repo = AdminUserRepository();
  bool _loading = false;
  String _error = '';
  String _query = '';
  List<AdminUserModel> _users = [];
  int _pageIndex = 1;
  int _pageSize = 10;
  int _totalPages = 0;
  int _totalElements = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load({int? pageIndex, int? pageSize, String? keyword}) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    if (token == null || token.isEmpty) {
      setState(() => _error = 'Chưa đăng nhập.');
      return;
    }
    setState(() {
      _loading = true;
      _error = '';
      if (pageIndex != null) _pageIndex = pageIndex;
      if (pageSize != null) _pageSize = pageSize;
      if (keyword != null) _query = keyword;
    });
    try {
      final page = await _repo.listUsersPaged(
        token: token,
        keyword: _query,
        pageIndex: _pageIndex,
        pageSize: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _users = page.content;
        _totalPages = page.totalPages;
        _totalElements = page.totalElements;
        _pageIndex = page.pageIndex;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleActive(AdminUserModel user, bool active) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    if (token == null || token.isEmpty) return;

    setState(() {
      _error = '';
      _users = _users.map((u) => u.id == user.id ? u.copyWith(isActive: active) : u).toList();
    });

    try {
      final updated = await _repo.setActive(token: token, userId: user.id, active: active);
      if (!mounted) return;
      setState(() {
        _users = _users.map((u) => u.id == user.id ? updated : u).toList();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
      await _load();
    }
  }

  Future<void> _changeRole(AdminUserModel user, String role) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    if (token == null || token.isEmpty) return;

    setState(() {
      _error = '';
      _users = _users.map((u) => u.id == user.id ? u.copyWith(role: role) : u).toList();
    });

    try {
      final updated = await _repo.setRole(token: token, userId: user.id, role: role);
      if (!mounted) return;
      setState(() {
        _users = _users.map((u) => u.id == user.id ? updated : u).toList();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
      await _load();
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
                'Quản lý Users',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              tooltip: 'Refresh',
              onPressed: _loading ? null : _load,
              icon: const Icon(Icons.refresh),
            )
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Bật/tắt user và đổi role (PATIENT/THERAPIST/ADMIN).',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            hintText: 'Tìm theo email / username / role / id...',
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
          onChanged: (v) => _query = v,
          onSubmitted: (v) => _load(pageIndex: 1, keyword: v),
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
            child: Column(
              children: [
                Expanded(
                  child: _loading && _users.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.separated(
                          itemCount: _users.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final u = _users[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              title: Text(u.email, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('role: ${u.role} • active: ${u.isActive} • anonymous: ${u.isAnonymous}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Switch(
                                    value: u.isActive,
                                    onChanged: (v) => _toggleActive(u, v),
                                    activeColor: AppColors.success,
                                  ),
                                  const SizedBox(width: 8),
                                  DropdownButton<String>(
                                    value: u.role,
                                    onChanged: (val) {
                                      if (val == null) return;
                                      _changeRole(u, val);
                                    },
                                    items: const [
                                      DropdownMenuItem(value: 'PATIENT', child: Text('PATIENT')),
                                      DropdownMenuItem(value: 'THERAPIST', child: Text('THERAPIST')),
                                      DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN')),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                PaginationBar(
                  pageIndex: _pageIndex,
                  totalPages: _totalPages,
                  totalElements: _totalElements,
                  pageSize: _pageSize,
                  onPageChanged: (page) => _load(pageIndex: page),
                  onPageSizeChanged: (size) => _load(pageIndex: 1, pageSize: size),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
