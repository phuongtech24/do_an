package com.reconnect.mindhealth.modules.roadmap.dto;

import java.time.LocalDateTime;

public class RoadmapProgramModuleDto {
    private String moduleCode;
    private String title;
    private String programPhaseCode;
    private String programPhaseLabel;
    private Integer weekFrom;
    private Integer weekTo;
    private String interventionType;
    private String prerequisiteCodesJson;
    private Boolean hardLocked;
    private Boolean unlocked;
    private String unlockType;
    private String lockReason;
    private Boolean therapistOnlyAssignable;
    private LocalDateTime expectedUnlockAt;

    public String getModuleCode() {
        return moduleCode;
    }

    public void setModuleCode(String moduleCode) {
        this.moduleCode = moduleCode;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getProgramPhaseCode() {
        return programPhaseCode;
    }

    public void setProgramPhaseCode(String programPhaseCode) {
        this.programPhaseCode = programPhaseCode;
    }

    public String getProgramPhaseLabel() {
        return programPhaseLabel;
    }

    public void setProgramPhaseLabel(String programPhaseLabel) {
        this.programPhaseLabel = programPhaseLabel;
    }

    public Integer getWeekFrom() {
        return weekFrom;
    }

    public void setWeekFrom(Integer weekFrom) {
        this.weekFrom = weekFrom;
    }

    public Integer getWeekTo() {
        return weekTo;
    }

    public void setWeekTo(Integer weekTo) {
        this.weekTo = weekTo;
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

    public Boolean getHardLocked() {
        return hardLocked;
    }

    public void setHardLocked(Boolean hardLocked) {
        this.hardLocked = hardLocked;
    }

    public Boolean getUnlocked() {
        return unlocked;
    }

    public void setUnlocked(Boolean unlocked) {
        this.unlocked = unlocked;
    }

    public String getUnlockType() {
        return unlockType;
    }

    public void setUnlockType(String unlockType) {
        this.unlockType = unlockType;
    }

    public String getLockReason() {
        return lockReason;
    }

    public void setLockReason(String lockReason) {
        this.lockReason = lockReason;
    }

    public Boolean getTherapistOnlyAssignable() {
        return therapistOnlyAssignable;
    }

    public void setTherapistOnlyAssignable(Boolean therapistOnlyAssignable) {
        this.therapistOnlyAssignable = therapistOnlyAssignable;
    }

    public LocalDateTime getExpectedUnlockAt() {
        return expectedUnlockAt;
    }

    public void setExpectedUnlockAt(LocalDateTime expectedUnlockAt) {
        this.expectedUnlockAt = expectedUnlockAt;
    }
}
