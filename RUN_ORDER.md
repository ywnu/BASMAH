# BASMAH — SQL Run Order (Draft)

Owner: Jumanah | Branch: `feature/schema-integration`
Status: **Draft for Week 13 integration**. Other members' files are on separate branches and are **not yet integrated into this branch or `main`**.

## Prerequisites
- MySQL Server and MySQL Workbench (or another MySQL client).
- Use a fresh, disposable database for the full integration test. **Never drop an existing database containing work or important data.**
- Use the agreed schema and shared IDs. Do not run the seed script twice against a populated database; it uses fixed primary-key IDs.

## Confirmed file sequence (from current branches)

1. **Schema (Jumanah)** — `sql/schema/01_create_tables.sql` on `feature/schema-integration`. Creates `BASMAH`, eight tables, and ten foreign keys. The file uses `IF NOT EXISTS`, which does not alter existing table definitions.
2. **Seed (Aseel)** — `ASEEL_NEW/SQL/OPERATIONS/02_seed_data.sql` on `feature/sql-operations`. Insert fictional test data; expected counts: Users 6, Projects 3, Sources 8, Claims 12, Evidence 16, Reviews 12, Versions 5, ActivityLogs 0.
3. **Data quality (Aseel)** — `ASEEL_NEW/SQL/OPERATIONS/02b_data_quality_checks.sql` on `feature/sql-operations`. Expect five checks to return zero invalid rows.
4. **Demo queries (Aseel)** — `ASEEL_NEW/SQL/OPERATIONS/03_queries.sql` on `feature/sql-operations`. Execute in accordance with its instructions; includes transactional demo statements.

## Pending integration (final order needs confirmation)

5. **Views, triggers and indexes (Bayader)** — final SQL script path pending. Aseel's seed must execute **before** audit triggers if the initial audit log must remain empty. Triggers should be installed before testing later user actions that must be logged.
6. **Integrity and transaction tests (Hanan)** — final SQL script path pending. Run after the schema and any required seed/triggers. Confirm actual FK deletion rules and expected results with Hanan.
7. **Regression checks** — rerun `SHOW TABLES`, foreign-key checks, data-quality checks, view/trigger tests, and team demo on a fresh disposable database after merging approved scripts.

## Initial verification

```sql
USE BASMAH;
SHOW TABLES;
SELECT COUNT(*) AS TotalTables
FROM information_schema.tables
WHERE table_schema = 'BASMAH' AND table_type = 'BASE TABLE';
SELECT COUNT(*) AS TotalForeignKeys
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'BASMAH'
  AND REFERENCED_TABLE_NAME IS NOT NULL;
```

Expected with the current draft schema: `TotalTables = 8`, `TotalForeignKeys = 10`.

## Open decisions / integration blockers
- Hanan: approve `ON DELETE` and `ON UPDATE` policies and affected tests.
- Bayader: approve `ActivityLogs` contract and trigger insertion behavior.
- Team/Diyam: approve domain values (`Claims.Status`, `Reviews.Decision`, `Evidence.EvidenceType`, `Sources.SourceType`, `Users.Role`) and any CHECK constraints.
- Resolve final file paths after reviewed pull requests are integrated. Avoid claiming the integrated setup passed until it is actually tested.
