-- ============================================
-- STEP: CREATE VIEWS FOR POWER BI (FINAL CLEAN)
-- ============================================

-- Optional (makes queries shorter)
SET search_path TO cargo;


-- ============================================
-- 1. MAIN ANALYSIS VIEW
-- ============================================

CREATE OR REPLACE VIEW cargo.vw_disruption_analysis AS
SELECT 
    transaction_date,
    port_name,
    flow_type,
    region,
    period,
    container,
    dry_bulk,
    general_cargo,
    ro_ro,
    tanker,
    total_cargo,
    EXTRACT(YEAR FROM transaction_date) AS year_num,
    EXTRACT(MONTH FROM transaction_date) AS month_num,
    EXTRACT(QUARTER FROM transaction_date) AS quarter_num,
    EXTRACT(DOW FROM transaction_date) AS day_of_week,
    CASE 
        WHEN EXTRACT(DOW FROM transaction_date) IN (0,6) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type
FROM cargo.port_cargo
WHERE transaction_date BETWEEN '2026-01-01' AND '2026-03-31';


-- ============================================
-- 2. FLOW SUMMARY (KPI)
-- ============================================

CREATE OR REPLACE VIEW cargo.vw_flow_summary AS
SELECT 
    flow_type,
    period,
    SUM(total_cargo) AS total_volume,
    COUNT(DISTINCT transaction_date) AS active_days,
    ROUND(AVG(total_cargo),0) AS avg_daily_volume,
    MAX(total_cargo) AS peak_daily_volume,
    SUM(container) AS container_volume,
    SUM(tanker) AS tanker_volume,
    SUM(dry_bulk) AS dry_bulk_volume
FROM cargo.port_cargo
WHERE transaction_date BETWEEN '2026-01-01' AND '2026-03-31'
GROUP BY flow_type, period;


-- ============================================
-- 3. PORT + FLOW SUMMARY
-- ============================================

CREATE OR REPLACE VIEW cargo.vw_port_flow_summary AS
SELECT 
    port_name,
    region,
    flow_type,
    period,
    SUM(total_cargo) AS total_volume,
    COUNT(DISTINCT transaction_date) AS active_days,
    ROUND(AVG(total_cargo),0) AS avg_daily_volume,
    MAX(total_cargo) AS peak_daily_volume
FROM cargo.port_cargo
WHERE transaction_date BETWEEN '2026-01-01' AND '2026-03-31'
GROUP BY port_name, region, flow_type, period;


-- ============================================
-- 4. DAILY COMPARISON (LINE CHART)
-- ============================================

CREATE OR REPLACE VIEW cargo.vw_daily_comparison AS
SELECT 
    transaction_date,
    SUM(CASE WHEN flow_type = 'Incoming' THEN total_cargo ELSE 0 END) AS incoming_volume,
    SUM(CASE WHEN flow_type = 'Outgoing' THEN total_cargo ELSE 0 END) AS outgoing_volume,
    SUM(CASE WHEN flow_type = 'Incoming' THEN total_cargo ELSE 0 END) -
    SUM(CASE WHEN flow_type = 'Outgoing' THEN total_cargo ELSE 0 END) AS daily_balance
FROM cargo.port_cargo
WHERE transaction_date BETWEEN '2026-01-01' AND '2026-03-31'
GROUP BY transaction_date
ORDER BY transaction_date;


-- ============================================
-- 5. PERMISSIONS (FIXED)
-- ============================================

-- Grant access to all tables + views
GRANT SELECT ON ALL TABLES IN SCHEMA cargo TO PUBLIC;

-- Future tables/views auto-permission
ALTER DEFAULT PRIVILEGES IN SCHEMA cargo
GRANT SELECT ON TABLES TO PUBLIC;


-- ============================================
-- 6. TEST (VERIFY VIEWS)
-- ============================================

SELECT * FROM cargo.vw_disruption_analysis LIMIT 5;

SELECT * FROM cargo.vw_flow_summary;

SELECT * FROM cargo.vw_port_flow_summary;

SELECT * FROM cargo.vw_daily_comparison LIMIT 5;