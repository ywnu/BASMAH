-- BASMAH schema migration for databases created from the OLD 01_create_tables.sql.
-- Owner: Jumanah | 2026-11-28
-- DO NOT RUN on a newly-created database using the updated 01_create_tables.sql:
-- it already contains PasswordHash and all five CHECK constraints.
--
-- FIRST: review target and run against a disposable copy (e.g. BASMAH_TEST).
-- CAUTION: ALTER TABLE is DDL and implicitly commits; ROLLBACK does not undo it.
-- For local BASMAH_TEST, change USE BASMAH to USE BASMAH_TEST before executing.
-- Ensure all existing Role/Status/Decision/EvidenceType/SourceType values
-- are within the allowed lists before adding CHECK constraints.
-- This script is intentionally RUN-ONCE (non-idempotent).

USE BASMAH;

ALTER TABLE Users
    ADD COLUMN PasswordHash VARCHAR(255) NULL AFTER Email,
    ADD CONSTRAINT ck_users_role
        CHECK (Role IN ('Admin', 'Researcher', 'Reviewer'));

ALTER TABLE Sources
    ADD CONSTRAINT ck_sources_source_type
        CHECK (SourceType IN ('Article', 'Report', 'Website', 'Book', 'Dataset'));

ALTER TABLE Claims
    ADD CONSTRAINT ck_claims_status
        CHECK (Status IN ('Pending', 'Verified', 'Disputed', 'Rejected'));

ALTER TABLE Evidence
    ADD CONSTRAINT ck_evidence_evidence_type
        CHECK (EvidenceType IN ('Study', 'Expert Statement', 'Reference Data', 'Social Media Post'));

ALTER TABLE Reviews
    ADD CONSTRAINT ck_reviews_decision
        CHECK (Decision IN ('Approve', 'Reject', 'NeedsMoreEvidence'));

-- Read-only verification
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'Users'
  AND COLUMN_NAME = 'PasswordHash';

SELECT TABLE_NAME, CONSTRAINT_NAME
FROM information_schema.TABLE_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = DATABASE()
  AND CONSTRAINT_TYPE = 'CHECK'
  AND CONSTRAINT_NAME IN (
    'ck_users_role', 'ck_sources_source_type', 'ck_claims_status',
    'ck_evidence_evidence_type', 'ck_reviews_decision'
  )
ORDER BY TABLE_NAME;
