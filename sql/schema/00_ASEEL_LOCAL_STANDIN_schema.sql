-- =====================================================================
-- ASEEL LOCAL STAND-IN SCHEMA  (NOT the official schema!)
-- Purpose: lets Aseel run/test 02_seed_data.sql and 03_queries.sql
--          before Jumanah's sql/schema/01_create_tables.sql is ready.
-- DO NOT commit this to main. When Jumanah's schema is ready, replace this
-- file with hers and fix any name/type differences (see docs/ADAPTATION_CHECKLIST.md).
-- Entities follow the plan: Users, Projects, Sources, Claims, Evidence,
-- Reviews, Versions, ActivityLogs (audit, optional).
-- =====================================================================
DROP DATABASE IF EXISTS basmah_db;
CREATE DATABASE basmah_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE basmah_db;

CREATE TABLE Users (
  user_id     INT AUTO_INCREMENT PRIMARY KEY,
  full_name   VARCHAR(100) NOT NULL,
  email       VARCHAR(120) NOT NULL UNIQUE,
  role        ENUM('Admin','Researcher','Reviewer') NOT NULL DEFAULT 'Researcher',
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE Projects (
  project_id   INT AUTO_INCREMENT PRIMARY KEY,
  owner_id     INT NOT NULL,
  title        VARCHAR(150) NOT NULL,
  description  TEXT,
  status       ENUM('Active','Completed','Archived') NOT NULL DEFAULT 'Active',
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (owner_id) REFERENCES Users(user_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE Sources (
  source_id        INT AUTO_INCREMENT PRIMARY KEY,
  project_id       INT NOT NULL,
  title            VARCHAR(200) NOT NULL,
  source_type      ENUM('Article','Report','Website','Book','Dataset') NOT NULL,
  publisher        VARCHAR(120),
  url              VARCHAR(255),
  publication_date DATE,
  FOREIGN KEY (project_id) REFERENCES Projects(project_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE Claims (
  claim_id    INT AUTO_INCREMENT PRIMARY KEY,
  project_id  INT NOT NULL,
  created_by  INT NOT NULL,
  claim_text  VARCHAR(500) NOT NULL,
  status      ENUM('Pending','Verified','Disputed','Rejected') NOT NULL DEFAULT 'Pending',
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (project_id) REFERENCES Projects(project_id) ON DELETE RESTRICT,
  FOREIGN KEY (created_by) REFERENCES Users(user_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE Evidence (
  evidence_id  INT AUTO_INCREMENT PRIMARY KEY,
  claim_id     INT NOT NULL,
  source_id    INT NOT NULL,
  stance       ENUM('Supports','Contradicts','Neutral') NOT NULL,
  excerpt      VARCHAR(500),
  added_by     INT NOT NULL,
  added_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (claim_id)  REFERENCES Claims(claim_id)   ON DELETE RESTRICT,
  FOREIGN KEY (source_id) REFERENCES Sources(source_id) ON DELETE RESTRICT,
  FOREIGN KEY (added_by)  REFERENCES Users(user_id)     ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE Reviews (
  review_id    INT AUTO_INCREMENT PRIMARY KEY,
  claim_id     INT NOT NULL,
  reviewer_id  INT NOT NULL,
  verdict      ENUM('Approve','Reject','NeedsMoreEvidence') NOT NULL,
  comments     VARCHAR(500),
  reviewed_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (claim_id)    REFERENCES Claims(claim_id) ON DELETE RESTRICT,
  FOREIGN KEY (reviewer_id) REFERENCES Users(user_id)   ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE Versions (
  version_id   INT AUTO_INCREMENT PRIMARY KEY,
  claim_id     INT NOT NULL,
  version_no   INT NOT NULL,
  claim_text   VARCHAR(500) NOT NULL,
  changed_by   INT NOT NULL,
  change_note  VARCHAR(255),
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (claim_id, version_no),
  FOREIGN KEY (claim_id)   REFERENCES Claims(claim_id) ON DELETE RESTRICT,
  FOREIGN KEY (changed_by) REFERENCES Users(user_id)   ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE ActivityLogs (
  log_id      INT AUTO_INCREMENT PRIMARY KEY,
  user_id     INT NULL,
  action      VARCHAR(50) NOT NULL,
  table_name  VARCHAR(50) NOT NULL,
  record_id   INT NOT NULL,
  logged_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
