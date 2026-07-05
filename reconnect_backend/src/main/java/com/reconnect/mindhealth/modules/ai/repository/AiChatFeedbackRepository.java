package com.reconnect.mindhealth.modules.ai.repository;

import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.reconnect.mindhealth.modules.ai.entity.AiChatFeedback;

@Repository
public interface AiChatFeedbackRepository extends JpaRepository<AiChatFeedback, UUID> {
}
