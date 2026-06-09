package com.reconnect.mindhealth.modules.roadmap.service.impl;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;
import com.reconnect.mindhealth.modules.roadmap.dto.TherapistPatientQuestProgressDto;
import com.reconnect.mindhealth.modules.roadmap.dto.TherapistPatientQuestProgressItemDto;
import com.reconnect.mindhealth.modules.roadmap.entity.PatientQuest;
import com.reconnect.mindhealth.modules.roadmap.enums.QuestSourceType;
import com.reconnect.mindhealth.modules.roadmap.enums.QuestStatus;
import com.reconnect.mindhealth.modules.roadmap.repository.PatientQuestRepository;
import com.reconnect.mindhealth.modules.roadmap.service.TherapistQuestProgressService;

import jakarta.persistence.EntityNotFoundException;

@Service
public class TherapistQuestProgressServiceImpl implements TherapistQuestProgressService {

    private static final int RECENT_LIMIT = 10;

    private final PatientProfileRepository patientProfileRepository;
    private final PatientQuestRepository patientQuestRepository;

    public TherapistQuestProgressServiceImpl(
            PatientProfileRepository patientProfileRepository,
            PatientQuestRepository patientQuestRepository) {
        this.patientProfileRepository = patientProfileRepository;
        this.patientQuestRepository = patientQuestRepository;
    }

    @Override
    @Transactional(readOnly = true)
    public TherapistPatientQuestProgressDto getProgress(User therapistUser, UUID patientId) {
        PatientProfile patient = patientProfileRepository.findById(patientId)
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy bệnh nhân: " + patientId));
        if (patient.getTherapist() == null || !patient.getTherapist().getId().equals(therapistUser.getId())) {
            throw new SecurityException("Bạn chỉ được xem tiến độ CBT của bệnh nhân đang phụ trách.");
        }

        List<PatientQuest> quests = patientQuestRepository.findByPatientProfile_IdOrderByAssignedAtDesc(patientId);
        long totalAssigned = quests.size();
        long completed = quests.stream().filter(q -> q.getStatus() == QuestStatus.DONE).count();
        long systemAssigned = quests.stream().filter(q -> q.getSourceType() == QuestSourceType.SYSTEM).count();
        long therapistAssigned = quests.stream().filter(q -> q.getSourceType() == QuestSourceType.THERAPIST).count();

        TherapistPatientQuestProgressDto dto = new TherapistPatientQuestProgressDto();
        dto.setPatientId(patientId);
        dto.setTotalAssigned(totalAssigned);
        dto.setCompleted(completed);
        dto.setCompletionRate(totalAssigned == 0 ? 0 : Math.round((completed * 10000.0) / totalAssigned) / 100.0);
        dto.setSystemAssigned(systemAssigned);
        dto.setTherapistAssigned(therapistAssigned);
        dto.setAverageMastery(averageScore(quests, true));
        dto.setAveragePleasure(averageScore(quests, false));
        dto.setRecentQuests(quests.stream()
                .limit(RECENT_LIMIT)
                .map(TherapistPatientQuestProgressItemDto::new)
                .toList());
        return dto;
    }

    private Double averageScore(List<PatientQuest> quests, boolean mastery) {
        List<Integer> scores = quests.stream()
                .filter(q -> q.getStatus() == QuestStatus.DONE)
                .map(q -> mastery ? q.getMasteryScore() : q.getPleasureScore())
                .filter(score -> score != null)
                .toList();
        if (scores.isEmpty()) {
            return null;
        }
        double average = scores.stream().mapToInt(Integer::intValue).average().orElse(0);
        return Math.round(average * 10.0) / 10.0;
    }
}
