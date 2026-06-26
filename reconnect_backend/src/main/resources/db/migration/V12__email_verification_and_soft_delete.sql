-- ReConnect MindHealth
-- V12 - Email verification OTP + safe delete support

ALTER TABLE users
    ADD COLUMN IF NOT EXISTS email_verified BIT(1) NOT NULL DEFAULT b'0',
    ADD COLUMN IF NOT EXISTS email_verification_otp VARCHAR(16) NULL,
    ADD COLUMN IF NOT EXISTS email_verification_expires_at DATETIME NULL,
    ADD COLUMN IF NOT EXISTS email_verification_sent_at DATETIME NULL;

UPDATE users
SET email_verified = b'1'
WHERE email_verified IS NULL
   OR email_verified = b'0';

