-- =====================================================================
-- 03_queries.sql | Owner: Aseel | Branch: feature/sql-operations
-- Written against Jumanah's schema (01_create_tables.sql). Run AFTER schema + 02_seed_data.sql.
-- Each query: purpose + expected result (based on the seed data).
-- UPDATE/DELETE demos are isolated: they use a disposable row (id 9001)
-- or run inside a transaction that is ROLLED BACK, so seed data stays intact.
-- =====================================================================
USE BASMAH;

-- ---------- A. SELECT / WHERE / ORDER BY --------------------------------
-- Q1. Purpose: list all claims. Expected: 12 rows.
SELECT ClaimID, ClaimText, Status FROM Claims;

-- Q2. Purpose: WHERE filter - only verified claims. Expected: 5 rows (ids 2,7,8,10,12).
SELECT ClaimID, ClaimText FROM Claims WHERE Status = 'Verified';

-- Q3. Purpose: ORDER BY + LIMIT - the 5 most recently added claims (highest IDs; Claims has no date column).
--     Expected: ids 12,11,10,9,8.
SELECT ClaimID, ClaimText FROM Claims ORDER BY ClaimID DESC LIMIT 5;

-- Q4. Purpose: LIKE search on claim text. Expected: 3 rows, ids 3, 7, 8 (contain "water"; LIKE is case-insensitive).
SELECT ClaimID, ClaimText FROM Claims WHERE ClaimText LIKE '%Water%';

-- Q5. Purpose: AND / IN. Expected: claims of projects 1 and 2 that are Pending or Disputed (ids 1, 4, 9).
SELECT ClaimID, ProjectID, Status FROM Claims
WHERE ProjectID IN (1, 2) AND Status IN ('Pending', 'Disputed')
ORDER BY ClaimID;

-- ---------- B. JOINs -----------------------------------------------------
-- Q6. Purpose: INNER JOIN claim + project + creator. Expected: 12 rows.
SELECT c.ClaimID, c.ClaimText, p.ProjectName, u.FullName AS CreatedByName
FROM Claims c
JOIN Projects p ON p.ProjectID = c.ProjectID
JOIN Users u    ON u.UserID    = c.CreatedBy
ORDER BY c.ClaimID;

-- Q7. Purpose: claim + evidence + source (the core fact-checking view). Expected: 16 rows.
SELECT c.ClaimID, c.ClaimText, e.EvidenceType, s.Title AS SourceTitle, s.SourceType
FROM Evidence e
JOIN Claims  c ON c.ClaimID  = e.ClaimID
JOIN Sources s ON s.SourceID = e.SourceID
ORDER BY c.ClaimID, e.EvidenceID;

-- Q8. Purpose: claim + reviewer + decision. Expected: 12 rows.
SELECT c.ClaimID, c.ClaimText, u.FullName AS Reviewer, r.Decision
FROM Reviews r
JOIN Claims c ON c.ClaimID = r.ClaimID
JOIN Users  u ON u.UserID  = r.ReviewerID
ORDER BY c.ClaimID, r.ReviewID;

-- Q9. Purpose: LEFT JOIN - claims that have NOT been reviewed yet. Expected: ids 4 and 9.
SELECT c.ClaimID, c.ClaimText, c.Status
FROM Claims c
LEFT JOIN Reviews r ON r.ClaimID = c.ClaimID
WHERE r.ReviewID IS NULL;

-- ---------- C. GROUP BY / aggregates / HAVING -----------------------------
-- Q10. Purpose: number of claims per status. Expected: Verified 5, Rejected 4, Pending 2, Disputed 1.
SELECT Status, COUNT(*) AS TotalClaims FROM Claims GROUP BY Status;

-- Q11. Purpose: evidence count per claim, only claims with 2+ pieces of evidence.
--      Expected: claims 1, 3, 10, 11 (2 each).
SELECT c.ClaimID, c.ClaimText, COUNT(e.EvidenceID) AS EvidenceCount
FROM Claims c
JOIN Evidence e ON e.ClaimID = c.ClaimID
GROUP BY c.ClaimID, c.ClaimText
HAVING COUNT(e.EvidenceID) >= 2
ORDER BY c.ClaimID;

-- Q12. Purpose: claims per project and how many are Verified (COUNT + SUM).
--      Expected: Health Myths 4 claims / 1 verified; Science Facts 5 / 2; Geography Basics 3 / 2.
SELECT p.ProjectName, COUNT(c.ClaimID) AS Claims, SUM(c.Status = 'Verified') AS VerifiedClaims
FROM Projects p
JOIN Claims c ON c.ProjectID = p.ProjectID
GROUP BY p.ProjectID, p.ProjectName
ORDER BY p.ProjectID;

-- Q13. Purpose: how many reviews each reviewer did. Expected: Hanan 6, Bayader 6.
SELECT u.FullName, COUNT(r.ReviewID) AS ReviewsDone
FROM Users u
JOIN Reviews r ON r.ReviewerID = u.UserID
GROUP BY u.UserID, u.FullName
ORDER BY ReviewsDone DESC;

-- Q14. Purpose: evidence-type summary per source. Expected: 8 rows (every source is used).
--      e.g. source 3 (viral post) = 4 social media posts; source 8 (dataset) = 3 reference data.
SELECT s.SourceID, s.Title,
       SUM(e.EvidenceType = 'Study')             AS Studies,
       SUM(e.EvidenceType = 'Expert Statement')  AS ExpertStatements,
       SUM(e.EvidenceType = 'Reference Data')    AS ReferenceData,
       SUM(e.EvidenceType = 'Social Media Post') AS SocialMediaPosts
FROM Sources s
JOIN Evidence e ON e.SourceID = s.SourceID
GROUP BY s.SourceID, s.Title
ORDER BY s.SourceID;

-- ---------- D. Subqueries ---------------------------------------------------
-- Q15. Purpose: claims that received at least one 'Reject' review. Expected: ids 1,3,5,6,11.
SELECT ClaimID, ClaimText FROM Claims
WHERE ClaimID IN (SELECT ClaimID FROM Reviews WHERE Decision = 'Reject')
ORDER BY ClaimID;

-- Q16. Purpose: claims with more evidence than the average per claim (16 evidence / 12 claims = 1.33).
--      Expected: claim ids 1, 3, 10, 11 (2 pieces each).
SELECT ClaimID, COUNT(*) AS EvidenceCount
FROM Evidence
GROUP BY ClaimID
HAVING COUNT(*) > (SELECT COUNT(*) FROM Evidence) / (SELECT COUNT(*) FROM Claims)
ORDER BY ClaimID;

-- ---------- E. Versions -------------------------------------------------------
-- Q17. Purpose: how many times each claim was edited, with its current text. Expected: 4 rows:
--      claim 1 = 2 edits, claims 2, 5 and 7 = 1 edit each.
SELECT c.ClaimID, c.ClaimText, COUNT(v.VersionID) AS Edits, MAX(v.ChangedAt) AS LastChange
FROM Claims c
JOIN Versions v ON v.ClaimID = c.ClaimID
GROUP BY c.ClaimID, c.ClaimText
ORDER BY c.ClaimID;

-- ---------- F. UPDATE (safe) -----------------------------------------------------
-- Q18. Purpose: change a claim status with a scoped WHERE (primary key) inside a transaction,
--      then ROLLBACK so seed data is unchanged. Expected: claim 4 shows 'Verified' inside the
--      transaction, and 'Pending' again after ROLLBACK.
START TRANSACTION;
UPDATE Claims SET Status = 'Verified' WHERE ClaimID = 4;
SELECT ClaimID, Status FROM Claims WHERE ClaimID = 4;   -- Verified
ROLLBACK;
SELECT ClaimID, Status FROM Claims WHERE ClaimID = 4;   -- Pending again

-- ---------- G. DELETE (safe, isolated) -----------------------------------------------
-- Q19. Purpose: insert a disposable claim (id 9001, no children) then delete ONLY that row.
--      Expected: 1 row after insert, 0 rows after delete. Nothing references claim 9001.
INSERT INTO Claims (ClaimID, ProjectID, CreatedBy, ClaimText, Status)
VALUES (9001, 1, 3, 'DISPOSABLE demo claim - safe to delete', 'Pending');
SELECT ClaimID, ClaimText FROM Claims WHERE ClaimID = 9001;
DELETE FROM Claims WHERE ClaimID = 9001;
SELECT COUNT(*) AS RemainingDemoRows FROM Claims WHERE ClaimID = 9001;   -- 0
