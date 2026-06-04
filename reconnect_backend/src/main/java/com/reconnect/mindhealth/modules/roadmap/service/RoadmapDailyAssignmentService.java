package com.reconnect.mindhealth.modules.roadmap.service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;
import com.reconnect.mindhealth.modules.roadmap.dto.DailyQuestAssignmentSummaryDto;
import com.reconnect.mindhealth.modules.roadmap.entity.PatientQuest;
import com.reconnect.mindhealth.modules.roadmap.entity.QuestTemplate;
import com.reconnect.mindhealth.modules.roadmap.dto.RoadmapPreviewDto;
import com.reconnect.mindhealth.modules.roadmap.dto.RoadmapPreviewItemDto;
import com.reconnect.mindhealth.modules.roadmap.enums.QuestCategory;
import com.reconnect.mindhealth.modules.roadmap.enums.QuestDifficulty;
import com.reconnect.mindhealth.modules.roadmap.enums.QuestSourceType;
import com.reconnect.mindhealth.modules.roadmap.enums.QuestStatus;
import com.reconnect.mindhealth.modules.roadmap.repository.PatientQuestRepository;
import com.reconnect.mindhealth.modules.roadmap.repository.QuestTemplateRepository;

import jakarta.persistence.EntityNotFoundException;

@Service
public class RoadmapDailyAssignmentService {

    private static final Logger log = LoggerFactory.getLogger(RoadmapDailyAssignmentService.class);

    public static final int DAILY_MAX_QUESTS = 2;
    public static final LocalTime UNLOCK_TIME = LocalTime.of(6, 0);
    private static final ZoneId APP_ZONE = ZoneId.of("Asia/Bangkok");

    private final PatientProfileRepository patientProfileRepository;
    private final QuestTemplateRepository questTemplateRepository;
    private final PatientQuestRepository patientQuestRepository;

    public RoadmapDailyAssignmentService(
            PatientProfileRepository patientProfileRepository,
            QuestTemplateRepository questTemplateRepository,
            PatientQuestRepository patientQuestRepository) {
        this.patientProfileRepository = patientProfileRepository;
        this.questTemplateRepository = questTemplateRepository;
        this.patientQuestRepository = patientQuestRepository;
    }

    public DailyQuestAssignmentSummaryDto assignDailyQuestsForAllActivePatients(LocalDate date) {
        LocalDate effectiveDate = date != null ? date : LocalDate.now();
        DailyQuestAssignmentSummaryDto summary = new DailyQuestAssignmentSummaryDto(effectiveDate);
        List<PatientProfile> patients = patientProfileRepository.findByIsActiveTrueAndGraduatedAtIsNull();

        for (PatientProfile patient : patients) {
            summary.incrementProcessedPatients();
            try {
                int created = ensureDailySystemQuests(patient, effectiveDate).size();
                if (created > 0) {
                    summary.incrementCreatedQuests(created);
                } else {
                    summary.incrementSkippedPatients();
                }
            } catch (Exception e) {
                summary.incrementFailedPatients();
                log.warn("Daily roadmap assignment failed patientId={}, date={}, reason={}",
                        patient.getId(), effectiveDate, e.getMessage());
            }
        }

        log.info("Daily roadmap assignment summary date={}, processed={}, created={}, skipped={}, failed={}",
                summary.getDate(), summary.getProcessedPatients(), summary.getCreatedQuests(),
                summary.getSkippedPatients(), summary.getFailedPatients());
        return summary;
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public List<PatientQuest> ensureDailySystemQuests(PatientProfile patientProfile, LocalDate effectiveDate) {
        if (patientProfile == null || patientProfile.getId() == null) {
            throw new IllegalArgumentException("Missing patient profile.");
        }

        LocalDateTime from = effectiveDate.atStartOfDay();
        LocalDateTime to = effectiveDate.atTime(LocalTime.MAX);
        List<PatientQuest> existingSystem = patientQuestRepository.findDailyQuestsBySourceType(
                patientProfile.getId(), QuestSourceType.SYSTEM, from, to);
        if (existingSystem != null && !existingSystem.isEmpty()) {
            return Collections.emptyList();
        }

        return assignDailySystemQuests(patientProfile, effectiveDate);
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public List<PatientQuest> refreshDailySystemQuestsAfterLsas(
            PatientProfile patientProfile,
            LocalDate effectiveDate,
            Integer lsasTotal,
            LocalDate cycleStartDate) {
        if (patientProfile == null || patientProfile.getId() == null) {
            throw new IllegalArgumentException("Missing patient profile.");
        }

        LocalDateTime from = effectiveDate.atStartOfDay();
        LocalDateTime to = effectiveDate.atTime(LocalTime.MAX);
        List<PatientQuest> existingSystem = patientQuestRepository.findDailyQuestsBySourceType(
                patientProfile.getId(), QuestSourceType.SYSTEM, from, to);

        if (existingSystem != null && !existingSystem.isEmpty()) {
            boolean hasCompletedQuest = existingSystem.stream()
                    .anyMatch(quest -> quest.getStatus() == QuestStatus.DONE);
            if (hasCompletedQuest) {
                log.info("Skipped LSAS roadmap refresh because a system quest is already completed patientId={}, date={}, existing={}",
                        patientProfile.getId(), effectiveDate, existingSystem.size());
                return Collections.emptyList();
            }

            patientQuestRepository.deleteAll(existingSystem);
            patientQuestRepository.flush();
            log.info("Deleted stale daily system quests after LSAS patientId={}, date={}, deleted={}",
                    patientProfile.getId(), effectiveDate, existingSystem.size());
        }

        int effectiveLsas = lsasTotal != null ? Math.max(0, Math.min(lsasTotal, 144)) : resolveLatestLsasScore(patientProfile);
        LocalDate effectiveCycleStart = cycleStartDate != null ? cycleStartDate : effectiveDate;
        return assignDailySystemQuests(patientProfile, effectiveDate, effectiveLsas, effectiveCycleStart);
    }

    public RoadmapPreviewDto previewDailySystemQuestPlan(UUID patientId, LocalDate startDate, Integer days, Integer lsasScore) {
        PatientProfile patient = patientProfileRepository.findById(patientId)
                .orElseThrow(() -> new EntityNotFoundException("Patient profile not found: " + patientId));
        LocalDate effectiveStart = startDate != null ? startDate : LocalDate.now(APP_ZONE);
        int effectiveDays = days != null ? Math.max(1, Math.min(days, 28)) : 14;
        int effectiveLsas = lsasScore != null ? Math.max(0, Math.min(lsasScore, 144)) : resolveLatestLsasScore(patient);

        RoadmapPreviewDto preview = new RoadmapPreviewDto();
        preview.setPatientId(patient.getId());
        preview.setStartDate(effectiveStart);
        preview.setDays(effectiveDays);
        preview.setLsasScore(effectiveLsas);

        List<RoadmapPreviewItemDto> items = new ArrayList<>();
        int behavioralCount = 0;
        int cognitiveCount = 0;
        for (int day = 0; day < effectiveDays; day++) {
            LocalDate date = effectiveStart.plusDays(day);
            int cycleDayIndex = Math.floorMod(day, 14);
            for (int order = 1; order <= DAILY_MAX_QUESTS; order++) {
                QuestSelection selection = selectQuest(effectiveLsas, cycleDayIndex, order);
                if (selection.category() == QuestCategory.BEHAVIORAL) {
                    behavioralCount++;
                } else if (selection.category() == QuestCategory.COGNITIVE) {
                    cognitiveCount++;
                }
                items.add(new RoadmapPreviewItemDto(
                        date,
                        cycleDayIndex,
                        order,
                        selection.category(),
                        selection.difficulty(),
                        QuestSourceType.SYSTEM));
            }
        }

        preview.setItems(items);
        preview.setTotalSlots(items.size());
        preview.setBehavioralCount(behavioralCount);
        preview.setCognitiveCount(cognitiveCount);
        return preview;
    }

    private List<PatientQuest> assignDailySystemQuests(PatientProfile patientProfile, LocalDate effectiveDate) {
        int lsasTotal = resolveLatestLsasScore(patientProfile);
        LocalDate cycleStart = patientProfile.getCurrentCycleStartDate() != null
                ? patientProfile.getCurrentCycleStartDate().toLocalDate()
                : effectiveDate;
        return assignDailySystemQuests(patientProfile, effectiveDate, lsasTotal, cycleStart);
    }

    private List<PatientQuest> assignDailySystemQuests(
            PatientProfile patientProfile,
            LocalDate effectiveDate,
            int lsasTotal,
            LocalDate cycleStart) {
        List<QuestTemplate> allTemplates = questTemplateRepository.findAll();
        if (allTemplates.isEmpty()) {
            throw new IllegalStateException("No Quest Templates found. Please seed CBT data.");
        }

        int cycleDayIndex = (int) Math.floorMod(ChronoUnit.DAYS.between(cycleStart, effectiveDate), 14);
        int rotationSalt = Math.abs(patientProfile.getId().hashCode()) + effectiveDate.getDayOfYear();

        List<PatientQuest> created = new ArrayList<>();
        for (int order = 1; order <= DAILY_MAX_QUESTS; order++) {
            QuestSelection selection = selectQuest(lsasTotal, cycleDayIndex, order);
            QuestTemplate picked = pickTemplateByCategoryAndDifficulty(
                    allTemplates, selection.category(), selection.difficulty(), rotationSalt + order);
            if (picked == null) {
                picked = pickTemplateByCategory(allTemplates, selection.category(), rotationSalt + order);
            }
            if (picked == null) {
                picked = allTemplates.get(Math.abs(rotationSalt + order) % allTemplates.size());
            }

            PatientQuest quest = new PatientQuest();
            quest.setPatientProfile(patientProfile);
            quest.setQuestTemplate(picked);
            quest.setSourceType(QuestSourceType.SYSTEM);
            quest.setUnlockOrder(order);

            LocalDateTime now = LocalDateTime.now();
            LocalDateTime unlockAt = effectiveDate.atTime(UNLOCK_TIME);
            quest.setStatus(now.isBefore(unlockAt) ? QuestStatus.LOCKED : QuestStatus.AVAILABLE);
            quest.setAssignedAt(now);
            quest.setDueDate(effectiveDate.atTime(23, 59, 59));

            created.add(patientQuestRepository.save(quest));
        }

        log.info("Assigned legacy daily system quests patientId={}, date={}, created={}, lsas={}, cycleDay={}",
                patientProfile.getId(), effectiveDate, created.size(), lsasTotal, cycleDayIndex);
        return created;
    }

    private int resolveLatestLsasScore(PatientProfile patientProfile) {
        return patientProfile.getCurrentLsasScore() != null ? patientProfile.getCurrentLsasScore() : 0;
    }

    private QuestSelection selectQuest(int lsasTotal, int cycleDayIndex, int unlockOrder) {
        int globalSlotIndex = cycleDayIndex * DAILY_MAX_QUESTS + (unlockOrder - 1);
        if (lsasTotal >= 60) {
            if (globalSlotIndex % 5 == 4) {
                return new QuestSelection(QuestCategory.COGNITIVE, QuestDifficulty.EASY);
            }
            return new QuestSelection(QuestCategory.BEHAVIORAL, QuestDifficulty.EASY);
        }

        if (globalSlotIndex % 2 == 0) {
            return new QuestSelection(QuestCategory.BEHAVIORAL, QuestDifficulty.MEDIUM);
        }
        return new QuestSelection(QuestCategory.COGNITIVE, QuestDifficulty.MEDIUM);
    }

    private QuestTemplate pickTemplateByCategory(List<QuestTemplate> all, QuestCategory category, int salt) {
        List<QuestTemplate> filtered = new ArrayList<>();
        for (QuestTemplate template : all) {
            if (template.getCategory() == category) {
                filtered.add(template);
            }
        }
        if (filtered.isEmpty()) {
            return null;
        }
        return filtered.get(Math.abs(salt) % filtered.size());
    }

    private QuestTemplate pickTemplateByCategoryAndDifficulty(
            List<QuestTemplate> all,
            QuestCategory category,
            QuestDifficulty difficulty,
            int salt) {
        List<QuestTemplate> filtered = new ArrayList<>();
        for (QuestTemplate template : all) {
            if (template.getCategory() == category && template.getDifficulty() == difficulty) {
                filtered.add(template);
            }
        }
        if (filtered.isEmpty()) {
            return null;
        }
        return filtered.get(Math.abs(salt) % filtered.size());
    }

    private record QuestSelection(QuestCategory category, QuestDifficulty difficulty) {
    }
}
