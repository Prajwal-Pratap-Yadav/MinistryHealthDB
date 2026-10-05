USE ministry_health;

INSERT INTO role (role_name) VALUES
    ('Health Minister'),
    ('Finance Minister'),
    ('Secretary'),
    ('Deputy Secretary'),
    ('Assistant Minister');

INSERT INTO official (full_name) VALUES
    ('Arjun'), ('Rohan'), ('Kiran'), ('Vikas'),
    ('Prajwal'), ('Prakash'), ('Ramesh'), ('Manju'),
    ('Esha'), ('Kushi'), ('Bob'), ('Emannul'), ('Kalyan'), ('Vikram');

INSERT INTO official_role (official_id, role_id, assigned_at)
SELECT o.official_id, r.role_id, CURRENT_DATE
FROM official o
JOIN role r ON
       (o.full_name = 'Arjun' AND r.role_name = 'Health Minister')
    OR (o.full_name = 'Rohan' AND r.role_name = 'Finance Minister')
    OR (o.full_name IN ('Kiran','Vikas') AND r.role_name = 'Secretary')
    OR (
        o.full_name IN ('Prajwal','Prakash','Ramesh','Manju','Esha','Kushi','Bob','Emannul','Kalyan','Vikram')
        AND r.role_name IN ('Deputy Secretary','Assistant Minister')
    );

INSERT INTO minister (official_id, portfolio, appointed_at)
SELECT official_id, 'Health', CURRENT_DATE
FROM official WHERE full_name = 'Arjun';

INSERT INTO minister (official_id, portfolio, appointed_at)
SELECT official_id, 'Finance', CURRENT_DATE
FROM official WHERE full_name = 'Rohan';

INSERT INTO secretary (official_id, minister_id, office_title, appointed_at)
SELECT o.official_id, m.minister_id, 'Secretary', CURRENT_DATE
FROM official o
JOIN minister m ON m.portfolio = 'Health'
WHERE o.full_name = 'Kiran';

INSERT INTO secretary (official_id, minister_id, office_title, appointed_at)
SELECT o.official_id, m.minister_id, 'Secretary', CURRENT_DATE
FROM official o
JOIN minister m ON m.portfolio = 'Finance'
WHERE o.full_name = 'Vikas';

INSERT INTO division (division_code, division_name, description) VALUES
    ('ADMIN', 'Administrative Division', 'Administrative operations and coordination'),
    ('PPIA', 'Policy, Planning & International Aid', 'Policy, planning and international support'),
    ('SERVICE', 'Service Division', 'Health service delivery coordination'),
    ('PAEM', 'Planning, Administration & Emergency Management', 'Planning and emergency management'),
    ('PUBLIC', 'Public Health Service', 'Public health service functions'),
    ('AYUR', 'Ayurvedic Department', 'Ayurvedic services and administration'),
    ('DRUG', 'Drug Administration', 'Drug administration and regulatory functions');

INSERT INTO division_member (division_id, official_id, role_id, secretary_id, joined_at)
SELECT d.division_id, o.official_id, r.role_id, 1, CURRENT_DATE
FROM division d
JOIN official o ON o.full_name = 'Prajwal'
JOIN role r ON r.role_name = 'Health Minister'
WHERE d.division_code IN ('ADMIN','PPIA','SERVICE','PAEM','PUBLIC','AYUR','DRUG');

INSERT INTO division_member (division_id, official_id, role_id, secretary_id, joined_at)
SELECT d.division_id, o.official_id, r.role_id, 1, CURRENT_DATE
FROM division d
JOIN official o ON o.full_name = 'Prakash'
JOIN role r ON r.role_name = 'Deputy Secretary'
WHERE d.division_code IN ('ADMIN','PPIA','SERVICE','PAEM','PUBLIC','AYUR','DRUG');

INSERT INTO division_member (division_id, official_id, role_id, secretary_id, joined_at)
SELECT d.division_id, o.official_id, r.role_id, 1, CURRENT_DATE
FROM division d
JOIN official o ON o.full_name = 'Ramesh'
JOIN role r ON r.role_name = 'Deputy Secretary'
WHERE d.division_code IN ('ADMIN','AYUR','DRUG');

INSERT INTO division_member (division_id, official_id, role_id, secretary_id, joined_at)
SELECT d.division_id, o.official_id, r.role_id, 1, CURRENT_DATE
FROM division d
JOIN official o ON o.full_name = 'Manju'
JOIN role r ON r.role_name = 'Assistant Minister'
WHERE d.division_code IN ('ADMIN','AYUR','DRUG');

INSERT INTO division_member (division_id, official_id, role_id, secretary_id, joined_at)
SELECT d.division_id, o.official_id, r.role_id, 2, CURRENT_DATE
FROM division d
JOIN official o ON o.full_name = 'Esha'
JOIN role r ON r.role_name = 'Deputy Secretary'
WHERE d.division_code = 'PPIA';

INSERT INTO division_member (division_id, official_id, role_id, secretary_id, joined_at)
SELECT d.division_id, o.official_id, r.role_id, 2, CURRENT_DATE
FROM division d
JOIN official o ON o.full_name = 'Kushi'
JOIN role r ON r.role_name = 'Assistant Minister'
WHERE d.division_code = 'PPIA';

INSERT INTO division_member (division_id, official_id, role_id, secretary_id, joined_at)
SELECT d.division_id, o.official_id, r.role_id, 1, CURRENT_DATE
FROM division d
JOIN official o ON o.full_name = 'Bob'
JOIN role r ON r.role_name = 'Deputy Secretary'
WHERE d.division_code = 'PUBLIC';

INSERT INTO division_member (division_id, official_id, role_id, secretary_id, joined_at)
SELECT d.division_id, o.official_id, r.role_id, 1, CURRENT_DATE
FROM division d
JOIN official o ON o.full_name = 'Emannul'
JOIN role r ON r.role_name = 'Assistant Minister'
WHERE d.division_code = 'PUBLIC';

INSERT INTO division_member (division_id, official_id, role_id, secretary_id, joined_at)
SELECT d.division_id, o.official_id, r.role_id, 2, CURRENT_DATE
FROM division d
JOIN official o ON o.full_name = 'Arjun'
JOIN role r ON r.role_name = 'Health Minister'
WHERE d.division_code = 'SERVICE';

INSERT INTO division_member (division_id, official_id, role_id, secretary_id, joined_at)
SELECT d.division_id, o.official_id, r.role_id, 2, CURRENT_DATE
FROM division d
JOIN official o ON o.full_name = 'Kalyan'
JOIN role r ON r.role_name = 'Assistant Minister'
WHERE d.division_code = 'SERVICE';

INSERT INTO division_member (division_id, official_id, role_id, secretary_id, joined_at)
SELECT d.division_id, o.official_id, r.role_id, 2, CURRENT_DATE
FROM division d
JOIN official o ON o.full_name = 'Rohan'
JOIN role r ON r.role_name = 'Deputy Secretary'
WHERE d.division_code = 'PAEM';

INSERT INTO division_member (division_id, official_id, role_id, secretary_id, joined_at)
SELECT d.division_id, o.official_id, r.role_id, 2, CURRENT_DATE
FROM division d
JOIN official o ON o.full_name = 'Vikram'
JOIN role r ON r.role_name = 'Assistant Minister'
WHERE d.division_code = 'PAEM';
