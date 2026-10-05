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
    dm.joined_at
FROM official o
JOIN official_role orl ON orl.official_id = o.official_id
JOIN role r ON r.role_id = orl.role_id
LEFT JOIN minister m ON m.official_id = o.official_id
LEFT JOIN secretary s ON s.official_id = o.official_id
LEFT JOIN division_member dm ON dm.official_id = o.official_id
LEFT JOIN division d ON d.division_id = dm.division_id;

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
