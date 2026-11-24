# BASMAH – Deletion and Update Policy

**Owner:** Hanan Almutairi  
**Role:** Integrity & Transactions  
**Branch:** feature/integrity-transactions  
**Status:** Proposed – Pending Team Approval

## 1. Purpose

This document defines the proposed ON DELETE and ON UPDATE rules for the ten foreign key relationships in the BASMAH database.

The objective is to maintain referential integrity and protect important historical records.

## 2. Proposed Referential Actions

| Foreign Key Relationship | ON DELETE | ON UPDATE |
|---|---|---|
| Projects → Users | RESTRICT | CASCADE |
| Claims → Projects | RESTRICT | CASCADE |
| Claims → Users | RESTRICT | CASCADE |
| Evidence → Claims | RESTRICT | CASCADE |
| Evidence → Sources | RESTRICT | CASCADE |
| Reviews → Claims | RESTRICT | CASCADE |
| Reviews → Users | RESTRICT | CASCADE |
| Versions → Claims | RESTRICT | CASCADE |
| Versions → Users | RESTRICT | CASCADE |
| ActivityLogs → Users | RESTRICT | CASCADE |

## 3. Deletion Policy

RESTRICT is proposed for all ten foreign key relationships.

Reasons:
- Prevent accidental deletion of related records.
- Preserve evidence and review history.
- Protect claim versions.
- Maintain activity log records.
- Avoid losing important project information.

## 4. Update Policy

CASCADE is proposed for all ten relationships.

If a referenced primary key is updated, the corresponding foreign key values will be updated automatically.

Since primary keys use AUTO_INCREMENT, changing IDs is not expected during normal operation.

## 5. Testing Considerations

- Use disposable test records.
- Verify that deleting referenced parent records is rejected.
- Verify that historical records remain intact.
- Never perform destructive tests on important project data.

## 6. Approval

This policy is a proposal and requires team approval before modifying the database schema.


## 7. Test Results

The proposed referential integrity policies and transaction operations were tested.

### ON DELETE RESTRICT
- Attempted to delete a user referenced by a project.
- MySQL rejected the deletion with Error Code 1451.
- Result: PASSED.

### ON UPDATE CASCADE
- Updated a user's UserID.
- The related project's OwnerID was automatically updated.
- Verified that both IDs matched.
- Executed ROLLBACK to undo temporary changes.
- Result: PASSED.

### ROLLBACK Test
- Inserted a temporary test user.
- Verified that the record existed before rollback.
- Executed ROLLBACK.
- Verified that the record no longer existed.
- Result: PASSED.

### COMMIT Test
- Inserted a test user.
- Executed COMMIT.
- Verified that the record remained in the database.
- Result: PASSED.

### Cleanup
- Temporary test records were rolled back where applicable.
- The COMMIT test record was retained for verification.

### Conclusion
The tested RESTRICT, CASCADE, COMMIT, and ROLLBACK behaviors worked as expected.