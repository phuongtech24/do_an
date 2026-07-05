package com.reconnect.mindhealth.modules.roadmap.dto;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class RoadmapProgramStateDto {
    private Integer programWeek;
    private String programPhaseCode;
    private String programPhaseLabel;
    private String nextRecommendedIntervention;
    private LocalDateTime therapyProgramStartedAt;
    private LocalDateTime weekStartDate;
    private LocalDateTime weekEndDate;
    private LocalDateTime nextRerateAt;
    private List<RoadmapProgramModuleDto> unlockedModules = new ArrayList<>();
    private List<RoadmapProgramModuleDto> lockedModules = new ArrayList<>();

    public Integer getProgramWeek() { return programWeek; }
    public void setProgramWeek(Integer programWeek) { this.programWeek = programWeek; }
    public String getProgramPhaseCode() { return programPhaseCode; }
    public void setProgramPhaseCode(String programPhaseCode) { this.programPhaseCode = programPhaseCode; }
    public String getProgramPhaseLabel() { return programPhaseLabel; }
    public void setProgramPhaseLabel(String programPhaseLabel) { this.programPhaseLabel = programPhaseLabel; }
    public String getNextRecommendedIntervention() { return nextRecommendedIntervention; }
    public void setNextRecommendedIntervention(String nextRecommendedIntervention) { this.nextRecommendedIntervention = nextRecommendedIntervention; }
    public LocalDateTime getTherapyProgramStartedAt() { return therapyProgramStartedAt; }
    public void setTherapyProgramStartedAt(LocalDateTime therapyProgramStartedAt) { this.therapyProgramStartedAt = therapyProgramStartedAt; }
    public LocalDateTime getWeekStartDate() { return weekStartDate; }
    public void setWeekStartDate(LocalDateTime weekStartDate) { this.weekStartDate = weekStartDate; }
    public LocalDateTime getWeekEndDate() { return weekEndDate; }
    public void setWeekEndDate(LocalDateTime weekEndDate) { this.weekEndDate = weekEndDate; }
    public LocalDateTime getNextRerateAt() { return nextRerateAt; }
    public void setNextRerateAt(LocalDateTime nextRerateAt) { this.nextRerateAt = nextRerateAt; }
    public List<RoadmapProgramModuleDto> getUnlockedModules() { return unlockedModules; }
    public void setUnlockedModules(List<RoadmapProgramModuleDto> unlockedModules) { this.unlockedModules = unlockedModules; }
    public List<RoadmapProgramModuleDto> getLockedModules() { return lockedModules; }
    public void setLockedModules(List<RoadmapProgramModuleDto> lockedModules) { this.lockedModules = lockedModules; }
}
