package com.reconnect.mindhealth.modules.risk.controller;

import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.reconnect.mindhealth.common.dto.ApiResponse;
import com.reconnect.mindhealth.modules.risk.dto.RiskCalculationResultDto;
import com.reconnect.mindhealth.modules.risk.service.IRiskScoringService;

@RestController
@RequestMapping("/api/risk")
public class RiskController {

    @Autowired
    private IRiskScoringService riskScoringService;

    @PostMapping("/run-now")
    public ResponseEntity<ApiResponse<Integer>> runNow() {
        try {
            int processed = riskScoringService.calculateAndPersistForAllActivePatients();
            return ResponseEntity.ok(ApiResponse.success("Đã chạy Risk Index thành công!", processed));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi chạy Risk Index: " + e.getMessage()));
        }
    }

    @PostMapping("/run-one")
    public ResponseEntity<ApiResponse<RiskCalculationResultDto>> runOne(@RequestParam UUID patientId) {
        try {
            RiskCalculationResultDto result = riskScoringService.calculateAndPersist(patientId);
            return ResponseEntity.ok(ApiResponse.success("Đã tính Risk Index cho bệnh nhân!", result));
        } catch (Exception e) {
            return ResponseEntity.ok(ApiResponse.error("Lỗi khi tính Risk Index: " + e.getMessage()));
        }
    }
}

