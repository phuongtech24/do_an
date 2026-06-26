import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/mindhealth_scaffold.dart';
import '../../../../theme/app_colors.dart';
import '../providers/auth_provider.dart';

class StandardSignupScreen extends StatefulWidget {
  const StandardSignupScreen({super.key});

  @override
  State<StandardSignupScreen> createState() => _StandardSignupScreenState();
}

class _StandardSignupScreenState extends State<StandardSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _nicknameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSignup(BuildContext context, AuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await auth.register(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      nickname: _nicknameController.text.trim(),
      avatarIcon: 'avatar_cat',
      isAnonymous: false,
      anonymousModeEnabled: true,
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đăng ký thất bại: ${auth.errorMessage}'),
          backgroundColor: AppColors.alert,
        ),
      );
      return;
    }

    await auth.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    if (!mounted) return;

    if (auth.status == AuthStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng ký thành công. Hãy hoàn thiện hồ sơ ban đầu của bạn.'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/profile-setup?mode=standard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MindHealthScaffold(
      title: 'Đăng ký tài khoản',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tạo tài khoản mới',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Sau khi tạo tài khoản, bạn sẽ có cả hồ sơ ẩn danh để dùng trong app và hồ sơ thật để bác sĩ/admin hỗ trợ an toàn y tế.',
                style: TextStyle(color: AppColors.textSecondary, height: 1.45),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Vui lòng nhập email.';
                  if (!value.contains('@')) return 'Email không hợp lệ.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: 'Biệt danh hiển thị',
                  prefixIcon: Icon(Icons.face_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Vui lòng nhập biệt danh.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _hidePassword,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _hidePassword = !_hidePassword),
                    icon: Icon(_hidePassword ? Icons.visibility_off : Icons.visibility),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu.';
                  if (value.length < 6) return 'Mật khẩu tối thiểu 6 ký tự.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _hideConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Xác nhận mật khẩu',
                  prefixIcon: const Icon(Icons.lock_reset),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _hideConfirmPassword = !_hideConfirmPassword),
                    icon: Icon(_hideConfirmPassword ? Icons.visibility_off : Icons.visibility),
                  ),
                ),
                validator: (value) {
                  if (value != _passwordController.text) return 'Mật khẩu xác nhận không khớp.';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              Consumer<AuthProvider>(
                builder: (context, auth, child) {
                  final isLoading = auth.status == AuthStatus.loading;
                  return SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isLoading ? null : () => _onSignup(context, auth),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Đăng ký ngay'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/auth'),
                  child: const Text('Đã có tài khoản? Đăng nhập'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
