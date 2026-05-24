package com.reconnect.mindhealth.modules.clinical.repository;

import java.util.UUID;

import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.clinical.entity.TherapistProfile;
import com.reconnect.mindhealth.modules.clinical.enums.ApprovalStatus;

import jakarta.persistence.LockModeType;

@Repository
public interface TherapistProfileRepository extends JpaRepository<TherapistProfile, UUID> {
    TherapistProfile findByFullName(String fullName);
    java.util.List<TherapistProfile> findByApprovalStatusOrderByFullNameAsc(ApprovalStatus approvalStatus);
    long countByApprovalStatus(ApprovalStatus approvalStatus);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select t from TherapistProfile t where t.id = :id")
    TherapistProfile findByIdForUpdate(@Param("id") UUID id);

}
