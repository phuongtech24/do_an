import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../auth/presentation/providers/auth_provider.dart';
import '../../onboarding/presentation/providers/onboarding_provider.dart';

class PatientShellScreen extends StatelessWidget {
  const PatientShellScreen({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final onboarding = Provider.of<OnboardingProvider>(context);
    final patientId = auth.loginResponse?.user.id ?? '';
    final token = auth.loginResponse?.token;

    if (patientId.isNotEmpty && onboarding.onboardingStatus == null && onboarding.status != OnboardingStatus.loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<OnboardingProvider>(context, listen: false).loadOnboardingStatus(patientId, token: token);
      });
    }

    if (patientId.isNotEmpty && onboarding.onboardingStatus != null && !onboarding.isOnboardingComplete) {
      final nextRoute = onboarding.nextOnboardingRoute;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final current = GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();
        if (current != nextRoute) {
          context.go(nextRoute);
        }
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: shell,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: NavigationBar(
            height: 74,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            selectedIndex: shell.currentIndex,
            onDestinationSelected: (index) {
              shell.goBranch(index, initialLocation: index == shell.currentIndex);
            },
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Trang chủ'),
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                label: 'Nhật ký',
              ),
              NavigationDestination(
                icon: Icon(Icons.alt_route_rounded),
                label: 'Lộ trình',
              ),
              NavigationDestination(
                icon: Icon(Icons.medical_information_outlined),
                label: 'Tư vấn',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                label: 'Cá nhân',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
