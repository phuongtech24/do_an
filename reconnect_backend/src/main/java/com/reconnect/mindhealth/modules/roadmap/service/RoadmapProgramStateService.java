package com.reconnect.mindhealth.modules.roadmap.service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;
import com.reconnect.mindhealth.modules.roadmap.dto.PatientQuestDto;
import com.reconnect.mindhealth.modules.roadmap.dto.RoadmapProgramModuleDto;
import com.reconnect.mindhealth.modules.roadmap.dto.RoadmapProgramStateDto;
import com.reconnect.mindhealth.modules.roadmap.entity.QuestTemplate;
import com.reconnect.mindhealth.modules.roadmap.enums.QuestStatus;
import com.reconnect.mindhealth.modules.roadmap.repository.PatientQuestRepository;
import com.reconnect.mindhealth.modules.roadmap.repository.QuestTemplateRepository;

import jakarta.persistence.EntityNotFoundException;

@Service
public class RoadmapProgramStateService {

    private static final int MAX_PROGRAM_WEEK = 14;

    private final PatientProfileRepository patientProfileRepository;
    private final QuestTemplateRepository questTemplateRepository;
    private final PatientQuestRepository patientQuestRepository;
    private final ObjectMapper objectMapper;

    public RoadmapProgramStateService(
            PatientProfileRepository patientProfileRepository,
            QuestTemplateRepository questTemplateRepository,
            PatientQuestRepository patientQuestRepository,
            ObjectMapper objectMapper) {
        this.patientProfileRepository = patientProfileRepository;
        this.questTemplateRepository = questTemplateRepository;
        this.patientQuestRepository = patientQuestRepository;
        this.objectMapper = objectMapper;
    }

    @Transactional
    public RoadmapProgramStateDto getProgramState(UUID patientId, List<PatientQuestDto> todayAssignments) {
        PatientProfile patient = patientProfileRepository.findById(patientId)
                .orElseThrow(() -> new EntityNotFoundException("Patient profile not found: " + patientId));
        return buildProgramState(patient, todayAssignments);
    }

    @Transactional
    public RoadmapProgramStateDto buildProgramState(PatientProfile patient, List<PatientQuestDto> todayAssignments) {
        initializeProgramIfNeeded(patient);

        int programWeek = resolveProgramWeek(patient);
        ProgramPhase phase = resolvePhase(programWeek);
        List<RoadmapProgramModuleDto> unlocked = new ArrayList<>();
        List<RoadmapProgramModuleDto> locked = new ArrayList<>();

        List<QuestTemplate> clinicalTemplates = questTemplateRepository.findAll().stream()
                .filter(template -> template.getModuleCode() != null && !template.getModuleCode().isBlank())
                .sorted(Comparator
                        .comparing((QuestTemplate template) -> Optional.ofNullable(template.getProgramWeek()).orElse(99))
                        .thenComparing(QuestTemplate::getTitle))
                .toList();

        for (QuestTemplate template : clinicalTemplates) {
            RoadmapProgramModuleDto moduleDto = toModuleDto(template, phase, programWeek, patient);
            if (Boolean.TRUE.equals(moduleDto.getUnlocked())) {
                unlocked.add(moduleDto);
            } else {
                locked.add(moduleDto);
            }
        }

        RoadmapProgramStateDto dto = new RoadmapProgramStateDto();
        dto.setProgramWeek(programWeek);
        dto.setProgramPhaseCode(phase.code());
        dto.setProgramPhaseLabel(phase.label());
        dto.setNextRecommendedIntervention(resolveNextRecommendedIntervention(programWeek));
        dto.setTherapyProgramStartedAt(patient.getTherapyProgramStartedAt());
        dto.setWeekStartDate(resolveWeekStartDate(patient, programWeek));
        dto.setWeekEndDate(resolveWeekEndDate(patient, programWeek));
        dto.setNextRerateAt(resolveNextRerateAt(patient));
        dto.setUnlockedModules(unlocked);
        dto.setLockedModules(locked);
        dto.setTodayAssignments(todayAssignments != null ? todayAssignments : List.of());
        return dto;
    }

    public boolean isTherapistTrack(PatientProfile patient) {
        return patient != null
                && patient.getGraduatedAt() == null
                && (patient.getCurrentLsasScore() != null && patient.getCurrentLsasScore() >= 60);
    }

    @Transactional
    public void initializeProgramIfNeeded(PatientProfile patient) {
        if (!isTherapistTrack(patient)) {
            return;
        }
        boolean changed = false;
        if (patient.getTherapyProgramStartedAt() == null) {
            LocalDateTime startedAt = patient.getCurrentCycleStartDate() != null
                    ? patient.getCurrentCycleStartDate()
                    : LocalDateTime.now();
            patient.setTherapyProgramStartedAt(startedAt);
            changed = true;
        }
        int resolvedWeek = resolveProgramWeek(patient);
        if (patient.getCurrentProgramWeek() == null || !patient.getCurrentProgramWeek().equals(resolvedWeek)) {
            patient.setCurrentProgramWeek(resolvedWeek);
            changed = true;
        }
        if (changed) {
            patientProfileRepository.save(patient);
        }
    }

    public int resolveProgramWeek(PatientProfile patient) {
        if (!isTherapistTrack(patient)) {
            return 0;
        }
        if (patient.getCurrentProgramWeek() != null && patient.getCurrentProgramWeek() > 0) {
            return Math.min(MAX_PROGRAM_WEEK, patient.getCurrentProgramWeek());
        }
        LocalDateTime startedAt = patient.getTherapyProgramStartedAt();
        if (startedAt == null) {
            startedAt = patient.getCurrentCycleStartDate();
        }
        if (startedAt == null) {
            return 1;
        }
        long days = ChronoUnit.DAYS.between(startedAt.toLocalDate(), LocalDate.now());
        return Math.max(1, Math.min(MAX_PROGRAM_WEEK, (int) (days / 7) + 1));
    }

    public ProgramPhase resolvePhase(int programWeek) {
        if (programWeek >= 1 && programWeek <= 3) {
            return new ProgramPhase("MAP_AND_BELIEF_BREAK", "Tuần 1-3: Lập bản đồ và phá niềm tin");
        }
        if (programWeek >= 4 && programWeek <= 8) {
            return new ProgramPhase("REAL_WORLD_EXPERIMENTS", "Tuần 4-8: Thử nghiệm thực tế và khảo sát");
        }
        return new ProgramPhase("DEEP_COGNITIVE_MEMORY", "Tuần 9-14: Can thiệp nhận thức sâu và ký ức");
    }

    private RoadmapProgramModuleDto toModuleDto(
            QuestTemplate template,
            ProgramPhase currentPhase,
            int currentWeek,
            PatientProfile patient) {
        RoadmapProgramModuleDto dto = new RoadmapProgramModuleDto();
        dto.setModuleCode(template.getModuleCode());
        dto.setTitle(template.getTitle());
        dto.setProgramPhaseCode(template.getProgramPhaseCode());
        dto.setProgramPhaseLabel(resolvePhaseLabel(template.getProgramPhaseCode()));
        dto.setWeekFrom(template.getProgramWeek());
        dto.setWeekTo(resolveWeekTo(template.getModuleCode(), template.getProgramWeek()));
        dto.setInterventionType(template.getInterventionType());
        dto.setPrerequisiteCodesJson(template.getPrerequisiteCodesJson());
        dto.setHardLocked(Boolean.TRUE.equals(template.getHardLocked()));
        dto.setTherapistOnlyAssignable(Boolean.TRUE.equals(template.getTherapistOnlyAssignable()));
        dto.setExpectedUnlockAt(resolveExpectedUnlockAt(patient, template.getProgramWeek()));

        boolean weekUnlocked = template.getProgramWeek() == null || currentWeek >= template.getProgramWeek();
        List<String> prerequisites = readPrerequisites(template.getPrerequisiteCodesJson());
        boolean prerequisitesMet = prerequisites.stream().allMatch(code -> isModuleCompleted(patient.getId(), code));
        boolean unlocked = weekUnlocked && prerequisitesMet;
        dto.setUnlocked(unlocked);

        if (!weekUnlocked) {
            dto.setUnlockType("TIME");
            dto.setLockReason("Mở từ tuần " + template.getProgramWeek() + " của lộ trình.");
        } else if (!prerequisitesMet) {
            dto.setUnlockType("PREREQUISITE");
            dto.setLockReason("Cần hoàn thành module tiên quyết trước.");
        } else if (!currentPhase.code().equalsIgnoreCase(template.getProgramPhaseCode())
                && Boolean.TRUE.equals(template.getHardLocked())) {
            dto.setUnlockType("HARD_LOCK");
            dto.setLockReason("Kỹ thuật nâng cao chỉ mở đúng phase lâm sàng.");
        } else if (Boolean.TRUE.equals(template.getTherapistOnlyAssignable()) && !unlocked) {
            dto.setUnlockType("THERAPIST_ASSIGNMENT");
            dto.setLockReason("Đang chờ bác sĩ giao bài phù hợp.");
        } else {
            dto.setUnlockType(unlocked ? "UNLOCKED" : "TIME");
            dto.setLockReason("");
        }
        return dto;
    }

    private boolean isModuleCompleted(UUID patientId, String moduleCode) {
        if (moduleCode == null || moduleCode.isBlank()) {
            return true;
        }
        return !patientQuestRepository.findByPatientAndModuleCodeAndStatus(patientId, moduleCode, QuestStatus.DONE).isEmpty();
    }

    private List<String> readPrerequisites(String rawJson) {
        if (rawJson == null || rawJson.isBlank()) {
            return List.of();
        }
        try {
            return objectMapper.readValue(rawJson, new TypeReference<List<String>>() {
            });
        } catch (Exception ignored) {
            return List.of();
        }
    }

    private String resolveNextRecommendedIntervention(int week) {
        if (week <= 1) {
            return "Hoàn tất bản đồ vòng lặp lo âu và nhận diện suy nghĩ - triệu chứng - hành vi an toàn.";
        }
        if (week <= 3) {
            return "Ưu tiên các bài vứt bỏ hành vi an toàn và so sánh trải nghiệm trước/sau.";
        }
        if (week <= 8) {
            return "Ưu tiên Video Feedback hoặc Survey để kiểm chứng lỗi đọc suy nghĩ.";
        }
        return "Ưu tiên Then vs Now và Imagery Rescripting để xử lý tầng ký ức sâu hơn.";
    }

    private LocalDateTime resolveNextRerateAt(PatientProfile patient) {
        LocalDateTime cycleStart = patient.getCurrentCycleStartDate();
        if (cycleStart == null) {
            return null;
        }
        return cycleStart.plusDays(14);
    }

    private LocalDateTime resolveWeekStartDate(PatientProfile patient, int programWeek) {
        LocalDateTime startedAt = patient.getTherapyProgramStartedAt();
        if (startedAt == null || programWeek <= 0) {
            return null;
        }
        return startedAt.plusDays(Math.max(0, (programWeek - 1) * 7L));
    }

    private LocalDateTime resolveWeekEndDate(PatientProfile patient, int programWeek) {
        LocalDateTime weekStart = resolveWeekStartDate(patient, programWeek);
        if (weekStart == null) {
            return null;
        }
        return weekStart.plusDays(6);
    }

    private LocalDateTime resolveExpectedUnlockAt(PatientProfile patient, Integer targetWeek) {
        if (patient == null || patient.getTherapyProgramStartedAt() == null || targetWeek == null || targetWeek <= 0) {
            return null;
        }
        return patient.getTherapyProgramStartedAt().plusDays(Math.max(0, (targetWeek - 1) * 7L));
    }

    private Integer resolveWeekTo(String moduleCode, Integer weekFrom) {
        if (weekFrom == null) {
            return null;
        }
        return switch (moduleCode != null ? moduleCode : "") {
            case "VICIOUS_CYCLE" -> 1;
            case "SAFETY_BEHAVIOR_DROP" -> 3;
            case "VIDEO_FEEDBACK" -> 5;
            case "SURVEYS" -> 8;
            case "THEN_VS_NOW" -> 10;
            case "IMAGERY_RESCRIPTING" -> 14;
            default -> weekFrom;
        };
    }

    private String resolvePhaseLabel(String phaseCode) {
        if (phaseCode == null) {
            return "";
        }
        return switch (phaseCode) {
            case "MAP_AND_BELIEF_BREAK" -> "Tuần 1-3: Lập bản đồ và phá niềm tin";
            case "REAL_WORLD_EXPERIMENTS" -> "Tuần 4-8: Thử nghiệm thực tế và khảo sát";
            case "DEEP_COGNITIVE_MEMORY" -> "Tuần 9-14: Can thiệp nhận thức sâu và ký ức";
            default -> phaseCode;
        };
    }

    public record ProgramPhase(String code, String label) {
    }
}
