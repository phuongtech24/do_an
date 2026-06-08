import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/mindhealth_scaffold.dart';
import '../../../../theme/app_colors.dart';
import '../providers/auth_provider.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({
    super.key,
    this.mode = ProfileSetupMode.standard,
    this.redirectAfter,
  });

  final ProfileSetupMode mode;
  final String? redirectAfter;

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

enum ProfileSetupMode {
  standard,
  anonymousDemo,
  medicalProfile,
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nicknameController = TextEditingController();
  final _realFullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _educationController = TextEditingController();
  final _occupationController = TextEditingController();
  final _relationshipController = TextEditingController();
  final _medicalHistoryController = TextEditingController();

  bool _anonymousMode = true;
  String _gender = 'Nữ';
  DateTime? _dateOfBirth;
  int _avatarIndex = 0;
  bool _initialized = false;

  static const List<_AvatarOption> _avatarOptions = [
    _AvatarOption(code: 'avatar_cat', icon: Icons.pets_outlined, label: 'Mèo nhỏ'),
    _AvatarOption(code: 'avatar_leaf', icon: Icons.spa_outlined, label: 'Lá xanh'),
    _AvatarOption(code: 'avatar_sun', icon: Icons.wb_sunny_outlined, label: 'Nắng ấm'),
    _AvatarOption(code: 'avatar_cloud', icon: Icons.cloud_outlined, label: 'Mây dịu'),
    _AvatarOption(code: 'avatar_star', icon: Icons.auto_awesome_outlined, label: 'Ngôi sao'),
    _AvatarOption(code: 'avatar_flower', icon: Icons.local_florist_outlined, label: 'Bông hoa'),
  ];

  bool get _showAnonymousSection => widget.mode != ProfileSetupMode.medicalProfile;
  bool get _showMedicalSection => widget.mode != ProfileSetupMode.anonymousDemo;

  @override
  void dispose() {
    _nicknameController.dispose();
    _realFullNameController.dispose();
    _phoneNumberController.dispose();
    _emergencyContactController.dispose();
    _educationController.dispose();
    _occupationController.dispose();
    _relationshipController.dispose();
    _medicalHistoryController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final auth = context.read<AuthProvider>();
    final profile = auth.patientProfile;
    final user = auth.loginResponse?.user;

    _nicknameController.text = profile?.nickname ?? user?.username ?? '';
    _realFullNameController.text = profile?.realFullName ?? '';
    _phoneNumberController.text = profile?.phoneNumber ?? '';
    _emergencyContactController.text = profile?.emergencyContactPhone ?? '';
    _educationController.text = profile?.educationLevel ?? '';
    _occupationController.text = profile?.occupation ?? '';
    _relationshipController.text = profile?.relationshipStatus ?? '';
    _medicalHistoryController.text = profile?.medicalHistory ?? '';
    _anonymousMode = profile?.anonymousModeEnabled ?? true;
    _gender = profile?.gender?.isNotEmpty == true ? profile!.gender! : 'Nữ';
    if (profile?.dateOfBirth != null && profile!.dateOfBirth!.isNotEmpty) {
      _dateOfBirth = DateTime.tryParse(profile.dateOfBirth!);
    }

    final avatarCode = profile?.avatarIcon ?? 'avatar_cat';
    final foundIndex = _avatarOptions.indexWhere((item) => item.code == avatarCode);
    _avatarIndex = foundIndex >= 0 ? foundIndex : 0;
    if (widget.mode == ProfileSetupMode.medicalProfile) {
      _anonymousMode = profile?.anonymousModeEnabled ?? true;
    }
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final isAnonymousDemo = widget.mode == ProfileSetupMode.anonymousDemo;
    final isMedicalOnly = widget.mode == ProfileSetupMode.medicalProfile;

    return MindHealthScaffold(
      title: isAnonymousDemo
          ? 'Thiết lập hồ sơ ẩn danh'
          : isMedicalOnly
              ? 'Hoàn thiện hồ sơ y tế'
              : 'Thiết lập hồ sơ ban đầu',
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _ProfileSetupHero(mode: widget.mode),
            const SizedBox(height: 18),
            if (_showAnonymousSection) ...[
              _SectionCard(
                title: 'Hồ sơ ẩn danh',
                subtitle:
                    'Phần này hiển thị ra ngoài app. Bạn sẽ dùng biệt danh và avatar hệ thống để thấy an toàn hơn khi bắt đầu.',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nicknameController,
                      decoration: const InputDecoration(
                        labelText: 'Biệt danh',
                        hintText: 'Ví dụ: Mây Nhỏ, Daisy, CalmFox',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      validator: (value) {
                        if (_showAnonymousSection && (value == null || value.trim().isEmpty)) {
                          return 'Vui lòng nhập biệt danh.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _anonymousMode,
                      activeColor: AppColors.primary,
                      title: const Text('Bật chế độ ẩn danh'),
                      subtitle: const Text(
                        'Mặc định toàn bộ app sẽ hiển thị biệt danh và avatar hệ thống. Bác sĩ vẫn xem được hồ sơ y tế thật ở cổng quản trị.',
                      ),
                      onChanged: widget.mode == ProfileSetupMode.medicalProfile
                          ? (value) => setState(() => _anonymousMode = value)
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Chọn avatar hệ thống',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _avatarOptions.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.1,
                      ),
                      itemBuilder: (context, index) {
                        final option = _avatarOptions[index];
                        final selected = _avatarIndex == index;
                        return InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => setState(() => _avatarIndex = index),
                          child: Ink(
                            decoration: BoxDecoration(
                              color: selected ? AppColors.primary.withOpacity(0.08) : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: selected ? AppColors.primary : Colors.grey.shade300,
                                width: selected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  option.icon,
                                  color: selected ? AppColors.primary : AppColors.textSecondary,
                                  size: 30,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  option.label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                    color: selected ? AppColors.primary : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
            if (_showMedicalSection) ...[
              _SectionCard(
                title: 'Hồ sơ y tế chính thức',
                subtitle:
                    'Phần này chỉ dành cho bác sĩ và admin để phục vụ an toàn y tế, hỗ trợ khẩn cấp và xây dựng lộ trình điều trị đúng.',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _realFullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Họ và tên thật',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (_showMedicalSection && (value == null || value.trim().isEmpty)) {
                          return 'Vui lòng nhập họ và tên thật.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _DateOfBirthField(
                      value: _dateOfBirth,
                      onTap: _pickDateOfBirth,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: const InputDecoration(
                        labelText: 'Giới tính',
                        prefixIcon: Icon(Icons.wc_outlined),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
                        DropdownMenuItem(value: 'Nam', child: Text('Nam')),
                        DropdownMenuItem(value: 'Khác', child: Text('Khác')),
                      ],
                      onChanged: (value) => setState(() => _gender = value ?? 'Nữ'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Số điện thoại cá nhân',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (value) {
                        if (_showMedicalSection && (value == null || value.trim().isEmpty)) {
                          return 'Vui lòng nhập số điện thoại cá nhân.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emergencyContactController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Số điện thoại người liên hệ khẩn cấp',
                        prefixIcon: Icon(Icons.contact_phone_outlined),
                      ),
                      validator: (value) {
                        if (_showMedicalSection && (value == null || value.trim().isEmpty)) {
                          return 'Vui lòng nhập số điện thoại liên hệ khẩn cấp.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _educationController,
                      decoration: const InputDecoration(
                        labelText: 'Trình độ học vấn',
                        prefixIcon: Icon(Icons.school_outlined),
                      ),
                      validator: (value) {
                        if (_showMedicalSection && (value == null || value.trim().isEmpty)) {
                          return 'Vui lòng nhập trình độ học vấn.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _occupationController,
                      decoration: const InputDecoration(
                        labelText: 'Nghề nghiệp',
                        prefixIcon: Icon(Icons.work_outline),
                      ),
                      validator: (value) {
                        if (_showMedicalSection && (value == null || value.trim().isEmpty)) {
                          return 'Vui lòng nhập nghề nghiệp.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _relationshipController,
                      decoration: const InputDecoration(
                        labelText: 'Tình trạng hôn nhân / mối quan hệ',
                        prefixIcon: Icon(Icons.favorite_border),
                      ),
                      validator: (value) {
                        if (_showMedicalSection && (value == null || value.trim().isEmpty)) {
                          return 'Vui lòng nhập tình trạng hôn nhân hoặc mối quan hệ.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _medicalHistoryController,
                      minLines: 3,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Tiền sử bệnh lý / thuốc đang dùng',
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.medication_outlined),
                      ),
                      validator: (value) {
                        if (_showMedicalSection && (value == null || value.trim().isEmpty)) {
                          return 'Vui lòng mô tả ngắn gọn tiền sử bệnh lý hoặc thuốc đang dùng.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _onContinue,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(_buttonLabel()),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buttonLabel() {
    switch (widget.mode) {
      case ProfileSetupMode.anonymousDemo:
        return 'Lưu hồ sơ ẩn danh và làm LSAS';
      case ProfileSetupMode.medicalProfile:
        return 'Hoàn tất hồ sơ y tế';
      case ProfileSetupMode.standard:
        return 'Lưu hồ sơ và tiếp tục';
    }
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 20, 1, 1),
      firstDate: DateTime(now.year - 100, 1, 1),
      lastDate: DateTime(now.year - 10, 12, 31),
      helpText: 'Chọn ngày sinh',
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  Future<void> _onContinue() async {
    if (!_formKey.currentState!.validate()) return;
    if (_showMedicalSection && _dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày sinh.')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final body = <String, dynamic>{
      'nickname': _nicknameController.text.trim(),
      'avatarIcon': _avatarOptions[_avatarIndex].code,
      'anonymousModeEnabled': _anonymousMode,
    };

    if (_showMedicalSection) {
      body.addAll({
        'realFullName': _realFullNameController.text.trim(),
        'dateOfBirth': _dateOfBirth?.toIso8601String().split('T').first,
        'gender': _gender,
        'phoneNumber': _phoneNumberController.text.trim(),
        'emergencyContactPhone': _emergencyContactController.text.trim(),
        'educationLevel': _educationController.text.trim(),
        'occupation': _occupationController.text.trim(),
        'relationshipStatus': _relationshipController.text.trim(),
        'medicalHistory': _medicalHistoryController.text.trim(),
      });
    }

    final ok = await auth.updatePatientProfile(body);
    if (!mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage)),
      );
      return;
    }

    if (widget.mode == ProfileSetupMode.anonymousDemo) {
      context.go('/lsas');
      return;
    }

    final redirectAfter = widget.redirectAfter;
    if (redirectAfter != null && redirectAfter.isNotEmpty) {
      context.go(redirectAfter);
      return;
    }

    context.go('/lsas');
  }
}

class _ProfileSetupHero extends StatelessWidget {
  const _ProfileSetupHero({required this.mode});

  final ProfileSetupMode mode;

  @override
  Widget build(BuildContext context) {
    final isAnonymousDemo = mode == ProfileSetupMode.anonymousDemo;
    final isMedicalOnly = mode == ProfileSetupMode.medicalProfile;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF159489)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              isAnonymousDemo
                  ? Icons.privacy_tip_outlined
                  : isMedicalOnly
                      ? Icons.health_and_safety_outlined
                      : Icons.person_add_alt_1_outlined,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAnonymousDemo
                      ? 'Bắt đầu ẩn danh, an toàn'
                      : isMedicalOnly
                          ? 'Hoàn thiện hồ sơ y tế'
                          : 'Chuẩn bị hồ sơ ban đầu',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isAnonymousDemo
                      ? 'Bạn có thể dùng biệt danh và avatar hệ thống để làm LSAS trước. Khi cần mở khóa kết quả và lộ trình CBT, app sẽ mời bạn khai thêm hồ sơ thật.'
                      : isMedicalOnly
                          ? 'Hồ sơ thật giúp bác sĩ và admin hỗ trợ đúng, đặc biệt khi có nguy cơ khẩn cấp hoặc cần liên hệ an toàn.'
                          : 'Bạn sẽ có cả hai lớp danh tính: một hồ sơ ẩn danh để thấy an toàn khi dùng app, và một hồ sơ thật phục vụ y tế.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.92),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.45),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _DateOfBirthField extends StatelessWidget {
  const _DateOfBirthField({
    required this.value,
    required this.onTap,
  });

  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = value == null
        ? 'Chọn ngày sinh'
        : '${value!.day.toString().padLeft(2, '0')}/${value!.month.toString().padLeft(2, '0')}/${value!.year}';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Ngày tháng năm sinh',
          prefixIcon: Icon(Icons.cake_outlined),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: value == null ? AppColors.textSecondary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _AvatarOption {
  const _AvatarOption({
    required this.code,
    required this.icon,
    required this.label,
  });

  final String code;
  final IconData icon;
  final String label;
}
