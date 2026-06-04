package com.reconnect.mindhealth.modules.clinical.service.impl;

import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.reconnect.mindhealth.modules.clinical.dto.GoalSettingDto;
import com.reconnect.mindhealth.modules.clinical.dto.OnboardingStatusDto;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;
import com.reconnect.mindhealth.modules.clinical.service.IClinicalService;
import com.reconnect.mindhealth.modules.assessment.enums.LsasSubmissionType;
import com.reconnect.mindhealth.modules.assessment.repository.LsasSubmissionRepository;

import jakarta.persistence.EntityNotFoundException;
import com.fasterxml.jackson.core.type.TypeReference;

@Service
@Transactional
public class ClinicalServiceImpl implements IClinicalService {

    private static final Logger log = LoggerFactory.getLogger(ClinicalServiceImpl.class);

    @Autowired
    private PatientProfileRepository patientProfileRepository;

    @Autowired
    private LsasSubmissionRepository lsasSubmissionRepository;

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public GoalSettingDto saveGoals(GoalSettingDto dto) {
        if (dto == null || dto.getPatientId() == null) {
            throw new IllegalArgumentException("Thiếu thông tin patientId.");
        }

        List<String> goals = dto.getGoals();
        if (goals == null) {
            throw new IllegalArgumentException("Thiếu danh sách mục tiêu (goals).");
        }

        Set<String> normalized = new LinkedHashSet<>();
        for (String g : goals) {
            if (g == null) {
                continue;
            }
            String trimmed = g.trim();
            if (!trimmed.isEmpty()) {
                normalized.add(trimmed);
            }
        }

        if (normalized.size() < 3 || normalized.size() > 5) {
            throw new IllegalArgumentException("Bệnh nhân phải chọn từ 3 đến 5 mục tiêu trị liệu.");
        }

        UUID patientId = dto.getPatientId();
        PatientProfile patientProfile = patientProfileRepository.findById(patientId)
                .orElseThrow(() -> new EntityNotFoundException("Bệnh nhân không tồn tại với ID: " + patientId));

        try {
            List<String> goalsList = normalized.stream().collect(Collectors.toList());
            String json = objectMapper.writeValueAsString(goalsList);
            patientProfile.setGoalsJson(json);
            patientProfileRepository.save(patientProfile);

            GoalSettingDto result = new GoalSettingDto();
            result.setPatientId(patientId);
            result.setGoals(goalsList);

            log.info("Saved goals for patient {}. Goals count={}", patientId, goalsList.size());
            return result;
        } catch (Exception e) {
            log.error("Error saving goalsJson for patient {}", patientId, e);
            throw new RuntimeException("Lỗi khi lưu mục tiêu trị liệu: " + e.getMessage(), e);
        }
    }

    @Override
    @Transactional(readOnly = true)
    public GoalSettingDto getGoals(UUID patientId) {
        if (patientId == null) {
            throw new IllegalArgumentException("Thiếu thông tin patientId.");
        }

        PatientProfile patientProfile = patientProfileRepository.findById(patientId)
                .orElseThrow(() -> new EntityNotFoundException("Bệnh nhân không tồn tại với ID: " + patientId));

        List<String> goals = List.of();
        String goalsJson = patientProfile.getGoalsJson();
        if (goalsJson != null && !goalsJson.trim().isEmpty()) {
            try {
                goals = objectMapper.readValue(goalsJson, new TypeReference<List<String>>() {
                });
            } catch (Exception e) {
                log.error("Error parsing goalsJson for patient {}", patientId, e);
                goals = List.of();
            }
        }

        GoalSettingDto result = new GoalSettingDto();
        result.setPatientId(patientId);
        result.setGoals(goals);
        return result;
    }

    @Override
    public void completePsychoeducation(UUID patientId) {
        if (patientId == null) {
            throw new IllegalArgumentException("Thiếu thông tin patientId.");
        }
        PatientProfile patientProfile = patientProfileRepository.findById(patientId)
                .orElseThrow(() -> new EntityNotFoundException("Bệnh nhân không tồn tại với ID: " + patientId));

        if (Boolean.TRUE.equals(patientProfile.getPsychoeducationCompleted())) {
            return;
        }

        patientProfile.setPsychoeducationCompleted(true);
        patientProfile.setPsychoeducationCompletedAt(java.time.LocalDateTime.now());
        patientProfileRepository.save(patientProfile);
    }

    @Override
    @Transactional(readOnly = true)
    public OnboardingStatusDto getOnboardingStatus(UUID patientId) {
        if (patientId == null) {
            throw new IllegalArgumentException("Thiếu thông tin patientId.");
        }

        PatientProfile patientProfile = patientProfileRepository.findById(patientId)
                .orElseThrow(() -> new EntityNotFoundException("Bệnh nhân không tồn tại với ID: " + patientId));

        boolean hasBaseline = lsasSubmissionRepository.existsByPatientProfile_IdAndSubmissionType(patientId, LsasSubmissionType.BASELINE);
        boolean hasGoals = patientProfile.getGoalsJson() != null && !patientProfile.getGoalsJson().trim().isEmpty();
        boolean hasPsycho = Boolean.TRUE.equals(patientProfile.getPsychoeducationCompleted());

        OnboardingStatusDto dto = new OnboardingStatusDto();
        dto.setPatientId(patientId);
        dto.setHasBaselineLsas(hasBaseline);
        dto.setHasGoals(hasGoals);
        dto.setHasCompletedPsychoeducation(hasPsycho);
        return dto;
    }
}
