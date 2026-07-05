-- ReConnect MindHealth
-- V9 - Appointment booking integrity
--
-- Mục tiêu:
-- - Chặn double-book ở mức CSDL cho therapist và patient.
-- - Bổ sung index rõ ràng cho các truy vấn booking chính.
--
-- Lưu ý:
-- - Nếu dữ liệu local cũ đã có lịch trùng therapist/start_at hoặc patient/start_at
--   thì migration này sẽ fail khi thêm unique constraint. Cần dọn dữ liệu trùng trước.

ALTER TABLE appointments
    ADD CONSTRAINT uq_appointments_therapist_start_at UNIQUE (therapist_id, start_at);

ALTER TABLE appointments
    ADD CONSTRAINT uq_appointments_patient_start_at UNIQUE (patient_id, start_at);

CREATE INDEX idx_appointments_therapist_start_at
    ON appointments (therapist_id, start_at);

CREATE INDEX idx_appointments_patient_start_at
    ON appointments (patient_id, start_at);

CREATE INDEX idx_appointments_therapist_status_start_at
    ON appointments (therapist_id, status, start_at);
