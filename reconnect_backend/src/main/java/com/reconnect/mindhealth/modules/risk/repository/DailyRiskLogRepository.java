package com.reconnect.mindhealth.modules.risk.repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.reconnect.mindhealth.modules.risk.entity.DailyRiskLog;

@Repository
public interface DailyRiskLogRepository extends JpaRepository<DailyRiskLog, UUID> {
    Optional<DailyRiskLog> findByPatientProfile_IdAndRiskDate(UUID patientId, LocalDate riskDate);

    List<DailyRiskLog> findByPatientProfile_IdAndRiskDateBetweenOrderByRiskDateAsc(
            UUID patientId,
            LocalDate from,
            LocalDate to);
}
