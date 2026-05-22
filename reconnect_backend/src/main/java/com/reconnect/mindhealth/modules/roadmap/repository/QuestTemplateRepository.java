package com.reconnect.mindhealth.modules.roadmap.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.reconnect.mindhealth.modules.roadmap.entity.QuestTemplate;
import com.reconnect.mindhealth.modules.roadmap.enums.QuestCategory;

@Repository
public interface QuestTemplateRepository extends JpaRepository<QuestTemplate, UUID> {
    List<QuestTemplate> findByCategory(QuestCategory category);
}

