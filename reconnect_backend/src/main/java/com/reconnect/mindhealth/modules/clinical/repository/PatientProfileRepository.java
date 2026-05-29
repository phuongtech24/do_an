package com.reconnect.mindhealth.modules.clinical.repository;

import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;

@Repository
public interface PatientProfileRepository extends JpaRepository<PatientProfile, UUID> {
    PatientProfile findByNickName(String nickName);
    java.util.List<PatientProfile> findByIsActiveTrue();
    java.util.List<PatientProfile> findByIsActiveTrueAndGraduatedAtIsNull();
    long countByIsActiveTrue();
    long countByIsRedFlagActiveTrue();
    long countByGraduatedAtIsNotNull();

    java.util.List<PatientProfile> findByTherapist_User_IdOrderByCurrentRiskScoreDesc(UUID therapistUserId);

    java.util.List<PatientProfile> findByTherapist_User_IdAndIsRedFlagActiveTrueOrderByCurrentRiskScoreDesc(UUID therapistUserId);

    java.util.List<PatientProfile> findByIsRedFlagActiveTrueOrderByCurrentRiskScoreDesc();

    long countByTherapist_IdAndIsActiveTrueAndGraduatedAtIsNull(UUID therapistId);

}
