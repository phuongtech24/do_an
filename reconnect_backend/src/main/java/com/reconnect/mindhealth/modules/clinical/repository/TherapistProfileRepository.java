package com.reconnect.mindhealth.modules.clinical.repository;

import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.clinical.entity.TherapistProfile;
import com.reconnect.mindhealth.modules.clinical.enums.ApprovalStatus;

@Repository
public interface TherapistProfileRepository extends JpaRepository<TherapistProfile, UUID> {
    TherapistProfile findByFullName(String fullName);
    java.util.List<TherapistProfile> findByApprovalStatusOrderByFullNameAsc(ApprovalStatus approvalStatus);
    long countByApprovalStatus(ApprovalStatus approvalStatus);


}
