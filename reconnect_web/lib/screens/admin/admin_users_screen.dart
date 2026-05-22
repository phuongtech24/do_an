import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/auth/auth_provider.dart';
import '../../features/admin/data/models/admin_user_model.dart';
import '../../features/admin/data/repositories/admin_user_repository.dart';
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
      final list = await _repo.listUsers(token: token);
      if (!mounted) return;
      setState(() => _users = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  List<AdminUserModel> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _users;
    return _users.where((u) {
      return u.email.toLowerCase().contains(q) ||
          (u.username ?? '').toLowerCase().contains(q) ||
          u.role.toLowerCase().contains(q) ||
          u.id.toLowerCase().contains(q);
    }).toList();
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
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
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
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
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
            child: _loading && _users.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final u = _filtered[index];
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
        ),
      ],
    );
  }
}

