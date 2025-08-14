-- Debug shopping items access
-- This will help us understand what's happening with the data

-- Check current RLS policies on shopping_items
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'shopping_items';

-- Check if RLS is enabled
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'shopping_items';

-- Check sample shopping items data
SELECT id, user_id, name, category, created_at 
FROM shopping_items 
LIMIT 5;

-- Check profiles data
SELECT id, display_name, username 
FROM profiles 
LIMIT 5;

-- Check if there are any shopping items at all
SELECT COUNT(*) as total_shopping_items FROM shopping_items;

-- Check shopping items by a specific user (replace with actual user ID)
-- SELECT id, name, category FROM shopping_items WHERE user_id = 'REPLACE_WITH_ACTUAL_USER_ID';