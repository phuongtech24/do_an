package com.reconnect.mindhealth.common.seeder;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.UUID;
import java.util.Map;
import java.util.HashMap;
import java.util.regex.Pattern;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Component;
import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.auth.enums.Role;
import com.reconnect.mindhealth.modules.auth.repository.UserRepository;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.entity.TherapistProfile;
import com.reconnect.mindhealth.modules.clinical.enums.ApprovalStatus;
import com.reconnect.mindhealth.modules.clinical.enums.Status;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;
import com.reconnect.mindhealth.modules.clinical.repository.TherapistProfileRepository;
import com.reconnect.mindhealth.modules.assessment.entity.Phq9Question;
import com.reconnect.mindhealth.modules.assessment.repository.Phq9QuestionRepository;
import com.reconnect.mindhealth.modules.journal.entity.Journal;
import com.reconnect.mindhealth.modules.journal.enums.JournalType;
import com.reconnect.mindhealth.modules.journal.repository.JournalRepository;
import com.reconnect.mindhealth.modules.roadmap.entity.QuestTemplate;
import com.reconnect.mindhealth.modules.roadmap.enums.QuestCategory;
import com.reconnect.mindhealth.modules.roadmap.enums.QuestDifficulty;
import com.reconnect.mindhealth.modules.roadmap.repository.QuestTemplateRepository;
import com.reconnect.mindhealth.common.util.EncryptionUtil;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.security.crypto.password.PasswordEncoder;

@Component
public class DatabaseSeeder implements CommandLineRunner {

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PatientProfileRepository patientProfileRepository;

    @Autowired
    private TherapistProfileRepository therapistProfileRepository;

    @Autowired
    private Phq9QuestionRepository phq9QuestionRepository;

    @Autowired
    private JournalRepository journalRepository;

    @Autowired
    private QuestTemplateRepository questTemplateRepository;

    @Autowired
    private ObjectMapper objectMapper;

    @Value("classpath:seed_data/users.csv")
    private Resource usersCsv;

    @Value("classpath:seed_data/patient_profiles.csv")
    private Resource profilesCsv;

    @Value("classpath:seed_data/therapist_profiles.csv")
    private Resource therapistProfilesCsv;

    @Value("classpath:seed_data/phq9_questions.csv")
    private Resource questionsCsv;

    @Value("classpath:seed_data/journals.csv")
    private Resource journalsCsv;

    @Value("classpath:seed_data/quest_templates.csv")
    private Resource questTemplatesCsv;

    private Map<UUID, String> csvIdToEmailMap = new HashMap<>();
    private static final Pattern BCRYPT_PREFIX = Pattern.compile("^\\$2[ay]\\$.*");

    @Override
    public void run(String... args) throws Exception {
        boolean needsSeed = userRepository.count() == 0
                || therapistProfileRepository.count() == 0
                || patientProfileRepository.count() == 0
                || phq9QuestionRepository.count() == 0
                || questTemplateRepository.count() == 0;

        if (!needsSeed) {
            safeSeed("phq9_questions", this::seedPhq9Questions);
            System.out.println("====== RECONNECT: SKIP DATABASE SEEDING (DATA ALREADY EXISTS) ======");
            return;
        }

        System.out.println("====== RECONNECT: STARTING DATABASE SEEDING FROM CSV (AUTO) ======");

        safeSeed("users", this::seedUsers);
        safeSeed("therapist_profiles", this::seedTherapistProfiles);
        safeSeed("patient_profiles", this::seedPatientProfiles);
        safeSeed("phq9_questions", this::seedPhq9Questions);
        safeSeed("journals", this::seedJournals);
        safeSeed("quest_templates", this::seedQuestTemplates);

        System.out.println("====== RECONNECT: DATABASE SEEDING FINISHED (CHECK LOGS ABOVE) ======");
    }

    @FunctionalInterface
    private interface SeedTask {
        void run() throws Exception;
    }

    private void safeSeed(String name, SeedTask task) {
        try {
            task.run();
        } catch (Exception e) {
            System.err.println("====== RECONNECT: SEED STEP FAILED: " + name + " ======");
            e.printStackTrace();
        }
    }

    private void seedUsers() throws Exception {
        if (!usersCsv.exists()) {
            System.out.println("Users CSV file not found at classpath:seed_data/users.csv");
            return;
        }
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(usersCsv.getInputStream(), StandardCharsets.UTF_8))) {
            String line;
            boolean isHeader = true;
            while ((line = reader.readLine()) != null) {
                if (isHeader) {
                    isHeader = false;
                    continue;
                }
                String[] data = line.split(",");
                if (data.length < 7) continue;

                UUID id = UUID.fromString(data[0].trim());
                String email = data[1].trim();
                String username = data[2].trim();
                String passwordHash = data[3].trim();
                Role role = Role.valueOf(data[4].trim());
                boolean isAnonymous = Boolean.parseBoolean(data[5].trim());
                boolean isActive = Boolean.parseBoolean(data[6].trim());

                boolean emailExists = userRepository.existsByEmail(email);
                boolean usernameExists = username != null && !username.isBlank() && userRepository.existsByUsername(username);
                if (emailExists || usernameExists || userRepository.existsById(id)) {
                    csvIdToEmailMap.put(id, email);
                    continue;
                }

                if (!userRepository.existsById(id) && !userRepository.existsByEmail(email)) {
                    User user = new User();
                    user.setId(id);
                    user.setEmail(email);
                    user.setUsername(username);
                    
                    // Hash raw password if it's not already a BCrypt hash
                    String finalPassword = passwordHash;
                    if (finalPassword != null && !BCRYPT_PREFIX.matcher(finalPassword).matches()) {
                        finalPassword = passwordEncoder.encode(finalPassword);
                    }
                    user.setPasswordHash(finalPassword);
                    
                    user.setRole(role);
                    user.setIsAnonymous(isAnonymous);
                    user.setIsActive(isActive);
                    try {
                        userRepository.save(user);
                        System.out.println("Successfully seeded user: " + username);
                    } catch (Exception ex) {
                        System.out.println("Skipping seed user (constraint): " + email);
                    }
                }
                
                // Track mapping between CSV UUID and Email
                csvIdToEmailMap.put(id, email);
            }
        }
    }

    private void seedTherapistProfiles() throws Exception {
        if (!therapistProfilesCsv.exists()) {
            System.out.println("Therapist profiles CSV file not found at classpath:seed_data/therapist_profiles.csv");
            return;
        }

        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(therapistProfilesCsv.getInputStream(), StandardCharsets.UTF_8))) {
            String line;
            boolean isHeader = true;
            while ((line = reader.readLine()) != null) {
                if (isHeader) {
                    isHeader = false;
                    continue;
                }
                String[] data = line.split(",", -1);
                if (data.length < 6) {
                    continue;
                }

                UUID userId = UUID.fromString(data[0].trim());
                String fullName = data[1].trim();
                String specialization = data[2].trim();
                String bio = data[3].trim();
                String meetingLink = data[4].trim();
                String approvalStatusRaw = data[5].trim();

                User user = userRepository.findById(userId).orElse(null);
                if (user == null) {
                    continue;
                }

                if (therapistProfileRepository.existsById(user.getId())) {
                    continue;
                }

                TherapistProfile profile = new TherapistProfile();
                profile.setUser(userRepository.getReferenceById(user.getId()));
                profile.setFullName(fullName.isBlank() ? user.getUsername() : fullName);
                profile.setSpecialization(specialization.isBlank() ? null : specialization);
                profile.setBio(bio.isBlank() ? null : bio);
                profile.setMeetingLink(meetingLink.isBlank() ? null : meetingLink);

                ApprovalStatus approvalStatus = ApprovalStatus.PENDING;
                if (!approvalStatusRaw.isBlank()) {
                    approvalStatus = ApprovalStatus.valueOf(approvalStatusRaw);
                }
                profile.setApprovalStatus(approvalStatus);

                try {
                    therapistProfileRepository.save(profile);
                    System.out.println("Successfully seeded therapist profile: " + profile.getFullName());
                } catch (Exception ex) {
                    System.out.println("Skipping seed therapist profile (constraint): " + userId);
                }
            }
        }
    }

    private void seedPatientProfiles() throws Exception {
        if (!profilesCsv.exists()) {
            System.out.println("Patient profiles CSV file not found at classpath:seed_data/patient_profiles.csv");
            return;
        }
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(profilesCsv.getInputStream(), StandardCharsets.UTF_8))) {
            String line;
            boolean isHeader = true;
            while ((line = reader.readLine()) != null) {
                if (isHeader) {
                    isHeader = false;
                    continue;
                }
                String[] data = line.split(",");
                if (data.length < 5) continue;

                UUID userId = UUID.fromString(data[0].trim());
                String nickname = data[1].trim();
                Status status = Status.valueOf(data[2].trim());
                String avatarIcon = data[3].trim();
                boolean isRedFlagActive = Boolean.parseBoolean(data[4].trim());

                // Find the actual user by email using our mapping
                String email = csvIdToEmailMap.get(userId);
                User user = email != null ? userRepository.findByEmail(email).orElse(null) : null;
                
                if (user != null && !patientProfileRepository.existsById(user.getId())) {
                    PatientProfile profile = new PatientProfile();
                    profile.setUser(userRepository.getReferenceById(user.getId()));
                    profile.setNickName(nickname);
                    profile.setStatus(status);
                    profile.setAvatarIcon(avatarIcon);
                    profile.setIsRedFlagActive(isRedFlagActive);
                    try {
                        patientProfileRepository.save(profile);
                        System.out.println("Successfully seeded patient profile: " + nickname);
                    } catch (Exception ex) {
                        System.out.println("Skipping seed patient profile (constraint): " + user.getId());
                    }
                }
            }
        }
    }

    private void seedPhq9Questions() throws Exception {
        if (!questionsCsv.exists()) {
            System.out.println("PHQ-9 questions CSV file not found at classpath:seed_data/phq9_questions.csv");
            return;
        }
        System.out.println("Upserting PHQ-9 questions into database...");
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(questionsCsv.getInputStream(), StandardCharsets.UTF_8))) {
            String line;
            boolean isHeader = true;
            while ((line = reader.readLine()) != null) {
                if (isHeader) {
                    isHeader = false;
                    continue;
                }
                String[] data = line.split(",", 2);
                if (data.length < 2) continue;

                Integer questionNumber = Integer.parseInt(data[0].trim());
                String text = data[1].trim().replace("\"", "");

                Phq9Question question = phq9QuestionRepository.findByQuestionNumber(questionNumber);
                if (question == null) {
                    question = new Phq9Question(questionNumber, text);
                } else {
                    question.setText(text);
                }
                phq9QuestionRepository.save(question);
                System.out.println("Successfully upserted PHQ-9 question " + questionNumber + ": " + text);
            }
        }
    }

    private void seedJournals() throws Exception {
        if (!journalsCsv.exists()) {
            System.out.println("Journals CSV file not found at classpath:seed_data/journals.csv");
            return;
        }
        if (journalRepository.count() == 0) {
            System.out.println("Seeding journals into database...");
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(journalsCsv.getInputStream(), StandardCharsets.UTF_8))) {
                String line;
                boolean isHeader = true;
                while ((line = reader.readLine()) != null) {
                    if (isHeader) {
                        isHeader = false;
                        continue;
                    }
                    String[] data = line.split(",(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)");
                    if (data.length < 11) continue;

                    UUID patientUserId = UUID.fromString(data[0].trim());
                    JournalType journalType = JournalType.valueOf(data[1].trim());
                    Integer aiRiskScore = Integer.parseInt(data[2].trim());
                    String severityLevelStr = data[3].trim();
                    
                    String situation = data[4].trim();
                    String automaticThought = data[5].trim();
                    String emotion = data[6].trim();
                    Integer emotionScore = data[7].trim().isEmpty() ? null : Integer.parseInt(data[7].trim());
                    String adaptiveResponse = data[8].trim();
                    Integer reRatedScore = data[9].trim().isEmpty() ? null : Integer.parseInt(data[9].trim());
                    
                    String content = data[10].trim();

                    PatientProfile patient = patientProfileRepository.findById(patientUserId).orElse(null);
                    if (patient != null) {
                        Journal journal = new Journal();
                        journal.setPatientProfile(patient);
                        journal.setJournalType(journalType);
                        journal.setAiRiskScore(aiRiskScore);
                        journal.setSeverityLevel(severityLevelStr);

                        Map<String, Object> contentMap = new HashMap<>();
                        if (journalType == JournalType.THOUGHT_RECORD) {
                            contentMap.put("situation", situation);
                            contentMap.put("automaticThought", automaticThought);
                            contentMap.put("emotion", emotion);
                            contentMap.put("emotionScore", emotionScore);
                            contentMap.put("adaptiveResponse", adaptiveResponse);
                            contentMap.put("reRatedScore", reRatedScore);
                        } else {
                            contentMap.put("content", content);
                        }

                        String jsonString = objectMapper.writeValueAsString(contentMap);
                        String encrypted = EncryptionUtil.encrypt(jsonString);
                        journal.setContentEncrypted(encrypted);

                        journalRepository.save(journal);
                        System.out.println("Successfully seeded journal of type: " + journalType);
                    }
                }
            }
        } else {
            System.out.println("Journals already exist in database.");
        }
    }

    private void seedQuestTemplates() throws Exception {
        if (!questTemplatesCsv.exists()) {
            System.out.println("Quest templates CSV file not found at classpath:seed_data/quest_templates.csv");
            return;
        }
        if (questTemplateRepository.count() == 0) {
            System.out.println("Seeding quest templates into database...");
            try (BufferedReader reader = new BufferedReader(
                    new InputStreamReader(questTemplatesCsv.getInputStream(), StandardCharsets.UTF_8))) {
                String line;
                boolean isHeader = true;
                while ((line = reader.readLine()) != null) {
                    if (isHeader) {
                        isHeader = false;
                        continue;
                    }
                    String[] data = line.split(",(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)");
                    if (data.length < 4) {
                        continue;
                    }
                    String title = data[0].trim().replace("\"", "");
                    String description = data[1].trim().replace("\"", "");
                    QuestCategory category = QuestCategory.valueOf(data[2].trim());
                    QuestDifficulty difficulty = QuestDifficulty.valueOf(data[3].trim());

                    QuestTemplate qt = new QuestTemplate();
                    qt.setTitle(title);
                    qt.setDescription(description);
                    qt.setCategory(category);
                    qt.setDifficulty(difficulty);
                    questTemplateRepository.save(qt);
                    System.out.println("Successfully seeded quest template: " + title);
                }
            }
        } else {
            System.out.println("Quest templates already exist in database.");
        }
    }
}
