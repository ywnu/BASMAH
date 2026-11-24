USE BASMAH;

-- Improve claim filtering by status
CREATE INDEX idx_claims_status
ON Claims (Status);