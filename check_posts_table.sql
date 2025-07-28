-- Check what columns exist in the posts table
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'posts'
ORDER BY ordinal_position; 