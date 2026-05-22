package com.reconnect.mindhealth.modules.clinical.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.reconnect.mindhealth.modules.clinical.entity.TherapistCredential;

@Repository
public interface TherapistCredentialRepository extends JpaRepository<TherapistCredential, UUID> {

    List<TherapistCredential> findByTherapistProfile_IdOrderByUploadedAtDesc(UUID therapistId);

    long countByTherapistProfile_Id(UUID therapistId);
}

