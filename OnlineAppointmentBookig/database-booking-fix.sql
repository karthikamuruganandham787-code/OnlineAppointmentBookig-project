-- ============================================================
-- MediBook booking fix — service → specialty → doctors
-- Database: onlineappointmentbooking (MariaDB port 3308)
-- Does NOT drop hospitals, specialties, time_slots, or appointments.
-- ============================================================
USE onlineappointmentbooking;

-- Doctors need a FK to specialties so service mapping is data-driven.
SET @col_exists := (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'onlineappointmentbooking'
      AND TABLE_NAME = 'doctors'
      AND COLUMN_NAME = 'specialty_id'
);
SET @sql := IF(@col_exists = 0,
    'ALTER TABLE doctors ADD COLUMN specialty_id INT NULL, ADD CONSTRAINT fk_doctors_specialty FOREIGN KEY (specialty_id) REFERENCES specialties(id)',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

CREATE TABLE IF NOT EXISTS service_specialties (
    service_id   INT NOT NULL,
    specialty_id INT NOT NULL,
    PRIMARY KEY (service_id, specialty_id),
    CONSTRAINT fk_ss_service   FOREIGN KEY (service_id)   REFERENCES services(id)    ON DELETE CASCADE,
    CONSTRAINT fk_ss_specialty FOREIGN KEY (specialty_id) REFERENCES specialties(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 20 specialists — IDs aligned with specialties.id and existing time_slots.doctor_id
INSERT INTO doctors (id, name, specialty, qualification, experience_years, rating, bio, profile_image, availability_status, specialty_id)
VALUES
(1,  'Dr. Ramesh Kumar',          'Cardiology',        'MBBS, MD (Cardiology)',         12, 4.9, 'Specialist in heart health and preventive cardiology.', 'doctor1.png', 'AVAILABLE', 1),
(2,  'Dr. Priya Sharma',          'Dermatology',       'MBBS, MD (Dermatology)',         8,  4.8, 'Focused on skin, hair, and cosmetic dermatology.', 'doctor2.png', 'AVAILABLE', 2),
(3,  'Dr. Arun Krishnan',         'General Medicine',  'MBBS, MD (General Medicine)',    6,  4.6, 'Comprehensive care for general health and chronic disease.', 'doctor3.png', 'AVAILABLE', 3),
(4,  'Dr. Meena Raj',             'Pediatrics',        'MBBS, MD (Pediatrics)',          9,  4.8, 'Dedicated to child health, vaccinations, and development.', 'doctor4.png', 'AVAILABLE', 4),
(5,  'Dr. Vikram Singh',          'Orthopedics',       'MBBS, MS (Ortho)',              15, 4.9, 'Expert in joint replacement, sports injuries, and spine care.', 'doctor5.png', 'AVAILABLE', 5),
(6,  'Dr. Ananya Iyer',           'Neurology',         'MBBS, DM (Neurology)',          11, 4.7, 'Specialist in brain and nervous system disorders.', 'doctor6.png', 'AVAILABLE', 6),
(7,  'Dr. Karthika Muruganadham', 'Gastroenterology',  'MBBS, DM (Gastroenterology)',   10, 4.8, 'Digestive system and liver care specialist.', 'doctor7.png', 'AVAILABLE', 7),
(8,  'Dr. Sneha Kapoor',          'Gynecology',        'MBBS, MS (OBG)',                13, 4.8, 'Women''s health, pregnancy, and gynecological care.', 'doctor8.png', 'AVAILABLE', 8),
(9,  'Dr. Rahul Menon',           'ENT Specialist',    'MBBS, MS (ENT)',                 9,  4.6, 'Ear, nose, and throat specialist.', 'doctor9.png', 'AVAILABLE', 9),
(10, 'Dr. Divya Nair',            'Ophthalmology',     'MBBS, MS (Ophthalmology)',      10, 4.7, 'Eye and vision care specialist.', 'doctor10.png', 'AVAILABLE', 10),
(11, 'Dr. Arvind Kumar',          'Urology',           'MBBS, MCh (Urology)',           14, 4.8, 'Urinary and reproductive health specialist.', 'doctor11.png', 'AVAILABLE', 11),
(12, 'Dr. Lakshmi Devi',          'Endocrinology',     'MBBS, DM (Endocrinology)',      11, 4.7, 'Hormonal and metabolic disorder specialist.', 'doctor12.png', 'AVAILABLE', 12),
(13, 'Dr. Suresh Babu',           'Pulmonology',       'MBBS, MD (Pulmonology)',        12, 4.6, 'Respiratory and lung care specialist.', 'doctor13.png', 'AVAILABLE', 13),
(14, 'Dr. Neha Verma',            'Psychiatry',        'MBBS, MD (Psychiatry)',          8,  4.7, 'Mental health consultation and counselling.', 'doctor14.png', 'AVAILABLE', 14),
(15, 'Dr. Ajay Thomas',           'General Surgery',   'MBBS, MS (General Surgery)',    16, 4.8, 'Surgical consultation and operative care.', 'doctor15.png', 'AVAILABLE', 15),
(16, 'Dr. Kavya Srinivasan',      'Dentistry',         'BDS, MDS',                      10, 4.9, 'General and cosmetic dentistry, root canal, and oral surgery.', 'doctor16.png', 'AVAILABLE', 16),
(17, 'Dr. Mohan Raj',             'Nephrology',        'MBBS, DM (Nephrology)',         13, 4.7, 'Kidney healthcare specialist.', 'doctor17.png', 'AVAILABLE', 17),
(18, 'Dr. Aishwarya Menon',       'Physiotherapy',     'BPT, MPT',                       7,  4.6, 'Physical rehabilitation and mobility care.', 'doctor18.png', 'AVAILABLE', 18),
(19, 'Dr. Sanjay Patel',          'Oncology',          'MBBS, DM (Oncology)',           14, 4.8, 'Specialist cancer care and treatment planning.', 'doctor19.png', 'AVAILABLE', 19),
(20, 'Dr. Pooja Reddy',           'Diabetology',       'MBBS, MD (Diabetology)',        10, 4.7, 'Diabetes and metabolic care specialist.', 'doctor20.png', 'AVAILABLE', 20)
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    specialty = VALUES(specialty),
    qualification = VALUES(qualification),
    experience_years = VALUES(experience_years),
    rating = VALUES(rating),
    bio = VALUES(bio),
    profile_image = VALUES(profile_image),
    availability_status = VALUES(availability_status),
    specialty_id = VALUES(specialty_id);

ALTER TABLE doctors AUTO_INCREMENT = 21;

-- Service → specialty (NOT hardcoded in JSP/JS)
DELETE FROM service_specialties;
INSERT INTO service_specialties (service_id, specialty_id) VALUES
(1, 3),   -- General Consultation → General Medicine
(2, 1),   -- Cardiology Consultation → Cardiology
(3, 2),   -- Dermatology Consultation → Dermatology
(4, 16),  -- Dental Care → Dentistry
(5, 3);   -- Health Check-up → General Medicine

-- Follow-up can be with any specialist
INSERT INTO service_specialties (service_id, specialty_id)
SELECT 6, id FROM specialties;

-- Keep doctor_services in sync for any remaining consumers
DELETE FROM doctor_services;
INSERT INTO doctor_services (doctor_id, service_id)
SELECT d.id, ss.service_id
FROM doctors d
JOIN service_specialties ss ON ss.specialty_id = d.specialty_id;
