-- STEP 5: COMBINE & VALIDATE DATA
-- SECTION 1: DATA COMPLETENESS CHECK
SELECT 
    'DATA COMPLETENESS SUMMARY' as report_section;
SELECT 
    flow_type,
    port_name,
    COUNT(*) as total_records,
    MIN(transaction_date) as earliest_date,
    MAX(transaction_date) as latest_date,
    SUM(container) as total_container,
    SUM(tanker) as total_tanker,
    SUM(dry_bulk) as total_dry_bulk,
    SUM(total_cargo) as grand_total
FROM cargo.port_cargo
GROUP BY flow_type, port_name
ORDER BY flow_type, port_name;
-- SECTION 2: YEARLY BREAKDOWN
SELECT 
    'YEARLY DATA BREAKDOWN' as report_section;

SELECT 
    flow_type,
    port_name,
    EXTRACT(YEAR FROM transaction_date) as year,
    COUNT(*) as records,
    SUM(total_cargo) as total_volume
FROM cargo.port_cargo
GROUP BY flow_type, port_name, EXTRACT(YEAR FROM transaction_date)
ORDER BY flow_type, port_name, year;

-- SECTION 3: DATA QUALITY CHECKS


SELECT 
    'DATA QUALITY CHECKS' as report_section;

SELECT 
    COUNT(*) as total_rows,
    SUM(CASE WHEN port_name IS NULL THEN 1 ELSE 0 END) as null_portname,
    SUM(CASE WHEN flow_type IS NULL THEN 1 ELSE 0 END) as null_flowtype,
    SUM(CASE WHEN transaction_date IS NULL THEN 1 ELSE 0 END) as null_date,
    SUM(CASE WHEN container IS NULL THEN 1 ELSE 0 END) as null_container,
    SUM(CASE WHEN tanker IS NULL THEN 1 ELSE 0 END) as null_tanker,
    SUM(CASE WHEN dry_bulk IS NULL THEN 1 ELSE 0 END) as null_drybulk
FROM cargo.port_cargo;
-- SECTION 4: DUPLICATE CHECK


SELECT 
    'DUPLICATE RECORD CHECK' as report_section;

SELECT 
    port_name,
    flow_type,
    transaction_date,
    COUNT(*) as duplicate_count
FROM cargo.port_cargo
GROUP BY port_name, flow_type, transaction_date
HAVING COUNT(*) > 1;
-- SECTION 5: ZERO ACTIVITY DAYS
SELECT 
    'ZERO ACTIVITY DAYS' as report_section;

SELECT 
    flow_type,
    port_name,
    COUNT(*) as zero_activity_days
FROM cargo.port_cargo
WHERE container = 0 
  AND dry_bulk = 0 
  AND general_cargo = 0 
  AND ro_ro = 0 
  AND tanker = 0
GROUP BY flow_type, port_name
ORDER BY zero_activity_days DESC;
-- SECTION 6: TOP 10 BUSIEST DAYS

SELECT 
    'TOP 10 BUSIEST DAYS' as report_section;

SELECT 
    transaction_date,
    port_name,
    flow_type,
    total_cargo,
    container,
    tanker,
    dry_bulk
FROM cargo.port_cargo
ORDER BY total_cargo DESC
LIMIT 10;
-- SECTION 7: MONTHLY AGGREGATION (2026 focus)
SELECT 
    '2026 MONTHLY BREAKDOWN ' as report_section;

SELECT 
    flow_type,
    port_name,
    EXTRACT(MONTH FROM transaction_date) as month,
    COUNT(*) as days_active,
    SUM(total_cargo) as monthly_volume,
    ROUND(AVG(total_cargo), 0) as avg_daily_volume
FROM cargo.port_cargo
WHERE EXTRACT(YEAR FROM transaction_date) = 2026
GROUP BY flow_type, port_name, EXTRACT(MONTH FROM transaction_date)
ORDER BY flow_type, port_name, month;

-- SECTION 8: INCOMING VS OUTGOING COMPARISON (2026)

SELECT 
    'INCOMING VS OUTGOING 2026 ' as report_section;

SELECT 
    port_name,
    SUM(CASE WHEN flow_type = 'Incoming' THEN total_cargo ELSE 0 END) as total_incoming,
    SUM(CASE WHEN flow_type = 'Outgoing' THEN total_cargo ELSE 0 END) as total_outgoing,
    SUM(CASE WHEN flow_type = 'Incoming' THEN total_cargo ELSE 0 END) - 
    SUM(CASE WHEN flow_type = 'Outgoing' THEN total_cargo ELSE 0 END) as net_balance,
    CASE 
        WHEN SUM(CASE WHEN flow_type = 'Incoming' THEN total_cargo ELSE 0 END) > 
             SUM(CASE WHEN flow_type = 'Outgoing' THEN total_cargo ELSE 0 END)
        THEN 'Import Heavy'
        ELSE 'Export Heavy'
    END as trade_balance
FROM cargo.port_cargo
WHERE EXTRACT(YEAR FROM transaction_date) = 2026
GROUP BY port_name
ORDER BY net_balance DESC;
-- SECTION 9: DATA GAP ANALYSIS

SELECT 
    'DATA GAP ANALYSIS' as report_section;

WITH date_range AS (
    SELECT MIN(transaction_date) as min_date,
           MAX(transaction_date) as max_date
    FROM cargo.port_cargo
),
all_dates AS (
    SELECT generate_series(min_date, max_date, '1 day'::interval)::date as date
    FROM date_range
),
daily_counts AS (
    SELECT 
        transaction_date,
        flow_type,
        port_name,
        COUNT(*) as record_count
    FROM cargo.port_cargo
    GROUP BY transaction_date, flow_type, port_name
)
SELECT 
    a.date as missing_date,
    f.flow_type,
    f.port_name
FROM all_dates a
CROSS JOIN (SELECT DISTINCT flow_type, port_name FROM cargo.port_cargo) f
LEFT JOIN daily_counts d 
    ON a.date = d.transaction_date 
   AND d.flow_type = f.flow_type 
   AND d.port_name = f.port_name
WHERE d.transaction_date IS NULL
  AND a.date >= '2020-01-01'
LIMIT 50;
-- SECTION 10: FINAL VERIFICATION REPORT
SELECT 
    'FINAL VERIFICATION REPORT' as report_section;

SELECT 
    'Total Records' as metric,
    CAST(COUNT(*) AS VARCHAR) as value
FROM cargo.port_cargo

UNION ALL

SELECT 
    'Total Ports',
    CAST(COUNT(DISTINCT port_name) AS VARCHAR)
FROM cargo.port_cargo

UNION ALL

SELECT 
    'Date Range',
    MIN(transaction_date)::VARCHAR || ' to ' || MAX(transaction_date)::VARCHAR
FROM cargo.port_cargo

UNION ALL

SELECT 
    'Incoming Records',
    CAST(COUNT(*) AS VARCHAR)
FROM cargo.port_cargo
WHERE flow_type = 'Incoming'

UNION ALL

SELECT 
    'Outgoing Records',
    CAST(COUNT(*) AS VARCHAR)
FROM cargo.port_cargo
WHERE flow_type = 'Outgoing'

UNION ALL

SELECT 
    'Total Container Volume',
    CAST(SUM(container) AS VARCHAR)
FROM cargo.port_cargo

UNION ALL

SELECT 
    'Total Tanker Volume',
    CAST(SUM(tanker) AS VARCHAR)
FROM cargo.port_cargo

UNION ALL

SELECT 
    'Total Dry Bulk Volume',
    CAST(SUM(dry_bulk) AS VARCHAR)
FROM cargo.port_cargo

UNION ALL

SELECT 
    'Overall Total Cargo',
    CAST(SUM(total_cargo) AS VARCHAR)
FROM cargo.port_cargo;
-- SECTION 11: SAMPLE DATA VERIFICATION

SELECT 
    'SAMPLE DATA (First 20 rows)' as report_section;

SELECT 
    transaction_date,
    port_name,
    flow_type,
    container,
    tanker,
    dry_bulk,
    total_cargo
FROM cargo.port_cargo
ORDER BY transaction_date, port_name, flow_type
LIMIT 20;