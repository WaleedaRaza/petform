-- Safe User Deletion Script
-- This script will delete a user and all their data safely

-- Replace 'user@example.com' with the email you want to delete
DO $$
DECLARE
    user_email TEXT := 'user@example.com'; -- CHANGE THIS TO THE EMAIL YOU WANT TO DELETE
    user_uuid UUID;
    deleted_count INTEGER := 0;
BEGIN
    -- Get the user's UUID
    SELECT id INTO user_uuid FROM auth.users WHERE email = user_email;
    
    IF user_uuid IS NULL THEN
        RAISE NOTICE 'User not found: %', user_email;
        RETURN;
    END IF;
    
    RAISE NOTICE 'Found user: % (UUID: %)', user_email, user_uuid;
    
    -- Temporarily disable RLS to allow deletion
    ALTER TABLE pets DISABLE ROW LEVEL SECURITY;
    ALTER TABLE posts DISABLE ROW LEVEL SECURITY;
    ALTER TABLE shopping_items DISABLE ROW LEVEL SECURITY;
    ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;
    ALTER TABLE tracking_metrics DISABLE ROW LEVEL SECURITY;
    ALTER TABLE tracking_entries DISABLE ROW LEVEL SECURITY;
    ALTER TABLE comments DISABLE ROW LEVEL SECURITY;
    ALTER TABLE auth0_user_mappings DISABLE ROW LEVEL SECURITY;
    
    -- Delete from auth0_user_mappings first
    DELETE FROM auth0_user_mappings WHERE supabase_user_id = user_uuid;
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RAISE NOTICE 'Deleted % rows from auth0_user_mappings', deleted_count;
    
    -- Delete from comments
    DELETE FROM comments WHERE user_id = user_uuid;
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RAISE NOTICE 'Deleted % rows from comments', deleted_count;
    
    -- Delete from tracking_entries (through tracking_metrics)
    DELETE FROM tracking_entries WHERE metric_id IN (
        SELECT id FROM tracking_metrics WHERE user_id = user_uuid
    );
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RAISE NOTICE 'Deleted % rows from tracking_entries', deleted_count;
    
    -- Delete from tracking_metrics
    DELETE FROM tracking_metrics WHERE user_id = user_uuid;
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RAISE NOTICE 'Deleted % rows from tracking_metrics', deleted_count;
    
    -- Delete from shopping_items
    DELETE FROM shopping_items WHERE user_id = user_uuid;
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RAISE NOTICE 'Deleted % rows from shopping_items', deleted_count;
    
    -- Delete from posts
    DELETE FROM posts WHERE user_id = user_uuid;
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RAISE NOTICE 'Deleted % rows from posts', deleted_count;
    
    -- Delete from pets
    DELETE FROM pets WHERE user_id = user_uuid;
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RAISE NOTICE 'Deleted % rows from pets', deleted_count;
    
    -- Delete from profiles
    DELETE FROM profiles WHERE user_id = user_uuid;
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RAISE NOTICE 'Deleted % rows from profiles', deleted_count;
    
    -- Re-enable RLS
    ALTER TABLE pets ENABLE ROW LEVEL SECURITY;
    ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
    ALTER TABLE shopping_items ENABLE ROW LEVEL SECURITY;
    ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
    ALTER TABLE tracking_metrics ENABLE ROW LEVEL SECURITY;
    ALTER TABLE tracking_entries ENABLE ROW LEVEL SECURITY;
    ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
    ALTER TABLE auth0_user_mappings ENABLE ROW LEVEL SECURITY;
    
    -- Finally, delete from auth.users
    DELETE FROM auth.users WHERE id = user_uuid;
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RAISE NOTICE 'Deleted % rows from auth.users', deleted_count;
    
    RAISE NOTICE 'Successfully deleted user: %', user_email;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Re-enable RLS in case of error
        ALTER TABLE pets ENABLE ROW LEVEL SECURITY;
        ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
        ALTER TABLE shopping_items ENABLE ROW LEVEL SECURITY;
        ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
        ALTER TABLE tracking_metrics ENABLE ROW LEVEL SECURITY;
        ALTER TABLE tracking_entries ENABLE ROW LEVEL SECURITY;
        ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
        ALTER TABLE auth0_user_mappings ENABLE ROW LEVEL SECURITY;
        
        RAISE NOTICE 'Error deleting user: %', SQLERRM;
        RAISE;
END $$; 