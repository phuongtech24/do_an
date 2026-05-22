package com.reconnect.mindhealth.modules.clinical.entity;

import java.util.List;
import java.util.UUID;

import com.reconnect.mindhealth.common.domain.BaseObject;
import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.clinical.enums.ApprovalStatus;

import jakarta.persistence.AttributeOverride;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.MapsId;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "therapist_profiles")
@AttributeOverride(name = "id",column = @Column(name ="user_id"))
public class TherapistProfile extends BaseObject {

    @Column(name = "full_name", nullable = false)
    private String fullName;

    @Column(name = "specialization")
    private String specialization;

    @Column(name = "bio", columnDefinition = "TEXT")
    private String bio;

    @Column(name = "meeting_link")
    private String meetingLink;

    @Enumerated(EnumType.STRING)
    @Column(name = "approval_status")
    private ApprovalStatus approvalStatus = ApprovalStatus.PENDING;

    @OneToOne
    @MapsId
    @JoinColumn(name = "user_id")
    private User user;


    @OneToMany(mappedBy = "therapist")
    private List<PatientProfile> patients;


    public String getFullName() {
        return fullName;
    }


    public void setFullName(String fullName) {
        this.fullName = fullName;
    }


    public String getSpecialization() {
        return specialization;
    }


    public void setSpecialization(String specialization) {
        this.specialization = specialization;
    }


    public String getBio() {
        return bio;
    }


    public void setBio(String bio) {
        this.bio = bio;
    }


    public String getMeetingLink() {
        return meetingLink;
    }


    public void setMeetingLink(String meetingLink) {
        this.meetingLink = meetingLink;
    }

    public ApprovalStatus getApprovalStatus() {
        return approvalStatus;
    }

    public void setApprovalStatus(ApprovalStatus approvalStatus) {
        this.approvalStatus = approvalStatus;
    }


    public User getUser() {
        return user;
    }


    public void setUser(User user) {
        this.user = user;
    }


    public List<PatientProfile> getPatients() {
        return patients;
    }


    public void setPatients(List<PatientProfile> patients) {
        this.patients = patients;
    }


    public TherapistProfile() {
    }


    public TherapistProfile(String fullName, String specialization, String bio, String meetingLink, User user,
            List<PatientProfile> patients) {
        this.fullName = fullName;
        this.specialization = specialization;
        this.bio = bio;
        this.meetingLink = meetingLink;
        this.user = user;
        this.patients = patients;
    }

    
}
