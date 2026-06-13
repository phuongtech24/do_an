package com.reconnect.mindhealth.modules.roadmap.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.reconnect.mindhealth.modules.roadmap.entity.BehavioralExperiment;
import com.reconnect.mindhealth.modules.roadmap.enums.BehavioralExperimentStatus;

public interface BehavioralExperimentRepository extends JpaRepository<BehavioralExperiment, UUID> {
    List<BehavioralExperiment> findByPatientProfile_IdOrderByAssignedAtDesc(UUID patientId);

    Optional<BehavioralExperiment> findTopByPatientProfile_IdAndStatusInOrderByAssignedAtDesc(
            UUID patientId,
            List<BehavioralExperimentStatus> statuses);

    Optional<BehavioralExperiment> findTopByPatientProfile_IdAndFearLadderItem_IdAndStatusInOrderByAssignedAtDesc(
            UUID patientId,
            UUID fearLadderItemId,
            List<BehavioralExperimentStatus> statuses);
}
