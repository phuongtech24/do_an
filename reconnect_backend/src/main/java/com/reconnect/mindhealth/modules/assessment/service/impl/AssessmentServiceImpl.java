package com.reconnect.mindhealth.modules.assessment.service.impl;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.reconnect.mindhealth.modules.assessment.dto.LsasAnswerRequestDto;
import com.reconnect.mindhealth.modules.assessment.dto.LsasSituationDto;
import com.reconnect.mindhealth.modules.assessment.dto.LsasSubmissionDto;
import com.reconnect.mindhealth.modules.assessment.dto.UserMoodDto;
import com.reconnect.mindhealth.modules.assessment.entity.LsasAnswer;
import com.reconnect.mindhealth.modules.assessment.entity.LsasSituation;
import com.reconnect.mindhealth.modules.assessment.entity.LsasSubmission;
import com.reconnect.mindhealth.modules.assessment.entity.UserMood;
import com.reconnect.mindhealth.modules.assessment.enums.LsasSubmissionType;
import com.reconnect.mindhealth.modules.assessment.repository.LsasSituationRepository;
import com.reconnect.mindhealth.modules.assessment.repository.LsasSubmissionRepository;
import com.reconnect.mindhealth.modules.assessment.repository.UserMoodRepository;
import com.reconnect.mindhealth.modules.assessment.service.IAssessmentService;
import com.reconnect.mindhealth.modules.clinical.entity.PatientProfile;
import com.reconnect.mindhealth.modules.clinical.repository.PatientProfileRepository;
import com.reconnect.mindhealth.modules.roadmap.service.FearLadderService;

import jakarta.persistence.EntityNotFoundException;

@Service
public class AssessmentServiceImpl implements IAssessmentService {

    private static final Logger log = LoggerFactory.getLogger(AssessmentServiceImpl.class);

    private final LsasSituationRepository lsasSituationRepository;
    private final LsasSubmissionRepository lsasSubmissionRepository;
    private final UserMoodRepository userMoodRepository;
    private final PatientProfileRepository patientProfileRepository;
    private final FearLadderService fearLadderService;

    public AssessmentServiceImpl(
            LsasSituationRepository lsasSituationRepository,
            LsasSubmissionRepository lsasSubmissionRepository,
            UserMoodRepository userMoodRepository,
            PatientProfileRepository patientProfileRepository,
            FearLadderService fearLadderService) {
        this.lsasSituationRepository = lsasSituationRepository;
        this.lsasSubmissionRepository = lsasSubmissionRepository;
        this.userMoodRepository = userMoodRepository;
        this.patientProfileRepository = patientProfileRepository;
        this.fearLadderService = fearLadderService;
    }

    @Override
    @Transactional(readOnly = true)
    public List<LsasSituationDto> getLsasSituations() {
        return lsasSituationRepository.findAllByOrderBySituationNumberAsc()
                .stream()
                .map(LsasSituationDto::new)
                .toList();
    }

    @Override
    @Transactional
    public LsasSubmissionDto submitLsas(LsasSubmissionDto dto) {
        PatientProfile patient = patientProfileRepository.findById(dto.getPatientId())
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy bệnh nhân: " + dto.getPatientId()));
        if (dto.getAnswers() == null || dto.getAnswers().size() != 24) {
            throw new IllegalArgumentException("LSAS cần đủ 24 câu trả lời.");
        }

        boolean hasBaseline = lsasSubmissionRepository.existsByPatientProfile_IdAndSubmissionType(
                patient.getId(), LsasSubmissionType.BASELINE);
        LsasSubmissionType type = dto.getSubmissionType();
        if (!hasBaseline) {
            type = LsasSubmissionType.BASELINE;
        } else if (type == null || type == LsasSubmissionType.BASELINE) {
            type = LsasSubmissionType.PERIODIC;
        }

        LsasSubmission submission = new LsasSubmission();
        submission.setPatientProfile(patient);
        submission.setSubmissionType(type);
        submission.setUnlockedAt(LocalDateTime.now().plusDays(14));

        int fearTotal = 0;
        int avoidanceTotal = 0;
        List<LsasAnswer> answers = new ArrayList<>();
        for (LsasAnswerRequestDto answerDto : dto.getAnswers()) {
            LsasSituation situation = lsasSituationRepository.findById(answerDto.getSituationId())
                    .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy tình huống LSAS."));
            int fear = normalizeLsasScore(answerDto.getFearScore());
            int avoidance = normalizeLsasScore(answerDto.getAvoidanceScore());
            LsasAnswer answer = new LsasAnswer();
            answer.setSubmission(submission);
            answer.setSituation(situation);
            answer.setFearScore(fear);
            answer.setAvoidanceScore(avoidance);
            answer.setTotalScore(fear + avoidance);
            answers.add(answer);
            fearTotal += fear;
            avoidanceTotal += avoidance;
        }
        submission.setFearTotal(fearTotal);
        submission.setAvoidanceTotal(avoidanceTotal);
        submission.setTotalScore(fearTotal + avoidanceTotal);
        submission.setAnswers(answers);

        LsasSubmission saved = lsasSubmissionRepository.save(submission);
        patient.setLastLsasDate(LocalDateTime.now());
        patient.setCurrentLsasScore(saved.getTotalScore());
        if (patient.getCurrentCycleStartDate() == null || type == LsasSubmissionType.BASELINE) {
            patient.setCurrentCycleStartDate(LocalDateTime.now());
        }
        patientProfileRepository.save(patient);

        if (type == LsasSubmissionType.BASELINE) {
            fearLadderService.rebuildFromBaseline(patient, answers);
        }

        log.info("LSAS submitted patientId={}, type={}, fearTotal={}, avoidanceTotal={}, total={}",
                patient.getId(), type, fearTotal, avoidanceTotal, saved.getTotalScore());
        return new LsasSubmissionDto(saved);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean isLsasOnCoolDown(UUID patientId) {
        PatientProfile patient = patientProfileRepository.findById(patientId)
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy bệnh nhân: " + patientId));
        if (patient.getLastLsasDate() == null) {
            return false;
        }
        return patient.getLastLsasDate().isAfter(LocalDateTime.now().minusDays(14));
    }

    @Override
    @Transactional(readOnly = true)
    public List<LsasSubmissionDto> getLsasHistory(UUID patientId) {
        patientProfileRepository.findById(patientId)
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy bệnh nhân: " + patientId));
        return lsasSubmissionRepository.findByPatientProfile_IdOrderByCreateDateDesc(patientId)
                .stream()
                .map(LsasSubmissionDto::new)
                .toList();
    }

    @Override
    @Transactional
    public UserMoodDto saveUserMood(UserMoodDto dto) {
        PatientProfile patient = patientProfileRepository.findById(dto.getPatientId())
                .orElseThrow(() -> new EntityNotFoundException("Không tìm thấy bệnh nhân: " + dto.getPatientId()));
        UserMood userMood = new UserMood();
        userMood.setPatientProfile(patient);
        userMood.setMoodScore(dto.getMoodScore());
        userMood.setDailyAgenda(dto.getDailyAgenda());
        return new UserMoodDto(userMoodRepository.save(userMood));
    }

    private int normalizeLsasScore(Integer score) {
        if (score == null) {
            return 0;
        }
        return Math.max(0, Math.min(3, score));
    }
}
