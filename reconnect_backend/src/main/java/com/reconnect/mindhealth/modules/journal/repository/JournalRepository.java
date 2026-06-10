package com.reconnect.mindhealth.modules.journal.repository;

import java.util.List;
import java.util.UUID;
import com.reconnect.mindhealth.modules.journal.entity.Journal;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

/**
 * Repository interface for CBT Journal logs.
 */
@Repository
public interface JournalRepository extends JpaRepository<Journal, UUID> {

    @Query("SELECT j FROM Journal j WHERE j.patientProfile.id = :patientId ORDER BY j.createDate DESC")
    List<Journal> findJournalsByPatientId(@Param("patientId") UUID patientId);

    List<Journal> findTop5ByPatientProfile_IdOrderByCreateDateDesc(UUID patientId);

    @Query("SELECT COALESCE(MAX(j.aiRiskScore), 0) FROM Journal j WHERE j.patientProfile.id = :patientId AND j.createDate >= :startOfDay AND j.createDate <= :endOfDay")
    Integer getMaxAiRiskScoreInDay(@Param("patientId") UUID patientId,
            @Param("startOfDay") java.util.Date startOfDay,
            @Param("endOfDay") java.util.Date endOfDay);
}
