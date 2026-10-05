# Reporting queries

## Ministry directory

```sql
SELECT *
FROM vw_ministry_directory
ORDER BY division_code, full_name;
```

## Division staffing

```sql
SELECT division_code, division_name, member_count
FROM vw_division_summary
ORDER BY member_count DESC, division_code;
```

## Secretary workload

```sql
SELECT secretary_name, minister_portfolio, direct_reports
FROM vw_secretary_workload
ORDER BY direct_reports DESC, secretary_name;
```

## Official assignments

```sql
SELECT *
FROM vw_ministry_directory
WHERE full_name = 'Prajwal'
ORDER BY division_code;
```
