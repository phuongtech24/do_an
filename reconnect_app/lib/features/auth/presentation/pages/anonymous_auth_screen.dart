import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/mindhealth_scaffold.dart';
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
      title: 'MindHealth - Dang nhap',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Đăng nhập tài khoản',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            const Text('MindHealth - Nền tảng trị liệu CBT'),
            const SizedBox(height: 16),
            const SizedBox(
              height: 500,
              child: _PatientLoginForm(),
            ),
          ],
        ),
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

  void _onStartAnonymous(BuildContext context, AuthProvider auth) async {
    final deviceId = 'web_user_${DateTime.now().millisecondsSinceEpoch}';

    final success = await auth.loginAnonymous(deviceId);

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bắt đầu trải nghiệm ẩn danh thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/profile-setup');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${auth.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          const SizedBox(height: 12),
          TextFormField(
            controller: _nicknameController,
            decoration: const InputDecoration(
              labelText: 'Nickname hoac email',
              hintText: 'rainy_panda',
              prefixIcon: Icon(Icons.account_circle_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui long nhap tai khoan';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passwordController,
            obscureText: _hidePassword,
            decoration: InputDecoration(
              labelText: 'Mat khau',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _hidePassword = !_hidePassword),
                icon: Icon(
                  _hidePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui long nhap mat khau';
              }
              if (value.length < 6) {
                return 'Mat khau toi thieu 6 ky tu';
              }
              return null;
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text('Quen mat khau?'),
            ),
          ),
          const SizedBox(height: 12),
          Consumer<AuthProvider>(
            builder: (context, auth, child) {
              return Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: auth.status == AuthStatus.loading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                await auth.login(
                                  _nicknameController.text.trim(),
                                  _passwordController.text.trim(),
                                );

                                if (context.mounted) {
                                  if (auth.status == AuthStatus.success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Chào mừng ${auth.loginResponse?.user.username ?? "bạn"} quay trở lại!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    context.go('/home');
                                  } else if (auth.status == AuthStatus.error) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Đăng nhập thất bại: ${auth.errorMessage}'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                      child: auth.status == AuthStatus.loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Dang nhap'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => context.go('/standard-signup'),
                      child: const Text('Dang ky tai khoan'),
                    ),
                  ),
                  const Divider(height: 32),
                  const Text('Hoặc trải nghiệm nhanh'),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                      ),
                      onPressed: auth.status == AuthStatus.loading
                          ? null
                          : () => _onStartAnonymous(context, auth),
                      icon: const Icon(Icons.bolt),
                      label: auth.status == AuthStatus.loading
                          ? const CircularProgressIndicator()
                          : const Text('Bắt đầu ngay (Ẩn danh)'),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
