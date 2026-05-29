import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

import '../../../../shared/widgets/mindhealth_scaffold.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool pushEnabled = true;
  bool vietnameseLanguage = true;

  @override
  Widget build(BuildContext context) {
    return MindHealthScaffold(
      title: 'Cai dat tai khoan',
      body: ListView(
        children: [
          const ListTile(
            title: Text('Avatar hien tai'),
            subtitle: Text('Nickname: RainyPanda'),
            leading: CircleAvatar(child: Icon(Icons.person_outline)),
          ),
          SwitchListTile(
            value: pushEnabled,
            onChanged: (value) => setState(() => pushEnabled = value),
            title: const Text('Nhan Push Notification'),
            subtitle: const Text('FR1.4'),
          ),
          SwitchListTile(
            value: vietnameseLanguage,
            onChanged: (value) => setState(() => vietnameseLanguage = value),
            title: const Text('Su dung tieng Viet'),
            subtitle: const Text('NFR: ho tro ngon ngu chinh tieng Viet'),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              context.go('/auth');
            },
            child: const Text('Dang xuat an toan'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {},
            child: const Text('Khoi phuc mat khau'),
          ),
        ],
      ),
    );
  }
}
