-- =====================================================================
-- 02_seed_data.sql  | Owner: Aseel | Branch: feature/sql-operations
-- Sample data for BASMA. Parent-before-child order:
-- Users -> Projects -> Sources -> Claims -> Evidence -> Reviews -> Versions
-- Stable IDs are explicit so Hanan and Bayader can reference them.
-- IDs 9000+ are RESERVED for disposable test rows (never used here).
-- Run AFTER the schema and BEFORE triggers (so no audit rows are produced).
-- All data is fictional sample data for a course project.
-- =====================================================================
USE basmah_db;

-- 1) Users (6) ---------------------------------------------------------
INSERT INTO Users (user_id, full_name, email, role, created_at) VALUES
(1, 'Diyam Alharbi',   'diyam@basma.test',   'Admin',      '2026-09-01 09:00:00'),
(2, 'Jumanah Alotaibi','jumanah@basma.test', 'Admin',      '2026-09-01 09:05:00'),
(3, 'Aseel Alqahtani', 'aseel@basma.test',   'Researcher', '2026-09-02 10:00:00'),
(4, 'Hanan Alshehri',  'hanan@basma.test',   'Reviewer',   '2026-09-02 10:10:00'),
(5, 'Bayader Aldosari','bayader@basma.test', 'Reviewer',   '2026-09-02 10:20:00'),
(6, 'Sara Almutairi',  'sara@basma.test',    'Researcher', '2026-09-03 11:00:00');

-- 2) Projects (3) ------------------------------------------------------
INSERT INTO Projects (project_id, owner_id, title, description, status, created_at) VALUES
(1, 3, 'Health Myths Check',     'Verifying common health claims shared on social media.', 'Active',    '2026-09-10 09:00:00'),
(2, 6, 'Science Facts Check',    'Verifying popular science and space claims.',            'Active',    '2026-09-12 09:00:00'),
(3, 1, 'Geography Basics Check', 'Verifying basic geography claims.',                       'Completed', '2026-09-15 09:00:00');

-- 3) Sources (8) -------------------------------------------------------
INSERT INTO Sources (source_id, project_id, title, source_type, publisher, url, publication_date) VALUES
(1, 1, 'Vitamin C and the Common Cold: Review',        'Report',  'Sample Health Org',    'https://example.org/vitc-review',   '2023-03-15'),
(2, 1, 'Sleep Needs of Adults',                        'Article', 'Sample Medical Journal','https://example.org/sleep-needs',  '2024-01-20'),
(3, 1, 'Social Media Health Tips (viral post)',        'Website', 'Unknown Blog',         'https://example.org/viral-tips',    '2025-05-02'),
(4, 2, 'Seeing Human Structures from Orbit',           'Article', 'Sample Space Agency',  'https://example.org/orbit-visible', '2022-08-10'),
(5, 2, 'The Brain: Myths and Facts',                   'Book',    'Sample University Press','https://example.org/brain-book',  '2021-06-01'),
(6, 2, 'Boiling Point of Water and Altitude',          'Report',  'Sample Science Institute','https://example.org/boiling',    '2020-11-30'),
(7, 3, 'Atlas of Countries and Capitals',              'Book',    'Sample Atlas Publisher','https://example.org/atlas',        '2024-09-09'),
(8, 3, 'World Capitals Dataset',                       'Dataset', 'Sample Open Data',      'https://example.org/capitals-data', '2025-02-14');

-- 4) Claims (12) -------------------------------------------------------
INSERT INTO Claims (claim_id, project_id, created_by, claim_text, status, created_at) VALUES
(1,  1, 3, 'Vitamin C prevents the common cold.',                          'Disputed', '2026-09-20 10:00:00'),
(2,  1, 3, 'Adults need at least 7 hours of sleep per night.',             'Verified', '2026-09-20 10:30:00'),
(3,  1, 6, 'Drinking cold water causes the flu.',                          'Rejected', '2026-09-21 09:00:00'),
(4,  1, 6, 'Eating carrots greatly improves night vision.',                'Pending',  '2026-09-21 09:30:00'),
(5,  2, 6, 'The Great Wall of China is visible from space with the naked eye.', 'Rejected', '2026-09-22 10:00:00'),
(6,  2, 6, 'Humans use only 10 percent of their brains.',                  'Rejected', '2026-09-22 10:30:00'),
(7,  2, 3, 'Water boils at 100 degrees Celsius at sea level.',             'Verified', '2026-09-23 09:00:00'),
(8,  2, 3, 'Water boils at a lower temperature at high altitude.',         'Verified', '2026-09-23 09:30:00'),
(9,  2, 6, 'Lightning never strikes the same place twice.',                'Pending',  '2026-09-24 09:00:00'),
(10, 3, 1, 'Riyadh is the capital of Saudi Arabia.',                       'Verified', '2026-09-25 09:00:00'),
(11, 3, 1, 'Sydney is the capital of Australia.',                          'Rejected', '2026-09-25 09:30:00'),
(12, 3, 3, 'Cairo is the capital of Egypt.',                               'Verified', '2026-09-26 09:00:00');

-- 5) Evidence (16) -----------------------------------------------------
INSERT INTO Evidence (evidence_id, claim_id, source_id, stance, excerpt, added_by, added_at) VALUES
(1,  1, 1, 'Contradicts', 'Regular vitamin C did not reduce how often most people caught colds.',        3, '2026-09-27 09:00:00'),
(2,  1, 3, 'Supports',    'Viral post says vitamin C stops every cold (no data given).',                 3, '2026-09-27 09:10:00'),
(3,  2, 2, 'Supports',    'Most adults function best with seven or more hours of sleep.',                3, '2026-09-27 09:20:00'),
(4,  3, 3, 'Supports',    'Viral post claims cold water causes flu (no data given).',                    6, '2026-09-27 09:30:00'),
(5,  3, 1, 'Contradicts', 'Respiratory infections are caused by viruses, not by temperature of drinks.', 6, '2026-09-27 09:40:00'),
(6,  4, 3, 'Neutral',     'Post repeats the carrot claim without sources.',                              6, '2026-09-27 09:50:00'),
(7,  5, 4, 'Contradicts', 'Astronauts report the wall is not visible to the naked eye from orbit.',      6, '2026-09-28 09:00:00'),
(8,  6, 5, 'Contradicts', 'Imaging shows activity across virtually all brain regions.',                  6, '2026-09-28 09:10:00'),
(9,  7, 6, 'Supports',    'Pure water boils at 100 C at standard sea-level pressure.',                   3, '2026-09-28 09:20:00'),
(10, 8, 6, 'Supports',    'Lower air pressure at altitude lowers the boiling point.',                    3, '2026-09-28 09:30:00'),
(11, 9, 4, 'Neutral',     'Tall structures are struck repeatedly; claim not directly addressed.',        6, '2026-09-28 09:40:00'),
(12, 10, 7, 'Supports',   'Atlas lists Riyadh as the capital of Saudi Arabia.',                          1, '2026-09-29 09:00:00'),
(13, 10, 8, 'Supports',   'Dataset row: Saudi Arabia - Riyadh.',                                         1, '2026-09-29 09:10:00'),
(14, 11, 7, 'Contradicts','Atlas lists Canberra as the capital of Australia.',                           3, '2026-09-29 09:20:00'),
(15, 11, 8, 'Contradicts','Dataset row: Australia - Canberra.',                                          3, '2026-09-29 09:30:00'),
(16, 12, 8, 'Supports',   'Dataset row: Egypt - Cairo.',                                                 3, '2026-09-29 09:40:00');

-- 6) Reviews (12) ------------------------------------------------------
-- Claims 4 and 9 intentionally have NO review (useful for LEFT JOIN demos).
INSERT INTO Reviews (review_id, claim_id, reviewer_id, verdict, comments, reviewed_at) VALUES
(1,  1, 4, 'NeedsMoreEvidence', 'Evidence is mixed; add a stronger source.',        '2026-10-01 10:00:00'),
(2,  1, 5, 'Reject',            'Strong source contradicts the claim.',             '2026-10-01 11:00:00'),
(3,  2, 4, 'Approve',           'Supported by a reliable article.',                 '2026-10-02 10:00:00'),
(4,  3, 5, 'Reject',            'Only supported by an unreliable blog.',            '2026-10-02 11:00:00'),
(5,  5, 4, 'Reject',            'Contradicted by orbital observations.',            '2026-10-03 10:00:00'),
(6,  6, 5, 'Reject',            'Well-known myth, contradicted by imaging.',        '2026-10-03 11:00:00'),
(7,  7, 4, 'Approve',           'Standard physics fact.',                           '2026-10-04 10:00:00'),
(8,  8, 5, 'Approve',           'Consistent with the pressure explanation.',        '2026-10-04 11:00:00'),
(9,  10, 4, 'Approve',          'Two independent sources agree.',                   '2026-10-05 10:00:00'),
(10, 11, 5, 'Reject',           'Two sources list Canberra.',                       '2026-10-05 11:00:00'),
(11, 12, 4, 'Approve',          'Dataset confirms.',                                '2026-10-05 12:00:00'),
(12, 12, 5, 'Approve',          'Agree with Hanan.',                                '2026-10-05 13:00:00');

-- 7) Versions (8) ------------------------------------------------------
INSERT INTO Versions (version_id, claim_id, version_no, claim_text, changed_by, change_note, created_at) VALUES
(1, 1, 1, 'Vitamin C cures the common cold.',                         3, 'Initial wording',                '2026-09-20 10:00:00'),
(2, 1, 2, 'Vitamin C prevents the common cold.',                      3, 'Changed cures to prevents',      '2026-09-24 10:00:00'),
(3, 2, 1, 'Adults need 8 hours of sleep.',                            3, 'Initial wording',                '2026-09-20 10:30:00'),
(4, 2, 2, 'Adults need at least 7 hours of sleep per night.',         3, 'Made wording match source',      '2026-09-25 10:00:00'),
(5, 5, 1, 'The Great Wall of China is visible from space.',           6, 'Initial wording',                '2026-09-22 10:00:00'),
(6, 5, 2, 'The Great Wall of China is visible from space with the naked eye.', 6, 'Clarified naked eye',   '2026-09-26 10:00:00'),
(7, 7, 1, 'Water boils at 100 degrees Celsius.',                      3, 'Initial wording',                '2026-09-23 09:00:00'),
(8, 7, 2, 'Water boils at 100 degrees Celsius at sea level.',         3, 'Added sea level condition',      '2026-09-27 09:00:00');

-- Optional: keep AUTO_INCREMENT counters clear of the reserved 9000+ test range.
-- (Nothing needed: next auto ids continue from 7, 4, 9, 13, 17, 13, 9.)
