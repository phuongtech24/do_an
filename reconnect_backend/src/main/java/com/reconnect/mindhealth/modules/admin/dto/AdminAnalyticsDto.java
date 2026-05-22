package com.reconnect.mindhealth.modules.admin.dto;

public class AdminAnalyticsDto {
    private long totalPatients;
    private long activePatients;
    private long redFlagPatients;
    private long graduatedPatients;
    private double graduationRate;

    private long totalTherapists;
    private long pendingTherapists;

    private long totalAppointments;

    public long getTotalPatients() {
        return totalPatients;
    }

    public void setTotalPatients(long totalPatients) {
        this.totalPatients = totalPatients;
    }

    public long getActivePatients() {
        return activePatients;
    }

    public void setActivePatients(long activePatients) {
        this.activePatients = activePatients;
    }

    public long getRedFlagPatients() {
        return redFlagPatients;
    }

    public void setRedFlagPatients(long redFlagPatients) {
        this.redFlagPatients = redFlagPatients;
    }

    public long getGraduatedPatients() {
        return graduatedPatients;
    }

    public void setGraduatedPatients(long graduatedPatients) {
        this.graduatedPatients = graduatedPatients;
    }

    public double getGraduationRate() {
        return graduationRate;
    }

    public void setGraduationRate(double graduationRate) {
        this.graduationRate = graduationRate;
    }

    public long getTotalTherapists() {
        return totalTherapists;
    }

    public void setTotalTherapists(long totalTherapists) {
        this.totalTherapists = totalTherapists;
    }

    public long getPendingTherapists() {
        return pendingTherapists;
    }

    public void setPendingTherapists(long pendingTherapists) {
        this.pendingTherapists = pendingTherapists;
    }

    public long getTotalAppointments() {
        return totalAppointments;
    }

    public void setTotalAppointments(long totalAppointments) {
        this.totalAppointments = totalAppointments;
    }
}

