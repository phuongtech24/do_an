package com.reconnect.mindhealth.modules.admin.dto;

public class AdminDemoControlProgressRequestDto {
    private Integer programWeek;
    private Integer masteredCount;

    public Integer getProgramWeek() {
        return programWeek;
    }

    public void setProgramWeek(Integer programWeek) {
        this.programWeek = programWeek;
    }

    public Integer getMasteredCount() {
        return masteredCount;
    }

    public void setMasteredCount(Integer masteredCount) {
        this.masteredCount = masteredCount;
    }
}
