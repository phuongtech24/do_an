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
      title: 'UC10 - Telehealth',
      body: Consumer<TelehealthProvider>(
        builder: (context, telehealth, _) {
          final assigned = telehealth.isAssigned;
          final bannerText = assigned
              ? (telehealth.therapistName.isNotEmpty ? 'Bác sĩ phụ trách: ${telehealth.therapistName}' : 'Bạn đã được gán bác sĩ phụ trách.')
              : (telehealth.assignmentMessage.isNotEmpty
                  ? telehealth.assignmentMessage
                  : 'Bạn chưa được gán bác sĩ phụ trách. Vui lòng chờ Admin gán bác sĩ để đặt lịch.');

          return ListView(
            children: [
              Card(
                child: ListTile(
                  leading: Icon(assigned ? Icons.verified_user_outlined : Icons.warning_amber_rounded, color: assigned ? Colors.teal : Colors.deepOrange),
                  title: Text(assigned ? 'Telehealth sẵn sàng' : 'Chưa được gán bác sĩ'),
                  subtitle: Text(bannerText),
                ),
              ),
              FeatureCard(
                title: 'Đặt lịch khám',
                subtitle: assigned ? 'Chọn khung giờ trống' : 'Cần được Admin gán bác sĩ trước',
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
                title: 'Lịch sử đặt khám',
                subtitle: 'Xem các ca khám đã đặt',
                icon: Icons.history,
                onTap: () {
                  context.push('/telehealth/my-appointments');
                },
              ),
              FeatureCard(
                title: 'Chế độ danh tính',
                subtitle: 'FR6.4 - chọn chia sẻ tên thật hoặc ẩn danh',
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

