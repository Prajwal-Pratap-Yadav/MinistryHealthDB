CREATE DATABASE government_health_system;
USE government_health_system;

-- Create minister_health table
CREATE TABLE minister_health (
    id INT PRIMARY KEY,
    name VARCHAR(30),
    position VARCHAR(50) NOT NULL UNIQUE
);

-- Insert data into minister_health table
INSERT INTO minister_health (id, name, position)
VALUES
(1, 'Arjun', 'Health Minister'),
(2, 'Rohan', 'Finance Minister');

SELECT * FROM minister_health;

-- Create the minister table with a foreign key referencing the minister_health table
CREATE TABLE minister (
    minister_id INT PRIMARY KEY,
    minister_name VARCHAR(100),
    position VARCHAR(100),
    health_minister_id INT, 
    FOREIGN KEY (health_minister_id) REFERENCES minister_health(id)
);

INSERT INTO minister (minister_id, minister_name, position, health_minister_id)
VALUES 
(1, 'Arjun', 'Health Minister', 1),
(2, 'Rohan', 'Finance Minister', NULL); 

SELECT * FROM minister;

-- Create the secretary table with a foreign key referencing the minister table
CREATE TABLE secretary (
    secretary_id INT PRIMARY KEY,
    secretary_name VARCHAR(100),
    position VARCHAR(100),
    minister_id INT, -- Foreign key referencing the minister table
    FOREIGN KEY (minister_id) REFERENCES minister(minister_id)
);

INSERT INTO secretary (secretary_id, secretary_name, position, minister_id)
VALUES 
(1, 'Kiran', 'Health Minister', 1),
(2, 'Vikas', 'Finance Minister', 2);

SELECT * FROM secretary;

-- Create administrative table with foreign key referencing secretary
CREATE TABLE administrative_division (
    id INT PRIMARY KEY,
    name VARCHAR(30),
    position VARCHAR(50) NOT NULL,
    secretary_id INT,
    FOREIGN KEY (secretary_id) REFERENCES secretary(secretary_id)
);

-- Insert data into administrative table
INSERT INTO administrative_division (id, name, position, secretary_id)
VALUES
    (1, 'Prajwal', 'Health Minister', 1),
    (2, 'Prakash', 'Deputy Health Secretary', 1),
    (701, 'Ramesh', 'Deputy Health Secretary', 1),
    (801, 'Manju', 'Assistant Health Minister', 1);
    
    SELECT * FROM administrative_division;

-- Create ppia_division table with foreign key referencing secretary
CREATE TABLE ppia_division (
    id INT PRIMARY KEY,
    name VARCHAR(30),
    position VARCHAR(50) NOT NULL,
    secretary_id INT,
    FOREIGN KEY (secretary_id) REFERENCES secretary(secretary_id)
);

-- Insert data into ppia_division table
INSERT INTO ppia_division (id, name, position, secretary_id)
VALUES
    (1, 'Prajwal', 'Health Minister', 1),
    (2, 'Prakash', 'Deputy Health Secretary', 1),
    (1101, 'Esha', 'Deputy Health Secretary', 2),
    (1201, 'Kushi', 'Assistant Health Minister', 2);
    
    SELECT * FROM ppia_division;

-- Create service_division table with foreign key referencing secretary
CREATE TABLE service_division (
    id INT PRIMARY KEY,
    name VARCHAR(30),
    position VARCHAR(50) NOT NULL,
    secretary_id INT,
    FOREIGN KEY (secretary_id) REFERENCES secretary(secretary_id)
);

-- Insert data into service_division table
INSERT INTO service_division (id, name, position, secretary_id)
VALUES
    (1, 'Prajwal', 'Health Minister', 1),
    (2, 'Prakash', 'Deputy Health Secretary', 1),
    (1501, 'Arjun', 'Deputy Health Secretary', 2),
    (1601, 'Kalyan', 'Assistant Health Minister', 2);
    
    SELECT * FROM service_division;

-- Create paem_division table with foreign key referencing secretary
CREATE TABLE paem_division (
    id INT PRIMARY KEY,
    name VARCHAR(30),
    position VARCHAR(50) NOT NULL,
    secretary_id INT,
    FOREIGN KEY (secretary_id) REFERENCES secretary(secretary_id)
);

-- Insert data into paem_division table
INSERT INTO paem_division (id, name, position, secretary_id)
VALUES
(1, 'Prajwal', 'Health Minister', 1),
(2, 'Prakash', 'Deputy Health Secretary', 1),
(1502, 'Rohan', 'Deputy Health Secretary', 2),
(1602, 'Vikram', 'Assistant Health Minister', 2);

SELECT * FROM paem_division;

CREATE TABLE health_service(
   id INT PRIMARY KEY,
    name VARCHAR(30),
    position VARCHAR(50) NOT NULL,
    secretary_id INT,
    FOREIGN KEY (secretary_id) REFERENCES secretary(secretary_id)
);

INSERT INTO health_service (id, name, position, secretary_id)
VALUES
    (1, 'Prajwal', 'Health Minister', 1),
    (2, 'Prakash', 'Deputy Health Secretary', 1),
    (701, 'Bob', 'Deputy Health Secretary', 1),
    (801, 'Emannul', 'Assistant Health Minister', 1);


-- Create the ayurvedic_departement table with a foreign key referencing the secretary table
CREATE TABLE ayurvedic_departement (
    id INT PRIMARY KEY,
    name VARCHAR(30),
    position VARCHAR(50) NOT NULL,
    secretary_id INT,
    FOREIGN KEY (secretary_id) REFERENCES secretary(secretary_id)
);

-- Insert data into ayurvedic_departement table
INSERT INTO ayurvedic_departement (id, name, position, secretary_id)
VALUES
    (1, 'Prajwal', 'Health Minister', 1),
    (2, 'Prakash', 'Deputy Health Secretary', 1),
    (701, 'Ramesh', 'Deputy Health Secretary', 1),
    (801, 'Manju', 'Assistant Health Minister', 1);
    
SELECT * FROM ayurvedic_departement;

-- Create the drug_administration table with a foreign key referencing the secretary table
CREATE TABLE drug_administration (
    id INT PRIMARY KEY,
    name VARCHAR(30),
    position VARCHAR(50) NOT NULL,
    secretary_id INT,
    FOREIGN KEY (secretary_id) REFERENCES secretary(secretary_id)
);

-- Insert data into drug_administration table
INSERT INTO drug_administration (id, name, position, secretary_id)
VALUES
    (1, 'Prajwal', 'Health Minister', 1),
    (2, 'Prakash', 'Deputy Health Secretary', 1),
    (701, 'Ramesh', 'Deputy Health Secretary', 1),
    (801, 'Manju', 'Assistant Health Minister', 1);

SELECT * FROM drug_administration;
