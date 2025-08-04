-- List All Users Script
-- This will show you all users in your database

-- List all Auth0 users
SELECT 
    id,
    email,
    created_at,
    updated_at,
    email_confirmed_at,
    last_sign_in_at
FROM auth.users
ORDER BY created_at DESC;

-- List all Auth0 mappings
SELECT 
    auth0_user_id,
    supabase_user_id,
    email,
    created_at
FROM auth0_user_mappings
ORDER BY created_at DESC;

-- Count users
SELECT 
    'Total Auth0 users' as description,
    COUNT(*) as count
FROM auth.users
UNION ALL
SELECT 
    'Total Auth0 mappings' as description,
    COUNT(*) as count
FROM auth0_user_mappings; 