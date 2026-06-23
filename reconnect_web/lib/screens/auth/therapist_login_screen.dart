import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/auth/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../admin/main_admin_screen.dart';
import '../therapist/main_therapist_screen.dart';
import '../therapist/therapist_credentials_upload_screen.dart';
import '../../features/therapist/data/repositories/therapist_credential_repository.dart';

class TherapistLoginScreen extends StatefulWidget {
  const TherapistLoginScreen({super.key});

  @override
  State<TherapistLoginScreen> createState() => _TherapistLoginScreenState();
}

class _TherapistLoginScreenState extends State<TherapistLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final TherapistCredentialRepository _credentialRepo = TherapistCredentialRepository();

  bool _loading = false;
  String _error = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;

      if (auth.role == 'ADMIN') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainAdminScreen()));
        return;
      }

      final token = auth.token ?? '';
      final status = await _credentialRepo.myStatus(token: token);
      if (!mounted) return;
      if (status.approvalStatus != 'ACTIVE') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TherapistCredentialsUploadScreen()));
        return;
      }

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainTherapistScreen()));
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.medication, size: 80, color: AppColors.primary),
              const SizedBox(height: 24),
              const Text(
                'Hệ thống Quản trị ReConnect',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text('Cổng đăng nhập dành cho Chuyên gia & Quản trị viên', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 48),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                onSubmitted: (_) => _loading ? null : _submit(),
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              if (_error.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(_error, style: const TextStyle(color: AppColors.alert, fontSize: 12)),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _loading ? 'ĐANG ĐĂNG NHẬP...' : 'ĐĂNG NHẬP',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
