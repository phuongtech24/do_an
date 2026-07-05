package com.reconnect.mindhealth.common.seeder;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.io.ClassPathResource;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import com.reconnect.mindhealth.modules.auth.entity.User;
import com.reconnect.mindhealth.modules.auth.enums.Role;
import com.reconnect.mindhealth.modules.auth.repository.UserRepository;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.entity.TherapistProfile;
import com.reconnect.mindhealth.modules.clinical.enums.ApprovalStatus;
import com.reconnect.mindhealth.modules.clinical.enums.Status;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;
import com.reconnect.mindhealth.modules.clinical.repository.TherapistProfileRepository;

@Component
public class DatabaseSeeder implements CommandLineRunner {

    private static final Logger log = LoggerFactory.getLogger(DatabaseSeeder.class);

    private final UserRepository userRepository;
    private final PatientProfileRepository patientProfileRepository;
    private final TherapistProfileRepository therapistProfileRepository;
    private final PasswordEncoder passwordEncoder;

    public DatabaseSeeder(
            UserRepository userRepository,
            PatientProfileRepository patientProfileRepository,
            TherapistProfileRepository therapistProfileRepository,
            PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.patientProfileRepository = patientProfileRepository;
        this.therapistProfileRepository = therapistProfileRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void run(String... args) {
        try {
            seedUsers();
            seedPatientProfiles();
            seedTherapistProfiles();
        } catch (Exception exception) {
            log.warn("Database seed skipped: {}", exception.getMessage());
        }
    }

    @Transactional
    protected void seedUsers() {
        for (String[] row : readCsv("seed_data/users.csv")) {
            UUID id = UUID.fromString(value(row, 0));
            String email = value(row, 1);
            String username = value(row, 2);
            String rawPassword = value(row, 3);
            Role role = Role.valueOf(value(row, 4));
            boolean isAnonymous = Boolean.parseBoolean(value(row, 5));
            boolean isActive = Boolean.parseBoolean(value(row, 6));

            User user = userRepository.findById(id)
                    .or(() -> userRepository.findByEmail(email))
                    .orElseGet(User::new);

            boolean isNew = user.getId() == null;
            if (isNew) {
                user.setId(id);
                user.setPasswordHash(passwordEncoder.encode(rawPassword));
            }

            user.setEmail(email);
            user.setUsername(username);
            user.setRole(role);
            user.setIsAnonymous(isAnonymous);
            user.setIsActive(isActive);
            userRepository.save(user);
        }
    }

    @Transactional
    protected void seedPatientProfiles() {
        for (String[] row : readCsv("seed_data/patient_profiles.csv")) {
            UUID userId = UUID.fromString(value(row, 0));
            User user = userRepository.findById(userId).orElse(null);
            if (user == null || user.getRole() != Role.PATIENT) {
                continue;
            }

            PatientProfile profile = patientProfileRepository.findById(userId).orElseGet(PatientProfile::new);
            profile.setId(userId);
            profile.setUser(user);
            profile.setNickName(value(row, 1));
            profile.setStatus(parseStatus(value(row, 2)));
            profile.setAvatarIcon(value(row, 3));
            profile.setIsRedFlagActive(Boolean.parseBoolean(value(row, 4)));
            patientProfileRepository.save(profile);
        }
    }

    @Transactional
    protected void seedTherapistProfiles() {
        for (String[] row : readCsv("seed_data/therapist_profiles.csv")) {
            UUID userId = UUID.fromString(value(row, 0));
            User user = userRepository.findById(userId).orElse(null);
            if (user == null || user.getRole() != Role.THERAPIST) {
                continue;
            }

            TherapistProfile profile = therapistProfileRepository.findById(userId).orElseGet(TherapistProfile::new);
            profile.setId(userId);
            profile.setUser(user);
            profile.setFullName(value(row, 1));
            profile.setSpecialization(blankToNull(value(row, 2)));
            profile.setBio(blankToNull(value(row, 3)));
            profile.setMeetingLink(blankToNull(value(row, 4)));
            profile.setApprovalStatus(parseApproval(value(row, 5)));
            profile.setPhoneNumber(blankToNull(value(row, 6)));
            profile.setHometown(blankToNull(value(row, 7)));
            profile.setBirthYear(parseInteger(value(row, 8)));
            profile.setVoiceDescription(blankToNull(value(row, 9)));
            profile.setTherapyStyle(blankToNull(value(row, 10)));
            profile.setAvatarUrl(blankToNull(value(row, 11)));
            therapistProfileRepository.save(profile);
        }
    }

    private List<String[]> readCsv(String classpathLocation) {
        List<String[]> rows = new ArrayList<>();
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(
                new ClassPathResource(classpathLocation).getInputStream(),
                StandardCharsets.UTF_8))) {
            String line;
            boolean headerSkipped = false;
            while ((line = reader.readLine()) != null) {
                if (!headerSkipped) {
                    headerSkipped = true;
                    continue;
                }
                if (line.isBlank()) {
                    continue;
                }
                rows.add(line.split(",", -1));
            }
            return rows;
        } catch (Exception exception) {
            throw new IllegalStateException("Cannot read seed file: " + classpathLocation, exception);
        }
    }

    private String value(String[] row, int index) {
        return index < row.length ? row[index].trim() : "";
    }

    private String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }

    private Integer parseInteger(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return Integer.parseInt(value.trim());
    }

    private Status parseStatus(String value) {
        if (value == null || value.isBlank()) {
            return Status.STABLE;
        }
        return Status.valueOf(value.trim());
    }

    private ApprovalStatus parseApproval(String value) {
        if (value == null || value.isBlank()) {
            return ApprovalStatus.PENDING;
        }
        return ApprovalStatus.valueOf(value.trim());
    }
}
