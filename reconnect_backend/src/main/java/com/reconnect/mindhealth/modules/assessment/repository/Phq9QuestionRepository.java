package com.reconnect.mindhealth.modules.assessment.repository;

import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.reconnect.mindhealth.modules.assessment.entity.Phq9Question;

@Repository
public interface Phq9QuestionRepository extends JpaRepository<Phq9Question, UUID> {
    Phq9Question findByQuestionNumber(Integer questionNumber);
}
