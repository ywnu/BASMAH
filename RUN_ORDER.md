# BASMAH — SQL Integration Run Order

**Owner:** Jumanah Alotaibi  
**Branch:** `feature/schema-integration`  
**Status:** Integration instructions prepared; **full clean-database regression test not yet executed**.

## Before running

- Use MySQL 8.0 or a compatible MySQL server and MySQL Workbench / MySQL CLI.
- Execute this plan on an **empty, disposable test database/server environment**. Do **not** run `DROP DATABASE` against the team's existing local data. The schema creates a database named `BASMAH`; choose a test instance that does not already have a valuable `BASMAH` database.
- Pull/download the **specific listed files from their own branches**. They are not yet all present together in `feature/schema-integration` or `main`.
- The seed uses fixed IDs: **run it once only** against an empty schema. `CREATE TABLE IF NOT EXISTS` does not migrate columns.
- Pause if the team approves a change to columns, CHECK constraints, or `PasswordHash`: update the schema **and** affected seed/API code first.

## Source files and execution sequence

| Step | Owner / branch | File | Purpose |
| --- | --- | --- | --- |
| 1 | Jumanah — `feature/schema-integration` | `sql/schema/01_create_tables.sql` | Creates `BASMAH`, 8 tables, 10 FKs |
| 2 | Aseel — `feature/sql-operations` | `ASEEL_NEW/SQL/OPERATIONS/02_seed_data.sql` | Inserts shared demo records; leave `ActivityLogs` empty |
| 3 | Aseel — `feature/sql-operations` | `ASEEL_NEW/SQL/OPERATIONS/02b_data_quality_checks.sql` | 5 checks; each query returns **0 rows** |
| 4 | Aseel — `feature/sql-operations` | `ASEEL_NEW/SQL/OPERATIONS/03_queries.sql` | 19 SQL demonstrations; Q18 rolls back; Q19 inserts/deletes a disposable claim |
| 5 | Bayader — `feature/views-triggers-indexes` | `sql/advanced/04_views.sql` | Creates `vw_ClaimEvidenceSources` |
| 6 | Bayader — `feature/views-triggers-indexes` | `sql/advanced/05_triggers.sql` | Creates `trg_claim_after_insert` on `Claims` |
| 7 | Bayader — `feature/views-triggers-indexes` | `sql/advanced/06_indexes.sql` | Creates `idx_claims_status` |
| 8 | Hanan — `feature/integrity-transactions` | `docs/deletion_policy.md` | Review documented FK/COMMIT/ROLLBACK/constraint tests and confirm policy; **this is documentation, not an executable SQL script** |
| 9 | Jumanah + team | Verification and final regression below | Check counts, view, trigger, index, integrity, and evidence |

**Why Aseel's queries precede the trigger:** Q19 inserts a throwaway claim. If run after the trigger is installed, its audit record persists even when the claim is later deleted. Running Q19 before installing Bayader's trigger makes initial audit-log counts predictable. Subsequent new claims should generate audit entries.

**Do not use the legacy files** under `sql/operations/` on Aseel's branch for this run. In particular, the old seed uses `basmah_db` and incompatible column names; use `ASEEL_NEW/SQL/OPERATIONS/` until the team consolidates the approved paths.

## Checkpoint A — schema and seed

Run after steps 1–2:

```sql
USE BASMAH;
SHOW TABLES;

SELECT COUNT(*) AS TotalTables
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'BASMAH' AND TABLE_TYPE = 'BASE TABLE';

SELECT COUNT(*) AS TotalForeignKeys
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'BASMAH' AND REFERENCED_TABLE_NAME IS NOT NULL;

SELECT 'Users' AS TableName, COUNT(*) AS RowCount FROM Users
UNION ALL SELECT 'Projects', COUNT(*) FROM Projects
UNION ALL SELECT 'Sources', COUNT(*) FROM Sources
UNION ALL SELECT 'Claims', COUNT(*) FROM Claims
UNION ALL SELECT 'Evidence', COUNT(*) FROM Evidence
UNION ALL SELECT 'Reviews', COUNT(*) FROM Reviews
UNION ALL SELECT 'Versions', COUNT(*) FROM Versions
UNION ALL SELECT 'ActivityLogs', COUNT(*) FROM ActivityLogs;
```

Expected: **8 tables**, **10 foreign keys**; row counts **Users 6, Projects 3, Sources 8, Claims 12, Evidence 16, Reviews 12, Versions 5, ActivityLogs 0**.

For step 3, **each of DQ1–DQ5 should return 0 rows**. Step 4's Q18 and Q19 should leave the original seed rows unchanged.

## Checkpoint B — view, trigger and index

After steps 5–7, execute on the **disposable test database**:

```sql
USE BASMAH;

-- The view joins evidence and sources; 16 seed evidence rows are expected.
SELECT COUNT(*) AS ViewRows FROM vw_ClaimEvidenceSources;

-- Check the installed index (and see Bayader's EXPLAIN evidence).
SHOW INDEX FROM Claims WHERE Key_name = 'idx_claims_status';

-- Trigger smoke test. The trigger writes an audit log as part of this INSERT.
-- The entire test is rolled back afterwards.
START TRANSACTION;
INSERT INTO Claims (ClaimID, ProjectID, CreatedBy, ClaimText, Status)
VALUES (9301, 1, 3, 'INTEGRATION_SMOKE_TEST', 'Pending');

SELECT LogID, UserID, Action, ActionDate
FROM ActivityLogs
WHERE UserID = 3 AND Action = 'Created claim ID: 9301';
-- Expected: exactly 1 row inside the transaction.

ROLLBACK;

SELECT COUNT(*) AS RemainingTestClaims
FROM Claims WHERE ClaimID = 9301;
SELECT COUNT(*) AS RemainingTestLogs
FROM ActivityLogs
WHERE UserID = 3 AND Action = 'Created claim ID: 9301';
-- Expected: 0 and 0.
```

A passed trigger smoke test confirms the specific audit insert and rollback behavior. Also review Hanan's FK/constraint test evidence and run approved tests on disposable rows. Do not delete real data to check `RESTRICT`.

## Checkpoint C — integration handoff

- Confirm the **actual** approved values for `Role`, `Status`, `Decision`, `EvidenceType`, and `SourceType`. Aseel's values are currently provisional; there are **no CHECK constraints** in the baseline DDL.
- Confirm Hanan's proposed **ON DELETE RESTRICT / ON UPDATE CASCADE** for all 10 FKs with the team before declaring schema freeze.
- Bayader's audit trigger requires `Claims.CreatedBy` to reference an existing user; the current `ActivityLogs.UserID NOT NULL` is compatible.
- Decide whether email/password login is part of scope. `Users.PasswordHash` is **not** in the current schema. If added, coordinate seed migration and backend hashing.
- Have Aseel upload her FastAPI/API documentation branch and coordinate endpoint field names; do not claim verified API↔MySQL integration until code is committed and retested.
- Have Deem replace/mock-data frontend calls with the agreed backend API and document successful end-to-end flows.
- Collect test screenshots/logs, resolve differences, review PRs, then integrate **approved** code into `main`.

## Troubleshooting and safety

- **Table exists but changes are missing:** `IF NOT EXISTS` does not modify the table. Use a reviewed `ALTER TABLE` migration or a new disposable database; never erase your working one.
- **Duplicate primary key on seed:** likely seeded twice or used a nonempty database. Stop; don't delete user data to make the script pass.
- **Unknown column/table from Aseel's files:** likely running the legacy `sql/operations/` script instead of `ASEEL_NEW/SQL/OPERATIONS/`.
- **Unexpected audit log after demo DELETE:** check whether Q19 ran after the trigger was installed; audit trails can legitimately record a creation even if the claim is deleted later.
- **Index/trigger already exists:** do not blindly rerun creation scripts on an already configured schema.
- **Integration status:** passing tests documented on individual branches does **not** mean this full sequence has been executed and passed together.
