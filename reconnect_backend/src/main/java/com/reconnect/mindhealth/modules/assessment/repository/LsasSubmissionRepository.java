package com.reconnect.mindhealth.modules.assessment.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.reconnect.mindhealth.modules.assessment.entity.LsasSubmission;
import com.reconnect.mindhealth.modules.assessment.enums.LsasSubmissionType;

public interface LsasSubmissionRepository extends JpaRepository<LsasSubmission, UUID> {
    boolean existsByPatientProfile_IdAndSubmissionType(UUID patientId, LsasSubmissionType submissionType);

    LsasSubmission findTopByPatientProfile_IdOrderByCreateDateDesc(UUID patientId);
    LsasSubmission findTopByPatientProfile_IdAndSubmissionTypeOrderByCreateDateAsc(UUID patientId, LsasSubmissionType submissionType);

    List<LsasSubmission> findByPatientProfile_IdOrderByCreateDateDesc(UUID patientId);
}
