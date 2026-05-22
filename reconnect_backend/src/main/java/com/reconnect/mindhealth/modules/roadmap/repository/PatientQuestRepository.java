package com.reconnect.mindhealth.modules.roadmap.repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.reconnect.mindhealth.modules.roadmap.entity.PatientQuest;

@Repository
public interface PatientQuestRepository extends JpaRepository<PatientQuest, UUID> {

    @Query("SELECT pq FROM PatientQuest pq WHERE pq.patientProfile.id = :patientId AND pq.assignedAt BETWEEN :from AND :to ORDER BY pq.unlockOrder ASC, pq.createDate ASC")
    List<PatientQuest> findDailyQuests(@Param("patientId") UUID patientId,
            @Param("from") LocalDateTime from,
            @Param("to") LocalDateTime to);
}

