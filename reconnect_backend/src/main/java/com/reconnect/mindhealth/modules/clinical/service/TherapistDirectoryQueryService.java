package com.reconnect.mindhealth.modules.clinical.service;

import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.reconnect.mindhealth.modules.clinical.dto.TherapistApplicantDto;
import com.reconnect.mindhealth.modules.clinical.dto.TherapistDirectoryItemDto;
import com.reconnect.mindhealth.modules.clinical.entity.TherapistProfile;
import com.reconnect.mindhealth.modules.clinical.enums.ApprovalStatus;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;
import com.reconnect.mindhealth.modules.clinical.repository.TherapistCredentialRepository;
import com.reconnect.mindhealth.modules.clinical.repository.TherapistProfileRepository;
import com.reconnect.mindhealth.modules.clinical.repository.projection.TherapistCountProjection;

import jakarta.persistence.EntityNotFoundException;

@Service
public class TherapistDirectoryQueryService {

    private final TherapistProfileRepository therapistProfileRepository;
    private final TherapistCredentialRepository therapistCredentialRepository;
    private final PatientProfileRepository patientProfileRepository;

    public TherapistDirectoryQueryService(
            TherapistProfileRepository therapistProfileRepository,
            TherapistCredentialRepository therapistCredentialRepository,
            PatientProfileRepository patientProfileRepository) {
        this.therapistProfileRepository = therapistProfileRepository;
        this.therapistCredentialRepository = therapistCredentialRepository;
        this.patientProfileRepository = patientProfileRepository;
    }

    @Transactional(readOnly = true)
    @Cacheable(cacheNames = "therapistDirectoryList", key = "'ACTIVE'")
    public List<TherapistDirectoryItemDto> listSelectableTherapists() {
        List<TherapistProfile> therapists = therapistProfileRepository.findByApprovalStatusOrderByFullNameAsc(
                ApprovalStatus.ACTIVE);
        List<TherapistProfile> activeTherapists = therapists.stream()
                .filter(profile -> profile.getUser() != null && Boolean.TRUE.equals(profile.getUser().getIsActive()))
                .toList();
        Map<UUID, Long> credentialCountMap = loadCredentialCountMap(activeTherapists);
        Map<UUID, Long> caseloadCountMap = loadCaseloadCountMap(activeTherapists);
        return activeTherapists.stream()
                .map(profile -> new TherapistDirectoryItemDto(
                        profile,
                        credentialCountMap.getOrDefault(profile.getId(), 0L),
                        caseloadCountMap.getOrDefault(profile.getId(), 0L)))
                .toList();
    }

    @Transactional(readOnly = true)
    @Cacheable(cacheNames = "therapistDirectoryItem", key = "#therapistId")
    public TherapistDirectoryItemDto getSelectableTherapist(UUID therapistId) {
        TherapistProfile profile = therapistProfileRepository.findByIdWithUser(therapistId)
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy chuyên gia."));
        if (profile.getApprovalStatus() != ApprovalStatus.ACTIVE
                || profile.getUser() == null
                || !Boolean.TRUE.equals(profile.getUser().getIsActive())) {
            throw new IllegalStateException("Chuyên gia này hiện chưa sẵn sàng nhận bệnh nhân.");
        }
        Map<UUID, Long> credentialCountMap = loadCredentialCountMap(List.of(profile));
        Map<UUID, Long> caseloadCountMap = loadCaseloadCountMap(List.of(profile));
        return new TherapistDirectoryItemDto(
                profile,
                credentialCountMap.getOrDefault(profile.getId(), 0L),
                caseloadCountMap.getOrDefault(profile.getId(), 0L));
    }

    @Transactional(readOnly = true)
    @Cacheable(cacheNames = "adminTherapistList", key = "#status == null ? 'ALL' : #status.name()")
    public List<TherapistApplicantDto> listAdminTherapists(ApprovalStatus status) {
        List<TherapistProfile> therapists = status == null
                ? therapistProfileRepository.findAllOrderByFullNameAsc()
                : therapistProfileRepository.findByApprovalStatusOrderByFullNameAsc(status);
        Map<UUID, Long> credentialCountMap = loadCredentialCountMap(therapists);
        Map<UUID, Long> caseloadCountMap = loadCaseloadCountMap(therapists);
        return therapists.stream()
                .map(profile -> new TherapistApplicantDto(
                        profile,
                        credentialCountMap.getOrDefault(profile.getId(), 0L),
                        caseloadCountMap.getOrDefault(profile.getId(), 0L)))
                .toList();
    }

    private Map<UUID, Long> loadCredentialCountMap(List<TherapistProfile> therapists) {
        List<UUID> therapistIds = therapists.stream().map(TherapistProfile::getId).toList();
        if (therapistIds.isEmpty()) {
            return Collections.emptyMap();
        }
        return therapistCredentialRepository.countByTherapistIds(therapistIds).stream()
                .collect(Collectors.toMap(TherapistCountProjection::getTherapistId, TherapistCountProjection::getCount));
    }

    private Map<UUID, Long> loadCaseloadCountMap(List<TherapistProfile> therapists) {
        List<UUID> therapistIds = therapists.stream().map(TherapistProfile::getId).toList();
        if (therapistIds.isEmpty()) {
            return Collections.emptyMap();
        }
        return patientProfileRepository.countActiveCaseloadByTherapistIds(therapistIds).stream()
                .collect(Collectors.toMap(TherapistCountProjection::getTherapistId, TherapistCountProjection::getCount));
    }
}
