import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/feature_card.dart';
import '../../../../shared/widgets/mindhealth_scaffold.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/telehealth_provider.dart';

class TelehealthScreen extends StatefulWidget {
  const TelehealthScreen({super.key});

  @override
  State<TelehealthScreen> createState() => _TelehealthScreenState();
}

class _TelehealthScreenState extends State<TelehealthScreen> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final patientId = auth.loginResponse?.user.id ?? '';
    final token = auth.loginResponse?.token;
    if (patientId.isNotEmpty) {
      Provider.of<TelehealthProvider>(context, listen: false).loadAssignmentStatus(patientId, token: token);
    }
    _loaded = true;
  }

  @override
  Widget build(BuildContext context) {
    return MindHealthScaffold(
      title: 'Telehealth CBT',
      body: Consumer<TelehealthProvider>(
        builder: (context, telehealth, _) {
          final assigned = telehealth.isAssigned;
          final bannerText = assigned
              ? (telehealth.therapistName.isNotEmpty
                  ? 'Chuyên gia đồng hành: ${telehealth.therapistName}'
                  : 'Bạn đã có chuyên gia đồng hành.')
              : (telehealth.assignmentMessage.isNotEmpty
                  ? telehealth.assignmentMessage
                  : 'Bạn chưa chọn chuyên gia phù hợp để bắt đầu đặt lịch CBT.');

          return ListView(
            children: [
              Card(
                child: ListTile(
                  leading: Icon(
                    assigned ? Icons.verified_user_outlined : Icons.warning_amber_rounded,
                    color: assigned ? Colors.teal : Colors.deepOrange,
                  ),
                  title: Text(assigned ? 'Telehealth sẵn sàng' : 'Bạn chưa chọn chuyên gia'),
                  subtitle: Text(bannerText),
                ),
              ),
              if (!assigned)
                FeatureCard(
                  title: 'Chọn chuyên gia phù hợp',
                  subtitle: 'Xem danh sách therapist ACTIVE và chọn người bạn thấy hợp nhất',
                  icon: Icons.people_alt_outlined,
                  onTap: () => context.push('/therapist-matching'),
                ),
              FeatureCard(
                title: 'Đặt lịch kham',
                subtitle: assigned ? 'Chọn khung giờ CBT còn trống' : 'Cần chọn chuyên gia trước',
                icon: Icons.schedule_outlined,
                onTap: assigned
                    ? () => context.push('/telehealth/booking')
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(bannerText)),
                        );
                      },
              ),
              FeatureCard(
                title: 'Lịch sử đặt kham',
                subtitle: 'Xem các ca kham đã đặt',
                icon: Icons.history,
                onTap: () => context.push('/telehealth/my-appointments'),
              ),
              FeatureCard(
                title: 'Chế độ danh tính',
                subtitle: 'Chọn chia sẻ nickname hoặc danh tính thật khi vào buổi CBT',
                icon: Icons.verified_user_outlined,
                trailing: Switch(
                  value: true,
                  onChanged: (_) {},
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
