package com.reconnect.mindhealth.modules.assessment.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.reconnect.mindhealth.modules.assessment.entity.LsasAnswer;

public interface LsasAnswerRepository extends JpaRepository<LsasAnswer, UUID> {
    List<LsasAnswer> findBySubmission_Id(UUID submissionId);
}
