-- BASMAH Database: initial schema (Week 12)
-- Owner: Jumanah Alotaibi | Schema & Integration
-- Based on Diyam's proposed Data Dictionary (feature/database-design).
-- IMPORTANT: ON DELETE / ON UPDATE policies are provisional, pending Hanan's review.
-- ActivityLogs contract and system-action behavior are pending Bayader's review.
-- Allowed status/decision/type values and CHECK constraints are not yet finalized.

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
