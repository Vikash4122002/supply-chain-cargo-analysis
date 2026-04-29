-- ============================================
-- DETAILED INCOMING VS OUTGOING ANALYSIS
-- ============================================

-- 1. DAILY COMPARISON
SELECT 
    transaction_date,
    SUM(CASE WHEN flow_type = 'Incoming' THEN total_cargo ELSE 0 END) as incoming_daily,
    SUM(CASE WHEN flow_type = 'Outgoing' THEN total_cargo ELSE 0 END) as outgoing_daily
FROM cargo.port_cargo   
WHERE transaction_date BETWEEN '2026-01-01' AND '2026-03-31'
GROUP BY transaction_date
ORDER BY transaction_date;


-- ============================================
-- 2. PERCENTAGE CHANGE BY CARGO TYPE
-- ============================================

SELECT 
    cargo_type,
    flow_type,
    ROUND(((after_volume - before_volume) * 100.0 / NULLIF(before_volume,0)), 2) as pct_change
FROM (
    SELECT 
        'Container' as cargo_type,
        flow_type,
        SUM(CASE WHEN period = 'Before_Disruption' THEN container ELSE 0 END) as before_volume,
        SUM(CASE WHEN period = 'After_Disruption' THEN container ELSE 0 END) as after_volume
    FROM cargo.port_cargo
    WHERE transaction_date BETWEEN '2026-01-01' AND '2026-03-31'
    GROUP BY flow_type

    UNION ALL

    SELECT 
        'Tanker',
        flow_type,
        SUM(CASE WHEN period = 'Before_Disruption' THEN tanker ELSE 0 END),
        SUM(CASE WHEN period = 'After_Disruption' THEN tanker ELSE 0 END)
    FROM cargo.port_cargo
    WHERE transaction_date BETWEEN '2026-01-01' AND '2026-03-31'
    GROUP BY flow_type

    UNION ALL

    SELECT 
        'Dry Bulk',
        flow_type,
        SUM(CASE WHEN period = 'Before_Disruption' THEN dry_bulk ELSE 0 END),
        SUM(CASE WHEN period = 'After_Disruption' THEN dry_bulk ELSE 0 END)
    FROM cargo.port_cargo
    WHERE transaction_date BETWEEN '2026-01-01' AND '2026-03-31'
    GROUP BY flow_type

) subquery
ORDER BY cargo_type, flow_type;


-- ============================================
-- 3. MOST IMPACTED PORT BY FLOW TYPE
-- ============================================

WITH port_flow_changes AS (
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
    ROUND(((after_vol - before_vol) * 100.0 / NULLIF(before_vol,0)), 2) as pct_change,
    CASE 
        WHEN after_vol > before_vol THEN 'Increase'
        WHEN after_vol < before_vol THEN 'Decrease'
        ELSE 'No Change'
    END as trend
FROM port_flow_changes
WHERE before_vol > 0
ORDER BY pct_change;