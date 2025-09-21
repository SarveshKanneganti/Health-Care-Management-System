📌 Project Overview

This project focuses on designing and analyzing a Health Care Management System using MySQL. The database simulates real-world hospital operations through seven interconnected datasets: patients, doctors,visits, diagnoses, prescriptions, lab_results, and billing. The goal is to demonstrate database design, SQL querying, and healthcare analytics capabilities.

🗂️ Database Design

The database, named health_db, is structured to capture the end-to-end hospital workflow:

•	Patients: Stores demographic details of individuals visiting the hospital.

•	Doctors: Maintains physician information, specialties, and availability.

•	Visits: Records each consultation with patient ID, doctor ID, and visit type.

•	Diagnoses: Links visits to medical conditions.

•	Prescriptions: Stores medicines prescribed per visit.

•	Lab_Results: Tracks diagnostic test outcomes.

•	Billing: Manages billing amounts, insurance coverage, and payment status.

Primary and foreign key relationships enforce integrity between entities, ensuring accurate linkage of clinical and financial data.

🧹 Data Preparation

The original datasets were cleaned in Excel to handle missing values, inconsistent formatting, and invalid entries. This step ensured smooth import into MySQL.

⚙️ Implementation Steps

1.	Created a new database: CREATE DATABASE health_db;

2.	Defined tables with DDL scripts (primary keys, foreign keys, constraints).

3.	Imported cleaned datasets into MySQL using LOAD DATA INFILE or GUI import.

4.	Verified data integrity through exploratory queries.

🔎 SQL Queries & Analysis

SQL queries were designed from basic to advanced to answer healthcare-related business questions, such as:

•	Count visits by type (e.g., emergency, routine).

•	Most frequently diagnosed conditions.

•	Doctor workload distribution.

•	Average billing per diagnosis.

•	Returning patients within 6 months (using window functions).

•	Outstanding billing trends by payment status.

These queries demonstrate practical SQL concepts including joins, aggregations, subqueries, and window functions.

📊 Key Insights

•	Identified the most common diagnoses and prescription trends.

•	Measured doctor workloads across different specialties.

•	Analyzed patient return rates, revealing patterns of recurring visits.

•	Explored billing performance and insurance coverage gaps.

🛠️ Tools & Technologies

•	Database: MySQL

•	Data Cleaning: Microsoft Excel

•	Querying: SQL (DDL, DML, joins, subqueries, window functions)

## Thank You

