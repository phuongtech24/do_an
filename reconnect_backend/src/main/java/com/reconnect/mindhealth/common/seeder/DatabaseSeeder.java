package com.reconnect.mindhealth.common.seeder;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.UUID;
import java.util.Map;
import java.util.HashMap;
import java.util.List;
import java.util.Set;
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
import com.reconnect.mindhealth.modules.assessment.entity.LsasSituation;
import com.reconnect.mindhealth.modules.assessment.enums.LsasSituationGroup;
import com.reconnect.mindhealth.modules.assessment.repository.LsasSituationRepository;
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
    private LsasSituationRepository lsasSituationRepository;

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

    @Value("classpath:seed_data/lsas_situations.csv")
    private Resource lsasSituationsCsv;

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
                || lsasSituationRepository.count() == 0
                || questTemplateRepository.count() == 0;

        if (!needsSeed) {
            safeSeed("lsas_situations", this::seedLsasSituations);
            System.out.println("====== RECONNECT: SKIP DATABASE SEEDING (DATA ALREADY EXISTS) ======");
            return;
        }

        System.out.println("====== RECONNECT: STARTING DATABASE SEEDING FROM CSV (AUTO) ======");

        safeSeed("users", this::seedUsers);
        safeSeed("therapist_profiles", this::seedTherapistProfiles);
        safeSeed("patient_profiles", this::seedPatientProfiles);
        safeSeed("lsas_situations", this::seedLsasSituations);
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

    private void seedLsasSituations() throws Exception {
        if (!lsasSituationsCsv.exists()) {
            System.out.println("LSAS situations CSV file not found at classpath:seed_data/lsas_situations.csv");
            return;
        }
        System.out.println("Upserting LSAS situations into database...");
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(lsasSituationsCsv.getInputStream(), StandardCharsets.UTF_8))) {
            String line;
            boolean isHeader = true;
            while ((line = reader.readLine()) != null) {
                if (isHeader) {
                    isHeader = false;
                    continue;
                }
                String[] data = line.split(",(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)");
                if (data.length < 3) continue;

                Integer situationNumber = Integer.parseInt(data[0].trim());
                LsasSituationGroup group = LsasSituationGroup.valueOf(data[1].trim());
                String text = data[2].trim().replace("\"", "");

                LsasSituation situation = lsasSituationRepository.findBySituationNumber(situationNumber);
                if (situation == null) {
                    situation = new LsasSituation();
                    situation.setSituationNumber(situationNumber);
                } else {
                    situation.setSituationNumber(situationNumber);
                }
                situation.setSituationGroup(group);
                situation.setText(text);
                lsasSituationRepository.save(situation);
                System.out.println("Successfully upserted LSAS situation " + situationNumber + ": " + text);
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
            ensureClinicalQuestTemplates();
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
        ensureClinicalQuestTemplates();
    }

    private void ensureClinicalQuestTemplates() throws Exception {
        purgeLegacyQuestTemplates();

        ensureClinicalQuestTemplate(
                "SOCIAL_PHONE_PUBLIC",
                "Gọi điện thoại ở nơi công cộng",
                "Gọi một cuộc điện thoại ngắn ở nơi có người xung quanh, bỏ bớt hành vi an toàn và ghi lại điều thực sự xảy ra.",
                QuestCategory.SOCIAL,
                QuestDifficulty.EASY,
                1,
                "MAP_AND_BELIEF_BREAK",
                "BEHAVIORAL_EXPERIMENT",
                List.of(),
                false,
                false);
        ensureClinicalQuestTemplate(
                "SOCIAL_ASK_DIRECTIONS",
                "Hỏi đường một người lạ",
                "Hỏi đường hoặc hỏi thông tin đơn giản từ một người lạ, sau đó so sánh dự đoán lo âu với kết quả thực tế.",
                QuestCategory.SOCIAL,
                QuestDifficulty.EASY,
                1,
                "MAP_AND_BELIEF_BREAK",
                "BEHAVIORAL_EXPERIMENT",
                List.of(),
                false,
                false);
        ensureClinicalQuestTemplate(
                "SOCIAL_SMALL_TALK",
                "Chào và bắt chuyện ngắn",
                "Chào một người quen hoặc bắt đầu một câu trò chuyện ngắn, chú ý xem phản ứng thật có giống điều mình lo không.",
                QuestCategory.SOCIAL,
                QuestDifficulty.EASY,
                2,
                "MAP_AND_BELIEF_BREAK",
                "BEHAVIORAL_EXPERIMENT",
                List.of("SOCIAL_ASK_DIRECTIONS"),
                false,
                false);
        ensureClinicalQuestTemplate(
                "SOCIAL_EAT_PUBLIC",
                "Ăn uống ở nơi công cộng",
                "Ăn hoặc uống một món nhỏ ở nơi công cộng và ghi lại mức sợ hãi, né tránh trước và sau khi thực hiện.",
                QuestCategory.SOCIAL,
                QuestDifficulty.MEDIUM,
                4,
                "REAL_WORLD_EXPERIMENTS",
                "BEHAVIORAL_EXPERIMENT",
                List.of("SOCIAL_SMALL_TALK"),
                false,
                false);
        ensureClinicalQuestTemplate(
                "SOCIAL_JOIN_SMALL_GROUP",
                "Tham gia vào nhóm nhỏ",
                "Tham gia một nhóm nhỏ trong vài phút, thử nói một câu ngắn và quan sát phản ứng thực tế của mọi người.",
                QuestCategory.SOCIAL,
                QuestDifficulty.MEDIUM,
                5,
                "REAL_WORLD_EXPERIMENTS",
                "BEHAVIORAL_EXPERIMENT",
                List.of("SOCIAL_EAT_PUBLIC"),
                false,
                false);
        ensureClinicalQuestTemplate(
                "SOCIAL_ASK_QUESTION",
                "Đặt câu hỏi trong lớp hoặc cuộc họp",
                "Chuẩn bị và đặt một câu hỏi ngắn trong lớp học, cuộc họp hoặc nhóm trao đổi.",
                QuestCategory.SOCIAL,
                QuestDifficulty.MEDIUM,
                6,
                "REAL_WORLD_EXPERIMENTS",
                "BEHAVIORAL_EXPERIMENT",
                List.of("SOCIAL_JOIN_SMALL_GROUP"),
                true,
                false);
        ensureClinicalQuestTemplate(
                "SOCIAL_PRESENT_OPINION",
                "Trình bày ý kiến trước nhóm nhỏ",
                "Nêu một ý kiến cá nhân trước nhóm nhỏ, giảm hành vi an toàn như né mắt, nói quá nhỏ hoặc chuẩn bị quá mức.",
                QuestCategory.SOCIAL,
                QuestDifficulty.HARD,
                8,
                "REAL_WORLD_EXPERIMENTS",
                "BEHAVIORAL_EXPERIMENT",
                List.of("SOCIAL_ASK_QUESTION"),
                true,
                true);
        ensureClinicalQuestTemplate(
                "SOCIAL_ASK_STAFF_HELP",
                "Nhờ nhân viên hỗ trợ",
                "Chủ động hỏi nhân viên cửa hàng, lễ tân hoặc bộ phận hỗ trợ về một thông tin đơn giản.",
                QuestCategory.SOCIAL,
                QuestDifficulty.EASY,
                3,
                "MAP_AND_BELIEF_BREAK",
                "BEHAVIORAL_EXPERIMENT",
                List.of("SOCIAL_PHONE_PUBLIC"),
                false,
                false);
        ensureClinicalQuestTemplate(
                "SOCIAL_POLITE_REFUSAL",
                "Từ chối một yêu cầu nhỏ",
                "Tập nói lời từ chối lịch sự với một yêu cầu nhỏ, sau đó ghi lại điều người khác phản hồi thật sự.",
                QuestCategory.SOCIAL,
                QuestDifficulty.HARD,
                10,
                "DEEP_COGNITIVE_MEMORY",
                "BEHAVIORAL_EXPERIMENT",
                List.of("SOCIAL_PRESENT_OPINION"),
                true,
                true);
        ensureClinicalQuestTemplate(
                "SOCIAL_SMALL_MISTAKE",
                "Thực hiện một lỗi nhỏ có kiểm soát",
                "Cố ý thực hiện một lỗi xã hội rất nhỏ và an toàn, ví dụ hỏi lại thông tin, để kiểm chứng nỗi sợ bị đánh giá.",
                QuestCategory.SOCIAL,
                QuestDifficulty.HARD,
                12,
                "DEEP_COGNITIVE_MEMORY",
                "BEHAVIORAL_EXPERIMENT",
                List.of("SOCIAL_POLITE_REFUSAL"),
                true,
                true);
    }

    private void purgeLegacyQuestTemplates() {
        Set<String> canonicalModuleCodes = Set.of(
                "SOCIAL_PHONE_PUBLIC",
                "SOCIAL_ASK_DIRECTIONS",
                "SOCIAL_SMALL_TALK",
                "SOCIAL_EAT_PUBLIC",
                "SOCIAL_JOIN_SMALL_GROUP",
                "SOCIAL_ASK_QUESTION",
                "SOCIAL_PRESENT_OPINION",
                "SOCIAL_ASK_STAFF_HELP",
                "SOCIAL_POLITE_REFUSAL",
                "SOCIAL_SMALL_MISTAKE");
        Set<String> legacyModuleCodes = Set.of(
                "VICIOUS_CYCLE",
                "SAFETY_BEHAVIOR_DROP",
                "VIDEO_FEEDBACK",
                "SURVEYS",
                "THEN_VS_NOW",
                "IMAGERY_RESCRIPTING");

        List<QuestTemplate> legacy = questTemplateRepository.findAll().stream()
                .filter(template -> template.getModuleCode() == null
                        || template.getModuleCode().isBlank()
                        || legacyModuleCodes.contains(template.getModuleCode()))
                .filter(template -> template.getModuleCode() == null
                        || template.getModuleCode().isBlank()
                        || !canonicalModuleCodes.contains(template.getModuleCode()))
                .toList();
        if (!legacy.isEmpty()) {
            questTemplateRepository.deleteAll(legacy);
            System.out.println("Removed legacy CBT quest templates: " + legacy.size());
        }
    }
    private void ensureClinicalQuestTemplate(
            String moduleCode,
            String title,
            String description,
            QuestCategory category,
            QuestDifficulty difficulty,
            int programWeek,
            String programPhaseCode,
            String interventionType,
            List<String> prerequisites,
            boolean therapistOnlyAssignable,
            boolean hardLocked) throws Exception {
        QuestTemplate template = questTemplateRepository.findFirstByModuleCode(moduleCode).orElse(null);
        if (template == null) {
            template = new QuestTemplate();
        }
        template.setModuleCode(moduleCode);
        template.setTitle(title);
        template.setDescription(description);
        template.setCategory(category);
        template.setDifficulty(difficulty);
        template.setProgramWeek(programWeek);
        template.setProgramPhaseCode(programPhaseCode);
        template.setInterventionType(interventionType);
        template.setPrerequisiteCodesJson(objectMapper.writeValueAsString(prerequisites));
        template.setTherapistOnlyAssignable(therapistOnlyAssignable);
        template.setHardLocked(hardLocked);
        questTemplateRepository.save(template);
    }
}

