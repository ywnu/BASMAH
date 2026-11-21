# How my files were adapted to Jumanah's schema

My first version used a temporary schema I assumed from the plan. After receiving `01_create_tables.sql`
the three SQL files were rewritten. Main differences:

| Topic | Temporary schema | Official schema |
|---|---|---|
| Database | `basmah_db` | `BASMAH` |
| Naming | snake_case (`claim_id`) | PascalCase (`ClaimID`) |
| Dates | `created_at` on several tables | only `Reviews.ReviewDate` and `Versions.ChangedAt` |
| Sources | had `project_id`, publisher, date | only `Title`, `URL`, `SourceType` |
| Evidence | `stance` (Supports/Contradicts) | `EvidenceType` -> I used Study / Expert Statement / Reference Data / Social Media Post |
| Reviews | `verdict`, `comments` | `Decision`, `ReviewDate` (no comments) |
| Versions | `version_no`, `claim_text` | `PreviousText`, `ChangedAt` (no version number) |

Queries changed because of this: Q3 (no date -> order by ID), Q12 (no dates -> verified count),
Q14 and Q15 (no stance -> evidence type / Reject reviews), Q17 (no version number -> edit count).
Data-quality checks DQ1 and DQ4 were rewritten for the same reason.

## To confirm with the team (values are not final in the schema)
- Diyam / Jumanah: allowed values for `Claims.Status`, `Evidence.EvidenceType`, `Reviews.Decision`, `Users.Role`, `Sources.SourceType`
  (I used the values listed at the top of `02_seed_data.sql`).
- Is `Versions.PreviousText` meant to store the text before the edit? (I assumed yes.)
- If the final schema adds CHECK constraints or changes ON DELETE rules, re-run all scripts and adjust.

## Notes
- **Windows:** MySQL stores database/table names in lower case (`basmah`), so `USE BASMAH;` still works.
  On Mac/Linux names are case-sensitive, so the files use `BASMAH` exactly as in Jumanah's schema.
- **Re-running:** the schema file does not drop the database and the seed inserts fixed IDs. To start clean run
  `DROP DATABASE BASMAH;` first, then schema -> seed -> 02b -> 03. Running the seed twice gives
  `Error 1062 Duplicate entry` (harmless: nothing is inserted).
- `ActivityLogs` is empty by design; it will be filled by Bayader's trigger.
