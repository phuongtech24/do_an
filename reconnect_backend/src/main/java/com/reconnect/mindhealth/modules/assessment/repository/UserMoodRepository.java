package com.reconnect.mindhealth.modules.assessment.repository;

import com.reconnect.mindhealth.modules.assessment.entity.UserMood;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.Date;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface UserMoodRepository extends JpaRepository<UserMood, UUID> {

    @Query("SELECT u FROM UserMood u WHERE u.patientProfile.id = :patientId AND u.createDate >= :startOfDay AND u.createDate <= :endOfDay ORDER BY u.createDate DESC")
    List<UserMood> findMoodByPatientAndDateRange(
            @Param("patientId") UUID patientId,
            @Param("startOfDay") Date startOfDay,
            @Param("endOfDay") Date endOfDay
    );

    List<UserMood> findTop3ByPatientProfile_IdOrderByCreateDateDesc(UUID patientId);
}
