-- NUCLEAR DELETE - COMPLETELY REMOVE ALL USER DATA
-- WARNING: This will PERMANENTLY delete all data for a specific email
-- Use this for testing when you want a completely clean slate

-- Replace 'YOUR_EMAIL_HERE' with the actual email you want to completely wipe
-- For example: 'wal33draza@gmail.com'

DO $$
DECLARE
    target_email TEXT := 'YOUR_EMAIL_HERE'; -- CHANGE THIS TO YOUR EMAIL
    mapping_record RECORD;
    profile_record RECORD;
BEGIN
    RAISE NOTICE 'NUCLEAR DELETE starting for email: %', target_email;
    
    -- Step 1: Find all Auth0 mappings for this email
    FOR mapping_record IN 
        SELECT * FROM auth0_user_mappings WHERE email = target_email
    LOOP
        RAISE NOTICE 'Found Auth0 mapping: % -> %', mapping_record.auth0_user_id, mapping_record.supabase_user_id;
        
        -- Delete all data tied to this supabase_user_id
        DELETE FROM pets WHERE user_id = mapping_record.supabase_user_id;
        DELETE FROM shopping_items WHERE user_id = mapping_record.supabase_user_id;
        DELETE FROM tracking_metrics WHERE user_id = mapping_record.supabase_user_id;
        DELETE FROM follows WHERE follower_id = mapping_record.supabase_user_id OR following_id = mapping_record.supabase_user_id;
        
        RAISE NOTICE 'Deleted pets, shopping items, tracking metrics, follows for user: %', mapping_record.supabase_user_id;
    END LOOP;
    
    -- Step 2: Find all profiles for this email
    FOR profile_record IN 
        SELECT * FROM profiles WHERE email = target_email
    LOOP
        RAISE NOTICE 'Found profile: % (user_id: %)', profile_record.username, profile_record.user_id;
        
        -- Delete all posts by this author
        DELETE FROM posts WHERE author = profile_record.username;
        
        -- Delete all data tied to this profile user_id (in case different from mapping)
        DELETE FROM pets WHERE user_id = profile_record.user_id;
        DELETE FROM shopping_items WHERE user_id = profile_record.user_id;
        DELETE FROM tracking_metrics WHERE user_id = profile_record.user_id;
        DELETE FROM follows WHERE follower_id = profile_record.user_id OR following_id = profile_record.user_id;
        
        RAISE NOTICE 'Deleted posts, pets, shopping items, tracking metrics, follows for profile user: %', profile_record.user_id;
    END LOOP;
    
    -- Step 3: Delete the mappings and profiles themselves
    DELETE FROM auth0_user_mappings WHERE email = target_email;
    DELETE FROM profiles WHERE email = target_email;
    
    -- Step 4: Delete from auth.users if needed
    DELETE FROM auth.users WHERE email = target_email;
    
    RAISE NOTICE 'NUCLEAR DELETE completed for email: %', target_email;
    RAISE NOTICE 'All data has been permanently removed!';
END $$;

-- Verification: Show what remains for this email (should be empty)
SELECT 'Verification - Auth0 mappings remaining:' as check_type, COUNT(*) as count 
FROM auth0_user_mappings WHERE email = 'YOUR_EMAIL_HERE';

SELECT 'Verification - Profiles remaining:' as check_type, COUNT(*) as count 
FROM profiles WHERE email = 'YOUR_EMAIL_HERE';

SELECT 'Verification - Auth users remaining:' as check_type, COUNT(*) as count 
FROM auth.users WHERE email = 'YOUR_EMAIL_HERE';