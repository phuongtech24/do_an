package com.reconnect.mindhealth.modules.roadmap.service.impl;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.reconnect.mindhealth.modules.assessment.entity.Phq9Submission;
import com.reconnect.mindhealth.modules.assessment.repository.Phq9Repository;
import com.reconnect.mindhealth.common.config.StorageProperties;
import com.reconnect.mindhealth.modules.ai.dto.QuestProofVisionResultDto;
import com.reconnect.mindhealth.modules.ai.service.IQuestProofVisionService;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;
import com.reconnect.mindhealth.modules.roadmap.dto.CompleteQuestRequest;
import com.reconnect.mindhealth.modules.roadmap.dto.PatientQuestDto;
import com.reconnect.mindhealth.modules.roadmap.dto.VerifyQuestProofResponseDto;
import com.reconnect.mindhealth.modules.roadmap.entity.PatientQuest;
import com.reconnect.mindhealth.modules.roadmap.entity.QuestTemplate;
import com.reconnect.mindhealth.modules.roadmap.enums.QuestCategory;
import com.reconnect.mindhealth.modules.roadmap.enums.QuestSourceType;
import com.reconnect.mindhealth.modules.roadmap.enums.QuestStatus;
import com.reconnect.mindhealth.modules.roadmap.repository.PatientQuestRepository;
import com.reconnect.mindhealth.modules.roadmap.repository.QuestTemplateRepository;
import com.reconnect.mindhealth.modules.roadmap.service.IRoadmapService;

import jakarta.persistence.EntityNotFoundException;

@Service
@Transactional
public class RoadmapServiceImpl implements IRoadmapService {

    private static final Logger log = LoggerFactory.getLogger(RoadmapServiceImpl.class);

    private static final int DAILY_MAX_QUESTS = 2;
    private static final LocalTime UNLOCK_TIME = LocalTime.of(6, 0);

    @Autowired
    private PatientProfileRepository patientProfileRepository;

    @Autowired
    private QuestTemplateRepository questTemplateRepository;

    @Autowired
    private PatientQuestRepository patientQuestRepository;

    @Autowired
    private Phq9Repository phq9Repository;

    @Autowired
    private StorageProperties storageProperties;

    @Autowired
    private IQuestProofVisionService questProofVisionService;

    @Override
    public List<PatientQuestDto> getDailyQuests(UUID patientId) {
        return getOrCreateDailyQuests(patientId);
    }

    @Transactional
    public List<PatientQuestDto> getOrCreateDailyQuests(UUID patientId) {
        if (patientId == null) {
            throw new IllegalArgumentException("Thiếu thông tin patientId.");
        }

        PatientProfile patientProfile = patientProfileRepository.findById(patientId)
                .orElseThrow(() -> new EntityNotFoundException("Bệnh nhân không tồn tại với ID: " + patientId));

        LocalDate effectiveDate = resolveEffectiveDate(LocalDateTime.now());
        LocalDateTime from = effectiveDate.atStartOfDay();
        LocalDateTime to = effectiveDate.atTime(LocalTime.MAX);

        List<PatientQuest> todays = patientQuestRepository.findDailyQuests(patientId, from, to);
        if (todays == null) {
            todays = Collections.emptyList();
        }

        if (todays.isEmpty()) {
            todays = assignDailyQuests(patientProfile, effectiveDate);
        }

        List<PatientQuestDto> dtos = new ArrayList<>();
        for (PatientQuest pq : todays) {
            dtos.add(new PatientQuestDto(pq));
        }
        return dtos;
    }

    private LocalDate resolveEffectiveDate(LocalDateTime now) {
        if (now.toLocalTime().isBefore(UNLOCK_TIME)) {
            return now.toLocalDate().minusDays(1);
        }
        return now.toLocalDate();
    }

    private List<PatientQuest> assignDailyQuests(PatientProfile patientProfile, LocalDate effectiveDate) {
        List<QuestTemplate> allTemplates = questTemplateRepository.findAll();
        if (allTemplates.isEmpty()) {
            throw new IllegalStateException("Chưa có Quest Templates trong hệ thống. Vui lòng seed dữ liệu quest_templates.");
        }

        int phq9Total = 0;
        Phq9Submission last = phq9Repository.findTopByPatientProfile_IdOrderByCreateDateDesc(patientProfile.getId());
        if (last != null && last.getTotalScore() != null) {
            phq9Total = last.getTotalScore();
        }

        // Simple deterministic daily selection:
        // - Severe (>=15): prioritize BEHAVIORAL
        // - Else: balance BEHAVIORAL + COGNITIVE
        List<QuestCategory> desired = new ArrayList<>();
        if (phq9Total >= 15) {
            desired.add(QuestCategory.BEHAVIORAL);
            desired.add(QuestCategory.BEHAVIORAL);
        } else {
            desired.add(QuestCategory.BEHAVIORAL);
            desired.add(QuestCategory.COGNITIVE);
        }

        List<PatientQuest> created = new ArrayList<>();
        int order = 1;
        for (QuestCategory c : desired) {
            if (created.size() >= DAILY_MAX_QUESTS) {
                break;
            }
            QuestTemplate picked = pickTemplateByCategory(allTemplates, c, order);
            if (picked == null) {
                picked = allTemplates.get(order % allTemplates.size());
            }

            PatientQuest pq = new PatientQuest();
            pq.setPatientProfile(patientProfile);
            pq.setQuestTemplate(picked);
            pq.setSourceType(QuestSourceType.SYSTEM);
            pq.setUnlockOrder(order);

            LocalDateTime unlockAt = effectiveDate.atTime(UNLOCK_TIME);
            LocalDateTime now = LocalDateTime.now();
            pq.setStatus(now.isBefore(unlockAt) ? QuestStatus.LOCKED : QuestStatus.AVAILABLE);

            pq.setAssignedAt(now);
            pq.setDueDate(effectiveDate.atTime(23, 59, 59));

            created.add(patientQuestRepository.save(pq));
            order++;
        }

        log.info("Assigned {} daily quests for patient {} on {}", created.size(), patientProfile.getId(), effectiveDate);
        return created;
    }

    private QuestTemplate pickTemplateByCategory(List<QuestTemplate> all, QuestCategory category, int salt) {
        List<QuestTemplate> filtered = new ArrayList<>();
        for (QuestTemplate t : all) {
            if (t.getCategory() == category) {
                filtered.add(t);
            }
        }
        if (filtered.isEmpty()) {
            return null;
        }
        return filtered.get(Math.abs(salt) % filtered.size());
    }

    @Override
    @Transactional
    public PatientQuestDto completeQuest(UUID patientId, UUID patientQuestId, CompleteQuestRequest request) {
        if (patientId == null) {
            throw new IllegalArgumentException("Thiếu thông tin patientId.");
        }
        if (patientQuestId == null) {
            throw new IllegalArgumentException("Thiếu thông tin patientQuestId.");
        }

        PatientQuest pq = patientQuestRepository.findById(patientQuestId)
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy nhiệm vụ với ID: " + patientQuestId));

        if (!pq.getPatientProfile().getId().equals(patientId)) {
            throw new SecurityException("Bạn không có quyền cập nhật nhiệm vụ này.");
        }

        if (pq.getStatus() == QuestStatus.DONE) {
            return new PatientQuestDto(pq);
        }
        if (pq.getStatus() == QuestStatus.LOCKED) {
            throw new IllegalStateException("Nhiệm vụ chưa được mở khóa.");
        }

        if (request != null) {
            if (request.getMasteryScore() != null) {
                int m = request.getMasteryScore();
                if (m < 0 || m > 10) {
                    throw new IllegalArgumentException("Mastery score phải trong khoảng 0-10.");
                }
                pq.setMasteryScore(m);
            }
            if (request.getPleasureScore() != null) {
                int p = request.getPleasureScore();
                if (p < 0 || p > 10) {
                    throw new IllegalArgumentException("Pleasure score phải trong khoảng 0-10.");
                }
                pq.setPleasureScore(p);
            }
            if (request.getProofImageUrl() != null) {
                pq.setProofImageUrl(request.getProofImageUrl());
            }
        }

        pq.setStatus(QuestStatus.DONE);
        pq.setCompletedAt(LocalDateTime.now());
        PatientQuest saved = patientQuestRepository.save(pq);
        return new PatientQuestDto(saved);
    }

    @Override
    @Transactional
    public VerifyQuestProofResponseDto verifyQuestProof(UUID patientId, UUID patientQuestId, byte[] imageBytes,
            String mimeType) {
        if (patientId == null) {
            throw new IllegalArgumentException("Thiếu thông tin patientId.");
        }
        if (patientQuestId == null) {
            throw new IllegalArgumentException("Thiếu thông tin patientQuestId.");
        }
        if (imageBytes == null || imageBytes.length == 0) {
            throw new IllegalArgumentException("Thiếu dữ liệu ảnh minh chứng.");
        }
        if (mimeType == null || mimeType.isBlank()) {
            mimeType = "image/jpeg";
        }

        PatientQuest pq = patientQuestRepository.findById(patientQuestId)
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy nhiệm vụ với ID: " + patientQuestId));

        if (!pq.getPatientProfile().getId().equals(patientId)) {
            throw new SecurityException("Bạn không có quyền nộp minh chứng cho nhiệm vụ này.");
        }

        QuestTemplate template = pq.getQuestTemplate();
        String questTitle = template != null ? template.getTitle() : "";
        String questDescription = template != null ? template.getDescription() : "";

        String ext = guessExtension(mimeType);
        String fileName = patientQuestId + "-" + System.currentTimeMillis() + ext;
        Path root = Paths.get(storageProperties.getUploadDir(), storageProperties.getQuestProofDir())
                .toAbsolutePath()
                .normalize();

        try {
            Files.createDirectories(root);
            Path target = root.resolve(fileName).normalize();
            if (!target.startsWith(root)) {
                throw new SecurityException("Đường dẫn upload không hợp lệ.");
            }
            Files.write(target, imageBytes);
        } catch (Exception e) {
            throw new IllegalStateException("Không thể lưu ảnh minh chứng: " + e.getMessage());
        }

        String publicPath = "/uploads/" + storageProperties.getQuestProofDir() + "/" + fileName;
        QuestProofVisionResultDto vision = questProofVisionService.verifyQuestProof(questTitle, questDescription,
                imageBytes, mimeType);

        boolean accepted = Boolean.TRUE.equals(vision.getRelevant())
                && (vision.getScore() != null && vision.getScore() >= 70)
                && (vision.getConfidence() != null && vision.getConfidence() >= 0.6);

        pq.setProofImageUrl(publicPath);
        pq.setProofAiRelevant(vision.getRelevant());
        pq.setProofAiConfidence(vision.getConfidence());
        pq.setProofAiScore(vision.getScore());
        pq.setProofAiReason(vision.getReason());
        pq.setProofVerifiedAt(LocalDateTime.now());
        patientQuestRepository.save(pq);

        return new VerifyQuestProofResponseDto(accepted, publicPath, vision);
    }

    private String guessExtension(String mimeType) {
        String t = mimeType.toLowerCase().trim();
        if (t.contains("png")) {
            return ".png";
        }
        if (t.contains("webp")) {
            return ".webp";
        }
        return ".jpg";
    }
}
