package com.reconnect.mindhealth.modules.roadmap.service.impl;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.reconnect.mindhealth.common.config.StorageProperties;
import com.reconnect.mindhealth.modules.ai.dto.QuestProofVisionResultDto;
import com.reconnect.mindhealth.modules.ai.service.IQuestProofVisionService;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;
import com.reconnect.mindhealth.modules.roadmap.dto.CompleteQuestRequest;
import com.reconnect.mindhealth.modules.roadmap.dto.PatientQuestDto;
import com.reconnect.mindhealth.modules.roadmap.dto.RoadmapSafetyOverlayDto;
import com.reconnect.mindhealth.modules.roadmap.dto.VerifyQuestProofResponseDto;
import com.reconnect.mindhealth.modules.roadmap.entity.PatientQuest;
import com.reconnect.mindhealth.modules.roadmap.entity.QuestTemplate;
import com.reconnect.mindhealth.modules.roadmap.enums.QuestStatus;
import com.reconnect.mindhealth.modules.roadmap.repository.PatientQuestRepository;
import com.reconnect.mindhealth.modules.roadmap.service.IRoadmapService;
import com.reconnect.mindhealth.modules.roadmap.service.RoadmapDailyAssignmentService;

import jakarta.persistence.EntityNotFoundException;

@Service
@Transactional
public class RoadmapServiceImpl implements IRoadmapService {

    private static final LocalTime UNLOCK_TIME = RoadmapDailyAssignmentService.UNLOCK_TIME;

    @Autowired
    private PatientProfileRepository patientProfileRepository;

    @Autowired
    private PatientQuestRepository patientQuestRepository;

    @Autowired
    private RoadmapDailyAssignmentService dailyAssignmentService;

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
        dailyAssignmentService.ensureDailySystemQuests(patientProfile, effectiveDate);

        LocalDateTime from = effectiveDate.atStartOfDay();
        LocalDateTime to = effectiveDate.atTime(LocalTime.MAX);
        List<PatientQuest> todays = patientQuestRepository.findDailyQuests(patientId, from, to);

        List<PatientQuestDto> dtos = new ArrayList<>();
        for (PatientQuest patientQuest : todays) {
            dtos.add(new PatientQuestDto(patientQuest));
        }
        return dtos;
    }

    @Override
    public RoadmapSafetyOverlayDto getSafetyOverlay(UUID patientId) {
        if (patientId == null) {
            throw new IllegalArgumentException("Thiếu thông tin patientId.");
        }

        PatientProfile patientProfile = patientProfileRepository.findById(patientId)
                .orElseThrow(() -> new EntityNotFoundException("Bệnh nhân không tồn tại với ID: " + patientId));
        int riskScore = patientProfile.getCurrentRiskScore() != null ? patientProfile.getCurrentRiskScore() : 0;
        boolean redFlagActive = Boolean.TRUE.equals(patientProfile.getIsRedFlagActive());
        boolean active = redFlagActive || riskScore >= 70;
        String message = active
                ? "Bạn đang có dấu hiệu cần hỗ trợ thêm. Hãy đặt lịch với chuyên gia hoặc thực hiện bài grounding ngắn."
                : "";
        String recommendedAction = active ? "BOOK_TELEHEALTH" : "NONE";
        return new RoadmapSafetyOverlayDto(active, riskScore, redFlagActive, message, recommendedAction);
    }

    private LocalDate resolveEffectiveDate(LocalDateTime now) {
        if (now.toLocalTime().isBefore(UNLOCK_TIME)) {
            return now.toLocalDate().minusDays(1);
        }
        return now.toLocalDate();
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

        PatientQuest patientQuest = patientQuestRepository.findById(patientQuestId)
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy nhiệm vụ với ID: " + patientQuestId));

        if (!patientQuest.getPatientProfile().getId().equals(patientId)) {
            throw new SecurityException("Bạn không có quyền cập nhật nhiệm vụ này.");
        }

        if (patientQuest.getStatus() == QuestStatus.DONE) {
            return new PatientQuestDto(patientQuest);
        }
        if (patientQuest.getStatus() == QuestStatus.LOCKED) {
            throw new IllegalStateException("Nhiệm vụ chưa được mở khóa.");
        }

        if (request != null) {
            if (request.getMasteryScore() != null) {
                int masteryScore = request.getMasteryScore();
                if (masteryScore < 0 || masteryScore > 10) {
                    throw new IllegalArgumentException("Mastery score phải trong khoảng 0-10.");
                }
                patientQuest.setMasteryScore(masteryScore);
            }
            if (request.getPleasureScore() != null) {
                int pleasureScore = request.getPleasureScore();
                if (pleasureScore < 0 || pleasureScore > 10) {
                    throw new IllegalArgumentException("Pleasure score phải trong khoảng 0-10.");
                }
                patientQuest.setPleasureScore(pleasureScore);
            }
            if (request.getProofImageUrl() != null) {
                patientQuest.setProofImageUrl(request.getProofImageUrl());
            }
        }

        patientQuest.setStatus(QuestStatus.DONE);
        patientQuest.setCompletedAt(LocalDateTime.now());
        PatientQuest saved = patientQuestRepository.save(patientQuest);
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

        PatientQuest patientQuest = patientQuestRepository.findById(patientQuestId)
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy nhiệm vụ với ID: " + patientQuestId));

        if (!patientQuest.getPatientProfile().getId().equals(patientId)) {
            throw new SecurityException("Bạn không có quyền nộp minh chứng cho nhiệm vụ này.");
        }

        QuestTemplate template = patientQuest.getQuestTemplate();
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

        patientQuest.setProofImageUrl(publicPath);
        patientQuest.setProofAiRelevant(vision.getRelevant());
        patientQuest.setProofAiConfidence(vision.getConfidence());
        patientQuest.setProofAiScore(vision.getScore());
        patientQuest.setProofAiReason(vision.getReason());
        patientQuest.setProofVerifiedAt(LocalDateTime.now());
        patientQuestRepository.save(patientQuest);

        return new VerifyQuestProofResponseDto(accepted, publicPath, vision);
    }

    private String guessExtension(String mimeType) {
        String type = mimeType.toLowerCase().trim();
        if (type.contains("png")) {
            return ".png";
        }
        if (type.contains("webp")) {
            return ".webp";
        }
        return ".jpg";
    }
}
