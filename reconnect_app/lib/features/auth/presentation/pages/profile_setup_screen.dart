import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _occupationController = TextEditingController();
  final _medicalHistoryController = TextEditingController();

  bool _anonymousMode = true;
  String _gender = 'N\u1EEF';
  String? _selectedEducationLevel;
  String? _selectedRelationshipStatus;
  DateTime? _dateOfBirth;
  int _avatarIndex = 0;
  bool _initialized = false;

  static const List<String> _educationLevels = [
    'C\u1EA5p 2',
    'C\u1EA5p 3',
    'Trung c\u1EA5p',
    'Cao \u0111\u1EB3ng',
    '\u0110\u1EA1i h\u1ECDc',
    'Sau \u0111\u1EA1i h\u1ECDc',
    'Kh\u00E1c',
  ];

  static const List<String> _relationshipStatuses = [
    '\u0110\u1ED9c th\u00E2n',
    '\u0110ang t\u00ECm hi\u1EC3u',
    'H\u1EB9n h\u00F2',
    '\u0110\u00E3 k\u1EBFt h\u00F4n',
    'Ly h\u00F4n',
    'G\u00F3a',
    'Kh\u00E1c',
  ];

  static const List<_AvatarOption> _avatarOptions = [
    _AvatarOption(code: 'avatar_cat', icon: Icons.pets_outlined, label: 'M\u00E8o nh\u1ECF'),
    _AvatarOption(code: 'avatar_leaf', icon: Icons.spa_outlined, label: 'L\u00E1 xanh'),
    _AvatarOption(code: 'avatar_sun', icon: Icons.wb_sunny_outlined, label: 'N\u1EAFng \u1EA5m'),
    _AvatarOption(code: 'avatar_cloud', icon: Icons.cloud_outlined, label: 'M\u00E2y d\u1ECBu'),
    _AvatarOption(code: 'avatar_star', icon: Icons.auto_awesome_outlined, label: 'Ng\u00F4i sao'),
    _AvatarOption(code: 'avatar_flower', icon: Icons.local_florist_outlined, label: 'B\u00F4ng hoa'),
  ];

  bool get _showAnonymousSection => widget.mode != ProfileSetupMode.medicalProfile;
  bool get _showMedicalSection => widget.mode != ProfileSetupMode.anonymousDemo;

  @override
  void dispose() {
    _nicknameController.dispose();
    _realFullNameController.dispose();
    _phoneNumberController.dispose();
    _emergencyContactController.dispose();
    _occupationController.dispose();
    _medicalHistoryController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final auth = context.read<AuthProvider>();

    if (auth.isGuest) {
      final guestProfile = auth.guestProfile;
      final user = auth.loginResponse?.user;
      _nicknameController.text = guestProfile?.nickname ?? user?.username ?? '';
      final avatarCode = guestProfile?.avatarIcon ?? 'avatar_cat';
      final foundIndex = _avatarOptions.indexWhere((item) => item.code == avatarCode);
      _avatarIndex = foundIndex >= 0 ? foundIndex : 0;
      _anonymousMode = true;
    } else {
      final profile = auth.patientProfile;
      final user = auth.loginResponse?.user;
      _nicknameController.text = profile?.nickname ?? user?.username ?? '';
      _realFullNameController.text = profile?.realFullName ?? '';
      _phoneNumberController.text = profile?.phoneNumber ?? '';
      _emergencyContactController.text = profile?.emergencyContactPhone ?? '';
      _occupationController.text = profile?.occupation ?? '';
      _medicalHistoryController.text = profile?.medicalHistory ?? '';
      _selectedEducationLevel = _educationLevels.contains(profile?.educationLevel)
          ? profile?.educationLevel
          : null;
      _selectedRelationshipStatus = _relationshipStatuses.contains(profile?.relationshipStatus)
          ? profile?.relationshipStatus
          : null;
      _anonymousMode = profile?.anonymousModeEnabled ?? true;
      _gender = profile?.gender?.isNotEmpty == true ? profile!.gender! : 'N\u1EEF';
      if (profile?.dateOfBirth != null && profile!.dateOfBirth!.isNotEmpty) {
        _dateOfBirth = DateTime.tryParse(profile.dateOfBirth!);
      }

      final avatarCode = profile?.avatarIcon ?? 'avatar_cat';
      final foundIndex = _avatarOptions.indexWhere((item) => item.code == avatarCode);
      _avatarIndex = foundIndex >= 0 ? foundIndex : 0;
    }

    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final isAnonymousDemo = widget.mode == ProfileSetupMode.anonymousDemo;
    final isMedicalOnly = widget.mode == ProfileSetupMode.medicalProfile;

    return MindHealthScaffold(
      title: isAnonymousDemo
          ? 'Thi\u1EBFt l\u1EADp h\u1ED3 s\u01A1 kh\u00E1ch'
          : isMedicalOnly
              ? 'Ho\u00E0n thi\u1EC7n h\u1ED3 s\u01A1 y t\u1EBF'
              : 'Thi\u1EBFt l\u1EADp h\u1ED3 s\u01A1 ban \u0111\u1EA7u',
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _ProfileSetupHero(mode: widget.mode),
            const SizedBox(height: 18),
            if (_showAnonymousSection) ...[
              _SectionCard(
                title: widget.mode == ProfileSetupMode.anonymousDemo
                    ? 'H\u1ED3 s\u01A1 kh\u00E1ch v\u00E3ng lai'
                    : 'H\u1ED3 s\u01A1 hi\u1EC3n th\u1ECB trong app',
                subtitle: widget.mode == ProfileSetupMode.anonymousDemo
                    ? '\u1EDE b\u01B0\u1EDBc n\u00E0y b\u1EA1n ch\u1EC9 c\u1EA7n ch\u1ECDn bi\u1EC7t danh v\u00E0 avatar h\u1EC7 th\u1ED1ng \u0111\u1EC3 b\u1EAFt \u0111\u1EA7u l\u00E0m LSAS m\u1ED9t c\u00E1ch nh\u1EB9 nh\u00E0ng, ch\u01B0a c\u1EA7n khai th\u00F4ng tin y t\u1EBF th\u1EADt.'
                    : 'Ph\u1EA7n n\u00E0y l\u00E0 l\u1EDBp hi\u1EC3n th\u1ECB b\u00EAn ngo\u00E0i app. B\u1EA1n c\u00F3 th\u1EC3 d\u00F9ng bi\u1EC7t danh v\u00E0 avatar h\u1EC7 th\u1ED1ng \u0111\u1EC3 c\u1EA3m th\u1EA5y an to\u00E0n h\u01A1n khi b\u1EAFt \u0111\u1EA7u.',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nicknameController,
                      decoration: const InputDecoration(
                        labelText: 'Bi\u1EC7t danh',
                        hintText: 'V\u00ED d\u1EE5: M\u00E2y Nh\u1ECF, Daisy, CalmFox',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      validator: (value) {
                        if (_showAnonymousSection && (value == null || value.trim().isEmpty)) {
                          return 'Vui l\u00F2ng nh\u1EADp bi\u1EC7t danh.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    if (!isAnonymousDemo)
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _anonymousMode,
                        activeColor: AppColors.primary,
                        title: const Text('B\u1EADt ch\u1EBF \u0111\u1ED9 \u1EA9n danh'),
                        subtitle: const Text(
                          'Khi b\u1EADt, app \u01B0u ti\u00EAn hi\u1EC3n th\u1ECB bi\u1EC7t danh v\u00E0 avatar h\u1EC7 th\u1ED1ng. B\u00E1c s\u0129 v\u1EABn xem \u0111\u01B0\u1EE3c h\u1ED3 s\u01A1 y t\u1EBF th\u1EADt trong c\u1ED5ng qu\u1EA3n tr\u1ECB.',
                        ),
                        onChanged: (value) => setState(() => _anonymousMode = value),
                      ),
                    if (!isAnonymousDemo) const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Ch\u1ECDn avatar h\u1EC7 th\u1ED1ng',
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
                title: 'H\u1ED3 s\u01A1 y t\u1EBF ch\u00EDnh th\u1EE9c',
                subtitle:
                    'Ph\u1EA7n n\u00E0y ch\u1EC9 d\u00E0nh cho b\u00E1c s\u0129 v\u00E0 admin \u0111\u1EC3 ph\u1EE5c v\u1EE5 an to\u00E0n y t\u1EBF, h\u1ED7 tr\u1EE3 kh\u1EA9n c\u1EA5p v\u00E0 x\u00E2y d\u1EF1ng l\u1ED9 tr\u00ECnh \u0111i\u1EC1u tr\u1ECB \u0111\u00FAng cho b\u1EA1n.',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _realFullNameController,
                      decoration: const InputDecoration(
                        labelText: 'H\u1ECD v\u00E0 t\u00EAn th\u1EADt',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (_showMedicalSection && (value == null || value.trim().isEmpty)) {
                          return 'Vui l\u00F2ng nh\u1EADp h\u1ECD v\u00E0 t\u00EAn th\u1EADt.';
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
                        labelText: 'Gi\u1EDBi t\u00EDnh',
                        prefixIcon: Icon(Icons.wc_outlined),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'N\u1EEF', child: Text('N\u1EEF')),
                        DropdownMenuItem(value: 'Nam', child: Text('Nam')),
                        DropdownMenuItem(value: 'Kh\u00E1c', child: Text('Kh\u00E1c')),
                      ],
                      onChanged: (value) => setState(() => _gender = value ?? 'N\u1EEF'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'S\u1ED1 \u0111i\u1EC7n tho\u1EA1i c\u00E1 nh\u00E2n',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (_showMedicalSection && text.isEmpty) {
                          return 'Vui l\u00F2ng nh\u1EADp s\u1ED1 \u0111i\u1EC7n tho\u1EA1i c\u00E1 nh\u00E2n.';
                        }
                        if (text.isNotEmpty && !RegExp(r'^\d+$').hasMatch(text)) {
                          return 'S\u1ED1 \u0111i\u1EC7n tho\u1EA1i ch\u1EC9 \u0111\u01B0\u1EE3c ch\u1EE9a ch\u1EEF s\u1ED1.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emergencyContactController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'S\u1ED1 \u0111i\u1EC7n tho\u1EA1i ng\u01B0\u1EDDi li\u00EAn h\u1EC7 kh\u1EA9n c\u1EA5p',
                        prefixIcon: Icon(Icons.contact_phone_outlined),
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isNotEmpty && !RegExp(r'^\d+$').hasMatch(text)) {
                          return 'S\u1ED1 \u0111i\u1EC7n tho\u1EA1i ch\u1EC9 \u0111\u01B0\u1EE3c ch\u1EE9a ch\u1EEF s\u1ED1.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedEducationLevel,
                      decoration: const InputDecoration(
                        labelText: 'Tr\u00ECnh \u0111\u1ED9 h\u1ECDc v\u1EA5n',
                        prefixIcon: Icon(Icons.school_outlined),
                      ),
                      items: _educationLevels
                          .map((item) => DropdownMenuItem<String>(value: item, child: Text(item)))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedEducationLevel = value),
                      validator: (value) {
                        if (_showMedicalSection && (value == null || value.trim().isEmpty)) {
                          return 'Vui l\u00F2ng ch\u1ECDn tr\u00ECnh \u0111\u1ED9 h\u1ECDc v\u1EA5n.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _occupationController,
                      decoration: const InputDecoration(
                        labelText: 'Ngh\u1EC1 nghi\u1EC7p',
                        prefixIcon: Icon(Icons.work_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedRelationshipStatus,
                      decoration: const InputDecoration(
                        labelText: 'T\u00ECnh tr\u1EA1ng h\u00F4n nh\u00E2n / m\u1ED1i quan h\u1EC7',
                        prefixIcon: Icon(Icons.favorite_border),
                      ),
                      items: _relationshipStatuses
                          .map((item) => DropdownMenuItem<String>(value: item, child: Text(item)))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedRelationshipStatus = value),
                      validator: (value) {
                        if (_showMedicalSection && (value == null || value.trim().isEmpty)) {
                          return 'Vui l\u00F2ng ch\u1ECDn t\u00ECnh tr\u1EA1ng h\u00F4n nh\u00E2n / m\u1ED1i quan h\u1EC7.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _medicalHistoryController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Ti\u1EC1n s\u1EED b\u1EC7nh l\u00FD / thu\u1ED1c \u0111ang d\u00F9ng',
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.medical_information_outlined),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _onContinue,
                child: Text(_buttonLabel()),
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
        return 'L\u01B0u h\u1ED3 s\u01A1 kh\u00E1ch v\u00E0 l\u00E0m LSAS';
      case ProfileSetupMode.medicalProfile:
        return 'Ho\u00E0n t\u1EA5t h\u1ED3 s\u01A1 y t\u1EBF';
      case ProfileSetupMode.standard:
        return 'L\u01B0u h\u1ED3 s\u01A1 v\u00E0 ti\u1EBFp t\u1EE5c';
    }
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 20, 1, 1),
      firstDate: DateTime(now.year - 100, 1, 1),
      lastDate: DateTime(now.year - 10, 12, 31),
      helpText: 'Ch\u1ECDn ng\u00E0y sinh',
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  Future<void> _onContinue() async {
    if (!_formKey.currentState!.validate()) return;
    if (_showMedicalSection && _dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui l\u00F2ng ch\u1ECDn ng\u00E0y sinh.')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();

    if (auth.isGuest && widget.mode == ProfileSetupMode.anonymousDemo) {
      final ok = await auth.updateGuestProfile({
        'nickname': _nicknameController.text.trim(),
        'avatarIcon': _avatarOptions[_avatarIndex].code,
      });
      if (!mounted) return;
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.errorMessage)),
        );
        return;
      }
      context.go('/lsas');
      return;
    }

    final body = <String, dynamic>{};
    if (_showAnonymousSection) {
      body.addAll({
        'nickname': _nicknameController.text.trim(),
        'avatarIcon': _avatarOptions[_avatarIndex].code,
        'anonymousModeEnabled': _anonymousMode,
      });
    }

    if (_showMedicalSection) {
      body.addAll({
        'realFullName': _realFullNameController.text.trim(),
        'dateOfBirth': _dateOfBirth?.toIso8601String().split('T').first,
        'gender': _gender,
        'phoneNumber': _phoneNumberController.text.trim(),
        'emergencyContactPhone': _emergencyContactController.text.trim(),
        'educationLevel': _selectedEducationLevel,
        'occupation': _occupationController.text.trim(),
        'relationshipStatus': _selectedRelationshipStatus,
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
                      ? 'Tr\u1EA3i nghi\u1EC7m tr\u01B0\u1EDBc b\u1EB1ng Guest Mode'
                      : isMedicalOnly
                          ? 'B\u1ED5 sung h\u1ED3 s\u01A1 y t\u1EBF'
                          : 'Chu\u1EA9n b\u1ECB h\u1ED3 s\u01A1 ban \u0111\u1EA7u',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isAnonymousDemo
                      ? 'B\u1EA1n s\u1EBD ch\u1ECDn bi\u1EC7t danh v\u00E0 avatar h\u1EC7 th\u1ED1ng tr\u01B0\u1EDBc, sau \u0111\u00F3 l\u00E0m LSAS. K\u1EBFt qu\u1EA3 chi ti\u1EBFt ch\u1EC9 m\u1EDF sau khi b\u1EA1n li\u00EAn k\u1EBFt t\u00E0i kho\u1EA3n v\u00E0 v\u01B0\u1EE3t qua c\u1ED5ng an to\u00E0n y t\u1EBF.'
                      : isMedicalOnly
                          ? 'H\u1ED3 s\u01A1 th\u1EADt gi\u00FAp b\u00E1c s\u0129 h\u1ED7 tr\u1EE3 \u0111\u00FAng v\u00E0 can thi\u1EC7p an to\u00E0n khi c\u1EA7n. B\u1EC1 m\u1EB7t app v\u1EABn c\u00F3 th\u1EC3 ti\u1EBFp t\u1EE5c hi\u1EC3n th\u1ECB bi\u1EC7t danh n\u1EBFu b\u1EA1n b\u1EADt ch\u1EBF \u0111\u1ED9 \u1EA9n danh.'
                          : 'MindHealth t\u00E1ch ri\u00EAng l\u1EDBp hi\u1EC3n th\u1ECB trong app v\u00E0 l\u1EDBp h\u1ED3 s\u01A1 y t\u1EBF th\u1EADt \u0111\u1EC3 v\u1EEBa an to\u00E0n t\u00E2m l\u00FD, v\u1EEBa b\u1EA3o \u0111\u1EA3m an to\u00E0n \u0111i\u1EC1u tr\u1ECB.',
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
        ? 'Ch\u1ECDn ng\u00E0y sinh'
        : '${value!.day.toString().padLeft(2, '0')}/${value!.month.toString().padLeft(2, '0')}/${value!.year}';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Ng\u00E0y th\u00E1ng n\u0103m sinh',
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
