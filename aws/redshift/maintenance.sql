-- Analyze tables for query optimization
ANALYZE raw.customers;
ANALYZE raw.transactions;
ANALYZE marts.customer_transactions;

-- Vacuum tables to reclaim space and resort rows
VACUUM raw.customers TO 75 PERCENT;
VACUUM raw.transactions TO 75 PERCENT;
VACUUM marts.customer_transactions TO 75 PERCENT;

-- Clean up old data (example: keep last 2 years of data)
DELETE FROM raw.transactions 
WHERE transaction_date < DATEADD(year, -2, CURRENT_DATE);

-- Update statistics for better query planning
ANALYZE COMPRESSION raw.customers;
ANALYZE COMPRESSION raw.transactions;
ANALYZE COMPRESSION marts.customer_transactions;

-- Check for table bloat
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname || '.' || tablename)) as total_size,
    pg_size_pretty(pg_relation_size(schemaname || '.' || tablename)) as table_size,
    pg_size_pretty(pg_total_relation_size(schemaname || '.' || tablename) - 
                  pg_relation_size(schemaname || '.' || tablename)) as bloat_size
FROM pg_tables
WHERE schemaname IN ('raw', 'marts')
ORDER BY pg_total_relation_size(schemaname || '.' || tablename) DESC;

-- Check for long-running queries
SELECT
    pid,
    user_name,
    starttime,
    query,
    status
FROM pg_stat_activity
WHERE status = 'running'
AND starttime < DATEADD(hour, -1, CURRENT_TIMESTAMP);

-- Check for table statistics
SELECT
    schemaname,
    tablename,
    attname,
    n_distinct,
    null_frac,
    avg_width
FROM pg_stats
WHERE schemaname IN ('raw', 'marts')
ORDER BY schemaname, tablename, attname; 