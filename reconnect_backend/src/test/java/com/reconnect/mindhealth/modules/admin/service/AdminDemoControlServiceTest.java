package com.reconnect.mindhealth.modules.admin.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.reconnect.mindhealth.modules.admin.dto.AdminDemoControlResultDto;
import com.reconnect.mindhealth.modules.assessment.repository.UserMoodRepository;
import com.reconnect.mindhealth.modules.booster.repository.AppointmentRepository;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.enums.TaperingStage;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;
import com.reconnect.mindhealth.modules.clinical.service.ClinicalTriageService;
import com.reconnect.mindhealth.modules.journal.service.IJournalService;
import com.reconnect.mindhealth.modules.risk.entity.DailyRiskLog;
import com.reconnect.mindhealth.modules.risk.repository.DailyRiskLogRepository;
import com.reconnect.mindhealth.modules.roadmap.entity.FearLadderItem;
import com.reconnect.mindhealth.modules.roadmap.entity.PatientQuest;
import com.reconnect.mindhealth.modules.roadmap.enums.FearLadderStatus;
import com.reconnect.mindhealth.modules.roadmap.repository.BehavioralExperimentRepository;
import com.reconnect.mindhealth.modules.roadmap.repository.FearLadderItemRepository;
import com.reconnect.mindhealth.modules.roadmap.service.RoadmapDailyAssignmentService;
import com.reconnect.mindhealth.modules.roadmap.service.RoadmapProgramStateService;
import com.reconnect.mindhealth.modules.roadmap.service.RoadmapProgramStateService.ProgramPhase;

@ExtendWith(MockitoExtension.class)
class AdminDemoControlServiceTest {

    @Mock
    private PatientProfileRepository patientProfileRepository;
    @Mock
    private DailyRiskLogRepository dailyRiskLogRepository;
    @Mock
    private RoadmapDailyAssignmentService roadmapDailyAssignmentService;
    @Mock
    private UserMoodRepository userMoodRepository;
    @Mock
    private IJournalService journalService;
    @Mock
    private AppointmentRepository appointmentRepository;
    @Mock
    private ClinicalTriageService clinicalTriageService;
    @Mock
    private FearLadderItemRepository fearLadderItemRepository;
    @Mock
    private BehavioralExperimentRepository behavioralExperimentRepository;
    @Mock
    private RoadmapProgramStateService roadmapProgramStateService;

    @InjectMocks
    private AdminDemoControlService adminDemoControlService;

    @Test
    void setProgramWeek_updatesProgramWeek_andClearsGraduationState() {
        UUID patientId = UUID.randomUUID();
        PatientProfile patient = new PatientProfile();
        patient.setId(patientId);
        patient.setGraduatedAt(LocalDateTime.now());
        patient.setTaperingStage(TaperingStage.MONTHLY);
        patient.setCurrentLsasScore(72);

        when(patientProfileRepository.findById(patientId)).thenReturn(Optional.of(patient));
        when(patientProfileRepository.save(any(PatientProfile.class))).thenAnswer(invocation -> invocation.getArgument(0));
        when(fearLadderItemRepository.findByPatientProfile_IdOrderByLadderOrderAsc(patientId)).thenReturn(List.of());
        when(roadmapProgramStateService.resolveProgramWeek(any(PatientProfile.class))).thenReturn(12);
        when(roadmapProgramStateService.resolvePhase(anyInt()))
                .thenReturn(new ProgramPhase("DEEP_COGNITIVE_MEMORY", "Tuần 9-14"));

        AdminDemoControlResultDto result = adminDemoControlService.setProgramWeek(patientId, 12, UUID.randomUUID());

        assertEquals(12, patient.getCurrentProgramWeek());
        assertEquals(TaperingStage.NONE, patient.getTaperingStage());
        assertEquals(12, result.getProgramWeek());
        assertFalse(result.getGraduationReady());
        verify(behavioralExperimentRepository).deleteByPatientProfile_Id(patientId);
    }

    @Test
    void setLsasBand_selfHelp_doesNotOpenTriage() {
        UUID patientId = UUID.randomUUID();
        PatientProfile patient = new PatientProfile();
        patient.setId(patientId);
        patient.setCurrentLsasScore(72);

        when(patientProfileRepository.findById(patientId)).thenReturn(Optional.of(patient));
        when(patientProfileRepository.save(any(PatientProfile.class))).thenAnswer(invocation -> invocation.getArgument(0));
        when(dailyRiskLogRepository.findByPatientProfile_IdAndRiskDate(eq(patientId), any(LocalDate.class)))
                .thenReturn(Optional.of(new DailyRiskLog()));
        when(fearLadderItemRepository.findByPatientProfile_IdOrderByLadderOrderAsc(patientId)).thenReturn(List.of());
        when(roadmapProgramStateService.resolveProgramWeek(any(PatientProfile.class))).thenReturn(6);
        when(roadmapProgramStateService.resolvePhase(anyInt()))
                .thenReturn(new ProgramPhase("MAP_AND_BELIEF_BREAK", "Tuần 1-3"));

        AdminDemoControlResultDto result = adminDemoControlService.setLsasBand(patientId, "SELF_HELP", UUID.randomUUID());

        assertEquals(45, patient.getCurrentLsasScore());
        assertFalse(Boolean.TRUE.equals(patient.getTriageRequired()));
        assertEquals("SET_LSAS_BAND", result.getAction());
        verify(clinicalTriageService, never()).openUrgentTriage(any(PatientProfile.class));
        verify(dailyRiskLogRepository).save(any(DailyRiskLog.class));
    }

    @Test
    void setFearLadderMastery_marksLeadingItemsMastered() {
        UUID patientId = UUID.randomUUID();
        PatientProfile patient = new PatientProfile();
        patient.setId(patientId);

        FearLadderItem item1 = new FearLadderItem();
        item1.setLadderOrder(1);
        FearLadderItem item2 = new FearLadderItem();
        item2.setLadderOrder(2);
        FearLadderItem item3 = new FearLadderItem();
        item3.setLadderOrder(3);

        when(patientProfileRepository.findById(patientId)).thenReturn(Optional.of(patient));
        when(fearLadderItemRepository.findByPatientProfile_IdOrderByLadderOrderAsc(patientId))
                .thenReturn(List.of(item1, item2, item3));
        when(roadmapProgramStateService.resolveProgramWeek(any(PatientProfile.class))).thenReturn(10);
        when(roadmapProgramStateService.resolvePhase(anyInt()))
                .thenReturn(new ProgramPhase("DEEP_COGNITIVE_MEMORY", "Tuần 9-14"));

        AdminDemoControlResultDto result =
                adminDemoControlService.setFearLadderMastery(patientId, 2, UUID.randomUUID());

        assertEquals(FearLadderStatus.MASTERED, item1.getStatus());
        assertEquals(FearLadderStatus.MASTERED, item2.getStatus());
        assertEquals(FearLadderStatus.ACTIVE, item3.getStatus());
        assertEquals(3, result.getFearLadderUnlockedCount());
        assertEquals(2, result.getFearLadderMasteredCount());
        assertFalse(result.getGraduationReady());
        verify(fearLadderItemRepository).saveAll(any());
        verify(behavioralExperimentRepository).deleteByPatientProfile_Id(patientId);
    }

    @Test
    void unlockAllRoadmapContent_setsWeek14_andMastersEntireLadder() {
        UUID patientId = UUID.randomUUID();
        PatientProfile patient = new PatientProfile();
        patient.setId(patientId);
        patient.setTaperingStage(TaperingStage.QUARTERLY);
        patient.setGraduatedAt(LocalDateTime.now());

        FearLadderItem item1 = new FearLadderItem();
        item1.setLadderOrder(1);
        FearLadderItem item2 = new FearLadderItem();
        item2.setLadderOrder(2);

        when(patientProfileRepository.findById(patientId)).thenReturn(Optional.of(patient));
        when(patientProfileRepository.save(any(PatientProfile.class))).thenAnswer(invocation -> invocation.getArgument(0));
        when(fearLadderItemRepository.findByPatientProfile_IdOrderByLadderOrderAsc(patientId))
                .thenReturn(List.of(item1, item2));
        when(roadmapDailyAssignmentService.ensureDailySystemQuests(any(PatientProfile.class), any(LocalDate.class)))
                .thenReturn(List.of(new PatientQuest()));
        when(roadmapProgramStateService.resolveProgramWeek(any(PatientProfile.class))).thenReturn(14);
        when(roadmapProgramStateService.resolvePhase(anyInt()))
                .thenReturn(new ProgramPhase("DEEP_COGNITIVE_MEMORY", "Tuần 9-14"));

        AdminDemoControlResultDto result =
                adminDemoControlService.unlockAllRoadmapContent(patientId, UUID.randomUUID());

        assertEquals(14, patient.getCurrentProgramWeek());
        assertEquals(TaperingStage.NONE, patient.getTaperingStage());
        assertEquals(FearLadderStatus.MASTERED, item1.getStatus());
        assertEquals(FearLadderStatus.MASTERED, item2.getStatus());
        assertEquals("UNLOCK_ALL_ROADMAP_CONTENT", result.getAction());
        assertEquals(2, result.getFearLadderMasteredCount());
        assertTrue(Boolean.TRUE.equals(result.getGraduationReady()));
        assertEquals(1, result.getCreatedQuests());
        verify(fearLadderItemRepository).saveAll(any());
        verify(behavioralExperimentRepository).deleteByPatientProfile_Id(patientId);
    }
}
