-- =====================================================================
-- 02b_data_quality_checks.sql | Owner: Aseel | Branch: feature/sql-operations
-- Seed-data validation. EVERY query below should return 0 rows.
-- A returned row = a data problem (broken link or inconsistent record).
-- Run after 02_seed_data.sql.
-- =====================================================================
USE basmah_db;

-- DQ1. Evidence whose source belongs to a different project than its claim.
SELECT e.evidence_id FROM Evidence e
JOIN Claims c  ON c.claim_id  = e.claim_id
JOIN Sources s ON s.source_id = e.source_id
WHERE c.project_id <> s.project_id;

-- DQ2. Verified claims with no 'Approve' review.
SELECT c.claim_id FROM Claims c
WHERE c.status = 'Verified'
  AND NOT EXISTS (SELECT 1 FROM Reviews r WHERE r.claim_id = c.claim_id AND r.verdict = 'Approve');

-- DQ3. Rejected claims with no 'Reject' review.
SELECT c.claim_id FROM Claims c
WHERE c.status = 'Rejected'
  AND NOT EXISTS (SELECT 1 FROM Reviews r WHERE r.claim_id = c.claim_id AND r.verdict = 'Reject');

-- DQ4. Latest version text that differs from the current claim text.
SELECT v.claim_id FROM Versions v
JOIN Claims c ON c.claim_id = v.claim_id
WHERE v.version_no = (SELECT MAX(v2.version_no) FROM Versions v2 WHERE v2.claim_id = v.claim_id)
  AND v.claim_text <> c.claim_text;

-- DQ5. Claims with no evidence at all.
SELECT c.claim_id FROM Claims c
LEFT JOIN Evidence e ON e.claim_id = c.claim_id
WHERE e.evidence_id IS NULL;