package com.reconnect.mindhealth.modules.roadmap.service.impl;

import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;
import com.reconnect.mindhealth.modules.roadmap.dto.RoadmapProgramStateDto;
import com.reconnect.mindhealth.modules.roadmap.dto.RoadmapSafetyOverlayDto;
import com.reconnect.mindhealth.modules.roadmap.service.IRoadmapService;
import com.reconnect.mindhealth.modules.roadmap.service.RoadmapProgramStateService;

import jakarta.persistence.EntityNotFoundException;

@Service
@Transactional
public class RoadmapServiceImpl implements IRoadmapService {

    @Autowired
    private PatientProfileRepository patientProfileRepository;

    @Autowired
    private RoadmapProgramStateService roadmapProgramStateService;

    @Override
    @Transactional
    public RoadmapProgramStateDto getProgramState(UUID patientId) {
        return roadmapProgramStateService.getProgramState(patientId);
    }

    @Override
    @Transactional(readOnly = true)
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
                ? "Bạn đang có dấu hiệu cần hỗ trợ thêm. Hãy đặt lịch với chuyên gia hoặc dùng hỗ trợ an toàn ngay."
                : "";
        String recommendedAction = active ? "BOOK_TELEHEALTH" : "NONE";
        return new RoadmapSafetyOverlayDto(active, riskScore, redFlagActive, message, recommendedAction);
    }
}
