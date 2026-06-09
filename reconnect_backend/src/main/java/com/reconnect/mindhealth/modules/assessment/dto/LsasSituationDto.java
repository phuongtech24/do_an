package com.reconnect.mindhealth.modules.assessment.dto;

import java.util.UUID;

import com.reconnect.mindhealth.modules.assessment.entity.LsasSituation;
import com.reconnect.mindhealth.modules.assessment.enums.LsasSituationGroup;

public class LsasSituationDto {
    private UUID id;
    private Integer situationNumber;
    private String text;
    private LsasSituationGroup situationGroup;

    public LsasSituationDto() {
    }

    public LsasSituationDto(LsasSituation entity) {
        this.id = entity.getId();
        this.situationNumber = entity.getSituationNumber();
        this.text = entity.getText();
        this.situationGroup = entity.getSituationGroup();
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public Integer getSituationNumber() { return situationNumber; }
    public void setSituationNumber(Integer situationNumber) { this.situationNumber = situationNumber; }
    public String getText() { return text; }
    public void setText(String text) { this.text = text; }
    public LsasSituationGroup getSituationGroup() { return situationGroup; }
    public void setSituationGroup(LsasSituationGroup situationGroup) { this.situationGroup = situationGroup; }
}
