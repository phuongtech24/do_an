import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/feature_card.dart';
import '../../../../shared/widgets/mindhealth_scaffold.dart';

class TelehealthScreen extends StatelessWidget {
  const TelehealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MindHealthScaffold(
      title: 'UC10 - Telehealth',
      body: ListView(
        children: [
          const Card(
            child: ListTile(
              leading: Icon(Icons.warning_amber_rounded, color: Colors.deepOrange),
              title: Text('Canh bao tu bac si'),
              subtitle: Text(
                'Neu Risk Index vuot nguong 3 ngay lien tiep, he thong se yeu cau dat lich tham van.',
              ),
            ),
          ),
          FeatureCard(
            title: 'Dat lich kham',
            subtitle: 'FR6.3 - chon khung gio trong',
            icon: Icons.schedule_outlined,
            onTap: () {
              context.push('/telehealth/booking');
            },
          ),
          FeatureCard(
            title: 'Lich su dat kham',
            subtitle: 'Xem cac ca kham da dat',
            icon: Icons.history,
            onTap: () {
              context.push('/telehealth/my-appointments');
            },
          ),
          FeatureCard(
            title: 'Che do danh tinh',
            subtitle: 'FR6.4 - chon chia se ten that hoac an danh',
            icon: Icons.verified_user_outlined,
            trailing: Switch(
              value: true,
              onChanged: (_) {},
            ),
          ),
        ],
      ),
    );
  }
}
