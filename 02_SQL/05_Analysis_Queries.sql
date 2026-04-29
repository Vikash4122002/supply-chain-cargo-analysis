-- ============================================
-- STEP 7: ANALYSIS QUERIES
-- ============================================

-- ============================================
-- SECTION 1: OVERALL IMPACT
-- ============================================

SELECT '=== 1. OVERALL IMPACT ANALYSIS ===' as report_section;

SELECT 
    period,
    flow_type,
    COUNT(*) as total_days,
    SUM(container) as total_container,
    SUM(tanker) as total_tanker,
    SUM(dry_bulk) as total_dry_bulk,
    SUM(general_cargo) as total_general,
    SUM(total_cargo) as grand_total,
    ROUND(AVG(total_cargo), 0) as avg_daily_volume,
    ROUND(SUM(container) * 100.0 / NULLIF(SUM(total_cargo), 0), 2) as container_pct,
    ROUND(SUM(tanker) * 100.0 / NULLIF(SUM(total_cargo), 0), 2) as tanker_pct,
    ROUND(SUM(dry_bulk) * 100.0 / NULLIF(SUM(total_cargo), 0), 2) as bulk_pct
FROM cargo.port_cargo   
WHERE transaction_date BETWEEN '2026-01-01' AND '2026-03-31'
GROUP BY period, flow_type
ORDER BY flow_type, period;


-- ============================================
-- SECTION 2: GROWTH %
-- ============================================

SELECT '=== 2. GROWTH PERCENTAGE ===' as report_section;

WITH period_totals AS (
    SELECT 
        flow_type,
        period,
        SUM(total_cargo) as total_volume,
        SUM(container) as total_container,
        SUM(tanker) as total_tanker,
        SUM(dry_bulk) as total_bulk
    FROM cargo.port_cargo  
    WHERE transaction_date BETWEEN '2026-01-01' AND '2026-03-31'
    GROUP BY flow_type, period
)
SELECT 
    p1.flow_type,
    p1.total_volume as before_volume,
    p2.total_volume as after_volume,
    p2.total_volume - p1.total_volume as absolute_change,
    ROUND(((p2.total_volume - p1.total_volume) * 100.0 / p1.total_volume), 2) as total_growth_pct,
    ROUND(((p2.total_container - p1.total_container) * 100.0 / NULLIF(p1.total_container, 0)), 2) as container_growth_pct,
    ROUND(((p2.total_tanker - p1.total_tanker) * 100.0 / NULLIF(p1.total_tanker, 0)), 2) as tanker_growth_pct,
    ROUND(((p2.total_bulk - p1.total_bulk) * 100.0 / NULLIF(p1.total_bulk, 0)), 2) as bulk_growth_pct
FROM period_totals p1
JOIN period_totals p2 
    ON p1.flow_type = p2.flow_type
WHERE p1.period = 'Before_Disruption' 
  AND p2.period = 'After_Disruption'
ORDER BY p1.flow_type;


-- ============================================
-- SECTION 3: PORT-WISE IMPACT
-- ============================================

SELECT '=== 3. PORT-WISE IMPACT ===' as report_section;

WITH port_periods AS (
    SELECT 
        port_name,
        region,
        flow_type,
        period,
        SUM(total_cargo) as total_volume,
        COUNT(*) as active_days,
        ROUND(AVG(total_cargo), 0) as avg_daily
    FROM cargo.port_cargo   
    WHERE transaction_date BETWEEN '2026-01-01' AND '2026-03-31'
    GROUP BY port_name, region, flow_type, period
),
port_changes AS (
    SELECT 
        p1.port_name,
        p1.region,
        p1.flow_type,
        p1.total_volume as before_volume,
        p2.total_volume as after_volume,
        p1.active_days as before_days,
        p2.active_days as after_days,
        ROUND(((p2.total_volume - p1.total_volume) * 100.0 / p1.total_volume), 2) as pct_change
    FROM port_periods p1
    JOIN port_periods p2 
        ON p1.port_name = p2.port_name 
        AND p1.flow_type = p2.flow_type
    WHERE p1.period = 'Before_Disruption' 
      AND p2.period = 'After_Disruption'
)
SELECT 
    port_name,
    region,
    flow_type,
    before_volume,
    after_volume,
    pct_change,
    CASE 
        WHEN pct_change > 0 THEN 'INCREASE'
        WHEN pct_change < 0 THEN 'DECREASE'
        ELSE 'NO CHANGE'
    END as trend,
    RANK() OVER (PARTITION BY flow_type ORDER BY pct_change) as least_impacted_rank,
    RANK() OVER (PARTITION BY flow_type ORDER BY pct_change DESC) as most_impacted_rank
FROM port_changes
WHERE before_volume > 0
ORDER BY flow_type, pct_change;

-- ============================================
-- SECTION 4: MOST IMPACTED PORTS
-- ============================================

SELECT '=== 4. MOST IMPACTED PORTS (Top Declines) ===' as report_section;

WITH port_changes AS (
    SELECT 
        port_name,
        flow_type,
        SUM(CASE WHEN period = 'Before_Disruption' THEN total_cargo ELSE 0 END) as before_vol,
        SUM(CASE WHEN period = 'After_Disruption' THEN total_cargo ELSE 0 END) as after_vol
    FROM cargo.port_cargo   
    WHERE transaction_date BETWEEN '2026-01-01' AND '2026-03-31'
    GROUP BY port_name, flow_type
)
SELECT 
    port_name,
    flow_type,
    before_vol,
    after_vol,
    ROUND(
        ((after_vol - before_vol) * 100.0 / NULLIF(before_vol, 0)), 2
    ) as pct_change,
    RANK() OVER (
        ORDER BY ((after_vol - before_vol) * 100.0 / NULLIF(before_vol, 0))
    ) as decline_rank
FROM port_changes
WHERE before_vol > 0
ORDER BY pct_change
LIMIT 10;


-- ============================================
-- SECTION 5: CARGO TYPE IMPACT BY PORT
-- ============================================

SELECT '=== 5. CARGO TYPE IMPACT BY PORT ===' as report_section;

SELECT 
    port_name,
    flow_type,
    'Container' as cargo_type,
    SUM(CASE WHEN period = 'Before_Disruption' THEN container ELSE 0 END) as before_volume,
    SUM(CASE WHEN period = 'After_Disruption' THEN container ELSE 0 END) as after_volume
FROM cargo.port_cargo   
WHERE transaction_date BETWEEN '2026-01-01' AND '2026-03-31'
GROUP BY port_name, flow_type

UNION ALL

SELECT 
    port_name,
    flow_type,
    'Tanker',
    SUM(CASE WHEN period = 'Before_Disruption' THEN tanker ELSE 0 END),
    SUM(CASE WHEN period = 'After_Disruption' THEN tanker ELSE 0 END)
FROM cargo.port_cargo
WHERE transaction_date BETWEEN '2026-01-01' AND '2026-03-31'
GROUP BY port_name, flow_type

UNION ALL

SELECT 
    port_name,
    flow_type,
    'Dry Bulk',
    SUM(CASE WHEN period = 'Before_Disruption' THEN dry_bulk ELSE 0 END),
    SUM(CASE WHEN period = 'After_Disruption' THEN dry_bulk ELSE 0 END)
FROM cargo.port_cargo
WHERE transaction_date BETWEEN '2026-01-01' AND '2026-03-31'
GROUP BY port_name, flow_type

ORDER BY port_name, flow_type, cargo_type;


-- ============================================
-- SECTION 6: DAILY TREND WITH MOVING AVERAGE
-- ============================================

SELECT '=== 6. DAILY TREND WITH MOVING AVERAGE ===' as report_section;

SELECT 
    transaction_date,
    port_name,
    flow_type,
    total_cargo as daily_volume,

    ROUND(
        AVG(total_cargo) OVER (
            PARTITION BY port_name, flow_type 
            ORDER BY transaction_date 
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ), 0
    ) as moving_avg_7day,

    ROUND(
        AVG(total_cargo) OVER (
            PARTITION BY port_name, flow_type 
            ORDER BY transaction_date 
            ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
        ), 0
    ) as moving_avg_30day

FROM cargo.port_cargo  
WHERE transaction_date BETWEEN '2026-01-01' AND '2026-03-31'
ORDER BY port_name, flow_type, transaction_date
LIMIT 100;


-- ============================================
-- SECTION 7: TRADE BALANCE ANALYSIS
-- ============================================

SELECT '=== 7. TRADE BALANCE ===' as report_section;

SELECT 
    period,
    port_name,
    SUM(CASE WHEN flow_type = 'Incoming' THEN total_cargo ELSE 0 END) as imports,
    SUM(CASE WHEN flow_type = 'Outgoing' THEN total_cargo ELSE 0 END) as exports,

    SUM(CASE WHEN flow_type = 'Incoming' THEN total_cargo ELSE 0 END) - 
    SUM(CASE WHEN flow_type = 'Outgoing' THEN total_cargo ELSE 0 END) as trade_balance,

    CASE 
        WHEN SUM(CASE WHEN flow_type = 'Incoming' THEN total_cargo ELSE 0 END) > 
             SUM(CASE WHEN flow_type = 'Outgoing' THEN total_cargo ELSE 0 END)
        THEN 'Trade Deficit'
        ELSE 'Trade Surplus'
    END as trade_status

FROM cargo.port_cargo  
WHERE transaction_date BETWEEN '2026-01-01' AND '2026-03-31'
GROUP BY period, port_name
ORDER BY port_name, period;


-- ============================================
-- SECTION 8: REGION-WISE ANALYSIS
-- ============================================

SELECT '=== 8. REGION-WISE IMPACT ===' as report_section;

SELECT 
    region,
    period,
    flow_type,
    SUM(total_cargo) as total_volume,
    COUNT(*) as active_days,
    ROUND(AVG(total_cargo), 0) as avg_daily,

    ROUND(SUM(container) * 100.0 / NULLIF(SUM(total_cargo), 0), 2) as container_share,
    ROUND(SUM(tanker) * 100.0 / NULLIF(SUM(total_cargo), 0), 2) as tanker_share

FROM cargo.port_cargo  
WHERE transaction_date BETWEEN '2026-01-01' AND '2026-03-31'
  AND region != 'Unknown'
GROUP BY region, period, flow_type
ORDER BY region, flow_type, period;


-- ============================================
-- SECTION 9: WEEKDAY VS WEEKEND
-- ============================================

SELECT '=== 9. WEEKDAY VS WEEKEND ===' as report_section;

SELECT 
    period,
    flow_type,
    day_type,
    COUNT(*) as days,
    SUM(total_cargo) as total_volume,
    ROUND(AVG(total_cargo), 0) as avg_daily,
    ROUND(AVG(container), 0) as avg_container,
    ROUND(AVG(tanker), 0) as avg_tanker

FROM cargo.port_cargo   
WHERE transaction_date BETWEEN '2026-01-01' AND '2026-03-31'
GROUP BY period, flow_type, day_type
ORDER BY flow_type, period, day_type;


-- ============================================
-- SECTION 10: TOP 20 DAYS
-- ============================================

SELECT '=== 10. TOP 20 DAYS ===' as report_section;

SELECT 
    transaction_date,
    port_name,
    flow_type,
    period,
    total_cargo,
    container,
    tanker,
    dry_bulk

FROM cargo.port_cargo  
WHERE transaction_date BETWEEN '2026-01-01' AND '2026-03-31'
ORDER BY total_cargo DESC
LIMIT 20;
-- ============================================
-- SECTION 11: VOLUME DISTRIBUTION
-- ============================================

SELECT '=== 11. VOLUME DISTRIBUTION ===' as report_section;

SELECT 
    flow_type,
    period,

    ROUND(PERCENTILE_CONT(0.10) WITHIN GROUP (ORDER BY total_cargo)::numeric, 0) as p10,
    ROUND(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_cargo)::numeric, 0) as p25,
    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY total_cargo)::numeric, 0) as median,
    ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_cargo)::numeric, 0) as p75,
    ROUND(PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY total_cargo)::numeric, 0) as p90,

    ROUND(AVG(total_cargo)::numeric, 0) as mean,
    ROUND(STDDEV(total_cargo)::numeric, 0) as std_dev

FROM cargo.port_cargo
WHERE transaction_date BETWEEN '2026-01-01' AND '2026-03-31'
GROUP BY flow_type, period
ORDER BY flow_type, period;


-- ============================================
-- SECTION 12: POWER BI EXPORT
-- ============================================

SELECT '=== 12. POWER BI EXPORT ===' as report_section;

DROP TABLE IF EXISTS cargo.powerbi_export;   

CREATE TABLE cargo.powerbi_export AS
SELECT 
    transaction_date as date,
    port_name as port,
    flow_type,
    region,
    period,
    container,
    tanker,
    dry_bulk,
    general_cargo,
    ro_ro,
    total_cargo,
    year_num as year,
    month_num as month,
    quarter_num as quarter,
    day_type,
    CASE WHEN period = 'Before_Disruption' THEN total_cargo ELSE 0 END as before_volume,
    CASE WHEN period = 'After_Disruption' THEN total_cargo ELSE 0 END as after_volume
FROM cargo.port_cargo   
WHERE transaction_date BETWEEN '2026-01-01' AND '2026-03-31';


SELECT 
    'Power BI export created with ' || COUNT(*) || ' rows' as export_status
FROM cargo.powerbi_export;


-- ============================================
-- SECTION 13: EXECUTIVE SUMMARY (FINAL)
-- ============================================

SELECT '=== 13. EXECUTIVE SUMMARY ===' as report_section;

WITH overall_stats AS (
    SELECT 
        period,
        SUM(total_cargo) as total
    FROM cargo.port_cargo
    WHERE transaction_date BETWEEN '2026-01-01' AND '2026-03-31'
    GROUP BY period
),

before_after AS (
    SELECT 
        MAX(CASE WHEN period = 'Before_Disruption' THEN total END) as before_total,
        MAX(CASE WHEN period = 'After_Disruption' THEN total END) as after_total
    FROM overall_stats
),

cargo_changes AS (
    SELECT 
        'Container' as cargo_type,
        SUM(CASE WHEN period = 'After_Disruption' THEN container ELSE 0 END) -
        SUM(CASE WHEN period = 'Before_Disruption' THEN container ELSE 0 END) as change
    FROM cargo.port_cargo

    UNION ALL

    SELECT 
        'Tanker',
        SUM(CASE WHEN period = 'After_Disruption' THEN tanker ELSE 0 END) -
        SUM(CASE WHEN period = 'Before_Disruption' THEN tanker ELSE 0 END)
    FROM cargo.port_cargo

    UNION ALL

    SELECT 
        'Dry Bulk',
        SUM(CASE WHEN period = 'After_Disruption' THEN dry_bulk ELSE 0 END) -
        SUM(CASE WHEN period = 'Before_Disruption' THEN dry_bulk ELSE 0 END)
    FROM cargo.port_cargo
),

port_changes AS (
    SELECT 
        port_name,
        SUM(CASE WHEN period = 'After_Disruption' THEN total_cargo ELSE 0 END) -
        SUM(CASE WHEN period = 'Before_Disruption' THEN total_cargo ELSE 0 END) as change
    FROM cargo.port_cargo
    GROUP BY port_name
)

-- FINAL OUTPUT
SELECT 
    'Total Volume Before (Jan 1 - Feb 14, 2026)' as metric,
    before_total::TEXT as value
FROM before_after

UNION ALL

SELECT 
    'Total Volume After (Feb 16 - Mar 31, 2026)',
    after_total::TEXT
FROM before_after

UNION ALL

SELECT 
    'Absolute Change',
    (after_total - before_total)::TEXT
FROM before_after

UNION ALL

SELECT 
    'Percentage Change',
    ROUND((after_total - before_total) * 100.0 / NULLIF(before_total, 0), 2)::TEXT || '%'
FROM before_after

UNION ALL
SELECT 
    'Most Impacted Cargo Type',
    cargo_type
FROM (
    SELECT * FROM cargo_changes
    ORDER BY change
    LIMIT 1
) t

UNION ALL
SELECT 
    'Most Impacted Port',
    port_name
FROM (
    SELECT * FROM port_changes
    ORDER BY change
    LIMIT 1
) p

UNION ALL

SELECT 
    'Analysis Period Complete',
    'Jan 1, 2026 - Mar 31, 2026'

UNION ALL

SELECT 
    'Data Ready for Power BI',
    'YES';