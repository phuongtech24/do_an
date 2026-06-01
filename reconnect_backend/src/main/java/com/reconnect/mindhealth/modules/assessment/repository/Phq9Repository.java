package com.reconnect.mindhealth.modules.assessment.repository;

import com.reconnect.mindhealth.modules.assessment.entity.Phq9Submission;
import com.reconnect.mindhealth.modules.assessment.enums.Phq9Type;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.UUID;

@Repository
public interface Phq9Repository extends JpaRepository<Phq9Submission, UUID> {
    boolean existsByPatientProfile_IdAndSubmissionType(UUID patientId, Phq9Type submissionType);
    Phq9Submission findTopByPatientProfile_IdOrderByCreateDateDesc(UUID patientId);
    List<Phq9Submission> findByPatientProfile_IdOrderByCreateDateDesc(UUID patientId);
    List<Phq9Submission> findTop2ByPatientProfile_IdAndSubmissionTypeOrderByCreateDateDesc(UUID patientId,
            Phq9Type submissionType);
}
