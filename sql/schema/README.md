# BASMAH — Database Schema & Integration

**Owner:** Jumanah Alotaibi  
**Branch:** `feature/schema-integration`  
**Status:** Schema baseline implemented; final domain rules, login design, and integrated regression test pending team sign-off.

## Delivered schema

File: `sql/schema/01_create_tables.sql`

| Table | Purpose |
| --- | --- |
| `Users` | People and roles |
| `Projects` | Projects and their owners |
| `Sources` | Reference sources |
| `Claims` | Claims and their creators |
| `Evidence` | Evidence linking claims to sources |
| `Reviews` | Claim reviews and decisions |
| `Versions` | Previous claim text and change history |
| `ActivityLogs` | User action audit entries |

The baseline defines **8 tables, 8 primary keys, and 10 foreign keys**. Columns and types follow Diyam's `docs/database-design/DATA_DICTIONARY.md`.

**Current foreign-key behavior:** `ON DELETE RESTRICT` and `ON UPDATE CASCADE` for all 10 relationships. This matches Hanan's proposal in `docs/deletion_policy.md` (branch `feature/integrity-transactions`), **not yet recorded as formally approved**.

**ActivityLogs contract:** `LogID`, `UserID NOT NULL`, `Action`, `ActionDate`. Bayader's `sql/advanced/05_triggers.sql` inserts an audit entry when a `Claims` row is created, using `NEW.CreatedBy` as the logged user. No change to the ActivityLogs table is required for this trigger.

## Provisional allowed values

These are the literal values used in Aseel's **compatible** sample data (`ASEEL_NEW/SQL/OPERATIONS/02_seed_data.sql`, branch `feature/sql-operations`).

| Column | Values present in seed |
| --- | --- |
| `Users.Role` | `Admin`, `Researcher`, `Reviewer` |
| `Claims.Status` | `Pending`, `Verified`, `Disputed`, `Rejected` |
| `Reviews.Decision` | `Approve`, `Reject`, `NeedsMoreEvidence` |
| `Evidence.EvidenceType` | `Study`, `Expert Statement`, `Reference Data`, `Social Media Post` |
| `Sources.SourceType` | `Article`, `Report`, `Website`, `Book`, `Dataset` |

**No CHECK constraints have been added yet.** The seed values do not prove the complete set of valid values for future application writes. Confirm with the team and backend owner before enforcing a restricted set.

## Authentication decision (pending)

`Users` currently contains only `UserID`, `FullName`, `Email`, and `Role`; `Email` is unique. It **does not** contain `PasswordHash`.

If email/password login is formally in scope:
1. Agree whether the site uses pre-created demo accounts or self-registration.
2. Have the backend produce and verify a secure password hash (Argon2id preferred; never store a plaintext password).
3. Update the schema, migration strategy for existing users, Aseel's seed, and API documentation together.
4. Test the new flow before marking the schema final.

Do not add a `NOT NULL PasswordHash` column to existing populated tables without a migration/data plan.

## Compatibility and tests

- [x] Baseline schema and basic constraints created and locally tested by Jumanah (8 tables, 10 FKs; UNIQUE/FK/NOT NULL).
- [x] Compatible seed, data-quality checks and query evidence documented by Aseel on her branch.
- [x] View, trigger and index implementation and local tests documented by Bayader on her branch.
- [x] Referential integrity and transaction tests documented by Hanan on her branch.
- [ ] Team approval of domain values and FK deletion/update policy.
- [ ] Team decision about authentication and any required schema migration.
- [ ] One reproducible clean-database integration run with **all** approved files.
- [ ] Backend API ↔ MySQL and frontend ↔ API end-to-end checks.
- [ ] Final PR review and integration into `main`.

Other members' local tests are **not** equivalent to a completed integrated run on Jumanah's branch.

## Integration smoke-test results (Jumanah's local MySQL)

**Environment:** MySQL 8.0.41, MySQL Workbench; isolated database `BASMAH_TEST` (the original `BASMAH` was not used for these test writes).

**Evidence level:** Jumanah executed these tests locally and reported the expected outputs during the team-assisted integration walkthrough on 27–28 Nov 2026. This is a record of **user-confirmed local results**; it is not an independently executed CI run or a final reviewed test artifact.

| Scope | Observed outcome reported by Jumanah | Status |
| --- | --- | --- |
| Schema | 8 base tables, 10 FKs | PASS (reported) |
| Seed | Users 6; Projects 3; Sources 8; Claims 12; Evidence 16; Reviews 12; Versions 5; ActivityLogs 0 | PASS (reported) |
| Data-quality checks | DQ1–DQ5 each returned zero rows | PASS (reported) |
| Bayader view | `vw_ClaimEvidenceSources` returned 16 rows | PASS (reported) |
| Bayader trigger | `AFTER INSERT` on Claims logged `Created claim ID: 9301` with `UserID=3`; subsequent `ROLLBACK` left 0 test claims and 0 test logs | PASS (reported) |
| Bayader index | `idx_claims_status` exists on `Claims.Status`, `Non_unique=1` | PASS (reported) |
| Aseel queries | SELECT counts, status GROUP BY, evidence counts, several JOIN/subquery/version queries matched expected output | PASS (tested subset) |
| Aseel UPDATE/DELETE | Status `Verified` then `Pending` after rollback; temporary claim insert/delete and audit cleanup all matched expected counts | PASS (reported) |
| Hanan FK rule definitions | 10 `RESTRICT` delete rules and 10 `CASCADE` update rules | PASS (reported) |
| Hanan delete behavior | Deleting an associated user returned MySQL Error 1451; user remained after rollback | PASS (reported) |
| Hanan update behavior | Temporary `UserID` 9401 → 9403 also changed `Projects.OwnerID` to 9403; rollback removed temporary user/project | PASS (reported) |

**Post-test cleanup verification (user-confirmed):** After the transaction and FK tests, Jumanah rechecked the `BASMAH_TEST` row counts: Users=6, Projects=3, Sources=8, Claims=12, Evidence=16, Reviews=12, Versions=5, ActivityLogs=0. All disposable test record checks returned 0 (`Claims` IDs 9001/9301, `Users` IDs 9401/9403, `Projects` ID 9402). PASS (reported). No change was made to the production-like `BASMAH` database during this test flow.

**Still needed before marking integration complete:** full run of all 19 Aseel query statements against final approved files; final CHECK/authentication decision; documented test evidence (screenshots/logs); actual FastAPI↔MySQL and frontend↔API checks; reviewed PR integration into `main`. The view/trigger/index tests used equivalent SQL on `BASMAH_TEST`, not a replay of an already-merged team repository.

## Reproducible setup

Follow the root `RUN_ORDER.md`, which lists source branches, compatible paths, execution order, verification SQL and known blockers.

**Important:** `CREATE TABLE IF NOT EXISTS` does not upgrade an existing table. Never drop a shared or populated database to test changes. Use a separate disposable test instance/schema or a reviewed `ALTER TABLE` migration.

**Do not substitute** the older `sql/operations/02_seed_data.sql` in Aseel's branch; it targets `basmah_db` with different column names. Use the compatible `ASEEL_NEW/SQL/OPERATIONS/` files until the team consolidates the paths.

**PR rule:** Keep changes on `feature/schema-integration` and merge into `main` only after review and passing integration tests.
