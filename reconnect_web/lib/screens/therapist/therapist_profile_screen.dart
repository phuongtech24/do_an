import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../screens/auth/therapist_login_screen.dart';

class TherapistProfileScreen extends StatefulWidget {
  const TherapistProfileScreen({super.key});

  @override
  State<TherapistProfileScreen> createState() => _TherapistProfileScreenState();
}

class _TherapistProfileScreenState extends State<TherapistProfileScreen> {
  final TextEditingController _bioController = TextEditingController(text: 'Chuyên gia tham vấn tâm lý với 10 năm kinh nghiệm xử lý các ca Trầm cảm, Rối loạn lo âu và Re-Integration (Tái hòa nhập) cho người mắc hội chứng Hikikomori.');
  bool _isAcceptingNewPatients = true;

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ & Cài đặt Chuyên gia', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 1,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 800, // Fixed width for web/desktop feel
            padding: const EdgeInsets.all(32),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Avatar & Basic Info
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        const CircleAvatar(
                          radius: 80,
                          backgroundColor: AppColors.primary,
                          child: Text('A', style: TextStyle(fontSize: 64, color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, color: Colors.white),
                            onPressed: () {},
                            tooltip: 'Đổi ảnh đại diện',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('ThS. BS Nguyễn Văn A', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    const SizedBox(height: 8),

                    const SizedBox(height: 32),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.email, color: AppColors.textSecondary),
                      title: const Text('nguyen.vana@reconnect.vn', style: TextStyle(fontSize: 14)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.phone, color: AppColors.textSecondary),
                      title: const Text('0901 234 567', style: TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 48),
              
              // Right Column: Settings & Bio
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Lời tựa giới thiệu (Hiển thị cho Bệnh nhân)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _bioController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Nhập thông tin giới thiệu bản thân...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    const Text('Liên kết Phiên củng cố (Booster Link)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'VD: https://meet.google.com/abc-xyz',
                        prefixIcon: const Icon(Icons.link),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const Text('Link này sẽ được gửi tự động khi bạn xác nhận lịch hẹn.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    
                    const SizedBox(height: 32),
                    const Text('Cài đặt Trạng thái Online', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text('Đang nhận bệnh nhân mới', style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: const Text('Hiển thị tên bạn trên danh sách tham vấn cho bệnh nhân'),
                            value: _isAcceptingNewPatients,
                            activeColor: AppColors.success,
                            onChanged: (val) {
                              setState(() {
                                _isAcceptingNewPatients = val;
                              });
                            },
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.schedule, color: AppColors.primary),
                            title: const Text('Giờ làm việc: 08:00 - 17:00 (Thứ 2 - Thứ 6)'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.alert,
                            side: const BorderSide(color: AppColors.alert),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          ),
                          icon: const Icon(Icons.logout),
                          label: const Text('Đăng Xuất'),
                          onPressed: () {
                             Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const TherapistLoginScreen()),
                              (route) => false,
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          ),
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: const Text('Lưu Thay Đổi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã cập nhật Hồ sơ thành công!'), backgroundColor: AppColors.success),
                            );
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
