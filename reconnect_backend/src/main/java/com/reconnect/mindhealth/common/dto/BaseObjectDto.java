package com.reconnect.mindhealth.common.dto;
import java.io.Serializable;
import java.util.Date;
import java.util.UUID;
public abstract class BaseObjectDto implements Serializable  {
    private UUID id;
    private Date createDate;
    private String createdBy;
    private Date modifyDate;
    private String modifiedBy;
    private Boolean voided;

    public BaseObjectDto(UUID id, Date createDate, String createdBy, Date modifyDate, String modifiedBy,
            Boolean voided) {
        this.id = id;
        this.createDate = createDate;
        this.createdBy = createdBy;
        this.modifyDate = modifyDate;
        this.modifiedBy = modifiedBy;
        this.voided = voided;
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

    public BaseObjectDto() {
    }
    
}
