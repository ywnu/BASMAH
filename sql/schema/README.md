# BASMAH — Database Schema & Integration

**Owner:** Jumanah Alotaibi  
**Branch:** `feature/schema-integration`  
**Status:** Added CHECK rules and optional nullable PasswordHash in schema branch, matched to Aseel's seed/backend configuration; awaiting final team review, local migration test, and integrated regression tests.

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

The schema defines **8 tables, 8 primary keys, and 10 foreign keys**. It now includes optional `Users.PasswordHash VARCHAR(255) NULL` and five domain `CHECK` constraints. The data dictionary was based on the previous four-column Users table and must be updated by the design owner to include PasswordHash.

**Current foreign-key behavior:** `ON DELETE RESTRICT` and `ON UPDATE CASCADE` for all 10 relationships. This matches Hanan's proposal in `docs/deletion_policy.md` (branch `feature/integrity-transactions`), **not yet recorded as formally approved**.

**ActivityLogs contract:** `LogID`, `UserID NOT NULL`, `Action`, `ActionDate`. Bayader's `sql/advanced/05_triggers.sql` inserts an audit entry when a `Claims` row is created, using `NEW.CreatedBy` as the logged user. No change to the ActivityLogs table is required for this trigger.

## Domain values enforced in the updated schema (awaiting final team review)

These are the literal values used in Aseel's **compatible** sample data (`ASEEL_NEW/SQL/OPERATIONS/02_seed_data.sql`, branch `feature/sql-operations`).

| Column | Values present in seed |
| --- | --- |
| `Users.Role` | `Admin`, `Researcher`, `Reviewer` |
| `Claims.Status` | `Pending`, `Verified`, `Disputed`, `Rejected` |
| `Reviews.Decision` | `Approve`, `Reject`, `NeedsMoreEvidence` |
| `Evidence.EvidenceType` | `Study`, `Expert Statement`, `Reference Data`, `Social Media Post` |
| `Sources.SourceType` | `Article`, `Report`, `Website`, `Book`, `Dataset` |

**Five CHECK constraints are now defined in `01_create_tables.sql` for these agreed-with-Aseel values.** These match Aseel's current seed and reported backend config, but still need final team review and testing against all intended application write values. CHECK membership can need revision for new features.

## Optional authentication column (no login implemented)

`Users` now has `UserID`, `FullName`, `Email`, nullable `PasswordHash`, and `Role`; `Email` is unique. The extra column does **not** implement login, session tokens or access control.

If real email/password login is added later:
1. Agree whether the site uses pre-created demo accounts or self-registration.
2. Have the backend generate and verify secure password hashes (Aseel proposed bcrypt; never store or return plaintext passwords).
3. Update seed/demo accounts and API authentication/token/authorization together with backend/frontend.
4. Verify actual authentication security separately before claiming login support.

**Existing users in Aseel's seed have `PasswordHash = NULL`, so none can log in yet.** This is an intentionally non-breaking schema preparation, not authentication.

## Compatibility and tests

- [x] Baseline schema and basic constraints created and locally tested by Jumanah (8 tables, 10 FKs; UNIQUE/FK/NOT NULL).
- [x] Compatible seed, data-quality checks and query evidence documented by Aseel on her branch.
- [x] View, trigger and index implementation and local tests documented by Bayader on her branch.
- [x] Referential integrity and transaction tests documented by Hanan on her branch.
- [ ] Final team review of five domain CHECK values and Hanan's FK deletion/update policy (Aseel confirmed compatibility).
- [x] Nullable PasswordHash defined in new schema and run-once migration documented; [ ] test migration on BASMAH_TEST; [ ] decide whether to implement real login.
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

**Schema migration smoke test (user-confirmed, 28 Nov 2026):** Jumanah ran `sql/schema/02_migrate_existing_schema.sql` with `USE BASMAH_TEST;` on the existing test DB, confirmed the `PasswordHash` column is `varchar(255)` and nullable, and confirmed all five named `CHECK` constraints appeared. PASS (reported). **Not yet verified:** rejection of invalid values and post-migration seed row counts. This was not run on the original BASMAH database.

**Still needed before marking integration complete:** full run of all 19 Aseel query statements against final approved files; test the new CHECK constraints and optional PasswordHash migration; final authentication implementation decision; documented test evidence (screenshots/logs); actual FastAPI↔MySQL and frontend↔API checks; reviewed PR integration into `main`. The view/trigger/index tests used equivalent SQL on `BASMAH_TEST`, not a replay of an already-merged team repository.

## Reproducible setup

Follow the root `RUN_ORDER.md`, which lists source branches, compatible paths, execution order, verification SQL and known blockers.

**Important:** `CREATE TABLE IF NOT EXISTS` does not upgrade an existing table. Never drop a shared or populated database to test changes. Use the run-once `sql/schema/02_migrate_existing_schema.sql` on a **disposable copy** first (for `BASMAH_TEST`, edit its `USE BASMAH;` to `USE BASMAH_TEST;`). Do not run it on a newly created updated schema. MySQL `ALTER TABLE` implicitly commits and cannot be undone with ordinary `ROLLBACK`.

**Do not substitute** the older `sql/operations/02_seed_data.sql` in Aseel's branch; it targets `basmah_db` with different column names. Use the compatible `ASEEL_NEW/SQL/OPERATIONS/` files until the team consolidates the paths.

**PR rule:** Keep changes on `feature/schema-integration` and merge into `main` only after review and passing integration tests.
