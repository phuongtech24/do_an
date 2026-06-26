package com.reconnect.mindhealth.modules.auth.dto;

public class EmailVerificationResponseDto {
    private String email;
    private Boolean verificationRequired;
    private Integer expiresInSeconds;
    private String nextStep;

    public EmailVerificationResponseDto() {
    }

    public EmailVerificationResponseDto(String email, Boolean verificationRequired, Integer expiresInSeconds, String nextStep) {
        this.email = email;
        this.verificationRequired = verificationRequired;
        this.expiresInSeconds = expiresInSeconds;
        this.nextStep = nextStep;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public Boolean getVerificationRequired() {
        return verificationRequired;
    }

    public void setVerificationRequired(Boolean verificationRequired) {
        this.verificationRequired = verificationRequired;
    }

    public Integer getExpiresInSeconds() {
        return expiresInSeconds;
    }

    public void setExpiresInSeconds(Integer expiresInSeconds) {
        this.expiresInSeconds = expiresInSeconds;
    }

    public String getNextStep() {
        return nextStep;
    }

    public void setNextStep(String nextStep) {
        this.nextStep = nextStep;
    }
}
