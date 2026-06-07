import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/mindhealth_scaffold.dart';
import '../../../../theme/app_colors.dart';
import '../providers/auth_provider.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _fullNameController = TextEditingController();
  bool _anonymousMode = true;
  int _avatarIndex = 0;
  bool _isInitialized = false;

  static const List<IconData> _avatarIcons = [
    Icons.pets_outlined,
    Icons.emoji_nature_outlined,
    Icons.sentiment_satisfied_alt_outlined,
    Icons.bolt_outlined,
    Icons.self_improvement_outlined,
    Icons.favorite_border_rounded,
  ];

  @override
  void dispose() {
    _displayNameController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialized) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.loginResponse?.user;
    if (user != null) {
      _anonymousMode = user.isAnonymous;
      _displayNameController.text = user.username ?? '';
    }
    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return MindHealthScaffold(
      title: 'Thiết lập hồ sơ',
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 20),
          children: [
            _ProfileSetupHero(anonymousMode: _anonymousMode),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chọn chế độ hiển thị danh tính',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Bạn có thể bắt đầu bằng nickname ẩn danh, sau đó đổi sang tên thật khi đã sẵn sàng bước vào trị liệu sâu hơn.',
                    style: TextStyle(color: AppColors.textSecondary, height: 1.45),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Bật chế độ ẩn danh'),
                    subtitle: Text(
                      _anonymousMode
                          ? 'Hiển thị nickname và avatar ẩn danh trong app.'
                          : 'Dùng tên hiển thị và thông tin thật hơn khi cần.',
                    ),
                    activeColor: AppColors.primary,
                    value: _anonymousMode,
                    onChanged: (value) => setState(() => _anonymousMode = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: _cardDecoration(),
              child: Column(
                children: [
                  TextFormField(
                    controller: _displayNameController,
                    decoration: InputDecoration(
                      labelText: _anonymousMode ? 'Nickname hiển thị' : 'Tên hiển thị',
                      hintText: _anonymousMode ? 'calm_fox' : 'Nguyễn Văn A',
                      prefixIcon: const Icon(Icons.badge_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập tên hiển thị.';
                      }
                      return null;
                    },
                  ),
                  if (!_anonymousMode) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Họ và tên',
                        hintText: 'Nhập họ tên đầy đủ',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (!_anonymousMode && (value == null || value.trim().isEmpty)) {
                          return 'Vui lòng nhập họ và tên.';
                        }
                        return null;
                      },
                    ),
                  ],
                ],
              ),
            ),
            if (_anonymousMode) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: _cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chọn avatar ẩn danh',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Chọn một biểu tượng khiến bạn thấy gần gũi. Avatar này giúp bạn giữ cảm giác an toàn khi bắt đầu.',
                      style: TextStyle(color: AppColors.textSecondary, height: 1.45),
                    ),
                    const SizedBox(height: 14),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _avatarIcons.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (context, index) {
                        final selected = _avatarIndex == index;
                        return InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => setState(() => _avatarIndex = index),
                          child: Ink(
                            decoration: BoxDecoration(
                              color: selected ? AppColors.primary.withOpacity(0.1) : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: selected ? AppColors.primary : Colors.grey.shade300,
                                width: selected ? 2 : 1,
                              ),
                            ),
                            child: Icon(
                              _avatarIcons[index],
                              size: 30,
                              color: selected ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                        );
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
                label: const Text('Tiếp tục đến bài LSAS'),
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

  void _onContinue() {
    if (!_formKey.currentState!.validate()) return;
    context.go('/lsas');
  }
}

class _ProfileSetupHero extends StatelessWidget {
  const _ProfileSetupHero({required this.anonymousMode});

  final bool anonymousMode;

  @override
  Widget build(BuildContext context) {
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
              anonymousMode ? Icons.visibility_off_outlined : Icons.verified_user_outlined,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thiết lập hồ sơ khởi đầu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  anonymousMode
                      ? 'Bạn đang ở chế độ ẩn danh. Chúng ta sẽ dùng nickname và avatar để bắt đầu thật nhẹ nhàng.'
                      : 'Bạn đang chọn chế độ hiển thị rõ hơn để đồng hành lâu dài cùng chuyên gia.',
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

BoxDecoration _cardDecoration() {
  return BoxDecoration(
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
  );
}
