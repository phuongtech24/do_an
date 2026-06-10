package com.reconnect.mindhealth.modules.roadmap.dto;

import java.util.UUID;

import com.reconnect.mindhealth.common.dto.BaseObjectDto;
import com.reconnect.mindhealth.modules.roadmap.entity.QuestTemplate;
import com.reconnect.mindhealth.modules.roadmap.enums.QuestCategory;
import com.reconnect.mindhealth.modules.roadmap.enums.QuestDifficulty;

public class QuestTemplateDto extends BaseObjectDto {
    private UUID id;
    private String title;
    private String description;
    private QuestCategory category;
    private QuestDifficulty difficulty;
    private String moduleCode;
    private Integer programWeek;
    private String programPhaseCode;
    private String interventionType;
    private String prerequisiteCodesJson;
    private Boolean therapistOnlyAssignable;
    private Boolean hardLocked;

    public QuestTemplateDto() {
    }

    public QuestTemplateDto(QuestTemplate entity) {
        if (entity != null) {
            this.id = entity.getId();
            this.title = entity.getTitle();
            this.description = entity.getDescription();
            this.category = entity.getCategory();
            this.difficulty = entity.getDifficulty();
            this.moduleCode = entity.getModuleCode();
            this.programWeek = entity.getProgramWeek();
            this.programPhaseCode = entity.getProgramPhaseCode();
            this.interventionType = entity.getInterventionType();
            this.prerequisiteCodesJson = entity.getPrerequisiteCodesJson();
            this.therapistOnlyAssignable = entity.getTherapistOnlyAssignable();
            this.hardLocked = entity.getHardLocked();
        }
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

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
