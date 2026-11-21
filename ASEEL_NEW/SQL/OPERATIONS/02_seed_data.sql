-- =====================================================================
-- 02_seed_data.sql | Owner: Aseel | Branch: feature/sql-operations
-- Sample data for BASMAH, written against Jumanah's schema (01_create_tables.sql).
-- Insert order (parent before child):
--   Users -> Projects -> Sources -> Claims -> Evidence -> Reviews -> Versions
-- IDs are fixed so Hanan and Bayader can reference them.
-- IDs 9000+ are RESERVED for disposable test rows (never used here).
-- ActivityLogs is intentionally left empty (filled by Bayader's trigger).
-- Run AFTER the schema and BEFORE the trigger script.
-- All data is fictional sample data for a course project.
--
-- Provisional values (not finalized in the schema, pending team agreement):
--   Users.Role        : Admin, Researcher, Reviewer
--   Claims.Status     : Pending, Verified, Disputed, Rejected
--   Evidence.EvidenceType : Study, Expert Statement, Reference Data, Social Media Post
--   Reviews.Decision  : Approve, Reject, NeedsMoreEvidence
--   Sources.SourceType: Article, Report, Website, Book, Dataset
-- =====================================================================
USE BASMAH;

-- 1) Users (6)
INSERT INTO Users (UserID, FullName, Email, Role) VALUES
(1, 'Diyam Almneea',    'diyam@basma.test',   'Admin'),
(2, 'Jumanah Alotaibi', 'jumanah@basma.test', 'Admin'),
(3, 'Aseel Alotaibi',  'aseel@basma.test',   'Researcher'),
(4, 'Hanan Almutairi',   'hanan@basma.test',   'Reviewer'),
(5, 'Bayader Alotaibi', 'bayader@basma.test', 'Reviewer'),
(6, 'Sara Alshayea',   'sara@basma.test',    'Researcher');

-- 2) Projects (3)
INSERT INTO Projects (ProjectID, ProjectName, Description, OwnerID) VALUES
(1, 'Health Myths Check',     'Verifying common health claims shared on social media.', 3),
(2, 'Science Facts Check',    'Verifying popular science and space claims.',            6),
(3, 'Geography Basics Check', 'Verifying basic geography claims.',                      1);

-- 3) Sources (8)
INSERT INTO Sources (SourceID, Title, URL, SourceType) VALUES
(1, 'Vitamin C and the Common Cold: Review',     'https://example.org/vitc-review',   'Report'),
(2, 'Sleep Needs of Adults',                     'https://example.org/sleep-needs',   'Article'),
(3, 'Social Media Health Tips (viral post)',     'https://example.org/viral-tips',    'Website'),
(4, 'Seeing Human Structures from Orbit',        'https://example.org/orbit-visible', 'Article'),
(5, 'The Brain: Myths and Facts',                'https://example.org/brain-book',    'Book'),
(6, 'Boiling Point of Water and Altitude',       'https://example.org/boiling',       'Report'),
(7, 'Atlas of Countries and Capitals',           'https://example.org/atlas',         'Book'),
(8, 'World Capitals Dataset',                    'https://example.org/capitals-data', 'Dataset');

-- 4) Claims (12)
INSERT INTO Claims (ClaimID, ProjectID, CreatedBy, ClaimText, Status) VALUES
(1,  1, 3, 'Vitamin C prevents the common cold.',                               'Disputed'),
(2,  1, 3, 'Adults need at least 7 hours of sleep per night.',                  'Verified'),
(3,  1, 6, 'Drinking cold water causes the flu.',                               'Rejected'),
(4,  1, 6, 'Eating carrots greatly improves night vision.',                     'Pending'),
(5,  2, 6, 'The Great Wall of China is visible from space with the naked eye.', 'Rejected'),
(6,  2, 6, 'Humans use only 10 percent of their brains.',                       'Rejected'),
(7,  2, 3, 'Water boils at 100 degrees Celsius at sea level.',                  'Verified'),
(8,  2, 3, 'Water boils at a lower temperature at high altitude.',              'Verified'),
(9,  2, 6, 'Lightning never strikes the same place twice.',                     'Pending'),
(10, 3, 1, 'Riyadh is the capital of Saudi Arabia.',                            'Verified'),
(11, 3, 1, 'Sydney is the capital of Australia.',                               'Rejected'),
(12, 3, 3, 'Cairo is the capital of Egypt.',                                    'Verified');

-- 5) Evidence (16)
INSERT INTO Evidence (EvidenceID, ClaimID, SourceID, EvidenceText, EvidenceType) VALUES
(1,  1,  1, 'Regular vitamin C did not reduce how often most people caught colds.',        'Study'),
(2,  1,  3, 'Viral post says vitamin C stops every cold (no data given).',                 'Social Media Post'),
(3,  2,  2, 'Most adults function best with seven or more hours of sleep.',                'Study'),
(4,  3,  3, 'Viral post claims cold water causes the flu (no data given).',                'Social Media Post'),
(5,  3,  1, 'Respiratory infections are caused by viruses, not by the temperature of drinks.', 'Study'),
(6,  4,  3, 'Post repeats the carrot claim without sources.',                              'Social Media Post'),
(7,  5,  4, 'Astronauts report the wall is not visible to the naked eye from orbit.',      'Expert Statement'),
(8,  6,  5, 'Imaging shows activity across virtually all brain regions.',                  'Study'),
(9,  7,  6, 'Pure water boils at 100 C at standard sea-level pressure.',                   'Reference Data'),
(10, 8,  6, 'Lower air pressure at altitude lowers the boiling point.',                    'Reference Data'),
(11, 9,  3, 'Post repeats the lightning claim without sources.',                           'Social Media Post'),
(12, 10, 7, 'Atlas lists Riyadh as the capital of Saudi Arabia.',                          'Reference Data'),
(13, 10, 8, 'Dataset row: Saudi Arabia - Riyadh.',                                         'Reference Data'),
(14, 11, 7, 'Atlas lists Canberra as the capital of Australia.',                           'Reference Data'),
(15, 11, 8, 'Dataset row: Australia - Canberra.',                                          'Reference Data'),
(16, 12, 8, 'Dataset row: Egypt - Cairo.',                                                 'Reference Data');

-- 6) Reviews (12). Claims 4 and 9 intentionally have NO review (for LEFT JOIN demos).
INSERT INTO Reviews (ReviewID, ClaimID, ReviewerID, Decision, ReviewDate) VALUES
(1,  1,  4, 'NeedsMoreEvidence', '2026-10-01 10:00:00'),
(2,  1,  5, 'Reject',            '2026-10-01 11:00:00'),
(3,  2,  4, 'Approve',           '2026-10-02 10:00:00'),
(4,  3,  5, 'Reject',            '2026-10-02 11:00:00'),
(5,  5,  4, 'Reject',            '2026-10-03 10:00:00'),
(6,  6,  5, 'Reject',            '2026-10-03 11:00:00'),
(7,  7,  4, 'Approve',           '2026-10-04 10:00:00'),
(8,  8,  5, 'Approve',           '2026-10-04 11:00:00'),
(9,  10, 4, 'Approve',           '2026-10-05 10:00:00'),
(10, 11, 5, 'Reject',            '2026-10-05 11:00:00'),
(11, 12, 4, 'Approve',           '2026-10-05 12:00:00'),
(12, 12, 5, 'Approve',           '2026-10-05 13:00:00');

-- 7) Versions (5). PreviousText = the claim text BEFORE the edit.
INSERT INTO Versions (VersionID, ClaimID, ChangedBy, PreviousText, ChangedAt) VALUES
(1, 1, 3, 'Vitamin C kills cold viruses.',                      '2026-09-22 10:00:00'),
(2, 1, 3, 'Vitamin C cures the common cold.',                   '2026-09-24 10:00:00'),
(3, 2, 3, 'Adults need 8 hours of sleep.',                      '2026-09-25 10:00:00'),
(4, 5, 6, 'The Great Wall of China is visible from space.',     '2026-09-26 10:00:00'),
(5, 7, 3, 'Water boils at 100 degrees Celsius.',                '2026-09-27 09:00:00');
