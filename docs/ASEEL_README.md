# Aseel – SQL Operations & Evidence
Branch: `feature/sql-operations` | Role: SQL Operations & Evidence | Project: BASMA (Weeks 12–14)

## What is in this folder
| Path | What it is | Commit to branch? |
|---|---|---|
| `sql/operations/02_seed_data.sql` | Sample data (INSERTs), parent-before-child order, fixed IDs | Yes |
| `sql/operations/02b_data_quality_checks.sql` | 5 validation queries – each must return 0 rows | Yes |
| `sql/operations/03_queries.sql` | 19 demo queries (SELECT, JOIN, GROUP BY, subquery, UPDATE+ROLLBACK, safe DELETE) with purpose + expected result | Yes |
| `docs/ASEEL_operations_docs.md` | Seed-data matrix, query checklist, demo script | Yes |
| `docs/ADAPTATION_CHECKLIST.md` | How to adapt my files to Jumanah's official schema | Yes |
| `evidence/` | Screenshots: `00_show_tables.png`, `01_row_counts.png`, `queries/` (Q1-Q19), `data_quality/` (DQ1-DQ5) | Yes |
| `sql/schema/00_ASEEL_LOCAL_STANDIN_schema.sql` | **Archived temporary test schema**, not compatible with Jumanah's official BASMAH schema; do not execute for integration or merge as production DDL | **Reference only; exclude from final integration** |

## What I did (in the exact order I ran it, MySQL Workbench, local)
1. Ran `00_ASEEL_LOCAL_STANDIN_schema.sql` (my temporary schema) -> database `basmah_db` created. (First line gives warning 1008 "database doesn't exist" - expected on first run because of `DROP DATABASE IF EXISTS`.)
2. Opened a new query tab with `USE basmah_db; SHOW TABLES;` -> 8 tables returned.
3. Ran `02_seed_data.sql` -> sample data inserted.
4. Opened a new query tab with a row-count query -> Users 6, Projects 3, Sources 8, Claims 12, Evidence 16, Reviews 12, Versions 8 (matches the expected counts).
5. Ran `03_queries.sql` (Q1-Q19) -> outputs matched the expected results in the file comments (all 19 checked against the expected results). Q18 UPDATE ran inside a transaction and was rolled back (claim 4: Verified, then Pending). Q19 DELETE removed only the disposable claim 9001 (final count 0).
6. Ran `02b_data_quality_checks.sql` (after Q1-Q19) -> all 5 checks returned 0 rows. This also confirms the UPDATE/DELETE demos left the seed data intact. I translated the comments to English and saved the file in `sql/operations/`.

Note: the recommended run order for the team is schema -> seed -> 02b -> 03 (see "How to run"); both orders give the same result because Q18/Q19 do not change the seed data.

**Evidence:** all screenshots are done and saved in `evidence/` (SHOW TABLES, row counts, Q1-Q19, DQ1-DQ5).

**Still to do:**
- Send the shared IDs to Hanan and Bayader (see below).
- Re-run everything on Jumanah's official schema and fix any name/type differences.
- Continue work on branch `feature/sql-operations`, adapt to Jumanah's schema, then open a pull request. Exclude the temporary stand-in schema from final integration.
- Week 14: final verification on the integrated database, slides.

## Dependencies on others
- **Jumanah:** official `01_create_tables.sql`. Until then I use my temporary schema. Table/column names or ENUM values may differ (see `docs/ADAPTATION_CHECKLIST.md`).
- **Diyam:** data dictionary / EER, to confirm entity and column names.
- **Hanan, Bayader:** receive the shared test IDs below.

## Shared test IDs
Users 1–6 (1 Diyam, 2 Jumanah, 3 Aseel, 4 Hanan, 5 Bayader, 6 Sara) · Projects 1–3 · Sources 1–8 · Claims 1–12 (4 and 9 have no review) · Evidence 1–16 · Reviews 1–12 · Versions 1–8 · ActivityLogs empty (filled by Bayader's trigger).
Reserved for disposable test rows: **9000+** (Aseel 9001, Hanan from 9100, Bayader from 9200).

## How to run (MySQL Workbench)
Run in this order (File → Open SQL Script → Execute):
1. Schema (Jumanah's official schema for integration; the stand-in schema is retained for historical local-test reference only)
2. `sql/operations/02_seed_data.sql`
3. `sql/operations/02b_data_quality_checks.sql` (all results empty)
4. `sql/operations/03_queries.sql`
Seed must run **before** Bayader's trigger file, otherwise ActivityLogs gets seed rows.

## Limitations (honest notes)
- All data is fictional sample data.
- The temporary schema is my assumption, not the team-approved design.
