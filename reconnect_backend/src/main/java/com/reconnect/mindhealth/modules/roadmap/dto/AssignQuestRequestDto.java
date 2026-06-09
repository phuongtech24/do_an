package com.reconnect.mindhealth.modules.roadmap.dto;

import java.time.LocalDateTime;
import java.util.UUID;

public class AssignQuestRequestDto {
    private UUID questTemplateId;
    private LocalDateTime dueDate;

    public AssignQuestRequestDto() {
    }

    public UUID getQuestTemplateId() {
        return questTemplateId;
    }

    public void setQuestTemplateId(UUID questTemplateId) {
        this.questTemplateId = questTemplateId;
    }

    public LocalDateTime getDueDate() {
        return dueDate;
    }

    public void setDueDate(LocalDateTime dueDate) {
        this.dueDate = dueDate;
    }
}
