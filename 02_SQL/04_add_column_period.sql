-- ============================================
-- STEP 6: ADD PERIOD + REGION + ANALYSIS
-- ============================================

-- ============================================
-- SECTION 1: ADD PERIOD COLUMN
-- ============================================

DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'cargo' 
        AND table_name = 'port_cargo' 
        AND column_name = 'period'
    ) THEN
        ALTER TABLE cargo.port_cargo ADD COLUMN period VARCHAR(20);
    END IF;
END $$;

UPDATE cargo.port_cargo 
SET period = CASE 
    WHEN transaction_date < '2026-02-15' THEN 'Before_Disruption'
    ELSE 'After_Disruption'
END;

SELECT '=== PERIOD COLUMN ADDED ===';


-- ============================================
-- SECTION 2: ADD REGION COLUMN
-- ============================================

DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'cargo' 
        AND table_name = 'port_cargo' 
        AND column_name = 'region'
    ) THEN
        ALTER TABLE cargo.port_cargo ADD COLUMN region VARCHAR(20);
    END IF;
END $$;

UPDATE cargo.port_cargo 
SET region = CASE 
    WHEN port_name = 'Mumbai' THEN 'West'
    WHEN port_name IN ('Kochi','Madras') THEN 'South'
    WHEN port_name = 'Kolkata' THEN 'East'
    ELSE 'Unknown'
END;

SELECT '=== REGION COLUMN ADDED ===';


-- ============================================
-- SECTION 3: VERIFY PERIOD RANGE
-- ============================================

SELECT '=== ANALYSIS PERIOD VERIFICATION ===';

SELECT 
    period,
    MIN(transaction_date) AS start_date,
    MAX(transaction_date) AS end_date,
    COUNT(*) AS total_days
FROM cargo.port_cargo
WHERE transaction_date BETWEEN '2026-01-01' AND '2026-03-31'
GROUP BY period
ORDER BY period;


-- ============================================
-- SECTION 4: HELPER COLUMNS
-- ============================================

ALTER TABLE cargo.port_cargo ADD COLUMN IF NOT EXISTS year_num INT;
UPDATE cargo.port_cargo SET year_num = EXTRACT(YEAR FROM transaction_date);

ALTER TABLE cargo.port_cargo ADD COLUMN IF NOT EXISTS month_num INT;
UPDATE cargo.port_cargo SET month_num = EXTRACT(MONTH FROM transaction_date);

ALTER TABLE cargo.port_cargo ADD COLUMN IF NOT EXISTS quarter_num INT;
UPDATE cargo.port_cargo SET quarter_num = EXTRACT(QUARTER FROM transaction_date);

ALTER TABLE cargo.port_cargo ADD COLUMN IF NOT EXISTS day_type VARCHAR(10);

UPDATE cargo.port_cargo 
SET day_type = CASE 
    WHEN EXTRACT(DOW FROM transaction_date) IN (0,6) THEN 'Weekend'
    ELSE 'Weekday'
END;

SELECT '=== HELPER COLUMNS ADDED ===';


-- ============================================
-- SECTION 5: BEFORE VS AFTER SUMMARY (FINAL OUTPUT)
-- ============================================

SELECT '=== BEFORE VS AFTER SUMMARY ===';

SELECT 
    period,

    COUNT(*) AS total_days,

    TO_CHAR(SUM(container), 'FM9,999,999,999') AS total_container,

    TO_CHAR(SUM(tanker), 'FM9,999,999,999') AS total_tanker,

    TO_CHAR(SUM(total_cargo), 'FM9,999,999,999') AS grand_total

FROM cargo.port_cargo
WHERE transaction_date BETWEEN '2026-01-01' AND '2026-03-31'
GROUP BY period
ORDER BY period;


-- ============================================
-- SECTION 6: CUTOFF VALIDATION
-- ============================================

SELECT '=== CUTOFF VALIDATION ===';

SELECT 
    transaction_date,
    period,
    port_name,
    flow_type
FROM cargo.port_cargo
WHERE transaction_date BETWEEN '2026-02-10' AND '2026-02-20'
ORDER BY transaction_date;


-- ============================================
-- SECTION 7: INDEXES
-- ============================================

CREATE INDEX IF NOT EXISTS idx_period ON cargo.port_cargo(period);
CREATE INDEX IF NOT EXISTS idx_region ON cargo.port_cargo(region);
CREATE INDEX IF NOT EXISTS idx_year_month ON cargo.port_cargo(year_num, month_num);

SELECT '=== INDEXES CREATED ===';


-- ============================================
-- SECTION 8: FINAL REPORT
-- ============================================

SELECT 
    'Total Records' AS metric,
    COUNT(*)::TEXT AS value
FROM cargo.port_cargo

UNION ALL

SELECT 
    'Ports',
    COUNT(DISTINCT port_name)::TEXT
FROM cargo.port_cargo

UNION ALL

SELECT 
    'Date Range',
    MIN(transaction_date)::TEXT || ' to ' || MAX(transaction_date)::TEXT
FROM cargo.port_cargo;


-- ============================================
-- SECTION 9: FINAL READY CHECK (MATCH OUTPUT)
-- ============================================

SELECT '=== READY FOR ANALYSIS CHECK ===';

SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN 'PROJECT READY FOR POWER BI ANALYSIS'
        ELSE 'DATA ISSUE'
    END AS readiness_status,

    COUNT(DISTINCT period) AS periods_found,

    COUNT(DISTINCT flow_type) AS flow_types_found,

    COUNT(DISTINCT port_name) AS ports_found

FROM cargo.port_cargo;