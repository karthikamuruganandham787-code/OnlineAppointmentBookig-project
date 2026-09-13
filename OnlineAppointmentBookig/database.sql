-- ============================================================
-- MEDIBOOK - ONLINE APPOINTMENT BOOKING SYSTEM
-- Database: onlineappointmentbooking (MariaDB, port 3308)
-- ============================================================

CREATE DATABASE IF NOT EXISTS onlineappointmentbooking;
USE onlineappointmentbooking;

-- Disable FK checks so DROP TABLE works in any order
SET FOREIGN_KEY_CHECKS = 0;

-- Drop tables in reverse dependency order (children first)
DROP TABLE IF EXISTS appointments;
DROP TABLE IF EXISTS doctor_schedule;
DROP TABLE IF EXISTS doctor_services;
DROP TABLE IF EXISTS services;
DROP TABLE IF EXISTS doctors;

SET FOREIGN_KEY_CHECKS = 1;

-- ------------------------------------------------------------
-- DOCTORS
-- ------------------------------------------------------------
CREATE TABLE doctors (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    name                VARCHAR(120)  NOT NULL,
    specialty           VARCHAR(120)  NOT NULL,
    qualification       VARCHAR(120)  NOT NULL,
    experience_years    INT           NOT NULL DEFAULT 0,
    rating              DECIMAL(2,1)  NOT NULL DEFAULT 4.5,
    bio                 VARCHAR(500),
    profile_image       VARCHAR(255),
    availability_status VARCHAR(20)   NOT NULL DEFAULT 'AVAILABLE',
    created_at          TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- SERVICES
-- ------------------------------------------------------------
CREATE TABLE services (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    service_name  VARCHAR(120)  NOT NULL,
    description   VARCHAR(500),
    duration_mins INT           NOT NULL DEFAULT 15,
    fee           DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    icon          VARCHAR(60),
    status        VARCHAR(20)   NOT NULL DEFAULT 'ACTIVE'
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- DOCTOR_SERVICES (mapping)
-- ------------------------------------------------------------
CREATE TABLE doctor_services (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    doctor_id   INT NOT NULL,
    service_id  INT NOT NULL,
    CONSTRAINT fk_ds_doctor  FOREIGN KEY (doctor_id)  REFERENCES doctors(id)  ON DELETE CASCADE,
    CONSTRAINT fk_ds_service FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE,
    CONSTRAINT uq_doctor_service UNIQUE (doctor_id, service_id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- DOCTOR_SCHEDULE (availability per doctor/date/time)
-- ------------------------------------------------------------
CREATE TABLE doctor_schedule (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    doctor_id       INT          NOT NULL,
    schedule_date   DATE         NOT NULL,
    slot_time       TIME         NOT NULL,
    slot_end_time   TIME         NOT NULL,
    status          VARCHAR(20)  NOT NULL DEFAULT 'AVAILABLE', -- AVAILABLE, BOOKED, BLOCKED
    CONSTRAINT fk_sched_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE,
    CONSTRAINT uq_doctor_date_time UNIQUE (doctor_id, schedule_date, slot_time)
) ENGINE=InnoDB;

CREATE INDEX idx_schedule_lookup ON doctor_schedule (doctor_id, schedule_date, status);

-- ------------------------------------------------------------
-- APPOINTMENTS
-- ------------------------------------------------------------
CREATE TABLE appointments (
    appointment_id    INT AUTO_INCREMENT PRIMARY KEY,
    patient_name      VARCHAR(120) NOT NULL,
    email             VARCHAR(150) NOT NULL,
    phone             VARCHAR(20)  NOT NULL,
    doctor_id         INT          NOT NULL,
    service_id        INT          NOT NULL,
    appointment_date  DATE         NOT NULL,
    appointment_time  TIME         NOT NULL,
    reason            VARCHAR(300),
    notes             VARCHAR(500),
    status            VARCHAR(20)  NOT NULL DEFAULT 'CONFIRMED', -- CONFIRMED, CANCELLED, COMPLETED, PENDING
    created_at        TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_appt_doctor  FOREIGN KEY (doctor_id)  REFERENCES doctors(id),
    CONSTRAINT fk_appt_service FOREIGN KEY (service_id) REFERENCES services(id),
    -- Database-level double-booking prevention: a doctor cannot be double booked
    -- for the same date+time while the appointment is CONFIRMED/PENDING.
    CONSTRAINT uq_doctor_slot UNIQUE (doctor_id, appointment_date, appointment_time)
) ENGINE=InnoDB;

-- ============================================================
-- SEED DATA
-- ============================================================

INSERT INTO doctors (name, specialty, qualification, experience_years, rating, bio, profile_image, availability_status) VALUES
('Dr. Ramesh Kumar',   'Cardiologist',        'MBBS, MD (Cardiology)', 12, 4.9, 'Specialist in heart health and preventive cardiology with over a decade of clinical experience.', 'doctor1.png', 'AVAILABLE'),
('Dr. Anjali Sharma',  'Dermatologist',       'MBBS, MD (Dermatology)', 8,  4.8, 'Focused on skin, hair, and cosmetic dermatology treatments using modern techniques.', 'doctor2.png', 'AVAILABLE'),
('Dr. Suresh Iyer',    'Dentist',             'BDS, MDS',               10, 4.7, 'Experienced in general and cosmetic dentistry, root canal, and oral surgery.', 'doctor3.png', 'AVAILABLE'),
('Dr. Priya Nair',     'General Physician',   'MBBS, MD (General Medicine)', 6, 4.6, 'Provides comprehensive care for general health concerns and chronic disease management.', 'doctor4.png', 'AVAILABLE'),
('Dr. Karthik Raja',   'Orthopedic',          'MBBS, MS (Ortho)',       15, 4.9, 'Expert in joint replacement, sports injuries, and spine care.', 'doctor5.png', 'AVAILABLE'),
('Dr. Meera Pillai',   'Pediatrician',        'MBBS, MD (Pediatrics)',  9,  4.8, 'Dedicated to child health, vaccinations, and developmental care.', 'doctor6.png', 'AVAILABLE');

INSERT INTO services (service_name, description, duration_mins, fee, icon, status) VALUES
('General Consultation',      'Comprehensive checkup and health advice for common concerns.',        15, 300.00, 'stethoscope', 'ACTIVE'),
('Cardiology Consultation',   'Heart health evaluation including ECG review and risk assessment.',    30, 800.00, 'heart-pulse', 'ACTIVE'),
('Dermatology Consultation',  'Skin, hair, and nail condition evaluation and treatment planning.',    20, 600.00, 'skin', 'ACTIVE'),
('Dental Care',                'Routine dental checkup, cleaning, and minor procedures.',              30, 500.00, 'tooth', 'ACTIVE'),
('Health Check-up',            'Full-body preventive health screening package.',                      45, 1200.00, 'clipboard-check', 'ACTIVE'),
('Follow-up Consultation',     'Follow-up visit for reviewing ongoing treatment progress.',            15, 200.00, 'calendar-check', 'ACTIVE');

-- Map doctors to services they offer
INSERT INTO doctor_services (doctor_id, service_id) VALUES
(1, 2), (1, 1), (1, 6),
(2, 3), (2, 1), (2, 6),
(3, 4), (3, 1), (3, 6),
(4, 1), (4, 5), (4, 6),
(5, 1), (5, 5), (5, 6),
(6, 1), (6, 5), (6, 6);

-- Generate schedule slots for each doctor for the next 14 days,
-- 09:00 to 17:00, in 15-minute increments.

DELIMITER $$
CREATE PROCEDURE generate_schedule()
BEGIN
    DECLARE d INT DEFAULT 1;
    DECLARE day_offset INT DEFAULT 0;
    DECLARE slot_hour INT;
    DECLARE slot_min INT;
    DECLARE the_date DATE;
    DECLARE start_time TIME;
    DECLARE end_time TIME;

    WHILE d <= 6 DO
        SET day_offset = 0;
        WHILE day_offset < 14 DO
            SET the_date = DATE_ADD(CURDATE(), INTERVAL day_offset DAY);
            -- skip Sundays for variety
            IF DAYOFWEEK(the_date) != 1 THEN
                SET slot_hour = 9;
                SET slot_min = 0;
                WHILE slot_hour < 17 DO
                    SET start_time = MAKETIME(slot_hour, slot_min, 0);
                    SET end_time = ADDTIME(start_time, '00:15:00');
                    INSERT IGNORE INTO doctor_schedule (doctor_id, schedule_date, slot_time, slot_end_time, status)
                    VALUES (d, the_date, start_time, end_time, 'AVAILABLE');
                    SET slot_min = slot_min + 15;
                    IF slot_min >= 60 THEN
                        SET slot_min = 0;
                        SET slot_hour = slot_hour + 1;
                    END IF;
                END WHILE;
            END IF;
            SET day_offset = day_offset + 1;
        END WHILE;
        SET d = d + 1;
    END WHILE;
END$$
DELIMITER ;

CALL generate_schedule();
DROP PROCEDURE generate_schedule;

-- ============================================================
-- END OF SCRIPT
-- ============================================================
