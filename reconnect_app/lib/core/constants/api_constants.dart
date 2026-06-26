class ApiConstants {
  // ======================================================
  // BASE URL - Thay đổi tùy môi trường chạy
  // ======================================================
  // Web / iOS Simulator: 'http://localhost:8081/api'
  // Android Emulator: 'http://10.0.2.2:8081/api'
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8081/api',
  );

  // Auth Endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String registerAnonymous = '$baseUrl/auth/register-anonymous';
  static const String guestLinkAccount = '$baseUrl/auth/guest/link-account';
  static const String guestProfile = '$baseUrl/guest/profile';

  // User Endpoints
  static const String users = '$baseUrl/users';
  static String userById(String id) => '$baseUrl/users/$id';

  // Assessment Endpoints
  static const String getLsasSituations = '$baseUrl/assessment/lsas/situations';
  static const String submitLsas = '$baseUrl/assessment/lsas/submissions';
  static const String lsasHistory = '$baseUrl/assessment/lsas/history';
  static const String lsasCooldown = '$baseUrl/assessment/lsas/cooldown';
  static const String submitMood = '$baseUrl/assessment/mood';

  // Clinical Endpoints
  static const String saveGoals = '$baseUrl/clinical/goals';
  static const String getOnboardingStatus = '$baseUrl/clinical/onboarding-status';
  static const String completePsychoeducation = '$baseUrl/clinical/psychoeducation/complete';
  static const String therapistAssignmentStatus = '$baseUrl/clinical/therapist-assignment-status';
  static const String patientGoals = '$baseUrl/patient/goals';
  static const String patientTherapists = '$baseUrl/patient/therapists';
  static const String selectTherapist = '$baseUrl/patient/therapist-selection';
  static String patientTherapistDetail(String id) => '$baseUrl/patient/therapists/$id';
  static const String patientProfile = '$baseUrl/patient/profile';
  static const String patientProfileSafetyGate = '$baseUrl/patient/profile/safety-gate';

  // Roadmap Endpoints
  static const String getDailyQuests = '$baseUrl/roadmap/daily';
  static const String roadmapHistory = '$baseUrl/roadmap/history';
  static const String roadmapProgramState = '$baseUrl/roadmap/program-state';
  static const String roadmapSafetyOverlay = '$baseUrl/roadmap/safety-overlay';
  static String completeQuest(String id) => '$baseUrl/roadmap/quests/$id/complete';
  static String verifyQuestProof(String id) => '$baseUrl/roadmap/quests/$id/proof/verify';

  // LSAS / Fear Ladder Endpoints
  static const String fearLadder = '$baseUrl/fear-ladder';
  static const String behavioralExperimentToday = '$baseUrl/behavioral-experiments/today';
  static const String behavioralExperimentHistory = '$baseUrl/behavioral-experiments/history';
  static const String behavioralExperimentSelect = '$baseUrl/behavioral-experiments/select';
  static String startBehavioralExperiment(String id) => '$baseUrl/behavioral-experiments/$id/start';
  static String debriefBehavioralExperiment(String id) => '$baseUrl/behavioral-experiments/$id/debrief';

  // Journal Endpoints
  static const String saveJournal = '$baseUrl/journal/thought-records';
  static const String getJournals = '$baseUrl/journal/thought-records';
  static String getJournalById(String id) => '$baseUrl/journal/thought-records/$id';

  // AI Endpoints
  static const String guidedDiscovery = '$baseUrl/ai/guided-discovery';
  static const String cognitiveDistortions = '$baseUrl/ai/cognitive-distortions';
  static const String guideChat = '$baseUrl/ai/guide-chat';

  // Telehealth / Booster Endpoints
  static const String getAvailableSlots = '$baseUrl/booster/slots';
  static const String bookAppointment = '$baseUrl/booster/appointments/book';
  static const String myAppointments = '$baseUrl/booster/appointments/my';
}
