// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/auth/auth_provider.dart';
import '../../core/config/api_config.dart';
import '../../features/therapist/data/models/therapist_credential_model.dart';
import '../../features/therapist/data/models/therapist_profile_model.dart';
import '../../features/therapist/data/repositories/therapist_credential_repository.dart';
import '../../features/therapist/data/repositories/therapist_profile_repository.dart';
import '../../theme/app_colors.dart';
import '../auth/therapist_login_screen.dart';

class TherapistProfileScreen extends StatefulWidget {
  const TherapistProfileScreen({super.key});

  @override
  State<TherapistProfileScreen> createState() => _TherapistProfileScreenState();
}

class _TherapistProfileScreenState extends State<TherapistProfileScreen> {
  final TherapistProfileRepository _repo = TherapistProfileRepository();
  final TherapistCredentialRepository _credentialRepo = TherapistCredentialRepository();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _hometownController = TextEditingController();
  final TextEditingController _birthYearController = TextEditingController();
  final TextEditingController _voiceDescriptionController = TextEditingController();
  final TextEditingController _specializationController = TextEditingController();
  final TextEditingController _therapyStyleController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _meetingLinkController = TextEditingController();

  bool _loaded = false;
  bool _loading = false;
  bool _saving = false;
  bool _credentialLoading = false;
  bool _avatarUploading = false;
  String? _error;
  String? _avatarUrl;
  List<TherapistCredentialModel> _credentials = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _loadProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _hometownController.dispose();
    _birthYearController.dispose();
    _voiceDescriptionController.dispose();
    _specializationController.dispose();
    _therapyStyleController.dispose();
    _bioController.dispose();
    _meetingLinkController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null || token.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final profile = await _repo.getMyProfile(token: token);
      final credentials = await _credentialRepo.listMine(token: token);
      if (!mounted) return;
      _applyProfile(profile);
      setState(() => _credentials = credentials);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _applyProfile(TherapistProfileModel profile) {
    _fullNameController.text = profile.fullName;
    _phoneNumberController.text = profile.phoneNumber ?? '';
    _emailController.text = profile.email;
    _hometownController.text = profile.hometown ?? '';
    _birthYearController.text = profile.birthYear?.toString() ?? '';
    _voiceDescriptionController.text = profile.voiceDescription ?? '';
    _specializationController.text = profile.specialization ?? '';
    _therapyStyleController.text = profile.therapyStyle ?? '';
    _bioController.text = profile.bio ?? '';
    _meetingLinkController.text = profile.meetingLink ?? '';
    setState(() => _avatarUrl = profile.avatarUrl);
  }

  Future<void> _saveProfile() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null || token.isEmpty) return;

        final phoneNumber = _phoneNumberController.text.trim();
    if (phoneNumber.isEmpty) {
      setState(() => _error = 'Số điện thoại không được để trống.');
      return;
    }

    final meetingLink = _meetingLinkController.text.trim();
    if (meetingLink.isNotEmpty && !meetingLink.startsWith('https://') && !meetingLink.startsWith('http://')) {
      setState(() => _error = 'Link tư vấn phải bắt đầu bằng http:// hoặc https://.');
      return;
    }

    final birthYear = _birthYearController.text.trim();
    if (birthYear.isNotEmpty && int.tryParse(birthYear) == null) {
      setState(() => _error = 'Năm sinh phải là số hợp lệ.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final saved = await _repo.updateMyProfile(
        token: token,
        fullName: _fullNameController.text.trim(),
        phoneNumber: phoneNumber,
        hometown: _hometownController.text.trim(),
        birthYear: birthYear,
        voiceDescription: _voiceDescriptionController.text.trim(),
        specialization: _specializationController.text.trim(),
        therapyStyle: _therapyStyleController.text.trim(),
        bio: _bioController.text.trim(),
        meetingLink: meetingLink,
      );
      if (!mounted) return;
      _applyProfile(saved);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật hồ sơ chuyên gia.'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() => _saving = false);
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null || token.isEmpty) return;

    final file = await _pickFile(accept: 'image/jpeg,image/png,image/webp');
    if (file == null) return;

    setState(() {
      _avatarUploading = true;
      _error = null;
    });

    try {
      final bytes = await _readFileBytes(file);
      final saved = await _repo.uploadAvatar(
        token: token,
        bytes: bytes,
        fileName: file.name,
        contentType: file.type.isNotEmpty ? file.type : 'application/octet-stream',
      );
      if (!mounted) return;
      _applyProfile(saved);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật ảnh đại diện.'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() => _avatarUploading = false);
    }
  }

  Future<void> _pickAndUploadCredential() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null || token.isEmpty) return;

    final file = await _pickFile(accept: '.pdf,image/jpeg,image/png');
    if (file == null) return;

    setState(() {
      _credentialLoading = true;
      _error = null;
    });

    try {
      final bytes = await _readFileBytes(file);
      await _credentialRepo.upload(
        token: token,
        bytes: bytes,
        fileName: file.name,
        contentType: file.type.isNotEmpty ? file.type : 'application/octet-stream',
      );
      await _reloadCredentials(token);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã tải lên chứng chỉ thành công.'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() => _credentialLoading = false);
    }
  }

  Future<void> _downloadCredential(TherapistCredentialModel item) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null || token.isEmpty) return;

    try {
      final bytes = await _credentialRepo.downloadBytes(token: token, credentialId: item.id);
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
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> _deleteCredential(TherapistCredentialModel item) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
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
      _credentialLoading = true;
      _error = null;
    });

    try {
      await _credentialRepo.deleteCredential(token: token, credentialId: item.id);
      await _reloadCredentials(token);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa chứng chỉ.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() => _credentialLoading = false);
    }
  }

  Future<void> _reloadCredentials(String token) async {
    final list = await _credentialRepo.listMine(token: token);
    if (!mounted) return;
    setState(() => _credentials = list);
  }

  Future<html.File?> _pickFile({required String accept}) async {
    final input = html.FileUploadInputElement()..accept = accept;
    input.click();
    await input.onChange.first;
    return input.files?.isNotEmpty == true ? input.files!.first : null;
  }

  Future<List<int>> _readFileBytes(html.File file) async {
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoad.first;
    final data = reader.result;
    if (data is ByteBuffer) return data.asUint8List().toList();
    if (data is Uint8List) return data.toList();
    if (data is List<int>) return data;
    throw Exception('Không thể đọc dữ liệu file.');
  }

  void _logout() {
    Provider.of<AuthProvider>(context, listen: false).logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const TherapistLoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Hồ sơ chuyên gia', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Tải lại hồ sơ',
            onPressed: _loading || _saving ? null : _loadProfile,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.primary.withOpacity(0.08)),
                    boxShadow: const [
                      BoxShadow(color: Color(0x11000000), blurRadius: 18, offset: Offset(0, 8)),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 300, child: _buildProfileSummary()),
                      const SizedBox(width: 32),
                      Expanded(child: _buildForm()),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildProfileSummary() {
    final displayName = _fullNameController.text.trim().isEmpty ? 'Chuyên gia' : _fullNameController.text.trim();
    final avatar = _publicUrl(_avatarUrl);

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 72,
              backgroundColor: AppColors.primary,
              backgroundImage: avatar == null ? null : NetworkImage(avatar),
              child: avatar == null
                  ? Text(
                      displayName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontSize: 52, color: Colors.white, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            Material(
              color: AppColors.secondary,
              shape: const CircleBorder(),
              child: IconButton(
                tooltip: 'Đổi ảnh đại diện',
                onPressed: _avatarUploading ? null : _pickAndUploadAvatar,
                icon: _avatarUploading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.camera_alt, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          displayName,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        Text(
          _specializationController.text.trim().isEmpty ? 'Chưa cập nhật chuyên môn' : _specializationController.text.trim(),
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        _summaryTile(Icons.location_on_outlined, 'Quê quán', _safeText(_hometownController.text)),
        _summaryTile(Icons.cake_outlined, 'Năm sinh', _safeText(_birthYearController.text)),
        _summaryTile(Icons.record_voice_over_outlined, 'Giọng nói', _safeText(_voiceDescriptionController.text)),
        _summaryTile(Icons.email_outlined, 'Email', _safeText(_emailController.text)),
        _summaryTile(Icons.link_outlined, 'Link tư vấn', _safeText(_meetingLinkController.text)),
      ],
    );
  }

  Widget _summaryTile(IconData icon, String label, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(value),
    );
  }

  String _safeText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? 'Chưa cập nhật' : trimmed;
  }

  String? _publicUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final origin = ApiConfig.baseUrl.replaceFirst(RegExp(r'/api/?$'), '');
    return '$origin$path';
  }

  Widget _buildCredentialsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Chứng chỉ hành nghề', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              OutlinedButton.icon(
                onPressed: _credentialLoading ? null : _pickAndUploadCredential,
                icon: const Icon(Icons.upload_file, size: 18),
                label: Text(_credentialLoading ? 'Đang xử lý...' : 'Tải lên chứng chỉ'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Chấp nhận PDF/JPG/PNG dung lượng tối đa 5MB. Nếu file sai, hãy xóa rồi tải lên lại.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          if (_credentialLoading && _credentials.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()))
          else if (_credentials.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
              child: const Text('Chưa có chứng chỉ nào. Hãy bổ sung ít nhất 1 chứng chỉ để admin dễ xác minh.'),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _credentials.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = _credentials[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.description_outlined, color: AppColors.primary),
                  title: Text(item.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('${(item.sizeBytes / 1024).toStringAsFixed(1)} KB • ${item.uploadedAt}'),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      TextButton(
                        onPressed: _credentialLoading ? null : () => _downloadCredential(item),
                        child: const Text('Tải xuống'),
                      ),
                      TextButton(
                        onPressed: _credentialLoading ? null : () => _deleteCredential(item),
                        style: TextButton.styleFrom(foregroundColor: AppColors.alert),
                        child: const Text('Xóa'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_error != null && _error!.isNotEmpty)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.alert.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(_error!, style: const TextStyle(color: AppColors.alert)),
          ),
        const Text('Thông tin hiển thị với bệnh nhân', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 14),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            _buildField(_fullNameController, 'Họ tên chuyên gia', width: 250),
            _buildField(_phoneNumberController, 'Số điện thoại *', width: 180),
            _buildField(_hometownController, 'Quê quán / khu vực', width: 200),
            _buildField(_birthYearController, 'Năm sinh', width: 100),
          ],
        ),
        const SizedBox(height: 14),
        _buildField(
          _voiceDescriptionController,
          'Giọng nói',
          hintText: 'Ví dụ: giọng Bắc nhẹ, ấm, chậm rãi',
          width: double.infinity,
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            _buildField(
              _specializationController,
              'Chuyên môn',
              hintText: 'Ví dụ: CBT, lo âu xã hội, trầm cảm...',
              width: 320,
            ),
            _buildField(
              _therapyStyleController,
              'Phong cách trị liệu',
              hintText: 'Ví dụ: nhẹ nhàng, thực tế, nhiều bài tập',
              width: 320,
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildField(
          _bioController,
          'Giới thiệu bản thân',
          hintText: 'Viết ngắn gọn để bệnh nhân hiểu cách bạn đồng hành.',
          maxLines: 5,
          width: double.infinity,
        ),
        const SizedBox(height: 24),
        const Text('Link phòng tư vấn', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        _buildField(
          _meetingLinkController,
          '',
          hintText: 'Ví dụ: https://meet.google.com/abc-xyz',
          prefixIcon: const Icon(Icons.link),
          width: double.infinity,
        ),
        const SizedBox(height: 6),
        const Text(
          'Link này sẽ được gắn vào các lịch hẹn mới và hỗ trợ đồng bộ cho các lịch đang thiếu link.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        _buildCredentialsSection(),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.alert,
                side: const BorderSide(color: AppColors.alert),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Đăng xuất'),
              onPressed: _saving ? null : _logout,
            ),
            const SizedBox(width: 14),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              ),
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save, color: Colors.white),
              label: Text(
                _saving ? 'Đang lưu...' : 'Lưu thay đổi',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              onPressed: _saving ? null : _saveProfile,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    String? hintText,
    Widget? prefixIcon,
    int maxLines = 1,
    double width = 320,
  }) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: label.isEmpty ? null : label,
          hintText: hintText,
          prefixIcon: prefixIcon,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
