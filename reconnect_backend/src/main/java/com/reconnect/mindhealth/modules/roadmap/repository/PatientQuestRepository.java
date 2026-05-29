package com.reconnect.mindhealth.modules.roadmap.repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.reconnect.mindhealth.modules.roadmap.entity.PatientQuest;
import com.reconnect.mindhealth.modules.roadmap.enums.QuestSourceType;

@Repository
public interface PatientQuestRepository extends JpaRepository<PatientQuest, UUID> {

    @Query("SELECT pq FROM PatientQuest pq WHERE pq.patientProfile.id = :patientId AND pq.assignedAt BETWEEN :from AND :to ORDER BY pq.unlockOrder ASC, pq.createDate ASC")
    List<PatientQuest> findDailyQuests(@Param("patientId") UUID patientId,
            @Param("from") LocalDateTime from,
            @Param("to") LocalDateTime to);

    @Query("SELECT pq FROM PatientQuest pq WHERE pq.patientProfile.id = :patientId AND pq.sourceType = :sourceType AND pq.assignedAt BETWEEN :from AND :to ORDER BY pq.unlockOrder ASC, pq.createDate ASC")
    List<PatientQuest> findDailyQuestsBySourceType(@Param("patientId") UUID patientId,
            @Param("sourceType") QuestSourceType sourceType,
            @Param("from") LocalDateTime from,
            @Param("to") LocalDateTime to);
}
