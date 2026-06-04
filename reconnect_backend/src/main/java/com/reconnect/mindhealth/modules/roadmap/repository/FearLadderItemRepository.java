package com.reconnect.mindhealth.modules.roadmap.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.reconnect.mindhealth.modules.roadmap.entity.FearLadderItem;
import com.reconnect.mindhealth.modules.roadmap.enums.FearLadderStatus;

public interface FearLadderItemRepository extends JpaRepository<FearLadderItem, UUID> {
    List<FearLadderItem> findByPatientProfile_IdOrderByLadderOrderAsc(UUID patientId);

    List<FearLadderItem> findByPatientProfile_IdAndStatusOrderByLadderOrderAsc(UUID patientId, FearLadderStatus status);

    Optional<FearLadderItem> findByPatientProfile_IdAndSituation_Id(UUID patientId, UUID situationId);

    void deleteByPatientProfile_Id(UUID patientId);
}
