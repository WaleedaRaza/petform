-- Check the actual structure of the profiles table
-- This will help us understand what columns exist

-- Show table structure
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'profiles' 
ORDER BY ordinal_position;

-- Show sample data
SELECT * FROM profiles LIMIT 5;

-- Check if user_id column exists
SELECT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'profiles' AND column_name = 'user_id'
) as user_id_exists;

-- Check if id column exists (might be the primary key)
SELECT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'profiles' AND column_name = 'id'
) as id_exists; 