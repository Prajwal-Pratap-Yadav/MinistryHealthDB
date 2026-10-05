CREATE DATABASE IF NOT EXISTS ministry_health
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE ministry_health;

DROP VIEW IF EXISTS vw_secretary_workload;
DROP VIEW IF EXISTS vw_division_summary;
DROP VIEW IF EXISTS vw_ministry_directory;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS division_member;
DROP TABLE IF EXISTS division;
DROP TABLE IF EXISTS secretary;
DROP TABLE IF EXISTS minister;
DROP TABLE IF EXISTS official_role;
DROP TABLE IF EXISTS role;
DROP TABLE IF EXISTS official;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE official (
    official_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    full_name VARCHAR(120) NOT NULL,
    email VARCHAR(254) NULL,
    phone VARCHAR(32) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (official_id),
    UNIQUE KEY uq_official_name (full_name)
) ENGINE=InnoDB;

CREATE TABLE role (
    role_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    role_name VARCHAR(80) NOT NULL,
    PRIMARY KEY (role_id),
    UNIQUE KEY uq_role_name (role_name)
) ENGINE=InnoDB;

CREATE TABLE official_role (
    official_id INT UNSIGNED NOT NULL,
    role_id SMALLINT UNSIGNED NOT NULL,
    assigned_at DATE NOT NULL,
    PRIMARY KEY (official_id, role_id),
    CONSTRAINT fk_official_role_official
        FOREIGN KEY (official_id) REFERENCES official (official_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_official_role_role
        FOREIGN KEY (role_id) REFERENCES role (role_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE minister (
    minister_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    official_id INT UNSIGNED NOT NULL,
    portfolio VARCHAR(120) NOT NULL,
    appointed_at DATE NULL,
    PRIMARY KEY (minister_id),
    UNIQUE KEY uq_minister_official (official_id),
    CONSTRAINT fk_minister_official
        FOREIGN KEY (official_id) REFERENCES official (official_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE secretary (
    secretary_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    official_id INT UNSIGNED NOT NULL,
    minister_id INT UNSIGNED NOT NULL,
    office_title VARCHAR(120) NOT NULL,
    appointed_at DATE NULL,
    PRIMARY KEY (secretary_id),
    UNIQUE KEY uq_secretary_official (official_id),
    KEY ix_secretary_minister (minister_id),
    CONSTRAINT fk_secretary_official
        FOREIGN KEY (official_id) REFERENCES official (official_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_secretary_minister
        FOREIGN KEY (minister_id) REFERENCES minister (minister_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE division (
    division_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    division_code VARCHAR(24) NOT NULL,
    division_name VARCHAR(120) NOT NULL,
    description VARCHAR(255) NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (division_id),
    UNIQUE KEY uq_division_code (division_code),
    UNIQUE KEY uq_division_name (division_name)
) ENGINE=InnoDB;

CREATE TABLE division_member (
    division_id SMALLINT UNSIGNED NOT NULL,
    official_id INT UNSIGNED NOT NULL,
    role_id SMALLINT UNSIGNED NOT NULL,
    secretary_id INT UNSIGNED NULL,
    joined_at DATE NOT NULL,
    PRIMARY KEY (division_id, official_id),
    KEY ix_member_official (official_id),
    KEY ix_member_role (role_id),
    KEY ix_member_secretary (secretary_id),
    CONSTRAINT fk_member_division
        FOREIGN KEY (division_id) REFERENCES division (division_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_member_official
        FOREIGN KEY (official_id) REFERENCES official (official_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_member_role
        FOREIGN KEY (role_id) REFERENCES role (role_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_member_secretary
        FOREIGN KEY (secretary_id) REFERENCES secretary (secretary_id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;
