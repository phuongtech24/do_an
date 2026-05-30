import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/auth/auth_provider.dart';
import '../../features/admin/data/models/admin_patient_profile_model.dart';
import '../../features/admin/data/models/therapist_applicant_model.dart';
import '../../features/admin/data/repositories/admin_patient_profile_repository.dart';
import '../../features/admin/data/repositories/admin_therapist_approval_repository.dart';
import '../../features/admin/data/repositories/admin_user_repository.dart';
import '../../theme/app_colors.dart';

class AdminPatientProfilesScreen extends StatefulWidget {
  const AdminPatientProfilesScreen({super.key});

  @override
  State<AdminPatientProfilesScreen> createState() => _AdminPatientProfilesScreenState();
}

class _AdminPatientProfilesScreenState extends State<AdminPatientProfilesScreen> {
  final AdminPatientProfileRepository _repo = AdminPatientProfileRepository();
  final AdminUserRepository _userRepo = AdminUserRepository();
  final AdminTherapistApprovalRepository _therapistRepo = AdminTherapistApprovalRepository();

  bool _loading = false;
  String _error = '';
  String _query = '';
  bool _redFlagOnly = false;

  List<AdminPatientProfileModel> _items = [];

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
      final list = await _repo.listPatients(token: token, redFlagOnly: _redFlagOnly, q: _query);
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

  Future<void> _toggleActive(AdminPatientProfileModel item, bool active) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    if (token == null || token.isEmpty) return;

    setState(() {
      _error = '';
      _items = _items.map((x) => x.patientId == item.patientId ? x.copyWith(active: active) : x).toList();
    });

    try {
      await _userRepo.setActive(token: token, userId: item.patientId, active: active);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
      await _load();
    }
  }

  Future<void> _assignTherapist(AdminPatientProfileModel item) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    if (token == null || token.isEmpty) return;

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final therapists = await _therapistRepo.list(token: token, status: 'ACTIVE');
      if (!mounted) return;
      setState(() => _loading = false);
      await _showAssignDialog(item, therapists);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _showAssignDialog(AdminPatientProfileModel item, List<TherapistApplicantModel> therapists) async {
    String? selectedId = item.therapistId;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Gán chuyên gia phụ trách',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bệnh nhân: ${item.nickname ?? item.email ?? item.patientId}',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedId,
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Chuyên gia (ACTIVE)'),
                items: therapists
                    .map((t) => DropdownMenuItem<String>(
                          value: t.therapistId,
                          enabled: !(t.caseloadFull && selectedId != t.therapistId),
                          child: Text('${t.fullName} • ${t.email} • ${t.caseloadCount}/${t.caseloadLimit}${t.caseloadFull ? " • FULL" : ""}', overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: (v) => selectedId = v,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Lưu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (ok != true || selectedId == null || selectedId!.isEmpty) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    if (token == null || token.isEmpty) return;

    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      await _repo.assignTherapist(token: token, patientId: item.patientId, therapistId: selectedId!);
      if (!mounted) return;
      await _load();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gán chuyên gia cho bệnh nhân.'), backgroundColor: AppColors.success),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Quản lý hồ sơ bệnh nhân', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Dữ liệu lấy từ backend (/api/admin/patients).', style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
            Row(
              children: [
                FilterChip(
                  label: const Text('Red Flag only'),
                  selected: _redFlagOnly,
                  onSelected: _loading
                      ? null
                      : (v) async {
                          setState(() => _redFlagOnly = v);
                          await _load();
                        },
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
            hintText: 'Tìm theo nickname / email / chuyên gia...',
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
          onSubmitted: (_) => _load(),
        ),
        const SizedBox(height: 12),
        if (_error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(_error, style: const TextStyle(color: Colors.red)),
          ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _items.isEmpty
                  ? const Center(child: Text('Không có dữ liệu.'))
                  : ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final it = _items[i];
                        final risk = it.currentRiskScore ?? 0;
                        final red = it.redFlagActive == true;
                        return Container(
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      it.nickname?.isNotEmpty == true ? it.nickname! : (it.email ?? it.patientId),
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${it.email ?? ''} • risk: $risk • redFlag: $red',
                                      style: const TextStyle(color: Colors.black54),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Chuyên gia: ${it.therapistName ?? 'Chưa gán'}',
                                      style: const TextStyle(color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                children: [
                                  Switch(
                                    value: it.active ?? true,
                                    onChanged: _loading ? null : (v) => _toggleActive(it, v),
                                    activeColor: AppColors.success,
                                  ),
                                  const Text('Active'),
                                ],
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                                onPressed: _loading ? null : () => _assignTherapist(it),
                                child: const Text('Gán BS', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

