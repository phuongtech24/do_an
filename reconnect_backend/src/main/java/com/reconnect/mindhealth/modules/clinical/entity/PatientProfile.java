package com.reconnect.mindhealth.modules.clinical.entity;

import java.time.LocalDate;
import java.util.UUID;

import com.reconnect.mindhealth.common.domain.BaseObject;
import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.clinical.enums.Status;
import com.reconnect.mindhealth.modules.clinical.enums.TaperingStage;

import jakarta.persistence.AttributeOverride;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.MapsId;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "patient_profiles")
@AttributeOverride(name = "id",column = @Column(name ="user_id"))
public class PatientProfile extends BaseObject {

    @OneToOne
    @MapsId
    @JoinColumn(name = "user_id")
    private User user;

    @ManyToOne
    @JoinColumn(name = "therapist_id")
    private TherapistProfile therapist;

    @Column(name = "nickname", unique = true)
    private String nickName = "";

    @Enumerated(EnumType.STRING)
    @Column(name = "status")
    private Status status = Status.STABLE;

    @Column(name = "cognitive_map", columnDefinition = "json")
    private String cognitiveMap;

    @Column(name = "avatar_icon")
    private String avatarIcon = "default_avatar";

    @Column(name = "anonymous_mode_enabled")
    private Boolean anonymousModeEnabled = true;

    @Column(name = "real_full_name")
    private String realFullName;

    @Column(name = "date_of_birth")
    private LocalDate dateOfBirth;

    @Column(name = "gender")
    private String gender;

    @Column(name = "phone_number")
    private String phoneNumber;

    @Column(name = "emergency_contact_phone")
    private String emergencyContactPhone;

    @Column(name = "education_level")
    private String educationLevel;

    @Column(name = "occupation")
    private String occupation;

    @Column(name = "relationship_status")
    private String relationshipStatus;

    @Column(name = "medical_history", columnDefinition = "TEXT")
    private String medicalHistory;

    @Column(name = "lsas_demo_completed")
    private Boolean lsasDemoCompleted = false;

    @Column(name = "safety_gate_completed")
    private Boolean safetyGateCompleted = false;

    @Column(name = "medical_profile_completed")
    private Boolean medicalProfileCompleted = false;

    @Column(name = "goals_json", columnDefinition = "json")
    private String goalsJson;

    @Enumerated(EnumType.STRING)
    @Column(name = "tapering_stage")
    private TaperingStage taperingStage = TaperingStage.NONE;

    @Column(name = "current_risk_score")
    private Integer currentRiskScore = 0;

    @Column(name = "is_red_flag_active")
    private Boolean isRedFlagActive = false;

    @Column(name = "last_lsas_date")
    private java.time.LocalDateTime lastLsasDate;

    @Column(name = "current_lsas_score")
    private Integer currentLsasScore = 0;

    @Column(name = "current_cycle_start_date")
    private java.time.LocalDateTime currentCycleStartDate;

    @Column(name = "graduated_at")
    private java.time.LocalDateTime graduatedAt;

    @Column(name = "psychoeducation_completed")
    private Boolean psychoeducationCompleted = false;

    @Column(name = "psychoeducation_completed_at")
    private java.time.LocalDateTime psychoeducationCompletedAt;

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public TherapistProfile getTherapist() {
        return therapist;
    }

    public void setTherapist(TherapistProfile therapist) {
        this.therapist = therapist;
    }

    public String getNickName() {
        return nickName;
    }

    public void setNickName(String nickName) {
        this.nickName = nickName;
    }

    public Status getStatus() {
        return status;
    }

    public void setStatus(Status status) {
        this.status = status;
    }

    public String getCognitiveMap() {
        return cognitiveMap;
    }

    public void setCognitiveMap(String cognitiveMap) {
        this.cognitiveMap = cognitiveMap;
    }

    public String getAvatarIcon() {
        return avatarIcon;
    }

    public void setAvatarIcon(String avatarIcon) {
        this.avatarIcon = avatarIcon;
    }

    public Boolean getAnonymousModeEnabled() {
        return anonymousModeEnabled;
    }

    public void setAnonymousModeEnabled(Boolean anonymousModeEnabled) {
        this.anonymousModeEnabled = anonymousModeEnabled;
    }

    public String getRealFullName() {
        return realFullName;
    }

    public void setRealFullName(String realFullName) {
        this.realFullName = realFullName;
    }

    public LocalDate getDateOfBirth() {
        return dateOfBirth;
    }

    public void setDateOfBirth(LocalDate dateOfBirth) {
        this.dateOfBirth = dateOfBirth;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getEmergencyContactPhone() {
        return emergencyContactPhone;
    }

    public void setEmergencyContactPhone(String emergencyContactPhone) {
        this.emergencyContactPhone = emergencyContactPhone;
    }

    public String getEducationLevel() {
        return educationLevel;
    }

    public void setEducationLevel(String educationLevel) {
        this.educationLevel = educationLevel;
    }

    public String getOccupation() {
        return occupation;
    }

    public void setOccupation(String occupation) {
        this.occupation = occupation;
    }

    public String getRelationshipStatus() {
        return relationshipStatus;
    }

    public void setRelationshipStatus(String relationshipStatus) {
        this.relationshipStatus = relationshipStatus;
    }

    public String getMedicalHistory() {
        return medicalHistory;
    }

    public void setMedicalHistory(String medicalHistory) {
        this.medicalHistory = medicalHistory;
    }

    public Boolean getLsasDemoCompleted() {
        return lsasDemoCompleted;
    }

    public void setLsasDemoCompleted(Boolean lsasDemoCompleted) {
        this.lsasDemoCompleted = lsasDemoCompleted;
    }

    public Boolean getSafetyGateCompleted() {
        return safetyGateCompleted;
    }

    public void setSafetyGateCompleted(Boolean safetyGateCompleted) {
        this.safetyGateCompleted = safetyGateCompleted;
    }

    public Boolean getMedicalProfileCompleted() {
        return medicalProfileCompleted;
    }

    public void setMedicalProfileCompleted(Boolean medicalProfileCompleted) {
        this.medicalProfileCompleted = medicalProfileCompleted;
    }

    public String getGoalsJson() {
        return goalsJson;
    }

    public void setGoalsJson(String goalsJson) {
        this.goalsJson = goalsJson;
    }

    public TaperingStage getTaperingStage() {
        return taperingStage;
    }

    public void setTaperingStage(TaperingStage taperingStage) {
        this.taperingStage = taperingStage;
    }

    public Integer getCurrentRiskScore() {
        return currentRiskScore;
    }

    public void setCurrentRiskScore(Integer currentRiskScore) {
        this.currentRiskScore = currentRiskScore;
    }

    public PatientProfile(User user, TherapistProfile therapist, String nickName, Status status, String cognitiveMap) {
        this.user = user;
        this.therapist = therapist;
        this.nickName = nickName;
        this.status = status;
        this.cognitiveMap = cognitiveMap;
    }

    public PatientProfile() {
    }

    public Boolean getIsRedFlagActive() {
        return isRedFlagActive;
    }

    public void setIsRedFlagActive(Boolean isRedFlagActive) {
        this.isRedFlagActive = isRedFlagActive;
    }

    public java.time.LocalDateTime getLastLsasDate() {
        return lastLsasDate;
    }

    public void setLastLsasDate(java.time.LocalDateTime lastLsasDate) {
        this.lastLsasDate = lastLsasDate;
    }

    public Integer getCurrentLsasScore() {
        return currentLsasScore;
    }

    public void setCurrentLsasScore(Integer currentLsasScore) {
        this.currentLsasScore = currentLsasScore;
    }

    public java.time.LocalDateTime getCurrentCycleStartDate() {
        return currentCycleStartDate;
    }

    public void setCurrentCycleStartDate(java.time.LocalDateTime currentCycleStartDate) {
        this.currentCycleStartDate = currentCycleStartDate;
    }

    public java.time.LocalDateTime getGraduatedAt() {
        return graduatedAt;
    }

    public void setGraduatedAt(java.time.LocalDateTime graduatedAt) {
        this.graduatedAt = graduatedAt;
    }

    public Boolean getPsychoeducationCompleted() {
        return psychoeducationCompleted;
    }

    public void setPsychoeducationCompleted(Boolean psychoeducationCompleted) {
        this.psychoeducationCompleted = psychoeducationCompleted;
    }

    public java.time.LocalDateTime getPsychoeducationCompletedAt() {
        return psychoeducationCompletedAt;
    }

    public void setPsychoeducationCompletedAt(java.time.LocalDateTime psychoeducationCompletedAt) {
        this.psychoeducationCompletedAt = psychoeducationCompletedAt;
    }
}   
