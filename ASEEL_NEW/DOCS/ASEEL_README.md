# Aseel – SQL Operations & Evidence
Branch: `feature/sql-operations` | Project: BASMAH (Weeks 12–14) | Schema: Jumanah's `01_create_tables.sql` (database `BASMAH`)

## Files
| Path | What it is |
|---|---|
| `sql/operations/02_seed_data.sql` | Sample data, parent-before-child order, fixed IDs |
| `sql/operations/02b_data_quality_checks.sql` | 5 validation queries – each must return 0 rows |
| `sql/operations/03_queries.sql` | 19 demo queries with purpose + expected result |
| `docs/ASEEL_operations_docs.md` | Seed-data matrix, query checklist, observed results, demo script |
| `docs/SCHEMA_MAPPING.md` | How the files map to the official schema + open questions |
| `evidence/` | Screenshots: `00_show_tables.png`, `01_row_counts.png`, `queries/` (Q1–Q19), `data_quality/` (DQ1–DQ5) |

## How to run (MySQL Workbench)
1. Jumanah's `01_create_tables.sql` (for a clean start: `DROP DATABASE BASMAH;` first)
2. `sql/operations/02_seed_data.sql` (run once only)
3. `sql/operations/02b_data_quality_checks.sql` (all results empty)
4. `sql/operations/03_queries.sql` (run each query separately; Q18 and Q19 are blocks of several statements)

Seed must run **before** Bayader's trigger script, otherwise ActivityLogs gets rows from the seed.

## Expected row counts after seed
Users 6, Projects 3, Sources 8, Claims 12, Evidence 16, Reviews 12, Versions 5, ActivityLogs 0.

## Shared test IDs
Users 1–6 (4 Hanan, 5 Bayader), Projects 1–3, Sources 1–8, Claims 1–12 (4 and 9 have no review),
Evidence 1–16, Reviews 1–12, Versions 1–5. Disposable test rows use IDs 9000+ (Aseel 9001, Hanan from 9100, Bayader from 9200).

## Status
**Done and run on MySQL Workbench against Jumanah's schema:**
- Schema created (8 tables), seed inserted (row counts as expected).
- Data-quality checks DQ1–DQ5: all returned 0 rows.
- Queries Q1–Q19: every result matched the expected output (Q18 rolled back correctly, Q19 deleted only the disposable row).
- All screenshots saved in `evidence/`.

**Still to do:**
- Re-run everything on the final integrated `main` and re-check after Jumanah's schema updates (Week 14).
- Operations slides and demo (Week 14).
- Confirm the provisional values (Status, EvidenceType, Decision, Role) with the team.

## Dependencies on others
- **Jumanah:** schema is marked provisional; ON DELETE / CHECK rules may change.
- **Diyam:** data dictionary (to confirm entity and column meanings).
- **Hanan, Bayader:** use the shared IDs above.

## Limitations
- All data is fictional sample data.
- Allowed values for Status / EvidenceType / Decision / Role are my assumptions until the schema fixes them (see `docs/SCHEMA_MAPPING.md`).
