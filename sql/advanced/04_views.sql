USE BASMAH;

CREATE OR REPLACE VIEW vw_ClaimEvidenceSources AS
SELECT
    c.ClaimID,
    c.ClaimText,
    c.Status,
    e.EvidenceID,
    e.EvidenceText,
    e.EvidenceType,
    s.SourceID,
    s.Title AS SourceTitle,
    s.URL AS SourceURL
FROM Claims AS c
INNER JOIN Evidence AS e
    ON c.ClaimID = e.ClaimID
INNER JOIN Sources AS s
    ON e.SourceID = s.SourceID;