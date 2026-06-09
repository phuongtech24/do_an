package com.reconnect.mindhealth.modules.booster.service.impl;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.reconnect.mindhealth.modules.booster.entity.Appointment;
import com.reconnect.mindhealth.modules.booster.enums.AppointmentPurpose;
import com.reconnect.mindhealth.modules.booster.repository.AppointmentRepository;
import com.reconnect.mindhealth.modules.booster.service.ITaperingBoosterSchedulingService;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.enums.TaperingStage;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;

@Service
@Transactional
public class TaperingBoosterSchedulingServiceImpl implements ITaperingBoosterSchedulingService {

    private static final Logger log = LoggerFactory.getLogger(TaperingBoosterSchedulingServiceImpl.class);

    private static final LocalTime DEFAULT_START_TIME = LocalTime.of(10, 0);

    private final PatientProfileRepository patientProfileRepository;
    private final AppointmentRepository appointmentRepository;

    public TaperingBoosterSchedulingServiceImpl(PatientProfileRepository patientProfileRepository,
            AppointmentRepository appointmentRepository) {
        this.patientProfileRepository = patientProfileRepository;
        this.appointmentRepository = appointmentRepository;
    }

    @Override
    public int runDailyScheduling() {
        List<PatientProfile> active = patientProfileRepository.findByIsActiveTrue();
        int created = 0;

        for (PatientProfile p : active) {
            try {
                created += scheduleForPatient(p);
            } catch (Exception e) {
                log.warn("Scheduling failed for patient {}: {}", p.getId(), e.getMessage());
            }
        }
        return created;
    }

    private int scheduleForPatient(PatientProfile patient) {
        if (patient.getTherapist() == null) {
            return 0;
        }

        LocalDateTime now = LocalDateTime.now();

        int created = 0;

        if (patient.getGraduatedAt() == null) {
            if (patient.getTaperingStage() == null || patient.getTaperingStage() == TaperingStage.NONE) {
                return 0;
            }
            created += ensureNextTaperingAppointment(patient, now);
        } else {
            created += ensureBooster(patient, AppointmentPurpose.BOOSTER_3M, patient.getGraduatedAt().plusMonths(3), now);
            created += ensureBooster(patient, AppointmentPurpose.BOOSTER_6M, patient.getGraduatedAt().plusMonths(6), now);
            created += ensureBooster(patient, AppointmentPurpose.BOOSTER_12M, patient.getGraduatedAt().plusMonths(12), now);
        }

        return created;
    }

    private int ensureNextTaperingAppointment(PatientProfile patient, LocalDateTime now) {
        int intervalDays = switch (patient.getTaperingStage()) {
            case WEEKLY -> 7;
            case MONTHLY -> 14;
            case QUARTERLY -> 28;
            default -> 0;
        };
        if (intervalDays <= 0) {
            return 0;
        }

        Appointment last = appointmentRepository.findTopByPatientProfile_IdAndPurposeOrderByStartAtDesc(patient.getId(),
                AppointmentPurpose.TAPERING);

        LocalDateTime base = last != null && last.getStartAt() != null ? last.getStartAt() : now;
        LocalDateTime nextStart = base.plusDays(intervalDays)
                .withHour(DEFAULT_START_TIME.getHour())
                .withMinute(DEFAULT_START_TIME.getMinute())
                .withSecond(0)
                .withNano(0);

        // Only create if it's in the future (avoid backfilling too many)
        if (!nextStart.isAfter(now)) {
            nextStart = now.plusDays(1)
                    .withHour(DEFAULT_START_TIME.getHour())
                    .withMinute(DEFAULT_START_TIME.getMinute())
                    .withSecond(0)
                    .withNano(0);
        }

        if (appointmentRepository.existsByPatientProfile_IdAndPurposeAndStartAt(patient.getId(), AppointmentPurpose.TAPERING,
                nextStart)) {
            return 0;
        }
        if (appointmentRepository.existsByTherapistProfile_IdAndStartAt(patient.getTherapist().getId(), nextStart)) {
            return 0;
        }

        Appointment appt = new Appointment();
        appt.setPatientProfile(patient);
        appt.setTherapistProfile(patient.getTherapist());
        appt.setStartAt(nextStart);
        appt.setEndAt(nextStart.plusMinutes(30));
        appt.setIsAnonymous(true);
        appt.setMeetingLink(patient.getTherapist().getMeetingLink());
        appt.setPurpose(AppointmentPurpose.TAPERING);
        appt.setClinicalPurposeCode(AppointmentPurpose.TAPERING.name());
        appt.setCarePhaseCode(mapTaperingPhaseCode(patient.getTaperingStage()));
        appointmentRepository.save(appt);
        return 1;
    }

    private int ensureBooster(PatientProfile patient, AppointmentPurpose purpose, LocalDateTime boosterAt,
            LocalDateTime now) {
        LocalDateTime startAt = boosterAt
                .withHour(DEFAULT_START_TIME.getHour())
                .withMinute(DEFAULT_START_TIME.getMinute())
                .withSecond(0)
                .withNano(0);

        // Create only when boosterAt is within next 30 days and still in the future.
        if (!startAt.isAfter(now)) {
            return 0;
        }
        if (startAt.isAfter(now.plusDays(30))) {
            return 0;
        }

        if (appointmentRepository.existsByPatientProfile_IdAndPurposeAndStartAt(patient.getId(), purpose, startAt)) {
            return 0;
        }
        if (appointmentRepository.existsByTherapistProfile_IdAndStartAt(patient.getTherapist().getId(), startAt)) {
            return 0;
        }

        Appointment appt = new Appointment();
        appt.setPatientProfile(patient);
        appt.setTherapistProfile(patient.getTherapist());
        appt.setStartAt(startAt);
        appt.setEndAt(startAt.plusMinutes(30));
        appt.setIsAnonymous(true);
        appt.setMeetingLink(patient.getTherapist().getMeetingLink());
        appt.setPurpose(purpose);
        appt.setClinicalPurposeCode(purpose.name());
        appt.setCarePhaseCode("MAINTENANCE");
        appointmentRepository.save(appt);
        return 1;
    }

    private String mapTaperingPhaseCode(TaperingStage taperingStage) {
        return switch (taperingStage) {
            case WEEKLY -> "STANDARD_WEEKLY";
            case MONTHLY -> "TAPERING_BIWEEKLY";
            case QUARTERLY -> "TAPERING_3_TO_4_WEEKS";
            default -> "STANDARD_WEEKLY";
        };
    }
}
