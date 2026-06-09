package com.reconnect.mindhealth.modules.assessment.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.reconnect.mindhealth.modules.assessment.entity.LsasSituation;

public interface LsasSituationRepository extends JpaRepository<LsasSituation, java.util.UUID> {
    List<LsasSituation> findAllByOrderBySituationNumberAsc();

    LsasSituation findBySituationNumber(Integer situationNumber);
}
