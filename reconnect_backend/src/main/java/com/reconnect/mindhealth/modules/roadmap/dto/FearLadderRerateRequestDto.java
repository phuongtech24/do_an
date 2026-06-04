package com.reconnect.mindhealth.modules.roadmap.dto;

import java.util.List;
import java.util.UUID;

public class FearLadderRerateRequestDto {
    private UUID patientId;
    private List<FearLadderRerateItemDto> items;

    public UUID getPatientId() { return patientId; }
    public void setPatientId(UUID patientId) { this.patientId = patientId; }
    public List<FearLadderRerateItemDto> getItems() { return items; }
    public void setItems(List<FearLadderRerateItemDto> items) { this.items = items; }
}
