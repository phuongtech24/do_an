package com.reconnect.mindhealth.modules.guest.entity;

import java.time.LocalDateTime;

import com.reconnect.mindhealth.common.domain.BaseObject;
import com.reconnect.mindhealth.modules.auth.entity.User;

import jakarta.persistence.AttributeOverride;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.MapsId;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "guest_profiles")
@AttributeOverride(name = "id", column = @Column(name = "user_id"))
public class GuestProfile extends BaseObject {

    @OneToOne
    @MapsId
    @JoinColumn(name = "user_id")
    private User user;

    @Column(name = "nickname")
    private String nickname;

    @Column(name = "avatar_icon")
    private String avatarIcon = "avatar_cat";

    @Column(name = "lsas_demo_completed")
    private Boolean lsasDemoCompleted = false;

    @Column(name = "pending_lsas_answers_json", columnDefinition = "LONGTEXT")
    private String pendingLsasAnswersJson;

    @Column(name = "pending_lsas_total_score")
    private Integer pendingLsasTotalScore;

    @Column(name = "pending_lsas_submission_type")
    private String pendingLsasSubmissionType;

    @Column(name = "pending_lsas_completed_at")
    private LocalDateTime pendingLsasCompletedAt;

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public String getNickname() {
        return nickname;
    }

    public void setNickname(String nickname) {
        this.nickname = nickname;
    }

    public String getAvatarIcon() {
        return avatarIcon;
    }

    public void setAvatarIcon(String avatarIcon) {
        this.avatarIcon = avatarIcon;
    }

    public Boolean getLsasDemoCompleted() {
        return lsasDemoCompleted;
    }

    public void setLsasDemoCompleted(Boolean lsasDemoCompleted) {
        this.lsasDemoCompleted = lsasDemoCompleted;
    }

    public String getPendingLsasAnswersJson() {
        return pendingLsasAnswersJson;
    }

    public void setPendingLsasAnswersJson(String pendingLsasAnswersJson) {
        this.pendingLsasAnswersJson = pendingLsasAnswersJson;
    }

    public Integer getPendingLsasTotalScore() {
        return pendingLsasTotalScore;
    }

    public void setPendingLsasTotalScore(Integer pendingLsasTotalScore) {
        this.pendingLsasTotalScore = pendingLsasTotalScore;
    }

    public String getPendingLsasSubmissionType() {
        return pendingLsasSubmissionType;
    }

    public void setPendingLsasSubmissionType(String pendingLsasSubmissionType) {
        this.pendingLsasSubmissionType = pendingLsasSubmissionType;
    }

    public LocalDateTime getPendingLsasCompletedAt() {
        return pendingLsasCompletedAt;
    }

    public void setPendingLsasCompletedAt(LocalDateTime pendingLsasCompletedAt) {
        this.pendingLsasCompletedAt = pendingLsasCompletedAt;
    }
}
