package com.reconnect.mindhealth.modules.clinical.repository;

import java.util.UUID;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.repository.projection.TherapistCountProjection;

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

    @EntityGraph(attributePaths = {"user", "therapist", "therapist.user"})
    @Query("select p from PatientProfile p where p.isActive = true")
    java.util.List<PatientProfile> findActiveWithRelations();

    @EntityGraph(attributePaths = {"user", "therapist", "therapist.user"})
    @Query("""
            select p from PatientProfile p
            where p.isActive = true
              and p.triageRequired = true
              and (p.triageStatus is null or p.triageStatus <> com.reconnect.mindhealth.modules.clinical.enums.TriageStatus.CLOSED)
            order by
              case when p.triagePriority is null then 0 else p.triagePriority end desc,
              case when p.currentRiskScore is null then 0 else p.currentRiskScore end desc,
              p.triageTriggeredAt desc
            """)
    java.util.List<PatientProfile> findActiveTriageQueueWithRelations();

    @EntityGraph(attributePaths = {"user", "therapist", "therapist.user"})
    @Query("""
            select p from PatientProfile p
            where p.isRedFlagActive = true
            order by p.currentRiskScore desc
            """)
    java.util.List<PatientProfile> findRedFlagWithRelations();

    @EntityGraph(attributePaths = {"user", "therapist", "therapist.user"})
    @Query("""
            select p from PatientProfile p
            where p.therapist.user.id = :therapistUserId
            order by p.currentRiskScore desc
            """)
    java.util.List<PatientProfile> findByTherapistUserIdWithRelations(@Param("therapistUserId") UUID therapistUserId);

    @EntityGraph(attributePaths = {"user", "therapist", "therapist.user"})
    @Query("""
            select p from PatientProfile p
            where p.therapist.user.id = :therapistUserId
              and p.isRedFlagActive = true
            order by p.currentRiskScore desc
            """)
    java.util.List<PatientProfile> findRedFlagByTherapistUserIdWithRelations(
            @Param("therapistUserId") UUID therapistUserId);

    @Query("""
            select p.therapist.id as therapistId, count(p) as count
            from PatientProfile p
            where p.therapist.id in :therapistIds
              and p.isActive = true
              and p.graduatedAt is null
            group by p.therapist.id
            """)
    java.util.List<TherapistCountProjection> countActiveCaseloadByTherapistIds(
            @Param("therapistIds") java.util.List<UUID> therapistIds);

}
