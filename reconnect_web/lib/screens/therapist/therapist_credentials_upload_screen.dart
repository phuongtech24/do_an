// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/auth/auth_provider.dart';
import '../../features/therapist/data/models/therapist_credential_model.dart';
import '../../features/therapist/data/models/therapist_profile_status_model.dart';
import '../../features/therapist/data/repositories/therapist_credential_repository.dart';
import '../../theme/app_colors.dart';
import '../auth/therapist_login_screen.dart';
import 'main_therapist_screen.dart';

class TherapistCredentialsUploadScreen extends StatefulWidget {
  const TherapistCredentialsUploadScreen({super.key});

  @override
  State<TherapistCredentialsUploadScreen> createState() => _TherapistCredentialsUploadScreenState();
}

class _TherapistCredentialsUploadScreenState extends State<TherapistCredentialsUploadScreen> {
  final TherapistCredentialRepository _repo = TherapistCredentialRepository();

  bool _loading = false;
  String _error = '';
  TherapistProfileStatusModel? _status;
  List<TherapistCredentialModel> _items = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  Future<void> _loadAll() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    if (token == null || token.isEmpty) return;

    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final status = await _repo.myStatus(token: token);
      final list = await _repo.listMine(token: token);
      if (!mounted) return;
      setState(() {
        _status = status;
        _items = list;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _pickAndUpload() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    if (token == null || token.isEmpty) return;

    final input = html.FileUploadInputElement();
    input.accept = '.pdf,image/jpeg,image/png';
    input.click();

    input.onChange.listen((_) async {
      final file = input.files?.first;
      if (file == null) return;

      setState(() {
        _loading = true;
        _error = '';
      });

      try {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        await reader.onLoad.first;
        final data = reader.result;
        Uint8List bytesView;
        if (data is ByteBuffer) {
          bytesView = data.asUint8List();
        } else if (data is Uint8List) {
          bytesView = data;
        } else if (data is List<int>) {
          bytesView = Uint8List.fromList(data);
        } else {
          throw Exception('Cannot read file bytes');
        }

        final bytes = bytesView.toList();
        final contentType = file.type.isNotEmpty ? file.type : 'application/octet-stream';

        await _repo.upload(
          token: token,
          bytes: bytes,
          fileName: file.name,
          contentType: contentType,
        );
        await _loadAll();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tải lên chứng chỉ thành công. Vui lòng chờ phê duyệt.')),
        );
      } catch (e) {
        if (!mounted) return;
        setState(() => _error = e.toString().replaceAll('Exception: ', ''));
      } finally {
        if (!mounted) return;
        setState(() => _loading = false);
      }
    });
  }

  Future<void> _download(TherapistCredentialModel item) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    if (token == null || token.isEmpty) return;
    try {
      final bytes = await _repo.downloadBytes(token: token, credentialId: item.id);
      final blob = html.Blob([bytes], item.mimeType);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final a = html.AnchorElement(href: url)
        ..download = item.fileName
        ..style.display = 'none';
      html.document.body?.children.add(a);
      a.click();
      a.remove();
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    }
  }


  Future<void> _deleteCredential(TherapistCredentialModel item) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    if (token == null || token.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa chứng chỉ?'),
        content: Text('Bạn có chắc muốn xóa file "${item.fileName}" không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.alert, foregroundColor: Colors.white),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      await _repo.deleteCredential(token: token, credentialId: item.id);
      await _loadAll();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa chứng chỉ.')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  String _mapStatus(String s) {
    if (s == 'PENDING') return 'Chờ duyệt';
    if (s == 'ACTIVE') return 'Đang hoạt động';
    if (s == 'REJECTED') return 'Từ chối';
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;
    final canEnter = status != null && status.approvalStatus == 'ACTIVE';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Container(
          width: 720,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Tải lên chứng chỉ hành nghề',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _loading
                        ? null
                        : () {
                            Provider.of<AuthProvider>(context, listen: false).logout();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const TherapistLoginScreen()),
                              (_) => false,
                            );
                          },
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Đăng xuất'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Bạn có thể đăng nhập ngay, nhưng chỉ được dùng chức năng chuyên môn sau khi Admin duyệt.',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              if (status != null)
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _pill('Trạng thái', _mapStatus(status.approvalStatus)),
                    _pill('Số chứng chỉ', status.credentialCount.toString()),
                  ],
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _loading ? null : _pickAndUpload,
                    icon: const Icon(Icons.upload_file, color: Colors.white),
                    label: Text(_loading ? 'ĐANG TẢI LÊN...' : 'CHỌN FILE & TẢI LÊN', style: const TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: _loading ? null : _loadAll,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tải lại'),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: canEnter
                        ? () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainTherapistScreen()))
                        : null,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                    child: const Text('Vào hệ thống', style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
              const SizedBox(height: 12),
              const Text('Chỉ chấp nhận PDF/JPG/PNG ≤ 5MB.', style: TextStyle(fontSize: 12, color: Colors.black54)),
              if (_error.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(_error, style: const TextStyle(color: AppColors.alert)),
              ],
              const SizedBox(height: 16),
              SizedBox(
                height: 240,
                child: _loading && _items.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _items.isEmpty
                        ? const Center(child: Text('Chưa có chứng chỉ nào.'))
                        : ListView.separated(
                            itemCount: _items.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final it = _items[index];
                              return ListTile(
                                leading: const Icon(Icons.description_outlined),
                                title: Text(it.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
                                subtitle: Text('${(it.sizeBytes / 1024).toStringAsFixed(1)} KB • ${it.uploadedAt}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton(
                                      onPressed: _loading ? null : () => _download(it),
                                      child: const Text('Tải xuống'),
                                    ),
                                    IconButton(
                                      onPressed: _loading ? null : () => _deleteCredential(it),
                                      icon: const Icon(Icons.close, color: AppColors.alert),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text('$label: $value', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
