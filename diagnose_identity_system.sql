-- DIAGNOSE IDENTITY SYSTEM
-- This will show exactly what's happening with your account

-- Step 1: Show current Auth0 mappings
SELECT 'Current Auth0 Mappings:' as section;
SELECT 
    email,
    auth0_user_id,
    supabase_user_id,
    created_at,
    updated_at
FROM auth0_user_mappings
ORDER BY email, created_at;

-- Step 2: Show profiles (where usernames/display names are stored)
SELECT 'Current Profiles:' as section;
SELECT 
    email,
    username,
    display_name,
    user_id,
    created_at
FROM profiles
ORDER BY email;

-- Step 3: Show pets data
SELECT 'Current Pets Data:' as section;
SELECT 
    p.name as pet_name,
    p.user_id,
    pr.email as owner_email,
    pr.username as owner_username,
    p.created_at
FROM pets p
LEFT JOIN profiles pr ON p.user_id = pr.user_id
ORDER BY pr.email;

-- Step 4: Show shopping items data
SELECT 'Current Shopping Items:' as section;
SELECT 
    si.name as item_name,
    si.user_id,
    pr.email as owner_email,
    pr.username as owner_username,
    si.created_at
FROM shopping_items si
LEFT JOIN profiles pr ON si.user_id = pr.user_id
ORDER BY pr.email;

-- Step 5: Show posts data
SELECT 'Current Posts Data:' as section;
SELECT 
    title,
    author,
    created_at
FROM posts
ORDER BY author, created_at;

-- Step 6: Test the bulletproof function (this is what happens when you log in)
-- Replace YOUR_EMAIL and YOUR_AUTH0_ID with your actual values
-- SELECT 'Testing bulletproof function:' as section;
-- SELECT get_or_create_supabase_user_for_auth0(
--     'YOUR_NEW_AUTH0_ID',
--     'YOUR_EMAIL',
--     'Your Name',
--     'your_nickname',
--     null
-- ) as returned_supabase_id;