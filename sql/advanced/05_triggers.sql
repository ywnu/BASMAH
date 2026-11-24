USE BASMAH;

DELIMITER $$

CREATE TRIGGER trg_claim_after_insert
AFTER INSERT ON Claims
FOR EACH ROW
BEGIN
    INSERT INTO ActivityLogs (UserID, Action, ActionDate)
    VALUES (
        NEW.CreatedBy,
        CONCAT('Created claim ID: ', NEW.ClaimID),
        NOW()
    );
END$$

DELIMITER ;