import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/assessment/presentation/pages/phq9_screen.dart';
import '../../features/assessment/presentation/pages/progress_screen.dart';
import '../../features/auth/presentation/pages/anonymous_auth_screen.dart';
import '../../features/auth/presentation/pages/auth_gate_screen.dart';
import '../../features/auth/presentation/pages/profile_setup_screen.dart';
import '../../features/auth/presentation/pages/standard_signup_screen.dart';
import '../../features/home/presentation/pages/patient_home_screen.dart';
import '../../features/home/presentation/pages/safety_support_screen.dart';
import '../../features/journal_ai/presentation/pages/cbt_chat_screen.dart';
import '../../features/journal_ai/presentation/pages/coping_cards_screen.dart';
import '../../features/journal_ai/presentation/pages/journal_ai_screen.dart';
import '../../features/journal_ai/presentation/pages/risk_index_screen.dart';
import '../../features/journal_ai/presentation/pages/thought_record_screen.dart';
import '../../features/navigation/presentation/patient_shell_screen.dart';
import '../../features/roadmap/presentation/pages/quest_detail_screen.dart';
import '../../features/roadmap/presentation/pages/roadmap_screen.dart';
import '../../features/settings/presentation/pages/settings_screen.dart';
import '../../features/telehealth/booking_calendar_screen.dart';
import '../../features/telehealth/my_appointments_screen.dart';
import '../../features/telehealth/presentation/pages/telehealth_screen.dart';
import '../../features/onboarding/presentation/pages/goal_setting_screen.dart';
import '../../features/onboarding/presentation/pages/psycho_education_screen.dart';
import '../../features/onboarding/presentation/pages/therapist_matching_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'auth-gate',
        builder: (context, state) => const AuthGateScreen(),
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AnonymousAuthScreen(),
      ),
      GoRoute(
        path: '/standard-signup',
        name: 'standard-signup',
        builder: (context, state) => const StandardSignupScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        name: 'profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => PatientShellScreen(shell: shell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKey,
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const PatientHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/journal',
                name: 'journal',
                builder: (context, state) => const JournalAiScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/roadmap',
                name: 'roadmap',
                builder: (context, state) => const RoadmapScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/telehealth',
                name: 'telehealth',
                builder: (context, state) => const TelehealthScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/lsas',
        name: 'lsas',
        builder: (context, state) => const Phq9Screen(),
      ),
      GoRoute(
        path: '/phq9',
        name: 'phq9',
        builder: (context, state) => const Phq9Screen(),
      ),
      GoRoute(
        path: '/thought-record',
        name: 'thought-record',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ThoughtRecordScreen(
            agenda: extra?['agenda'] as String?,
            initialAnxietyScore: (extra?['anxietyScore'] as num?)?.toInt(),
            initialAvoidanceUrgeScore: (extra?['avoidanceUrgeScore'] as num?)?.toInt(),
            initialAnticipatoryAnxietyScore: (extra?['anticipatoryAnxietyScore'] as num?)?.toInt(),
            initialPostEventRuminationScore: (extra?['postEventRuminationScore'] as num?)?.toInt(),
          );
        },
      ),
      GoRoute(
        path: '/progress',
        name: 'progress',
        builder: (context, state) => const ProgressScreen(),
      ),
      GoRoute(
        path: '/safety-support',
        name: 'safety-support',
        builder: (context, state) => const SafetySupportScreen(),
      ),
      GoRoute(
        path: '/goal-setting',
        name: 'goal-setting',
        builder: (context, state) => const GoalSettingScreen(),
      ),
      GoRoute(
        path: '/psycho-education',
        name: 'psycho-education',
        builder: (context, state) => const PsychoeducationScreen(),
      ),
      GoRoute(
        path: '/therapist-matching',
        name: 'therapist-matching',
        builder: (context, state) => const TherapistMatchingScreen(),
      ),
      GoRoute(
        path: '/agenda-setting',
        name: 'agenda-setting',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ThoughtRecordScreen(
            agenda: extra?['agenda'] as String?,
            initialAnxietyScore: (extra?['anxietyScore'] as num?)?.toInt(),
            initialAvoidanceUrgeScore: (extra?['avoidanceUrgeScore'] as num?)?.toInt(),
            initialAnticipatoryAnxietyScore: (extra?['anticipatoryAnxietyScore'] as num?)?.toInt(),
            initialPostEventRuminationScore: (extra?['postEventRuminationScore'] as num?)?.toInt(),
          );
        },
      ),
      GoRoute(
        path: '/coping-cards',
        name: 'coping-cards',
        builder: (context, state) => const CopingCardsScreen(),
      ),
      GoRoute(
        path: '/cbt-chat',
        name: 'cbt-chat',
        builder: (context, state) => const CbtChatScreen(),
      ),
      GoRoute(
        path: '/risk-index',
        name: 'risk-index',
        builder: (context, state) => const RiskIndexScreen(),
      ),
      GoRoute(
        path: '/quest-detail',
        name: 'quest-detail',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return QuestDetailScreen(
            id: extra['id'] as String? ?? '',
            title: extra['title'] as String? ?? 'Nhiệm vụ',
            category: extra['category'] as String? ?? 'Chung',
            categoryColor: extra['categoryColor'] as Color? ?? Colors.blue,
            icon: extra['icon'] as IconData? ?? Icons.star,
          );
        },
      ),
      GoRoute(
        path: '/telehealth/booking',
        name: 'telehealth-booking',
        builder: (context, state) => const BookingCalendarScreen(),
      ),
      GoRoute(
        path: '/telehealth/my-appointments',
        name: 'telehealth-appointments',
        builder: (context, state) => const MyAppointmentsScreen(),
      ),
    ],
  );
}
