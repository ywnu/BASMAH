# Bayader — Views, Triggers & Indexing

**Project:** BASMAH (MySQL database course project)

**Assigned branch:** `feature/views-triggers-indexes`

## Implemented Tasks

### 1. Views — `04_views.sql`

Created `vw_ClaimEvidenceSources` to combine claims, evidence, and source information into a single view.

This view simplifies data retrieval and reduces the need to write repeated JOIN queries.

### 2. Triggers — `05_triggers.sql`

Created `trg_claim_after_insert`, an AFTER INSERT trigger on the Claims table.

The trigger automatically records the following information in the existing ActivityLogs table:

- UserID from NEW.CreatedBy.
- Action containing the newly created ClaimID.
- ActionDate using NOW().

The existing ActivityLogs schema was preserved without structural changes.

### 3. Indexes — `06_indexes.sql`

Created `idx_claims_status` on the Status column of the Claims table to support efficient filtering by claim status.

Existing primary key and foreign key indexes were reviewed to avoid duplicate indexes.

## Testing and Validation

| Test | Result |
|---|---|
| Schema compatibility | PASS |
| View creation | PASS |
| View data retrieval using test records | PASS |
| Trigger creation | PASS |
| Automatic audit log insertion | PASS |
| Transaction rollback | PASS |
| Index creation using SHOW INDEX | PASS |
| Index selection using EXPLAIN | PASS |

The EXPLAIN output confirmed that MySQL selected `idx_claims_status` when filtering claims by status.

Temporary test records were managed using transactions and rollback.

## Deliverables

- `04_views.sql`
- `05_triggers.sql`
- `06_indexes.sql`
- Testing screenshots
- Implementation documentation

## Weekly Checkpoints

- **Week 12:** Schema dependencies reviewed.
- **Week 13:** SQL implementation and local testing completed.
- **Week 14:** Final documentation, integration review, and pull request submission.

## Completion Checklist

- [x] Matches the reviewed schema and MySQL syntax.
- [x] View implemented and tested.
- [x] Trigger implemented and tested.
- [x] Index implemented and tested.
- [x] Duplicate indexes avoided.
- [x] Test results documented.
- [x] Testing screenshots organized.
- [x] SQL files and documentation committed to the assigned branch.
- [x] Pull request opened for integration review.

**Important:** Do not edit `main` directly. Coordinate shared table definitions with Jumanah and Diyam.