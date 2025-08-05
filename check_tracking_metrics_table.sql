-- Check the actual structure of the tracking_metrics table
-- This will help us understand what columns exist

-- Show table structure
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'tracking_metrics' 
ORDER BY ordinal_position;

-- Show sample data
SELECT * FROM tracking_metrics LIMIT 5;

-- Check if specific columns exist
SELECT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'tracking_metrics' AND column_name = 'current_value'
) as current_value_exists;

SELECT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'tracking_metrics' AND column_name = 'target_value'
) as target_value_exists;

SELECT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'tracking_metrics' AND column_name = 'frequency'
) as frequency_exists; 