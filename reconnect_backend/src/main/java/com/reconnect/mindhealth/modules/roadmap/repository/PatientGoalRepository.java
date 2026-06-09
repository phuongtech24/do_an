package com.reconnect.mindhealth.modules.roadmap.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.reconnect.mindhealth.modules.roadmap.entity.PatientGoal;
import com.reconnect.mindhealth.modules.roadmap.enums.PatientGoalStatus;

public interface PatientGoalRepository extends JpaRepository<PatientGoal, UUID> {
    List<PatientGoal> findByPatientProfile_IdAndStatusOrderByCreateDateDesc(UUID patientId, PatientGoalStatus status);
}
