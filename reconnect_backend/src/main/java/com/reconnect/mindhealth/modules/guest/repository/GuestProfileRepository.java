package com.reconnect.mindhealth.modules.guest.repository;

import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.reconnect.mindhealth.modules.guest.entity.GuestProfile;

public interface GuestProfileRepository extends JpaRepository<GuestProfile, UUID> {
}
