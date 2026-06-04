package com.reconnect.mindhealth.modules.assessment.entity;

import com.reconnect.mindhealth.common.domain.BaseObject;
import com.reconnect.mindhealth.modules.assessment.enums.LsasSituationGroup;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Table;

@Entity
@Table(name = "lsas_situations")
public class LsasSituation extends BaseObject {

    @Column(name = "situation_number", nullable = false, unique = true)
    private Integer situationNumber;

    @Column(name = "text", nullable = false, length = 1000)
    private String text;

    @Enumerated(EnumType.STRING)
    @Column(name = "situation_group", nullable = false)
    private LsasSituationGroup situationGroup;

    public Integer getSituationNumber() {
        return situationNumber;
    }

    public void setSituationNumber(Integer situationNumber) {
        this.situationNumber = situationNumber;
    }

    public String getText() {
        return text;
    }

    public void setText(String text) {
        this.text = text;
    }

    public LsasSituationGroup getSituationGroup() {
        return situationGroup;
    }

    public void setSituationGroup(LsasSituationGroup situationGroup) {
        this.situationGroup = situationGroup;
    }
}
