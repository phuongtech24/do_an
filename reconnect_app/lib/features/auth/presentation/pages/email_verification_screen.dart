import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/mindhealth_scaffold.dart';
import '../../../../theme/app_colors.dart';
import '../../../onboarding/presentation/utils/onboarding_route_resolver.dart';
import '../providers/auth_provider.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({
    super.key,
    required this.email,
    this.password,
    this.title = 'Xác minh email',
    this.subtitle,
    this.postVerifyRoute,
  });

  final String email;
  final String? password;
  final String title;
  final String? subtitle;
  final String? postVerifyRoute;

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify(BuildContext context, AuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return;

    final verified = await auth.verifyEmailOtp(
      email: widget.email,
      otp: _otpController.text.trim(),
    );
    if (!context.mounted) return;
    if (verified == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage),
          backgroundColor: AppColors.alert,
        ),
      );
      return;
    }

    if (widget.password != null && widget.password!.isNotEmpty) {
      await auth.login(widget.email, widget.password!.trim(), rememberMe: true);
      if (!context.mounted) return;
      if (auth.status != AuthStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage),
            backgroundColor: AppColors.alert,
          ),
        );
        return;
      }
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email đã được xác minh thành công.'),
        backgroundColor: AppColors.success,
      ),
    );

    if (widget.postVerifyRoute != null && widget.postVerifyRoute!.isNotEmpty) {
      context.go(widget.postVerifyRoute!);
      return;
    }

    final resolved = await OnboardingRouteResolver.resolve(context);
    if (!context.mounted) return;
    context.go(resolved.route);
  }

  Future<void> _resend(BuildContext context, AuthProvider auth) async {
    final response = await auth.resendEmailOtp(widget.email);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          response == null
              ? auth.errorMessage
              : 'Đã gửi lại mã OTP đến ${response.email}.',
        ),
        backgroundColor: response == null ? AppColors.alert : AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MindHealthScaffold(
      title: widget.title,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF159489)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kiểm tra hộp thư của bạn',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.subtitle ??
                        'Chúng tôi đã gửi mã OTP tới email ${widget.email}. Nhập mã để kích hoạt tài khoản và tiếp tục.',
                    style: TextStyle(color: Colors.white.withOpacity(0.92), height: 1.45),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Mã OTP',
                  prefixIcon: Icon(Icons.pin_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập mã OTP.';
                  }
                  if (value.trim().length < 4) {
                    return 'Mã OTP không hợp lệ.';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            Consumer<AuthProvider>(
              builder: (context, auth, child) {
                final isLoading = auth.status == AuthStatus.loading;
                return Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: isLoading ? null : () => _verify(context, auth),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Xác minh và tiếp tục'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: isLoading ? null : () => _resend(context, auth),
                      child: const Text('Gửi lại mã OTP'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: isLoading ? null : () => context.go('/auth'),
                      child: const Text('Quay lại đăng nhập'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

