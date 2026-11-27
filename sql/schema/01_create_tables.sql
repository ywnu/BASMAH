-- BASMAH Database: schema baseline (Weeks 12-14)
-- Owner: Jumanah Alotaibi | Schema & Integration
-- Matched to Diyam's Data Dictionary (feature/database-design).
-- 8 tables, 8 primary keys, 10 foreign keys.
--
-- CURRENT IMPLEMENTATION:
--   All 10 FKs use ON DELETE RESTRICT and ON UPDATE CASCADE.
--   These match Hanan's documented proposal; formal team approval is pending.
--   ActivityLogs stays (LogID, UserID, Action, ActionDate) with UserID NOT NULL.
--   Bayader's AFTER INSERT trigger on Claims uses NEW.CreatedBy to set UserID.
--
-- PROVISIONAL DOMAIN VALUES observed in Aseel's current BASMAH seed data:
--   Users.Role           : Admin, Researcher, Reviewer
--   Claims.Status        : Pending, Verified, Disputed, Rejected
--   Reviews.Decision     : Approve, Reject, NeedsMoreEvidence
--   Evidence.EvidenceType: Study, Expert Statement, Reference Data, Social Media Post
--   Sources.SourceType   : Article, Report, Website, Book, Dataset
-- Do NOT add CHECK constraints until the team confirms that these are exhaustive.
--
-- LOGIN DECISION PENDING:
--   Users.PasswordHash has NOT been added. Agree on demo accounts/registration,
--   backend password hashing, and Aseel's seed changes before adding it.
--
-- INTEGRATION NOTE:
--   CREATE TABLE IF NOT EXISTS will NOT modify existing table definitions.
--   Use an agreed ALTER TABLE migration or a new disposable test database
--   for future structural changes. Never drop an existing working database.

CREATE DATABASE IF NOT EXISTS BASMAH;
USE BASMAH;

CREATE TABLE IF NOT EXISTS Users (
    UserID INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(150) NOT NULL UNIQUE,
    Role VARCHAR(30) NOT NULL
);

CREATE TABLE IF NOT EXISTS Projects (
    ProjectID INT AUTO_INCREMENT PRIMARY KEY,
    ProjectName VARCHAR(150) NOT NULL,
    Description TEXT,
    OwnerID INT NOT NULL,
    CONSTRAINT fk_projects_owner
        FOREIGN KEY (OwnerID) REFERENCES Users(UserID)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Sources (
    SourceID INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(200) NOT NULL,
    URL VARCHAR(500),
    SourceType VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS Claims (
    ClaimID INT AUTO_INCREMENT PRIMARY KEY,
    ProjectID INT NOT NULL,
    CreatedBy INT NOT NULL,
    ClaimText TEXT NOT NULL,
    Status VARCHAR(30) NOT NULL,
    CONSTRAINT fk_claims_project
        FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_claims_creator
        FOREIGN KEY (CreatedBy) REFERENCES Users(UserID)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Evidence (
    EvidenceID INT AUTO_INCREMENT PRIMARY KEY,
    ClaimID INT NOT NULL,
    SourceID INT NOT NULL,
    EvidenceText TEXT NOT NULL,
    EvidenceType VARCHAR(30) NOT NULL,
    CONSTRAINT fk_evidence_claim
        FOREIGN KEY (ClaimID) REFERENCES Claims(ClaimID)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_evidence_source
        FOREIGN KEY (SourceID) REFERENCES Sources(SourceID)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Reviews (
    ReviewID INT AUTO_INCREMENT PRIMARY KEY,
    ClaimID INT NOT NULL,
    ReviewerID INT NOT NULL,
    Decision VARCHAR(30) NOT NULL,
    ReviewDate DATETIME NOT NULL,
    CONSTRAINT fk_reviews_claim
        FOREIGN KEY (ClaimID) REFERENCES Claims(ClaimID)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_reviews_reviewer
        FOREIGN KEY (ReviewerID) REFERENCES Users(UserID)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Versions (
    VersionID INT AUTO_INCREMENT PRIMARY KEY,
    ClaimID INT NOT NULL,
    ChangedBy INT NOT NULL,
    PreviousText TEXT NOT NULL,
    ChangedAt DATETIME NOT NULL,
    CONSTRAINT fk_versions_claim
        FOREIGN KEY (ClaimID) REFERENCES Claims(ClaimID)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_versions_user
        FOREIGN KEY (ChangedBy) REFERENCES Users(UserID)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS ActivityLogs (
    LogID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT NOT NULL,
    Action VARCHAR(100) NOT NULL,
    ActionDate DATETIME NOT NULL,
    CONSTRAINT fk_activitylogs_user
        FOREIGN KEY (UserID) REFERENCES Users(UserID)
        ON DELETE RESTRICT ON UPDATE CASCADE
);
