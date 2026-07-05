package com.reconnect.mindhealth.modules.roadmap.service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;
import com.reconnect.mindhealth.modules.roadmap.dto.RoadmapProgramModuleDto;
import com.reconnect.mindhealth.modules.roadmap.dto.RoadmapProgramStateDto;

import jakarta.persistence.EntityNotFoundException;

@Service
public class RoadmapProgramStateService {

    private static final int MAX_PROGRAM_WEEK = 14;

    private final PatientProfileRepository patientProfileRepository;

    public RoadmapProgramStateService(PatientProfileRepository patientProfileRepository) {
        this.patientProfileRepository = patientProfileRepository;
    }

    @Transactional
    public RoadmapProgramStateDto getProgramState(UUID patientId) {
        PatientProfile patient = patientProfileRepository.findById(patientId)
                .orElseThrow(() -> new EntityNotFoundException("Patient profile not found: " + patientId));
        return buildProgramState(patient);
    }

    @Transactional
    public RoadmapProgramStateDto buildProgramState(PatientProfile patient) {
        initializeProgramIfNeeded(patient);

        int programWeek = resolveProgramWeek(patient);
        ProgramPhase phase = resolvePhase(programWeek);
        List<RoadmapProgramModuleDto> unlocked = new ArrayList<>();
        List<RoadmapProgramModuleDto> locked = new ArrayList<>();

        for (ProgramModule module : defaultModules()) {
            RoadmapProgramModuleDto dto = toModuleDto(module, patient, programWeek);
            if (Boolean.TRUE.equals(dto.getUnlocked())) {
                unlocked.add(dto);
            } else {
                locked.add(dto);
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
            return new ProgramPhase("REAL_WORLD_EXPERIMENTS", "Tuần 4-8: Thử nghiệm thực tế");
        }
        return new ProgramPhase("DEEP_COGNITIVE_MEMORY", "Tuần 9-14: Can thiệp nhận thức sâu");
    }

    private RoadmapProgramModuleDto toModuleDto(ProgramModule module, PatientProfile patient, int currentWeek) {
        RoadmapProgramModuleDto dto = new RoadmapProgramModuleDto();
        dto.setModuleCode(module.code());
        dto.setTitle(module.title());
        dto.setProgramPhaseCode(module.phaseCode());
        dto.setProgramPhaseLabel(resolvePhaseLabel(module.phaseCode()));
        dto.setWeekFrom(module.weekFrom());
        dto.setWeekTo(module.weekTo());
        dto.setInterventionType(module.interventionType());
        dto.setHardLocked(false);
        dto.setTherapistOnlyAssignable(false);
        dto.setExpectedUnlockAt(resolveExpectedUnlockAt(patient, module.weekFrom()));
        boolean unlocked = currentWeek >= module.weekFrom();
        dto.setUnlocked(unlocked);
        dto.setUnlockType(unlocked ? "UNLOCKED" : "TIME");
        dto.setLockReason(unlocked ? "" : "Mở từ tuần " + module.weekFrom() + " của lộ trình.");
        return dto;
    }

    private List<ProgramModule> defaultModules() {
        return List.of(
                new ProgramModule("MAP_SOCIAL_ANXIETY", "Hiểu vòng lặp lo âu xã hội", "MAP_AND_BELIEF_BREAK", 1, 1, "PSYCHOEDUCATION"),
                new ProgramModule("SAFETY_BEHAVIOR_DROP", "Giảm hành vi an toàn", "MAP_AND_BELIEF_BREAK", 1, 3, "CBT"),
                new ProgramModule("FEAR_LADDER_EXPOSURE", "Thang sợ hãi và thử nghiệm hành vi", "REAL_WORLD_EXPERIMENTS", 4, 8, "BEHAVIORAL_EXPERIMENT"),
                new ProgramModule("REVIEW_AND_MAINTENANCE", "Tổng kết tiến triển và duy trì", "DEEP_COGNITIVE_MEMORY", 9, 14, "MAINTENANCE"));
    }

    private String resolveNextRecommendedIntervention(int week) {
        if (week <= 0) {
            return "Hoàn thành LSAS và chọn mục tiêu trị liệu để bắt đầu lộ trình phù hợp.";
        }
        if (week <= 3) {
            return "Ưu tiên hiểu vòng lặp lo âu và giảm hành vi an toàn.";
        }
        if (week <= 8) {
            return "Ưu tiên thực hiện thử nghiệm hành vi trên các nấc Fear Ladder đang mở.";
        }
        return "Ưu tiên tổng kết bài học, duy trì tiến triển và chuẩn bị giai đoạn booster.";
    }

    private LocalDateTime resolveNextRerateAt(PatientProfile patient) {
        LocalDateTime cycleStart = patient.getCurrentCycleStartDate();
        return cycleStart == null ? null : cycleStart.plusDays(14);
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
        return weekStart == null ? null : weekStart.plusDays(6);
    }

    private LocalDateTime resolveExpectedUnlockAt(PatientProfile patient, Integer targetWeek) {
        if (patient == null || patient.getTherapyProgramStartedAt() == null || targetWeek == null || targetWeek <= 0) {
            return null;
        }
        return patient.getTherapyProgramStartedAt().plusDays(Math.max(0, (targetWeek - 1) * 7L));
    }

    private String resolvePhaseLabel(String phaseCode) {
        if (phaseCode == null) {
            return "";
        }
        return switch (phaseCode) {
            case "MAP_AND_BELIEF_BREAK" -> "Tuần 1-3: Lập bản đồ và phá niềm tin";
            case "REAL_WORLD_EXPERIMENTS" -> "Tuần 4-8: Thử nghiệm thực tế";
            case "DEEP_COGNITIVE_MEMORY" -> "Tuần 9-14: Can thiệp nhận thức sâu";
            default -> phaseCode;
        };
    }

    public record ProgramPhase(String code, String label) {}
    private record ProgramModule(String code, String title, String phaseCode, int weekFrom, int weekTo, String interventionType) {}
}
