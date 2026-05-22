package com.reconnect.mindhealth.common.domain;

import jakarta.persistence.*;
import java.io.Serializable;
import java.util.Date;
import java.util.UUID;
import org.hibernate.annotations.CreationTimestamp;

@MappedSuperclass
public abstract class BaseObject implements Serializable {
    @Id
    @GeneratedValue(generator = "UUID")
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;
    @Column(name = "create_date")
    private Date createDate;
    @Column(name = "created_by")
    private String createdBy;
    @Column(name = "modify_date")
    private Date modifyDate;
    @Column(name = "modified_by")
    private String modifiedBy;
    @Column(name = "voided")
    private Boolean voided = false;
    @Column(name = "is_active")
    private Boolean isActive = true;
    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private Date createdAt;

    @PrePersist
    protected void onCreate() {
        this.createDate = new Date();
        if (this.createdBy == null) {
            this.createdBy = "system";
        }
        if (this.isActive == null) {
            this.isActive = true;
        }
        if (this.voided == null) {
            this.voided = false;
        }
    }

    @PreUpdate
    protected void onUpdate() {
        this.modifyDate = new Date();
        if (this.modifiedBy == null) {
            this.modifiedBy = "system";
        }
    }

    public UUID getId() {
        return id;
    }
    public void setId(UUID id) {
        this.id = id;
    }
    public Date getCreateDate() {
        return createDate;
    }
    public void setCreateDate(Date createDate) {
        this.createDate = createDate;
    }
    public String getCreatedBy() {
        return createdBy;
    }
    public void setCreatedBy(String createdBy) {
        this.createdBy = createdBy;
    }
    public Date getModifyDate() {
        return modifyDate;
    }
    public void setModifyDate(Date modifyDate) {
        this.modifyDate = modifyDate;
    }
    public String getModifiedBy() {
        return modifiedBy;
    }
    public void setModifiedBy(String modifiedBy) {
        this.modifiedBy = modifiedBy;
    }
    public Boolean getVoided() {
        return voided;
    }
    public void setVoided(Boolean voided) {
        this.voided = voided;
    }
    public Boolean getIsActive() {
        return isActive;
    }
    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }
    public BaseObject() {
    }
    
}
