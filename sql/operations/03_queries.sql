-- =====================================================================
-- 03_queries.sql | Owner: Aseel | Branch: feature/sql-operations
-- Run AFTER schema + 02_seed_data.sql. Each query: purpose + expected result
-- (expected results are based on the seed data in 02_seed_data.sql).
-- UPDATE/DELETE demos are isolated: they use a disposable row (id 9001)
-- or run inside a transaction that is ROLLED BACK, so seed data stays intact.
-- =====================================================================
USE basmah_db;

-- ---------- A. SELECT / WHERE / ORDER BY --------------------------------
-- Q1. Purpose: list all claims. Expected: 12 rows.
SELECT claim_id, claim_text, status FROM Claims;

-- Q2. Purpose: WHERE filter - only verified claims. Expected: 5 rows (ids 2,7,8,10,12).
SELECT claim_id, claim_text FROM Claims WHERE status = 'Verified';

-- Q3. Purpose: ORDER BY + LIMIT - newest 5 claims. Expected: ids 12,11,10,9,8.
SELECT claim_id, claim_text, created_at FROM Claims ORDER BY created_at DESC LIMIT 5;

-- Q4. Purpose: LIKE search on claim text. Expected: 3 rows, ids 3, 7, 8 (contain "water"; LIKE is case-insensitive).
SELECT claim_id, claim_text FROM Claims WHERE claim_text LIKE '%Water%';

-- Q5. Purpose: AND / IN. Expected: Claims of projects 1 and 2 that are Pending or Disputed
--     (ids 1, 4, 9).
SELECT claim_id, project_id, status FROM Claims
WHERE project_id IN (1, 2) AND status IN ('Pending', 'Disputed')
ORDER BY claim_id;

-- ---------- B. JOINs -----------------------------------------------------
-- Q6. Purpose: INNER JOIN claim + project + creator. Expected: 12 rows.
SELECT c.claim_id, c.claim_text, p.title AS project, u.full_name AS created_by
FROM Claims c
JOIN Projects p ON p.project_id = c.project_id
JOIN Users u    ON u.user_id    = c.created_by
ORDER BY c.claim_id;

-- Q7. Purpose: claim + evidence + source (the core fact-checking view). Expected: 16 rows.
SELECT c.claim_id, c.claim_text, e.stance, s.title AS source_title, s.publisher
FROM Evidence e
JOIN Claims  c ON c.claim_id  = e.claim_id
JOIN Sources s ON s.source_id = e.source_id
ORDER BY c.claim_id, e.evidence_id;

-- Q8. Purpose: claim + reviewer + verdict. Expected: 12 rows.
SELECT c.claim_id, c.claim_text, u.full_name AS reviewer, r.verdict
FROM Reviews r
JOIN Claims c ON c.claim_id = r.claim_id
JOIN Users  u ON u.user_id  = r.reviewer_id
ORDER BY c.claim_id, r.review_id;

-- Q9. Purpose: LEFT JOIN - claims that have NOT been reviewed yet. Expected: ids 4 and 9.
SELECT c.claim_id, c.claim_text, c.status
FROM Claims c
LEFT JOIN Reviews r ON r.claim_id = c.claim_id
WHERE r.review_id IS NULL;

-- ---------- C. GROUP BY / aggregates / HAVING -----------------------------
-- Q10. Purpose: number of claims per status. Expected: Verified 5, Rejected 4, Disputed 1, Pending 2.
--      (Rejected = ids 3,5,6,11; Pending = ids 4,9)
SELECT status, COUNT(*) AS total_claims FROM Claims GROUP BY status;

-- Q11. Purpose: evidence count per claim, only claims with 2+ pieces of evidence.
--      Expected: claim 1 (2), 3 (2), 10 (2), 11 (2).
SELECT c.claim_id, c.claim_text, COUNT(e.evidence_id) AS evidence_count
FROM Claims c
JOIN Evidence e ON e.claim_id = c.claim_id
GROUP BY c.claim_id, c.claim_text
HAVING COUNT(e.evidence_id) >= 2
ORDER BY c.claim_id;

-- Q12. Purpose: claims per project with MIN/MAX date. Expected: 3 rows (4, 5, 3 claims).
SELECT p.title, COUNT(c.claim_id) AS claims, MIN(c.created_at) AS first_claim, MAX(c.created_at) AS last_claim
FROM Projects p
JOIN Claims c ON c.project_id = p.project_id
GROUP BY p.project_id, p.title;

-- Q13. Purpose: how many reviews each reviewer did. Expected: Hanan 6, Bayader 6.
SELECT u.full_name, COUNT(r.review_id) AS reviews_done
FROM Users u
JOIN Reviews r ON r.reviewer_id = u.user_id
GROUP BY u.user_id, u.full_name
ORDER BY reviews_done DESC;

-- Q14. Purpose: evidence stance summary per source. Expected: 8 rows (every source has evidence).
SELECT s.source_id, s.title,
       SUM(e.stance = 'Supports')    AS supports,
       SUM(e.stance = 'Contradicts') AS contradicts,
       SUM(e.stance = 'Neutral')     AS neutral
FROM Sources s
JOIN Evidence e ON e.source_id = s.source_id
GROUP BY s.source_id, s.title
ORDER BY s.source_id;

-- ---------- D. Subqueries ---------------------------------------------------
-- Q15. Purpose: claims that have at least one 'Contradicts' evidence. Expected: ids 1,3,5,6,11.
SELECT claim_id, claim_text FROM Claims
WHERE claim_id IN (SELECT claim_id FROM Evidence WHERE stance = 'Contradicts')
ORDER BY claim_id;

-- Q16. Purpose: claims with more evidence than the average per claim (16 evidence / 12 claims = 1.33).
--      Expected: claim ids 1, 3, 10, 11 (2 pieces each).
SELECT claim_id, COUNT(*) AS evidence_count
FROM Evidence
GROUP BY claim_id
HAVING COUNT(*) > (SELECT COUNT(*) FROM Evidence) / (SELECT COUNT(*) FROM Claims)
ORDER BY claim_id;

-- ---------- E. Versions -------------------------------------------------------
-- Q17. Purpose: latest version of each edited claim. Expected: claims 1, 2, 5, 7 with version_no 2.
SELECT v.claim_id, v.version_no, v.claim_text
FROM Versions v
WHERE v.version_no = (SELECT MAX(v2.version_no) FROM Versions v2 WHERE v2.claim_id = v.claim_id)
ORDER BY v.claim_id;

-- ---------- F. UPDATE (safe) -----------------------------------------------------
-- Q18. Purpose: change a claim status with a scoped WHERE (primary key) inside a transaction,
--      then ROLLBACK so seed data is unchanged. Expected: claim 4 shows 'Verified' inside the
--      transaction, and 'Pending' again after ROLLBACK.
START TRANSACTION;
UPDATE Claims SET status = 'Verified' WHERE claim_id = 4;
SELECT claim_id, status FROM Claims WHERE claim_id = 4;   -- Verified
ROLLBACK;
SELECT claim_id, status FROM Claims WHERE claim_id = 4;   -- Pending again

-- ---------- G. DELETE (safe, isolated) -----------------------------------------------
-- Q19. Purpose: insert a disposable claim (id 9001, no children) then delete ONLY that row.
--      Expected: 1 row after insert, 0 rows after delete. FK-safe: nothing references claim 9001.
INSERT INTO Claims (claim_id, project_id, created_by, claim_text, status)
VALUES (9001, 1, 3, 'DISPOSABLE demo claim - safe to delete', 'Pending');
SELECT claim_id, claim_text FROM Claims WHERE claim_id = 9001;
DELETE FROM Claims WHERE claim_id = 9001;
SELECT COUNT(*) AS remaining_demo_rows FROM Claims WHERE claim_id = 9001;   -- 0
