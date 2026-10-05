USE ministry_health;

SELECT 'official' AS table_name, COUNT(*) AS row_count FROM official
UNION ALL SELECT 'role', COUNT(*) FROM role
UNION ALL SELECT 'official_role', COUNT(*) FROM official_role
UNION ALL SELECT 'minister', COUNT(*) FROM minister
UNION ALL SELECT 'secretary', COUNT(*) FROM secretary
UNION ALL SELECT 'division', COUNT(*) FROM division
UNION ALL SELECT 'division_member', COUNT(*) FROM division_member
ORDER BY table_name;

SELECT 'orphan_secretaries' AS check_name, COUNT(*) AS violations
FROM secretary s
LEFT JOIN minister m ON m.minister_id = s.minister_id
WHERE m.minister_id IS NULL
UNION ALL
SELECT 'orphan_division_members', COUNT(*)
FROM division_member dm
LEFT JOIN division d ON d.division_id = dm.division_id
LEFT JOIN official o ON o.official_id = dm.official_id
WHERE d.division_id IS NULL OR o.official_id IS NULL
UNION ALL
SELECT 'division_without_members', COUNT(*)
FROM division d
LEFT JOIN division_member dm ON dm.division_id = d.division_id
WHERE dm.official_id IS NULL;

SELECT 'duplicate_official_names' AS check_name, COUNT(*) AS violations
FROM (
    SELECT full_name FROM official GROUP BY full_name HAVING COUNT(*) > 1
) duplicates
UNION ALL
SELECT 'duplicate_division_codes', COUNT(*)
FROM (
    SELECT division_code FROM division GROUP BY division_code HAVING COUNT(*) > 1
) duplicates;

SELECT COUNT(*) AS directory_rows FROM vw_ministry_directory;
SELECT COUNT(*) AS division_summary_rows FROM vw_division_summary;
SELECT COUNT(*) AS secretary_workload_rows FROM vw_secretary_workload;

SELECT * FROM vw_ministry_directory ORDER BY division_code, full_name;
SELECT * FROM vw_division_summary ORDER BY member_count DESC, division_code;
SELECT * FROM vw_secretary_workload ORDER BY direct_reports DESC, secretary_name;
