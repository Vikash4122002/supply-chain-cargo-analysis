-- ============================================
-- COMPLETE DATA LOADING SCRIPT (FIXED)
-- For: US-Iran War Port Impact Analysis
-- CSV Structure: DateTime, Container, Dry Bulk, General Cargo, Roll-on/roll-off, Tanker
-- ============================================

-- ============================================
-- STEP 1: CREATE STAGING TABLE (7 columns to match CSV)
-- ============================================

-- Drop if exists (clean start)
DROP TABLE IF EXISTS temp_staging;

-- Create staging table with 7 columns to match CSV exactly
CREATE TEMP TABLE temp_staging (
    datetime TEXT,
    container TEXT,
    dry_bulk TEXT,
    general_cargo TEXT,
    ro_ro TEXT,
    tanker TEXT,
    moving_avg TEXT,        -- 7-day moving average column
    prior_year_avg TEXT     -- Prior year moving average column
);

-- Verify staging table created
SELECT 'Staging table created' as status;


-- ============================================
-- STEP 2: LOAD KOCHI INCOMING DATA
-- ============================================

-- Clear staging table
TRUNCATE TABLE temp_staging;

-- Load CSV file (now reading all 8 columns)
COPY temp_staging(datetime, container, dry_bulk, general_cargo, ro_ro, tanker, moving_avg, prior_year_avg)
FROM 'D:/Projects/Port_Impact_Analysis/01_Data/Raw/Incoming/incoming_kochi_port.csv'
DELIMITER ','
CSV HEADER
QUOTE '"'
NULL '';

-- Insert into main table (only using date and cargo columns)
INSERT INTO cargo.port_cargo 
(port_name, flow_type, transaction_date, container, dry_bulk, general_cargo, ro_ro, tanker)
SELECT 
    'Kochi' as port_name,
    'Incoming' as flow_type,
    -- Extract only date part from datetime (remove time)
    SPLIT_PART(datetime, ' ', 1)::DATE as transaction_date,
    COALESCE(NULLIF(container, ''), '0')::INT,
    COALESCE(NULLIF(dry_bulk, ''), '0')::INT,
    COALESCE(NULLIF(general_cargo, ''), '0')::INT,
    COALESCE(NULLIF(ro_ro, ''), '0')::INT,
    COALESCE(NULLIF(tanker, ''), '0')::INT
FROM temp_staging
WHERE datetime IS NOT NULL 
  AND datetime != ''
  AND SPLIT_PART(datetime, ' ', 1) ~ '^\d{4}-\d{2}-\d{2}$';  -- Valid date format

-- Show results
SELECT 'Kochi Incoming' as source, COUNT(*) as records_loaded FROM temp_staging;


-- ============================================
-- STEP 3: LOAD KOLKATA INCOMING DATA
-- ============================================

TRUNCATE TABLE temp_staging;

COPY temp_staging(datetime, container, dry_bulk, general_cargo, ro_ro, tanker, moving_avg, prior_year_avg)
FROM 'D:/Projects/Port_Impact_Analysis/01_Data/Raw/Incoming/incoming_kolkata_port.csv'
DELIMITER ','
CSV HEADER
QUOTE '"'
NULL '';

INSERT INTO cargo.port_cargo 
(port_name, flow_type, transaction_date, container, dry_bulk, general_cargo, ro_ro, tanker)
SELECT 
    'Kolkata',
    'Incoming',
    SPLIT_PART(datetime, ' ', 1)::DATE,
    COALESCE(NULLIF(container, ''), '0')::INT,
    COALESCE(NULLIF(dry_bulk, ''), '0')::INT,
    COALESCE(NULLIF(general_cargo, ''), '0')::INT,
    COALESCE(NULLIF(ro_ro, ''), '0')::INT,
    COALESCE(NULLIF(tanker, ''), '0')::INT
FROM temp_staging
WHERE datetime IS NOT NULL 
  AND datetime != ''
  AND SPLIT_PART(datetime, ' ', 1) ~ '^\d{4}-\d{2}-\d{2}$';

SELECT 'Kolkata Incoming' as source, COUNT(*) as records_loaded FROM temp_staging;


-- ============================================
-- STEP 4: LOAD MADRAS INCOMING DATA
-- ============================================

TRUNCATE TABLE temp_staging;

COPY temp_staging(datetime, container, dry_bulk, general_cargo, ro_ro, tanker, moving_avg, prior_year_avg)
FROM 'D:/Projects/Port_Impact_Analysis/01_Data/Raw/Incoming/incoming_madras_port.csv'
DELIMITER ','
CSV HEADER
QUOTE '"'
NULL '';

INSERT INTO cargo.port_cargo 
(port_name, flow_type, transaction_date, container, dry_bulk, general_cargo, ro_ro, tanker)
SELECT 
    'Madras',
    'Incoming',
    SPLIT_PART(datetime, ' ', 1)::DATE,
    COALESCE(NULLIF(container, ''), '0')::INT,
    COALESCE(NULLIF(dry_bulk, ''), '0')::INT,
    COALESCE(NULLIF(general_cargo, ''), '0')::INT,
    COALESCE(NULLIF(ro_ro, ''), '0')::INT,
    COALESCE(NULLIF(tanker, ''), '0')::INT
FROM temp_staging
WHERE datetime IS NOT NULL 
  AND datetime != ''
  AND SPLIT_PART(datetime, ' ', 1) ~ '^\d{4}-\d{2}-\d{2}$';

SELECT 'Madras Incoming' as source, COUNT(*) as records_loaded FROM temp_staging;


-- ============================================
-- STEP 5: LOAD MUMBAI INCOMING DATA
-- ============================================

TRUNCATE TABLE temp_staging;

COPY temp_staging(datetime, container, dry_bulk, general_cargo, ro_ro, tanker, moving_avg, prior_year_avg)
FROM 'D:/Projects/Port_Impact_Analysis/01_Data/Raw/Incoming/incoming_mumbai_port.csv'
DELIMITER ','
CSV HEADER
QUOTE '"'
NULL '';

INSERT INTO cargo.port_cargo 
(port_name, flow_type, transaction_date, container, dry_bulk, general_cargo, ro_ro, tanker)
SELECT 
    'Mumbai',
    'Incoming',
    SPLIT_PART(datetime, ' ', 1)::DATE,
    COALESCE(NULLIF(container, ''), '0')::INT,
    COALESCE(NULLIF(dry_bulk, ''), '0')::INT,
    COALESCE(NULLIF(general_cargo, ''), '0')::INT,
    COALESCE(NULLIF(ro_ro, ''), '0')::INT,
    COALESCE(NULLIF(tanker, ''), '0')::INT
FROM temp_staging
WHERE datetime IS NOT NULL 
  AND datetime != ''
  AND SPLIT_PART(datetime, ' ', 1) ~ '^\d{4}-\d{2}-\d{2}$';

SELECT 'Mumbai Incoming' as source, COUNT(*) as records_loaded FROM temp_staging;


-- ============================================
-- STEP 6: LOAD KOCHI OUTGOING DATA
-- ============================================

TRUNCATE TABLE temp_staging;

COPY temp_staging(datetime, container, dry_bulk, general_cargo, ro_ro, tanker, moving_avg, prior_year_avg)
FROM 'D:/Projects/Port_Impact_Analysis/01_Data/Raw/Outgoing/outgoing_kochi_port.csv'
DELIMITER ','
CSV HEADER
QUOTE '"'
NULL '';

INSERT INTO cargo.port_cargo 
(port_name, flow_type, transaction_date, container, dry_bulk, general_cargo, ro_ro, tanker)
SELECT 
    'Kochi',
    'Outgoing',
    SPLIT_PART(datetime, ' ', 1)::DATE,
    COALESCE(NULLIF(container, ''), '0')::INT,
    COALESCE(NULLIF(dry_bulk, ''), '0')::INT,
    COALESCE(NULLIF(general_cargo, ''), '0')::INT,
    COALESCE(NULLIF(ro_ro, ''), '0')::INT,
    COALESCE(NULLIF(tanker, ''), '0')::INT
FROM temp_staging
WHERE datetime IS NOT NULL 
  AND datetime != ''
  AND SPLIT_PART(datetime, ' ', 1) ~ '^\d{4}-\d{2}-\d{2}$';

SELECT 'Kochi Outgoing' as source, COUNT(*) as records_loaded FROM temp_staging;


-- ============================================
-- STEP 7: LOAD KOLKATA OUTGOING DATA
-- ============================================

TRUNCATE TABLE temp_staging;

COPY temp_staging(datetime, container, dry_bulk, general_cargo, ro_ro, tanker, moving_avg, prior_year_avg)
FROM 'D:/Projects/Port_Impact_Analysis/01_Data/Raw/Outgoing/outgoing_kolkata_port.csv'
DELIMITER ','
CSV HEADER
QUOTE '"'
NULL '';

INSERT INTO cargo.port_cargo 
(port_name, flow_type, transaction_date, container, dry_bulk, general_cargo, ro_ro, tanker)
SELECT 
    'Kolkata',
    'Outgoing',
    SPLIT_PART(datetime, ' ', 1)::DATE,
    COALESCE(NULLIF(container, ''), '0')::INT,
    COALESCE(NULLIF(dry_bulk, ''), '0')::INT,
    COALESCE(NULLIF(general_cargo, ''), '0')::INT,
    COALESCE(NULLIF(ro_ro, ''), '0')::INT,
    COALESCE(NULLIF(tanker, ''), '0')::INT
FROM temp_staging
WHERE datetime IS NOT NULL 
  AND datetime != ''
  AND SPLIT_PART(datetime, ' ', 1) ~ '^\d{4}-\d{2}-\d{2}$';

SELECT 'Kolkata Outgoing' as source, COUNT(*) as records_loaded FROM temp_staging;


-- ============================================
-- STEP 8: LOAD MADRAS OUTGOING DATA
-- ============================================

TRUNCATE TABLE temp_staging;

COPY temp_staging(datetime, container, dry_bulk, general_cargo, ro_ro, tanker, moving_avg, prior_year_avg)
FROM 'D:/Projects/Port_Impact_Analysis/01_Data/Raw/Outgoing/outgoing_madras_port.csv'
DELIMITER ','
CSV HEADER
QUOTE '"'
NULL '';

INSERT INTO cargo.port_cargo 
(port_name, flow_type, transaction_date, container, dry_bulk, general_cargo, ro_ro, tanker)
SELECT 
    'Madras',
    'Outgoing',
    SPLIT_PART(datetime, ' ', 1)::DATE,
    COALESCE(NULLIF(container, ''), '0')::INT,
    COALESCE(NULLIF(dry_bulk, ''), '0')::INT,
    COALESCE(NULLIF(general_cargo, ''), '0')::INT,
    COALESCE(NULLIF(ro_ro, ''), '0')::INT,
    COALESCE(NULLIF(tanker, ''), '0')::INT
FROM temp_staging
WHERE datetime IS NOT NULL 
  AND datetime != ''
  AND SPLIT_PART(datetime, ' ', 1) ~ '^\d{4}-\d{2}-\d{2}$';

SELECT 'Madras Outgoing' as source, COUNT(*) as records_loaded FROM temp_staging;


-- ============================================
-- STEP 9: LOAD MUMBAI OUTGOING DATA
-- ============================================

TRUNCATE TABLE temp_staging;

COPY temp_staging(datetime, container, dry_bulk, general_cargo, ro_ro, tanker, moving_avg, prior_year_avg)
FROM 'D:/Projects/Port_Impact_Analysis/01_Data/Raw/Outgoing/outgoing_mumbai_port.csv'
DELIMITER ','
CSV HEADER
QUOTE '"'
NULL '';

INSERT INTO cargo.port_cargo 
(port_name, flow_type, transaction_date, container, dry_bulk, general_cargo, ro_ro, tanker)
SELECT 
    'Mumbai',
    'Outgoing',
    SPLIT_PART(datetime, ' ', 1)::DATE,
    COALESCE(NULLIF(container, ''), '0')::INT,
    COALESCE(NULLIF(dry_bulk, ''), '0')::INT,
    COALESCE(NULLIF(general_cargo, ''), '0')::INT,
    COALESCE(NULLIF(ro_ro, ''), '0')::INT,
    COALESCE(NULLIF(tanker, ''), '0')::INT
FROM temp_staging
WHERE datetime IS NOT NULL 
  AND datetime != ''
  AND SPLIT_PART(datetime, ' ', 1) ~ '^\d{4}-\d{2}-\d{2}$';

SELECT 'Mumbai Outgoing' as source, COUNT(*) as records_loaded FROM temp_staging;


-- ============================================
-- STEP 10: FINAL VERIFICATION
-- ============================================

-- Drop staging table
DROP TABLE IF EXISTS temp_staging;

-- Complete summary of all loaded data
SELECT 
    flow_type,
    port_name,
    COUNT(*) as total_records,
    MIN(transaction_date) as earliest_date,
    MAX(transaction_date) as latest_date,
    SUM(container) as total_container,
    SUM(tanker) as total_tanker,
    SUM(dry_bulk) as total_bulk,
    SUM(total_cargo) as grand_total
FROM cargo.port_cargo
GROUP BY flow_type, port_name
ORDER BY flow_type, port_name;

-- Overall totals
SELECT 
    'OVERALL TOTALS' as category,
    COUNT(*) as total_rows,
    COUNT(DISTINCT port_name) as ports,
    COUNT(DISTINCT flow_type) as flow_types,
    MIN(transaction_date) as data_from,
    MAX(transaction_date) as data_to
FROM cargo.port_cargo;