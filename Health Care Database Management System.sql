/*
====================================================
        Healthcare Database Project Documentation
====================================================

1. Project Overview
-------------------
This project is based on a secured healthcare dataset sourced from Kaggle, 
containing seven interrelated CSV files:
    - Patients
    - Doctors
    - Visits
    - Diagnoses
    - Prescriptions
    - Lab_Results
    - Billing

The objective is to design a normalized relational schema in MYSQL, 
import the cleaned datasets, and execute SQL queries ranging from basic 
retrievals to advanced analytics—supporting healthcare insights and 
decision-making.

2. Data Preparation
-------------------
- Initial preprocessing performed in Excel to handle:
    * Missing values
    * 'NaN' entries
    * Inconsistent formats
- Cleaned files were then prepared for import into MYSQL using the Table Data Import Wizard.
- Ensured UTF-8 encoding and proper column alignment.

3. Project Objectives
---------------------
- Create and populate the schema with cleaned Kaggle data.
- Perform SQL queries covering:
    * Basic SELECT statements
    * Joins across multiple tables
    * Aggregations and Grouping
    * Window functions
    * Subqueries and CTEs
    * Analytical queries for patient care and billing efficiency
- Provide a comprehensive SQL demonstration that reflects 
  real-world healthcare data management and analytics.

====================================================
*/

/* ------------------------------------- Task 1- Creating Data Base & Tables ----------------------------- */                                       

-- Create schema
CREATE DATABASE IF NOT EXISTS healthdb
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_0900_ai_ci;
USE  healthdb;

-- =========================
-- 1) PATIENTS
-- =========================
CREATE TABLE patients (
  patient_id            INT NOT NULL PRIMARY KEY,
  first_name            VARCHAR(50)  NOT NULL,
  last_name             VARCHAR(50)  NOT NULL,
  gender                ENUM('M','F','O') NOT NULL,
  dob                   DATE NOT NULL,
  phone                 VARCHAR(20),
  email                 VARCHAR(100),
  address               VARCHAR(255),
  city                  VARCHAR(80),
  state                 VARCHAR(10),
  zip                   VARCHAR(10),
  insurance_provider    VARCHAR(40),
  insurance_member_id   VARCHAR(20)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- 2) DOCTORS
-- =========================
CREATE TABLE doctors (
  doctor_id     INT NOT NULL PRIMARY KEY,
  first_name    VARCHAR(50) NOT NULL,
  last_name     VARCHAR(50) NOT NULL,
  specialization VARCHAR(60),
  phone         VARCHAR(20),
  email         VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- 3) VISITS
-- =========================
CREATE TABLE visits (
  visit_id        INT NOT NULL PRIMARY KEY,
  patient_id      INT NOT NULL,
  doctor_id       INT NOT NULL,
  visit_datetime  DATETIME NOT NULL,
  visit_type      ENUM('Outpatient','Inpatient','ER','Telemedicine') NOT NULL,
  height_cm       DECIMAL(5,1),
  weight_kg       DECIMAL(6,1),
  systolic_bp     SMALLINT UNSIGNED,
  diastolic_bp    SMALLINT UNSIGNED,
  heart_rate      SMALLINT UNSIGNED,
  notes           VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- 4) DIAGNOSES (0..n per visit)
-- =========================
CREATE TABLE diagnoses (
  diag_id         INT NOT NULL PRIMARY KEY,
  visit_id        INT NOT NULL,
  icd10_code      VARCHAR(10) NOT NULL,
  diagnosis_desc  VARCHAR(255) NOT NULL,
  is_primary      TINYINT(1) NOT NULL DEFAULT 0,
  CONSTRAINT fk_diag_visit
    FOREIGN KEY (visit_id) REFERENCES visits(visit_id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- 5) PRESCRIPTIONS (0..n per visit)
-- =========================
CREATE TABLE prescriptions (
  prescription_id INT NOT NULL PRIMARY KEY,
  visit_id        INT NOT NULL,
  drug_name       VARCHAR(80) NOT NULL,
  dosage_mg       INT,
  frequency       VARCHAR(10),     -- e.g., OD, BID, TID, QHS, PRN
  days_supply     INT,
  refills         INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- 6) LAB RESULTS 
-- =========================
CREATE TABLE lab_results (
  lab_id        INT NOT NULL PRIMARY KEY,
  visit_id      INT NOT NULL,
  test_name     VARCHAR(60) NOT NULL,
  result_value  DECIMAL(10,2),
  unit          VARCHAR(20),
  ref_low       DECIMAL(10,2),
  ref_high      DECIMAL(10,2),
  flag          ENUM('Low','Normal','High')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- 7) BILLING 
-- =========================
CREATE TABLE billing (
  bill_id            INT NOT NULL PRIMARY KEY,
  visit_id           INT NOT NULL,
  total_cost         DECIMAL(10,2) NOT NULL,
  insurance_covered  DECIMAL(10,2) NOT NULL,
  patient_pay        DECIMAL(10,2) NOT NULL,
  payment_status     ENUM('Paid','Pending','Denied','Partial') NOT NULL,
  paid_date          DATE NULL,
  payment_method     ENUM('Card','Cash','Online','InsuranceOnly') NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--Cleaned and refined the datasets in Excel, then successfully imported them into the health_db database via MySQL Table Data Import Wizard for analysis

/* ------------------------------------- Task 2:- Basic & Advanced Analysis ----------------------------- */

USE healthdb;

/*1.Write a query to list all patients (first/last name and city), sorted by last name then first name ****/

SELECT first_name, last_name, city
FROM patients
ORDER BY last_name, first_name;

/*2. Write a query to find unique insurance providers in alphabetical manner ****/

SELECT DISTINCT insurance_provider
FROM patients
ORDER BY insurance_provider asc;

/*3. Write a query to list the top 5 cities having more patients ****/
SELECT city, COUNT(*) AS patient_count
FROM patients
GROUP BY city
ORDER BY patient_count DESC
LIMIT 5;

/*4.Write a query to display the total count of visits grouped by visit type ****/

SELECT visit_type, COUNT(*) AS visits_count
FROM visits
GROUP BY visit_type
ORDER BY visits_count DESC;

/*5.Write a query to find the payment status wise billing versus collections ****/

SELECT payment_status,
       ROUND(SUM(total_cost),2)        AS total_billed,
       ROUND(SUM(patient_pay),2)       AS total_patient_pay,
       ROUND(SUM(insurance_covered),2) AS total_insurance_covered
FROM billing
GROUP BY payment_status;

/*6.Write a query to find top 10 prescribed drugs ****/

SELECT drug_name, COUNT(*) AS times_prescribed
FROM prescriptions
GROUP BY drug_name
ORDER BY times_prescribed DESC
LIMIT 10;

/*7.Write a query to find the patients who enrolled for self-pay(not enrolled for insurance) ****/

SELECT COUNT(*) AS self_pay_patients
FROM patients
WHERE insurance_provider = 'None/SelfPay';

/*8.Write a query to find the top 10 doctors who made the highest gross in total billed amount ****/

SELECT d.doctor_id,
       CONCAT(d.first_name,' ',d.last_name) AS doctor_name,
       ROUND(SUM(b.total_cost),2) AS total_revenue
FROM doctors d
JOIN visits v ON v.doctor_id = d.doctor_id
JOIN billing b ON b.visit_id = v.visit_id
GROUP BY d.doctor_id, doctor_name
ORDER BY total_revenue DESC
LIMIT 10;

/*9.Write a query Lab abnormality rates by tast name ****/

SELECT test_name,
       COUNT(*) AS total_tests,
       SUM(flag='High' OR flag='Low') AS abnormal_count,
       ROUND(SUM(flag='High' OR flag='Low')/COUNT(*)*100,2) AS abnormal_pct
FROM lab_results
GROUP BY test_name
ORDER BY abnormal_pct DESC;

/*10.Write a query to find first and last visit dates of each patient  ****/

SELECT p.patient_id,
       MIN(v.visit_datetime) AS first_visit,
       MAX(v.visit_datetime) AS last_visit,
       COUNT(v.visit_id) AS total_visits
FROM patients p
JOIN visits v ON v.patient_id = p.patient_id
GROUP BY p.patient_id;
/*11.Write a query to find many diagnoses per visit  ****/

SELECT visit_id,COUNT(*) AS num_diagnoses
FROM diagnoses
GROUP BY visit_id
HAVING num_diagnoses >= 2
ORDER BY num_diagnoses DESC;

/*12.Write a query to find the patients who had never visited    ****/

SELECT p.patient_id, p.first_name, p.last_name
FROM patients p
LEFT JOIN visits v ON v.patient_id = p.patient_id
WHERE v.visit_id IS NULL;

/*13.Write a query to find the patients who paid bill after visiting 45 days ****/

SELECT b.bill_id, v.visit_id, v.visit_datetime, b.paid_date, DATEDIFF(b.paid_date, v.visit_datetime) AS delayed_days
FROM billing b
JOIN visits v ON v.visit_id = b.visit_id
WHERE b.paid_date IS NOT NULL
AND DATEDIFF(b.paid_date, v.visit_datetime) > 45;

/*14.Write a query to find the average turn around time between visit and payment ****/

SELECT ROUND(AVG(DATEDIFF(b.paid_date, v.visit_datetime)),2) AS avg_days_to_pay
FROM visits v
JOIN billing b ON b.visit_id = v.visit_id
WHERE b.paid_date IS NOT NULL;

/*15.Write a query to identify high-risk patients with ‘High’ lab results and chronic diagnoses  ****/

SELECT DISTINCT p.patient_id, p.first_name, p.last_name
FROM patients p
JOIN visits v ON v.patient_id = p.patient_id
JOIN lab_results l ON l.visit_id = v.visit_id AND l.flag='High'
JOIN diagnoses d ON d.visit_id = v.visit_id
WHERE d.icd10_code IN ('I10','E11.9','J45.909','E78.5');

/*16.Write a query to find the patients with multiple ER visits in last 45 days  ****/

SELECT p.patient_id,
CONCAT(p.first_name,' ',p.last_name) AS patient_name,
COUNT(v.visit_id) AS er_visits_45d
FROM patients p
JOIN visits v ON v.patient_id = p.patient_id
WHERE v.visit_type='ER'
AND v.visit_datetime >= CURDATE() - INTERVAL 45 DAY
GROUP BY p.patient_id, patient_name
HAVING er_visits_45d >= 2;

/*17.Write a query to find Insurance coverage ratio vs patient pay  ****/

SELECT insurance_provider, ROUND(AVG(insurance_covered / total_cost)*100,2) AS avg_coverage_pct,
ROUND(AVG(patient_pay / total_cost)*100,2) AS avg_patient_share_pct
FROM billing b
JOIN visits v ON v.visit_id = b.visit_id
JOIN patients p ON p.patient_id = v.patient_id
GROUP BY insurance_provider
ORDER BY avg_coverage_pct DESC;

/*18.Write a query to provide a monthly breakdown of visits by type (pivoted columns)  ****/

SELECT DATE_FORMAT(visit_datetime, '%Y-%m') AS ym, SUM(visit_type='Outpatient') AS outpatient_visits,
SUM(visit_type='Inpatient') AS inpatient_visits, SUM(visit_type='ER') AS er_visits, SUM(visit_type='Telemedicine') AS tele_visits
FROM visits
GROUP BY ym
ORDER BY ym;

/*19.Write a query to find the per-patient visit sequence ****/
SELECT visit_id, patient_id, visit_datetime,
ROW_NUMBER() OVER (PARTITION BY patient_id ORDER BY visit_datetime) AS visit_seq
FROM visits
ORDER BY patient_id, visit_seq;

/*20.Write a query to find patient retention rate who lasts past 6 months ****/

WITH seq AS (
SELECT patient_id, visit_id, visit_datetime,
LAG(visit_datetime) OVER (PARTITION BY patient_id ORDER BY visit_datetime) AS prev_dt
FROM visits
)
SELECT COUNT(DISTINCT patient_id) AS returning_patients
FROM seq
WHERE prev_dt IS NOT NULL
AND TIMESTAMPDIFF(DAY, prev_dt, visit_datetime) <= 180;

-- Thank You
