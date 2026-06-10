package com.reconnect.mindhealth.modules.roadmap.entity;

import com.reconnect.mindhealth.common.domain.BaseObject;
import com.reconnect.mindhealth.modules.roadmap.enums.QuestCategory;
import com.reconnect.mindhealth.modules.roadmap.enums.QuestDifficulty;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Table;

@Entity
@Table(name = "quest_templates")
public class QuestTemplate extends BaseObject {

    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "description", nullable = false, columnDefinition = "text")
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(name = "category", nullable = false)
    private QuestCategory category;

    @Enumerated(EnumType.STRING)
    @Column(name = "difficulty", nullable = false)
    private QuestDifficulty difficulty = QuestDifficulty.EASY;

    @Column(name = "module_code")
    private String moduleCode;

    @Column(name = "program_week")
    private Integer programWeek;

    @Column(name = "program_phase_code")
    private String programPhaseCode;

    @Column(name = "intervention_type")
    private String interventionType;

    @Column(name = "prerequisite_codes_json", columnDefinition = "json")
    private String prerequisiteCodesJson;

    @Column(name = "therapist_only_assignable")
    private Boolean therapistOnlyAssignable = false;

    @Column(name = "hard_locked")
    private Boolean hardLocked = false;

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public QuestCategory getCategory() {
        return category;
    }

    public void setCategory(QuestCategory category) {
        this.category = category;
    }

    public QuestDifficulty getDifficulty() {
        return difficulty;
    }

    public void setDifficulty(QuestDifficulty difficulty) {
        this.difficulty = difficulty;
    }

    public String getModuleCode() {
        return moduleCode;
    }

    public void setModuleCode(String moduleCode) {
        this.moduleCode = moduleCode;
    }

    public Integer getProgramWeek() {
        return programWeek;
    }

    public void setProgramWeek(Integer programWeek) {
        this.programWeek = programWeek;
    }

    public String getProgramPhaseCode() {
        return programPhaseCode;
    }

    public void setProgramPhaseCode(String programPhaseCode) {
        this.programPhaseCode = programPhaseCode;
    }

    public String getInterventionType() {
        return interventionType;
    }

    public void setInterventionType(String interventionType) {
        this.interventionType = interventionType;
    }

    public String getPrerequisiteCodesJson() {
        return prerequisiteCodesJson;
    }

    public void setPrerequisiteCodesJson(String prerequisiteCodesJson) {
        this.prerequisiteCodesJson = prerequisiteCodesJson;
    }

    public Boolean getTherapistOnlyAssignable() {
        return therapistOnlyAssignable;
    }

    public void setTherapistOnlyAssignable(Boolean therapistOnlyAssignable) {
        this.therapistOnlyAssignable = therapistOnlyAssignable;
    }

    public Boolean getHardLocked() {
        return hardLocked;
    }

    public void setHardLocked(Boolean hardLocked) {
        this.hardLocked = hardLocked;
    }
}
