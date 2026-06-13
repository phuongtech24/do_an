import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/mindhealth_scaffold.dart';
import '../../../../theme/app_colors.dart';
import '../../../onboarding/presentation/utils/onboarding_route_resolver.dart';
import '../providers/auth_provider.dart';

class AnonymousAuthScreen extends StatelessWidget {
  const AnonymousAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MindHealthScaffold(
      title: 'MindHealth - Đăng nhập',
      body: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  'Tiếp tục hành trình CBT của bạn hoặc trải nghiệm Guest Mode an toàn để làm LSAS trước.',
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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onStartAnonymous(BuildContext context, AuthProvider auth) async {
    final deviceId = 'web_user_${DateTime.now().millisecondsSinceEpoch}';
    final success = await auth.loginAnonymous(deviceId);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Đã tạo phiên guest. Hãy chọn biệt danh và avatar trước khi làm LSAS.'
              : 'Lỗi: ${auth.errorMessage}',
        ),
        backgroundColor: success ? AppColors.success : AppColors.alert,
      ),
    );

    if (success) {
      context.go('/profile-setup?mode=anonymous-demo');
    }
  }

  Future<void> _onLogin(BuildContext context, AuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return;

    await auth.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      rememberMe: _rememberMe,
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đăng nhập thất bại: ${auth.errorMessage}'),
        backgroundColor: AppColors.alert,
      ),
    );
  }

  Future<void> _showForgotPasswordFlow(BuildContext context, AuthProvider auth) async {
    final emailController = TextEditingController(text: _emailController.text.trim());
    final resetTokenController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    final requestReset = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Quên mật khẩu'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: 'Email đăng nhập'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Gửi email đặt lại'),
          ),
        ],
      ),
    );

    if (requestReset != true) return;

    final requested = await auth.requestPasswordReset(emailController.text.trim());
    if (!mounted) return;
    if (!requested) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage),
          backgroundColor: AppColors.alert,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Hệ thống đã tạo yêu cầu đặt lại mật khẩu. Hãy kiểm tra email của bạn. Nếu đang chạy local chưa cấu hình mail, bạn có thể lấy reset token từ log backend.',
        ),
        backgroundColor: AppColors.success,
      ),
    );

    final doReset = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đặt lại mật khẩu'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: resetTokenController,
                decoration: const InputDecoration(labelText: 'Reset token'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Nhập lại mật khẩu'),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Đặt lại'),
          ),
        ],
      ),
    );

    if (doReset != true) return;

    if (newPasswordController.text.trim() != confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu nhập lại chưa khớp.'),
          backgroundColor: AppColors.alert,
        ),
      );
      return;
    }

    final resetOk = await auth.resetPassword(
      resetToken: resetTokenController.text.trim(),
      newPassword: newPasswordController.text.trim(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(resetOk ? 'Đặt lại mật khẩu thành công.' : auth.errorMessage),
        backgroundColor: resetOk ? AppColors.success : AppColors.alert,
      ),
    );
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
                controller: _emailController,
                label: 'Email đăng nhập',
                hint: 'you@example.com',
                icon: Icons.account_circle_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập email.';
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
                  onPressed: isLoading ? null : () => _showForgotPasswordFlow(context, auth),
                  child: const Text('Quên mật khẩu?'),
                ),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _rememberMe,
                onChanged: isLoading ? null : (value) => setState(() => _rememberMe = value ?? true),
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('Ghi nhớ đăng nhập'),
                subtitle: const Text('Lưu refresh token an toàn trên thiết bị này.'),
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
                            'Bắt đầu ngay (ẩn danh)',
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
                      'Bạn sẽ chọn biệt danh và avatar hệ thống trước, sau đó làm bài LSAS 24 câu để trải nghiệm app trong chế độ an toàn.',
                      style: TextStyle(color: AppColors.textSecondary, height: 1.45),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Sau LSAS, app sẽ mời bạn liên kết tài khoản và cập nhật thông tin y tế tối thiểu để mở khóa lộ trình CBT chính thức.',
                      style: TextStyle(color: AppColors.textSecondary, height: 1.45),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonalIcon(
                        onPressed: isLoading ? null : () => _onStartAnonymous(context, auth),
                        icon: const Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
                        label: const Text(
                          'Bắt đầu ngay (ẩn danh)',
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
