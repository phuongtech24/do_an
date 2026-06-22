import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/assessment/presentation/providers/assessment_provider.dart';
import '../features/journal_ai/presentation/providers/journal_provider.dart';
import '../features/journal_ai/presentation/providers/guided_discovery_provider.dart';
import '../features/journal_ai/presentation/providers/cognitive_distortions_provider.dart';
import '../features/journal_ai/presentation/providers/guide_chat_provider.dart';
import '../features/onboarding/presentation/providers/onboarding_provider.dart';
import '../features/roadmap/presentation/providers/roadmap_provider.dart';
import '../features/telehealth/presentation/providers/telehealth_provider.dart';
import 'router/app_router.dart';
import 'theme/mindhealth_theme.dart';

class MindHealthApp extends StatelessWidget {
  const MindHealthApp({super.key});

  static void bootstrap() {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const MindHealthApp());
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AssessmentProvider()),
        ChangeNotifierProvider(create: (_) => JournalProvider()),
        ChangeNotifierProvider(create: (_) => GuidedDiscoveryProvider()),
        ChangeNotifierProvider(create: (_) => CognitiveDistortionsProvider()),
        ChangeNotifierProvider(create: (_) => GuideChatProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => RoadmapProvider()),
        ChangeNotifierProvider(create: (_) => TelehealthProvider()),
      ],
      child: MaterialApp.router(
        title: 'MindHealth',
        debugShowCheckedModeBanner: false,
        theme: MindHealthTheme.light(),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
