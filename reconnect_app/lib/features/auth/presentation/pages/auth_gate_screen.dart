import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../onboarding/presentation/utils/onboarding_route_resolver.dart';
import '../providers/auth_provider.dart';

class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({super.key});

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreAndRoute());
  }

  Future<void> _restoreAndRoute() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.restoreSession();
    if (!mounted) return;
    final decision = await OnboardingRouteResolver.resolve(context);
    if (!mounted) return;
    context.go(decision.route);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
