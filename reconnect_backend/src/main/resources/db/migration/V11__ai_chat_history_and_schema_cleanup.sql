-- ReConnect MindHealth
-- V11 - AI chat history persistence + schema cleanup
--
-- Mục tiêu:
-- - Chuẩn hóa schema hiện tại về 16 bảng lõi + 3 bảng AI chat.
-- - Bỏ daily_risk_logs và dọn các bảng legacy quest nếu còn sót.
-- - Bổ sung lưu lịch sử Trợ lý AI xuống DB để phục vụ audit / feedback.

DROP TABLE IF EXISTS ai_chat_feedback;
DROP TABLE IF EXISTS ai_chat_messages;
DROP TABLE IF EXISTS ai_chat_sessions;

DROP TABLE IF EXISTS daily_risk_logs;
DROP TABLE IF EXISTS patient_quests;
DROP TABLE IF EXISTS quest_templates;

CREATE TABLE IF NOT EXISTS ai_chat_sessions (
    id BINARY(16) NOT NULL,
    patient_id BINARY(16) NOT NULL,
    session_type VARCHAR(32) NOT NULL,
    screen_context VARCHAR(64) NULL,
    status VARCHAR(32) NOT NULL,
    started_at DATETIME(6) NULL,
    ended_at DATETIME(6) NULL,
    create_date DATETIME(6) NULL,
    created_by VARCHAR(255) NULL,
    modify_date DATETIME(6) NULL,
    modified_by VARCHAR(255) NULL,
    voided BIT(1) NULL,
    is_active BIT(1) NULL,
    created_at DATETIME(6) NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_ai_chat_sessions_patient
        FOREIGN KEY (patient_id) REFERENCES patient_profiles (user_id)
);

CREATE INDEX idx_ai_chat_sessions_patient_created_at
    ON ai_chat_sessions (patient_id, created_at);

CREATE INDEX idx_ai_chat_sessions_screen_status
    ON ai_chat_sessions (screen_context, status);

CREATE TABLE IF NOT EXISTS ai_chat_messages (
    id BINARY(16) NOT NULL,
    session_id BINARY(16) NOT NULL,
    sender_type VARCHAR(16) NOT NULL,
    message_text TEXT NOT NULL,
    used_fallback BIT(1) NOT NULL,
    related_topic_code VARCHAR(64) NULL,
    safety_escalation BIT(1) NOT NULL,
    intent_detected VARCHAR(64) NULL,
    create_date DATETIME(6) NULL,
    created_by VARCHAR(255) NULL,
    modify_date DATETIME(6) NULL,
    modified_by VARCHAR(255) NULL,
    voided BIT(1) NULL,
    is_active BIT(1) NULL,
    created_at DATETIME(6) NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_ai_chat_messages_session
        FOREIGN KEY (session_id) REFERENCES ai_chat_sessions (id)
);

CREATE INDEX idx_ai_chat_messages_session_created_at
    ON ai_chat_messages (session_id, created_at);

CREATE INDEX idx_ai_chat_messages_sender_created_at
    ON ai_chat_messages (sender_type, created_at);

CREATE TABLE IF NOT EXISTS ai_chat_feedback (
    id BINARY(16) NOT NULL,
    message_id BINARY(16) NOT NULL,
    patient_id BINARY(16) NOT NULL,
    rating INT NULL,
    feedback_text TEXT NULL,
    create_date DATETIME(6) NULL,
    created_by VARCHAR(255) NULL,
    modify_date DATETIME(6) NULL,
    modified_by VARCHAR(255) NULL,
    voided BIT(1) NULL,
    is_active BIT(1) NULL,
    created_at DATETIME(6) NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_ai_chat_feedback_message
        FOREIGN KEY (message_id) REFERENCES ai_chat_messages (id),
    CONSTRAINT fk_ai_chat_feedback_patient
        FOREIGN KEY (patient_id) REFERENCES patient_profiles (user_id)
);

CREATE INDEX idx_ai_chat_feedback_message_created_at
    ON ai_chat_feedback (message_id, created_at);

CREATE INDEX idx_ai_chat_feedback_patient_created_at
    ON ai_chat_feedback (patient_id, created_at);
