import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/mindhealth_scaffold.dart';
import '../providers/auth_provider.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _fullNameController = TextEditingController();
  bool _anonymousMode = true;
  int _avatarIndex = 0;
  bool _isInitialized = false; // Để tránh reset dữ liệu khi rebuild

  static const List<IconData> _avatarIcons = [
    Icons.pets_outlined,
    Icons.emoji_nature_outlined,
    Icons.sentiment_satisfied_alt_outlined,
    Icons.bolt_outlined,
    Icons.self_improvement_outlined,
    Icons.favorite_border_rounded,
  ];

  @override
  void dispose() {
    _displayNameController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final user = auth.loginResponse?.user;
      
      if (user != null) {
        _anonymousMode = user.isAnonymous ?? true;
        _displayNameController.text = user.username ?? "";
      }
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MindHealthScaffold(
      title: 'Tao ho so',
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            Text(
              'Chon che do hien thi danh tinh',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Bat che do an danh'),
              subtitle: const Text(
                'Bat: hien nickname/avatar, Tat: hien ten that.',
              ),
              value: _anonymousMode,
              onChanged: (value) => setState(() => _anonymousMode = value),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _displayNameController,
              decoration: InputDecoration(
                labelText: _anonymousMode ? 'Nickname' : 'Ten hien thi',
                hintText: _anonymousMode ? 'calm_fox' : 'Nguyen Van A',
                prefixIcon: const Icon(Icons.badge_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui long nhap ten hien thi';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            if (!_anonymousMode)
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Ho va ten that',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (!_anonymousMode && (value == null || value.trim().isEmpty)) {
                    return 'Vui long nhap ho va ten';
                  }
                  return null;
                },
              ),
            if (_anonymousMode) ...[
              const SizedBox(height: 12),
              const Text('Chon avatar an danh'),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _avatarIcons.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final selected = _avatarIndex == index;
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => _avatarIndex = index),
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).dividerColor,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Icon(_avatarIcons[index], size: 30),
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _onContinue,
                child: const Text('Lưu hồ sơ và tiếp tục LSAS'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onContinue() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    context.go('/lsas');
  }
}
