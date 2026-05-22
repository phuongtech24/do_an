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

  // User Endpoints
  static const String users = '$baseUrl/users';
  static String userById(String id) => '$baseUrl/users/$id';

  // Assessment Endpoints
  static const String submitPhq9 = '$baseUrl/assessment/phq9';
  static const String getPhq9Questions = '$baseUrl/assessment/phq9/questions';
  static const String phq9Cooldown = '$baseUrl/assessment/cooldown';
  static const String submitMood = '$baseUrl/assessment/mood';
  static const String savePhq9Question = '$baseUrl/assessment/phq9/questions/save';

  // Clinical Endpoints
  static const String saveGoals = '$baseUrl/clinical/goals';
  static const String getOnboardingStatus = '$baseUrl/clinical/onboarding-status';
  static const String completePsychoeducation = '$baseUrl/clinical/psychoeducation/complete';

  // Roadmap Endpoints
  static const String getDailyQuests = '$baseUrl/roadmap/daily';
  static String completeQuest(String id) => '$baseUrl/roadmap/quests/$id/complete';
  static String verifyQuestProof(String id) => '$baseUrl/roadmap/quests/$id/proof/verify';

  // Journal Endpoints
  static const String saveJournal = '$baseUrl/journal/thought-records';
  static const String getJournals = '$baseUrl/journal/thought-records';
  static String getJournalById(String id) => '$baseUrl/journal/thought-records/$id';

  // AI Endpoints
  static const String guidedDiscovery = '$baseUrl/ai/guided-discovery';
  static const String cognitiveDistortions = '$baseUrl/ai/cognitive-distortions';

  // Telehealth / Booster Endpoints
  static const String getAvailableSlots = '$baseUrl/booster/slots';
  static const String bookAppointment = '$baseUrl/booster/appointments/book';
  static const String myAppointments = '$baseUrl/booster/appointments/my';
}
