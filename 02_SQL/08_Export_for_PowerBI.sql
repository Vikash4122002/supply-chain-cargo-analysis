-- ============================================
-- FINAL DATA CHECK FOR POWER BI (CLEAN VERSION)
-- ============================================

SELECT * FROM (

    SELECT 
        'Total Records' as metric,
        COUNT(*)::VARCHAR as value
    FROM cargo.port_cargo
    WHERE transaction_date BETWEEN '2026-01-01' AND '2026-03-31'

    UNION ALL

    SELECT 
        'Before Records',
        COUNT(*)::VARCHAR
    FROM cargo.port_cargo
    WHERE transaction_date BETWEEN '2026-01-01' AND '2026-02-14'

    UNION ALL

    SELECT 
        'After Records',
        COUNT(*)::VARCHAR
    FROM cargo.port_cargo
    WHERE transaction_date BETWEEN '2026-02-16' AND '2026-03-31'

    UNION ALL

    SELECT 
        'Ports',
        COUNT(DISTINCT port_name)::VARCHAR
    FROM cargo.port_cargo
    WHERE transaction_date BETWEEN '2026-01-01' AND '2026-03-31'

    UNION ALL

    SELECT 
        'Flow Types',
        COUNT(DISTINCT flow_type)::VARCHAR
    FROM cargo.port_cargo
    WHERE transaction_date BETWEEN '2026-01-01' AND '2026-03-31'

    UNION ALL

    SELECT 
        'Date Range',
        MIN(transaction_date)::VARCHAR || ' to ' || MAX(transaction_date)::VARCHAR
    FROM cargo.port_cargo
    WHERE transaction_date BETWEEN '2026-01-01' AND '2026-03-31'

) final_output
ORDER BY metric;