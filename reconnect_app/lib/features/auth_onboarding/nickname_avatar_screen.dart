import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';

class NicknameAvatarScreen extends StatefulWidget {
  const NicknameAvatarScreen({super.key});

  @override
  State<NicknameAvatarScreen> createState() => _NicknameAvatarScreenState();
}

class _NicknameAvatarScreenState extends State<NicknameAvatarScreen> {
  final List<String> avatars = ['🦊', '🐰', '🐼', '🐯', '🐶', '🐱', '🦋', '🦉'];
  int _selectedAvatarIndex = 0;
  final TextEditingController _nicknameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Tạo Hồ Sơ Ẩn Danh', style: TextStyle(color: AppColors.textPrimary)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn Avatar của bạn',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Avatar ảo giúp bạn bảo vệ danh tính tuyệt đối.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            
            // Grid of Avatars
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: avatars.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedAvatarIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedAvatarIndex = index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.secondary : Colors.white,
                      shape: BoxShape.circle,
                      border: isSelected 
                        ? Border.all(color: AppColors.primary, width: 3)
                        : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        avatars[index],
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 48),
            const Text(
              'Tên hiển thị (Nickname)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(
                hintText: 'Nhập tên ảo (VD: Cáo Nhỏ)',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(20),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to LSAS assessment
                context.go('/lsas');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('TIẾP TỤC ĐÁNH GIÁ LSAS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }
}
