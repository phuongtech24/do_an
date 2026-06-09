package com.reconnect.mindhealth.modules.clinical.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.reconnect.mindhealth.modules.clinical.entity.TherapistCredential;
import com.reconnect.mindhealth.modules.clinical.repository.projection.TherapistCountProjection;

@Repository
public interface TherapistCredentialRepository extends JpaRepository<TherapistCredential, UUID> {

    List<TherapistCredential> findByTherapistProfile_IdOrderByUploadedAtDesc(UUID therapistId);

    long countByTherapistProfile_Id(UUID therapistId);

    @Query("""
            select c.therapistProfile.id as therapistId, count(c) as count
            from TherapistCredential c
            where c.therapistProfile.id in :therapistIds
            group by c.therapistProfile.id
            """)
    List<TherapistCountProjection> countByTherapistIds(@Param("therapistIds") List<UUID> therapistIds);
}
