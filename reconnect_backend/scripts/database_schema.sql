-- Database Schema for Reconnect MindHealth (PostgreSQL/MySQL Compatible)
-- Created: 2024-04-23
-- Version: 3.0 (CBT Clinical Focus)

-- 1. Users Table (Core Identity)
CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('PATIENT', 'THERAPIST')),
    is_anonymous BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Therapist Profiles
CREATE TABLE therapist_profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    full_name VARCHAR(255) NOT NULL,
    specialization VARCHAR(255),
    bio TEXT,
    meeting_link VARCHAR(255), -- Google Meet/Zoom link
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Patient Profiles (1-N with Therapist)
CREATE TABLE patient_profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    nickname VARCHAR(100) NOT NULL,
    is_anonymous BOOLEAN DEFAULT TRUE,
    therapist_id UUID REFERENCES therapist_profiles(user_id) ON DELETE SET NULL,
    status VARCHAR(20) DEFAULT 'STABLE' CHECK (status IN ('WARNING', 'STABLE', 'PROGRESSING')),
    cognitive_map JSONB, -- Stores CCD data (Core beliefs, assumptions, etc.)
    streak_days INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. PHQ-9 Assessment Tracking
CREATE TABLE phq_tests (
    id UUID PRIMARY KEY,
    patient_id UUID NOT NULL REFERENCES patient_profiles(user_id) ON DELETE CASCADE,
    score INT NOT NULL,
    severity VARCHAR(50),
    test_type VARCHAR(20) DEFAULT 'PERIODIC' CHECK (test_type IN ('BASELINE', 'PERIODIC')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. Daily Mood Logs (For Sparklines)
CREATE TABLE mood_logs (
    id UUID PRIMARY KEY,
    patient_id UUID NOT NULL REFERENCES patient_profiles(user_id) ON DELETE CASCADE,
    score INT NOT NULL, -- 0 to 100
    note TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. Thought Records (Journaling with AI)
CREATE TABLE thought_records (
    id UUID PRIMARY KEY,
    patient_id UUID NOT NULL REFERENCES patient_profiles(user_id) ON DELETE CASCADE,
    original_thought TEXT NOT NULL,
    distortion_type VARCHAR(100), -- Identified by AI (e.g., Catastrophizing)
    ai_response TEXT, -- Socratic questioning response
    risk_index INT DEFAULT 0, -- 0-100, > 80 triggers RED FLAG
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 7. AI Roadmap Tasks (Quests)
CREATE TABLE roadmap_tasks (
    id UUID PRIMARY KEY,
    patient_id UUID NOT NULL REFERENCES patient_profiles(user_id) ON DELETE CASCADE,
    category VARCHAR(20) NOT NULL CHECK (category IN ('COGNITIVE', 'BEHAVIORAL', 'SOCIAL', 'EMOTIONAL')),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'TODO' CHECK (status IN ('TODO', 'DONE')),
    mastery INT DEFAULT 0, -- 0 to 10
    pleasure INT DEFAULT 0, -- 0 to 10
    completed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 8. Booster Sessions (Appointments)
CREATE TABLE appointments (
    id UUID PRIMARY KEY,
    therapist_id UUID NOT NULL REFERENCES therapist_profiles(user_id) ON DELETE CASCADE,
    patient_id UUID NOT NULL REFERENCES patient_profiles(user_id) ON DELETE CASCADE,
    scheduled_at TIMESTAMP NOT NULL,
    status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'UPCOMING', 'COMPLETED', 'CANCELLED')),
    meeting_link TEXT, -- Copy of therapist link at time of booking
    notes TEXT, -- Private notes for therapist
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 9. PHQ-9 Questions Table (Clinical Seeding)
CREATE TABLE phq9_questions (
    id UUID PRIMARY KEY,
    question_number INT NOT NULL,
    text VARCHAR(1000) NOT NULL,
    create_date TIMESTAMP,
    created_by VARCHAR(255),
    modify_date TIMESTAMP,
    modified_by VARCHAR(255),
    voided BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
