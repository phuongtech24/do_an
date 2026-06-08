import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/mindhealth_scaffold.dart';
import '../../../../theme/app_colors.dart';
import '../../../onboarding/presentation/utils/onboarding_route_resolver.dart';
import '../providers/auth_provider.dart';

class AnonymousAuthScreen extends StatefulWidget {
  const AnonymousAuthScreen({super.key});

  @override
  State<AnonymousAuthScreen> createState() => _AnonymousAuthScreenState();
}

class _AnonymousAuthScreenState extends State<AnonymousAuthScreen> {
  @override
  Widget build(BuildContext context) {
    return MindHealthScaffold(
      title: 'MindHealth - Đăng nhập',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SizedBox(height: 6),
            _AuthHero(),
            SizedBox(height: 20),
            _PatientLoginForm(),
          ],
        ),
      ),
    );
  }
}

class _AuthHero extends StatelessWidget {
  const _AuthHero();

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
            child: const Icon(Icons.lock_open_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Đăng nhập tài khoản',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tiếp tục hành trình CBT của bạn hoặc bắt đầu trải nghiệm ẩn danh an toàn để làm LSAS trước.',
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

class _PatientLoginForm extends StatefulWidget {
  const _PatientLoginForm();

  @override
  State<_PatientLoginForm> createState() => _PatientLoginFormState();
}

class _PatientLoginFormState extends State<_PatientLoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;

  @override
  void dispose() {
    _nicknameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onStartAnonymous(BuildContext context, AuthProvider auth) async {
    final deviceId = 'web_user_${DateTime.now().millisecondsSinceEpoch}';
    final success = await auth.loginAnonymous(deviceId);
    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã tạo phiên ẩn danh. Hãy chọn biệt danh và avatar trước khi làm LSAS.'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/profile-setup?mode=anonymous-demo');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lỗi: ${auth.errorMessage}'),
        backgroundColor: AppColors.alert,
      ),
    );
  }

  Future<void> _onLogin(BuildContext context, AuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return;

    await auth.login(
      _nicknameController.text.trim(),
      _passwordController.text.trim(),
    );
    if (!context.mounted) return;

    if (auth.status == AuthStatus.success) {
      final name = auth.patientProfile?.nickname.isNotEmpty == true
          ? auth.patientProfile!.nickname
          : (auth.loginResponse?.user.username ?? 'bạn');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Chào mừng $name quay trở lại!'),
          backgroundColor: AppColors.success,
        ),
      );
      final decision = await OnboardingRouteResolver.resolve(context);
      if (!context.mounted) return;
      context.go(decision.route);
      return;
    }

    if (auth.status == AuthStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đăng nhập thất bại: ${auth.errorMessage}'),
          backgroundColor: AppColors.alert,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final isLoading = auth.status == AuthStatus.loading;

        return Form(
          key: _formKey,
          child: Column(
            children: [
              _AuthField(
                controller: _nicknameController,
                label: 'Nickname hoặc email',
                hint: 'rainy_panda hoặc email của bạn',
                icon: Icons.account_circle_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tài khoản.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _AuthField(
                controller: _passwordController,
                label: 'Mật khẩu',
                hint: 'Nhập mật khẩu của bạn',
                icon: Icons.lock_outline_rounded,
                obscureText: _hidePassword,
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _hidePassword = !_hidePassword),
                  icon: Icon(_hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập mật khẩu.';
                  }
                  if (value.length < 6) {
                    return 'Mật khẩu cần ít nhất 6 ký tự.';
                  }
                  return null;
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tính năng quên mật khẩu sẽ được nối ở batch sau.')),
                    );
                  },
                  child: const Text('Quên mật khẩu?'),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isLoading ? null : () => _onLogin(context, auth),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Đăng nhập'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: isLoading ? null : () => context.go('/standard-signup'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Text('Đăng ký tài khoản'),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Hoặc trải nghiệm nhanh',
                      style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 18),
              Container(
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
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.bolt_rounded, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Bắt đầu ngay (Ẩn danh)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Bạn sẽ được chọn biệt danh và avatar hệ thống trước, sau đó làm bài đánh giá LSAS 24 câu để xem app có thực sự hiểu trải nghiệm lo âu xã hội của mình không.',
                      style: TextStyle(color: AppColors.textSecondary, height: 1.45),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Sau bài LSAS, app mới mời bạn cung cấp thông tin thật tối thiểu để phục vụ an toàn y tế và mở khóa lộ trình CBT.',
                      style: TextStyle(color: AppColors.textSecondary, height: 1.45),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonalIcon(
                        onPressed: isLoading ? null : () => _onStartAnonymous(context, auth),
                        icon: const Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
                        label: const Text(
                          'Bắt đầu ngay (Ẩn danh)',
                          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary.withOpacity(0.08),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
