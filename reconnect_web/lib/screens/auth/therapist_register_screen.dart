import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class TherapistRegisterScreen extends StatefulWidget {
  const TherapistRegisterScreen({super.key});

  @override
  State<TherapistRegisterScreen> createState() => _TherapistRegisterScreenState();
}

class _TherapistRegisterScreenState extends State<TherapistRegisterScreen> {
  bool _isSubmitted = false;

  @override
  Widget build(BuildContext context) {
    if (_isSubmitted) {
      return Scaffold(
        body: Center(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.pending_actions_rounded, size: 80, color: AppColors.warning),
                const SizedBox(height: 24),
                const Text(
                  'Hồ sơ đang chờ duyệt',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tài khoản của bạn đã được ghi nhận. Quản trị viên (Admin) đang tiến hành xác thực bằng cấp và chứng chỉ y khoa của bạn. Vui lòng quay lại sau.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Quay lại Đăng nhập'),
                )
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký Hồ sơ Chuyên gia'),
      ),
      body: Center(
        child: Container(
          width: 500,
          margin: const EdgeInsets.symmetric(vertical: 32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Thông tin Định danh',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const SizedBox(height: 16),
                _buildTextField('Họ và tên thật (VD: Nguyễn Văn A)'),
                _buildTextField('Học hàm / Học vị (VD: ThS. BS)'),
                _buildTextField('Chuyên khoa (VD: Rối loạn lo âu, Trầm cảm)'),
                _buildTextField('Đơn vị công tác hiện tại'),
                const SizedBox(height: 24),
                const Text(
                  'Xác thực Bằng cấp',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.upload_file, size: 48, color: AppColors.secondary),
                      SizedBox(height: 8),
                      Text('Click để tải lên Chứng chỉ hành nghề (.pdf, .jpg)'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    setState(() {
                      _isSubmitted = true;
                    });
                  },
                  child: const Text('Gửi Yêu Cầu Phê Duyệt', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
