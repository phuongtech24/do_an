package com.reconnect.mindhealth.modules.assessment.dto;

import java.util.Date;
import java.util.UUID;

import com.reconnect.mindhealth.common.dto.BaseObjectDto;
import com.reconnect.mindhealth.modules.assessment.entity.UserMood;

public class UserMoodDto extends BaseObjectDto {
    private UUID patientId;
    private Integer moodScore; // Flutter gửi lên (0-100)
    private String dailyAgenda; // Flutter gửi lên

    public UserMoodDto() {
    }

    public UserMoodDto(UserMood entity) {
        if (entity != null) {
            this.setId(entity.getId());
            this.setCreateDate(entity.getCreateDate());
            this.setVoided(entity.getVoided());

            this.setMoodScore(entity.getMoodScore());
            this.setDailyAgenda(entity.getDailyAgenda());

        }
    }

    public UUID getPatientId() {
        return patientId;
    }

    public void setPatientId(UUID patientId) {
        this.patientId = patientId;
    }

    public Integer getMoodScore() {
        return moodScore;
    }

    public void setMoodScore(Integer moodScore) {
        this.moodScore = moodScore;
    }

    public String getDailyAgenda() {
        return dailyAgenda;
    }

    public void setDailyAgenda(String dailyAgenda) {
        this.dailyAgenda = dailyAgenda;
    }

}
