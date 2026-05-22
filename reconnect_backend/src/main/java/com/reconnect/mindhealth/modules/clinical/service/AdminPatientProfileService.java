package com.reconnect.mindhealth.modules.clinical.service;

import java.util.Comparator;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.reconnect.mindhealth.common.security.AuthContextService;
import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.auth.enums.Role;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;

@Service
public class AdminPatientProfileService {

    private final AuthContextService authContextService;
    private final PatientProfileRepository patientProfileRepository;

    public AdminPatientProfileService(
            AuthContextService authContextService,
            PatientProfileRepository patientProfileRepository) {
        this.authContextService = authContextService;
        this.patientProfileRepository = patientProfileRepository;
    }

    @Transactional(readOnly = true)
    public List<PatientProfile> listPatients(boolean redFlagOnly, String q) {
        User current = authContextService.requireCurrentUser();
        if (current.getRole() != Role.ADMIN) {
            throw new SecurityException("Forbidden: ADMIN role required.");
        }

        List<PatientProfile> list = redFlagOnly
                ? patientProfileRepository.findByIsRedFlagActiveTrueOrderByCurrentRiskScoreDesc()
                : patientProfileRepository.findByIsActiveTrue();

        String query = q == null ? "" : q.trim().toLowerCase();
        if (!query.isEmpty()) {
            list = list.stream().filter(p -> {
                String nickname = p.getNickName() != null ? p.getNickName().toLowerCase() : "";
                String email = p.getUser() != null && p.getUser().getEmail() != null ? p.getUser().getEmail().toLowerCase() : "";
                String therapistName = p.getTherapist() != null && p.getTherapist().getFullName() != null
                        ? p.getTherapist().getFullName().toLowerCase()
                        : "";
                return nickname.contains(query) || email.contains(query) || therapistName.contains(query);
            }).toList();
        }

        return list.stream()
                .sorted(Comparator.comparing((PatientProfile p) -> p.getCurrentRiskScore() != null ? p.getCurrentRiskScore() : 0).reversed())
                .toList();
    }
}

