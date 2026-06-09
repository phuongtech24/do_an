import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/onboarding_provider.dart';

class OnboardingRouteDecision {
  final String route;
  final bool isOnboardingComplete;

  const OnboardingRouteDecision({
    required this.route,
    required this.isOnboardingComplete,
  });
}

class OnboardingRouteResolver {
  static Future<OnboardingRouteDecision> resolve(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isLoggedIn) {
      return const OnboardingRouteDecision(
        route: '/auth',
        isOnboardingComplete: false,
      );
    }

    final patientId = auth.loginResponse?.user.id ?? '';
    if (patientId.isEmpty) {
      return const OnboardingRouteDecision(
        route: '/auth',
        isOnboardingComplete: false,
      );
    }

    if (auth.isGuest) {
      final guestProfile = auth.guestProfile;
      if (guestProfile == null ||
          guestProfile.nickname.trim().isEmpty ||
          guestProfile.avatarIcon.trim().isEmpty) {
        return const OnboardingRouteDecision(
          route: '/profile-setup?mode=anonymous-demo',
          isOnboardingComplete: false,
        );
      }
      return const OnboardingRouteDecision(
        route: '/lsas',
        isOnboardingComplete: false,
      );
    }

    final onboarding = Provider.of<OnboardingProvider>(context, listen: false);
    final ok = await onboarding.loadOnboardingStatus(patientId, token: auth.token);
    if (!ok) {
      return const OnboardingRouteDecision(
        route: '/home',
        isOnboardingComplete: true,
      );
    }

    return OnboardingRouteDecision(
      route: onboarding.nextOnboardingRoute,
      isOnboardingComplete: onboarding.isOnboardingComplete,
    );
  }
}
