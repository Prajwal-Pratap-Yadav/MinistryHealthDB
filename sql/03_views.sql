USE ministry_health;

CREATE OR REPLACE VIEW vw_ministry_directory AS
SELECT
    o.official_id,
    o.full_name,
    r.role_name,
    m.portfolio AS minister_portfolio,
    s.office_title AS secretary_office,
    d.division_code,
    d.division_name,
    appointment.joined_at
FROM official o
JOIN (
    -- A division appointment carries its own role; do not cross join it with
    -- every global role assigned to that person.
    SELECT official_id, role_id, division_id, joined_at
    FROM division_member
    UNION ALL
    -- Retain global roles that have no matching division appointment.
    SELECT orl.official_id, orl.role_id, NULL, NULL
    FROM official_role orl
    WHERE NOT EXISTS (
        SELECT 1 FROM division_member dm
        WHERE dm.official_id = orl.official_id AND dm.role_id = orl.role_id
    )
) appointment ON appointment.official_id = o.official_id
JOIN role r ON r.role_id = appointment.role_id
LEFT JOIN minister m ON m.official_id = o.official_id
LEFT JOIN secretary s ON s.official_id = o.official_id
LEFT JOIN division d ON d.division_id = appointment.division_id;

CREATE OR REPLACE VIEW vw_division_summary AS
SELECT
    d.division_code,
    d.division_name,
    d.active,
    COUNT(dm.official_id) AS member_count
FROM division d
LEFT JOIN division_member dm ON dm.division_id = d.division_id
GROUP BY d.division_id, d.division_code, d.division_name, d.active;

CREATE OR REPLACE VIEW vw_secretary_workload AS
SELECT
    s.secretary_id,
    o.full_name AS secretary_name,
    m.portfolio AS minister_portfolio,
    COUNT(DISTINCT dm.official_id) AS direct_reports
FROM secretary s
JOIN official o ON o.official_id = s.official_id
JOIN minister m ON m.minister_id = s.minister_id
LEFT JOIN division_member dm ON dm.secretary_id = s.secretary_id
GROUP BY s.secretary_id, o.full_name, m.portfolio;
