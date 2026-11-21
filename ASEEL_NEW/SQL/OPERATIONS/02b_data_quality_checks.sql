-- =====================================================================
-- 02b_data_quality_checks.sql | Owner: Aseel | Branch: feature/sql-operations
-- Seed-data validation. EVERY query below should return 0 rows.
-- A returned row = a data problem (broken link or inconsistent record).
-- Run after 02_seed_data.sql.
-- =====================================================================
USE BASMAH;

-- DQ1. Evidence rows whose claim or source does not exist (broken links).
SELECT e.EvidenceID FROM Evidence e
LEFT JOIN Claims  c ON c.ClaimID  = e.ClaimID
LEFT JOIN Sources s ON s.SourceID = e.SourceID
WHERE c.ClaimID IS NULL OR s.SourceID IS NULL;

-- DQ2. Verified claims with no 'Approve' review.
SELECT c.ClaimID FROM Claims c
WHERE c.Status = 'Verified'
  AND NOT EXISTS (SELECT 1 FROM Reviews r WHERE r.ClaimID = c.ClaimID AND r.Decision = 'Approve');

-- DQ3. Rejected claims with no 'Reject' review.
SELECT c.ClaimID FROM Claims c
WHERE c.Status = 'Rejected'
  AND NOT EXISTS (SELECT 1 FROM Reviews r WHERE r.ClaimID = c.ClaimID AND r.Decision = 'Reject');

-- DQ4. Version rows whose PreviousText is identical to the claim's current text.
SELECT v.VersionID FROM Versions v
JOIN Claims c ON c.ClaimID = v.ClaimID
WHERE v.PreviousText = c.ClaimText;

-- DQ5. Claims with no evidence at all.
SELECT c.ClaimID FROM Claims c
LEFT JOIN Evidence e ON e.ClaimID = c.ClaimID
WHERE e.EvidenceID IS NULL;
