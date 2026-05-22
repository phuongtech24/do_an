import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/auth/auth_provider.dart';
import '../../features/admin/data/models/therapist_applicant_model.dart';
import '../../features/admin/data/repositories/admin_therapist_approval_repository.dart';
import '../../theme/app_colors.dart';

class AdminVerifyDoctorScreen extends StatefulWidget {
  const AdminVerifyDoctorScreen({super.key});

  @override
  State<AdminVerifyDoctorScreen> createState() => _AdminVerifyDoctorScreenState();
}

class _AdminVerifyDoctorScreenState extends State<AdminVerifyDoctorScreen> {
  final AdminTherapistApprovalRepository _repo = AdminTherapistApprovalRepository();
  bool _loading = false;
  String _error = '';
  String _query = '';
  List<TherapistApplicantModel> _items = [];

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

  List<TherapistApplicantModel> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _items;
    return _items.where((it) {
      return it.fullName.toLowerCase().contains(q) ||
          it.email.toLowerCase().contains(q) ||
          (it.specialization ?? '').toLowerCase().contains(q) ||
          it.approvalStatus.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _setApproval(TherapistApplicantModel item, String status) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    if (token == null || token.isEmpty) return;

    setState(() {
      _loading = true;
      _error = '';
      _items = _items
          .map((x) => x.therapistId == item.therapistId
              ? TherapistApplicantModel(
                  therapistId: x.therapistId,
                  fullName: x.fullName,
                  email: x.email,
                  specialization: x.specialization,
                  approvalStatus: status,
                )
              : x)
          .toList();
    });

    try {
      final updated = await _repo.setApproval(token: token, therapistId: item.therapistId, status: status);
      if (!mounted) return;
      setState(() => _items = _items.map((x) => x.therapistId == item.therapistId ? updated : x).toList());
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
      await _load();
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _showCreateAccountDialog() async {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final specializationCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Cấp tài khoản Chuyên gia',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Admin đặt mật khẩu và cung cấp trực tiếp cho chuyên gia.', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Họ tên', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mật khẩu', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: specializationCtrl,
                decoration: const InputDecoration(labelText: 'Chuyên môn (optional)', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tạo', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final fullName = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text;
    final specialization = specializationCtrl.text.trim();
    if (fullName.isEmpty || email.isEmpty || password.isEmpty) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    if (token == null || token.isEmpty) return;

    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final created = await _repo.create(
        token: token,
        fullName: fullName,
        email: email,
        password: password,
        specialization: specialization.isEmpty ? null : specialization,
      );
      if (!mounted) return;
      setState(() => _items = [created, ..._items]);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã tạo tài khoản therapist. Trạng thái: PENDING'), backgroundColor: AppColors.success),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return AppColors.success;
      case 'REJECTED':
        return AppColors.alert;
      case 'PENDING':
      default:
        return Colors.amber;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'ACTIVE':
        return 'ĐÃ CẤP PHÉP';
      case 'REJECTED':
        return 'TỪ CHỐI';
      case 'PENDING':
      default:
        return 'CHỜ DUYỆT';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Quản lý Bác sĩ/Chuyên gia (Approval)', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Dữ liệu lấy từ backend (/api/admin/therapists).', style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
            Row(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  icon: const Icon(Icons.person_add, color: Colors.white),
                  label: const Text('CẤP TÀI KHOẢN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: _loading ? null : _showCreateAccountDialog,
                ),
                const SizedBox(width: 8),
                IconButton(onPressed: _loading ? null : _load, icon: const Icon(Icons.refresh)),
              ],
            )
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            hintText: 'Tìm theo tên / email / chuyên môn / status...',
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
                      final doc = _filtered[index];
                      final isPending = doc.approvalStatus == 'PENDING';
                      final color = _statusColor(doc.approvalStatus);
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: color.withOpacity(0.15),
                          child: Icon(Icons.medical_services, color: color),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(doc.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _statusLabel(doc.approvalStatus),
                                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text('Email: ${doc.email}${doc.specialization == null ? '' : ' • ${doc.specialization}'}'),
                        trailing: isPending
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                                    onPressed: _loading ? null : () => _setApproval(doc, 'ACTIVE'),
                                    child: const Text('DUYỆT', style: TextStyle(color: Colors.white)),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.alert),
                                    onPressed: _loading ? null : () => _setApproval(doc, 'REJECTED'),
                                    child: const Text('TỪ CHỐI', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              )
                            : null,
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

