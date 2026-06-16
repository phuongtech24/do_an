import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/auth/auth_provider.dart';
import '../../features/admin/data/models/therapist_applicant_model.dart';
import '../../features/admin/data/models/therapist_credential_model.dart';
import '../../features/admin/data/repositories/admin_therapist_approval_repository.dart';
import '../../features/admin/data/repositories/admin_therapist_credentials_repository.dart';
import '../../features/admin/data/repositories/admin_therapist_management_repository.dart';
import '../../features/admin/data/repositories/admin_user_repository.dart';
import '../../shared/widgets/pagination_bar.dart';
import '../../theme/app_colors.dart';

class AdminVerifyDoctorScreen extends StatefulWidget {
  const AdminVerifyDoctorScreen({super.key});

  @override
  State<AdminVerifyDoctorScreen> createState() => _AdminVerifyDoctorScreenState();
}

class _AdminVerifyDoctorScreenState extends State<AdminVerifyDoctorScreen> {
  final AdminTherapistApprovalRepository _repo = AdminTherapistApprovalRepository();
  final AdminTherapistCredentialsRepository _credRepo = AdminTherapistCredentialsRepository();
  final AdminUserRepository _adminUserRepo = AdminUserRepository();
  final AdminTherapistManagementRepository _managementRepo = AdminTherapistManagementRepository();

  bool _loading = false;
  String _error = '';
  String _query = '';
  int _pageIndex = 1;
  int _pageSize = 10;
  int _totalPages = 0;
  int _totalElements = 0;
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

    if (status == 'ACTIVE' && item.credentialCount <= 0) {
      setState(() => _error = 'Chưa có chứng chỉ. Không thể duyệt ACTIVE.');
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
      _items = _items
          .map((x) => x.therapistId == item.therapistId
              ? TherapistApplicantModel(
                  therapistId: x.therapistId,
                  fullName: x.fullName,
                  email: x.email,
                  hometown: x.hometown,
                  birthYear: x.birthYear,
                  voiceDescription: x.voiceDescription,
                  specialization: x.specialization,
                  therapyStyle: x.therapyStyle,
                  bio: x.bio,
                  meetingLink: x.meetingLink,
                  avatarUrl: x.avatarUrl,
                  approvalStatus: status,
                  credentialCount: x.credentialCount,
                  active: x.active,
                  caseloadCount: x.caseloadCount,
                  caseloadLimit: x.caseloadLimit,
                  caseloadFull: x.caseloadFull,
                )
              : x)
          .toList();
    });

    try {
      final updated = await _repo.setApproval(
        token: token,
        therapistId: item.therapistId,
        status: status,
      );
      if (!mounted) return;
      setState(() {
        _items = _items.map((x) => x.therapistId == item.therapistId ? updated : x).toList();
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

  Future<void> _toggleActive(TherapistApplicantModel item) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    if (token == null || token.isEmpty) return;

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final updated = await _adminUserRepo.setActive(
        token: token,
        userId: item.therapistId,
        active: !item.active,
      );
      if (!mounted) return;
      setState(() {
        _items = _items
            .map((x) => x.therapistId == item.therapistId
                ? TherapistApplicantModel(
                    therapistId: x.therapistId,
                    fullName: x.fullName,
                    email: x.email,
                    hometown: x.hometown,
                    birthYear: x.birthYear,
                    voiceDescription: x.voiceDescription,
                    specialization: x.specialization,
                    therapyStyle: x.therapyStyle,
                    bio: x.bio,
                    meetingLink: x.meetingLink,
                    avatarUrl: x.avatarUrl,
                    approvalStatus: x.approvalStatus,
                    credentialCount: x.credentialCount,
                    active: updated.isActive,
                    caseloadCount: x.caseloadCount,
                    caseloadLimit: x.caseloadLimit,
                    caseloadFull: x.caseloadFull,
                  )
                : x)
            .toList();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword(TherapistApplicantModel item) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    if (token == null || token.isEmpty) return;

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final newPassword = await _managementRepo.resetPassword(
        token: token,
        therapistId: item.therapistId,
      );
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Đặt lại mật khẩu'),
          content: SelectableText('Mật khẩu mới: $newPassword'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _editTherapist(TherapistApplicantModel item) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    if (token == null || token.isEmpty) return;

    final fullNameCtrl = TextEditingController(text: item.fullName);
    final hometownCtrl = TextEditingController(text: item.hometown ?? '');
    final birthYearCtrl = TextEditingController(text: item.birthYear?.toString() ?? '');
    final voiceDescriptionCtrl = TextEditingController(text: item.voiceDescription ?? '');
    final specializationCtrl = TextEditingController(text: item.specialization ?? '');
    final therapyStyleCtrl = TextEditingController(text: item.therapyStyle ?? '');
    final meetingLinkCtrl = TextEditingController(text: item.meetingLink ?? '');
    final bioCtrl = TextEditingController(text: item.bio ?? '');

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa hồ sơ chuyên gia'),
        content: SizedBox(
          width: 620,
          child: SingleChildScrollView(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: fullNameCtrl, decoration: const InputDecoration(labelText: 'Họ tên')),
              const SizedBox(height: 10),
              TextField(controller: hometownCtrl, decoration: const InputDecoration(labelText: 'Quê quán / khu vực')),
              const SizedBox(height: 10),
              TextField(
                controller: birthYearCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Năm sinh'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: voiceDescriptionCtrl,
                decoration: const InputDecoration(labelText: 'Giọng nói'),
              ),
              const SizedBox(height: 10),
              TextField(controller: specializationCtrl, decoration: const InputDecoration(labelText: 'Chuyên môn')),
              const SizedBox(height: 10),
              TextField(
                controller: therapyStyleCtrl,
                decoration: const InputDecoration(labelText: 'Phong cách trị liệu'),
              ),
              const SizedBox(height: 10),
              TextField(controller: meetingLinkCtrl, decoration: const InputDecoration(labelText: 'Link tư vấn')),
              const SizedBox(height: 10),
              TextField(controller: bioCtrl, decoration: const InputDecoration(labelText: 'Giới thiệu'), maxLines: 3),
            ],
          ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Lưu')),
        ],
      ),
    );

    if (ok != true) return;

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final updated = await _managementRepo.updateProfile(
        token: token,
        therapistId: item.therapistId,
        fullName: fullNameCtrl.text.trim(),
        hometown: hometownCtrl.text.trim(),
        birthYear: int.tryParse(birthYearCtrl.text.trim()),
        voiceDescription: voiceDescriptionCtrl.text.trim(),
        specialization: specializationCtrl.text.trim(),
        therapyStyle: therapyStyleCtrl.text.trim(),
        meetingLink: meetingLinkCtrl.text.trim(),
        bio: bioCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _items = _items.map((x) => x.therapistId == item.therapistId ? updated : x).toList();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _showCredentialsDialog(TherapistApplicantModel item) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    if (token == null || token.isEmpty) return;

    setState(() {
      _loading = true;
      _error = '';
    });

    List<AdminTherapistCredentialModel> list = [];
    try {
      list = await _credRepo.list(token: token, therapistId: item.therapistId);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) => _CredentialPreviewDialog(
        applicantName: item.fullName,
        therapistId: item.therapistId,
        token: token,
        credentials: list,
        repository: _credRepo,
        onDownloadError: (message) {
          if (!mounted) return;
          setState(() => _error = message);
        },
      ),
    );
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
              const Text(
                'Admin đặt mật khẩu và cung cấp trực tiếp cho chuyên gia.',
                style: TextStyle(color: Colors.black54),
              ),
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
                decoration: const InputDecoration(
                  labelText: 'Chuyên môn (optional)',
                  border: OutlineInputBorder(),
                ),
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
        const SnackBar(
          content: Text('Đã tạo tài khoản therapist. Trạng thái: PENDING'),
          backgroundColor: AppColors.success,
        ),
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
                Text(
                  'Quản lý Bác sĩ/Chuyên gia (Approval)',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Dữ liệu lấy từ backend (/api/admin/therapists).',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
            Row(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  icon: const Icon(Icons.person_add, color: Colors.white),
                  label: const Text(
                    'CẤP TÀI KHOẢN',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _loading ? null : _showCreateAccountDialog,
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _loading ? null : _load,
                  icon: const Icon(Icons.refresh),
                ),
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
          onChanged: (value) => setState(() => _query = value),
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
                        subtitle: Text(
                          'Email: ${doc.email}'
                          '${doc.specialization == null || doc.specialization!.isEmpty ? '' : ' • ${doc.specialization}'}'
                          '${doc.hometown == null || doc.hometown!.isEmpty ? '' : ' • ${doc.hometown}'}'
                          ' • Chứng chỉ: ${doc.credentialCount}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OutlinedButton(
                              onPressed: _loading ? null : () => _showCredentialsDialog(doc),
                              child: const Text('Xem chứng chỉ'),
                            ),
                            const SizedBox(width: 8),
                            if (isPending) ...[
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                                onPressed: _loading ? null : () => _setApproval(doc, 'ACTIVE'),
                                child: const Text('Duyệt', style: TextStyle(color: Colors.white)),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.alert),
                                onPressed: _loading ? null : () => _setApproval(doc, 'REJECTED'),
                                child: const Text('Từ chối', style: TextStyle(color: Colors.white)),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Tooltip(
                              message: doc.active ? 'Khóa tài khoản' : 'Mở khóa tài khoản',
                              child: Switch(
                                value: doc.active,
                                onChanged: _loading ? null : (_) => _toggleActive(doc),
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') _editTherapist(doc);
                                if (value == 'reset_pw') _resetPassword(doc);
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa hồ sơ')),
                                PopupMenuItem(value: 'reset_pw', child: Text('Đặt lại mật khẩu')),
                              ],
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Icon(Icons.more_vert),
                              ),
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

class _CredentialPreviewDialog extends StatefulWidget {
  const _CredentialPreviewDialog({
    required this.applicantName,
    required this.therapistId,
    required this.token,
    required this.credentials,
    required this.repository,
    required this.onDownloadError,
  });

  final String applicantName;
  final String therapistId;
  final String token;
  final List<AdminTherapistCredentialModel> credentials;
  final AdminTherapistCredentialsRepository repository;
  final ValueChanged<String> onDownloadError;

  @override
  State<_CredentialPreviewDialog> createState() => _CredentialPreviewDialogState();
}

class _CredentialPreviewDialogState extends State<_CredentialPreviewDialog> {
  final Map<String, Future<Uint8List?>> _previewFutures = {};

  bool _isImage(AdminTherapistCredentialModel item) {
    return item.mimeType.toLowerCase().startsWith('image/');
  }

  Future<Uint8List?> _loadPreview(AdminTherapistCredentialModel item) {
    return _previewFutures.putIfAbsent(item.id, () async {
      if (!_isImage(item)) return null;
      final bytes = await widget.repository.downloadBytes(
        token: widget.token,
        therapistId: widget.therapistId,
        credentialId: item.id,
      );
      return Uint8List.fromList(bytes);
    });
  }

  Future<void> _download(AdminTherapistCredentialModel item) async {
    try {
      final bytes = await widget.repository.downloadBytes(
        token: widget.token,
        therapistId: widget.therapistId,
        credentialId: item.id,
      );
      final blob = html.Blob([bytes], item.mimeType);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..download = item.fileName
        ..style.display = 'none';
      html.document.body?.children.add(anchor);
      anchor.click();
      anchor.remove();
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      widget.onDownloadError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _showImagePreview(AdminTherapistCredentialModel item, Uint8List bytes) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820, maxHeight: 700),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.fileName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: InteractiveViewer(
                      child: Image.memory(bytes, fit: BoxFit.contain),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Đóng'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: Text(
        'Chứng chỉ: ${widget.applicantName}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 680,
        child: widget.credentials.isEmpty
            ? const Text('Chưa có chứng chỉ nào.')
            : ListView.separated(
                shrinkWrap: true,
                itemCount: widget.credentials.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = widget.credentials[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withOpacity(0.08)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_isImage(item))
                          FutureBuilder<Uint8List?>(
                            future: _loadPreview(item),
                            builder: (context, snapshot) {
                              Widget child;
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                child = const Center(
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                );
                              } else if (snapshot.hasData && snapshot.data != null) {
                                final bytes = snapshot.data!;
                                child = InkWell(
                                  onTap: () => _showImagePreview(item, bytes),
                                  borderRadius: BorderRadius.circular(14),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.memory(
                                      bytes,
                                      width: 88,
                                      height: 88,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              } else {
                                child = const Icon(Icons.broken_image_outlined, color: AppColors.textSecondary);
                              }

                              return Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: child,
                              );
                            },
                          )
                        else
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.description_outlined, color: AppColors.primary, size: 30),
                                SizedBox(height: 6),
                                Text('PDF/File', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.fileName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${(item.sizeBytes / 1024).toStringAsFixed(1)} KB • ${item.uploadedAt}',
                                style: const TextStyle(color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (_isImage(item))
                                    FutureBuilder<Uint8List?>(
                                      future: _loadPreview(item),
                                      builder: (context, snapshot) {
                                        final bytes = snapshot.data;
                                        return OutlinedButton.icon(
                                          onPressed: bytes == null ? null : () => _showImagePreview(item, bytes),
                                          icon: const Icon(Icons.visibility_outlined),
                                          label: const Text('Xem ảnh'),
                                        );
                                      },
                                    ),
                                  TextButton(
                                    onPressed: () => _download(item),
                                    child: const Text('Tải'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
      ],
    );
  }
}
