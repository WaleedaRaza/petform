-- User Diagnosis Script
-- Replace 'user@example.com' with the email you're trying to delete

DO $$
DECLARE
    user_email TEXT := 'user@example.com'; -- CHANGE THIS
    user_uuid UUID;
    auth0_id TEXT;
BEGIN
    RAISE NOTICE '=== DIAGNOSING USER: % ===', user_email;
    
    -- Check if user exists in auth.users
    SELECT id INTO user_uuid FROM auth.users WHERE email = user_email;
    IF user_uuid IS NOT NULL THEN
        RAISE NOTICE '✓ Found in auth.users: %', user_uuid;
    ELSE
        RAISE NOTICE '✗ NOT found in auth.users';
    END IF;
    
    -- Check if user exists in auth0_user_mappings
    SELECT auth0_user_id INTO auth0_id FROM auth0_user_mappings WHERE email = user_email;
    IF auth0_id IS NOT NULL THEN
        RAISE NOTICE '✓ Found in auth0_user_mappings: %', auth0_id;
    ELSE
        RAISE NOTICE '✗ NOT found in auth0_user_mappings';
    END IF;
    
    -- Check for orphaned data
    IF user_uuid IS NOT NULL THEN
        RAISE NOTICE '=== CHECKING FOR ORPHANED DATA ===';
        
        -- Check pets
        IF EXISTS(SELECT 1 FROM pets WHERE user_id = user_uuid) THEN
            RAISE NOTICE '⚠ Found pets for this user';
        END IF;
        
        -- Check posts
        IF EXISTS(SELECT 1 FROM posts WHERE user_id = user_uuid) THEN
            RAISE NOTICE '⚠ Found posts for this user';
        END IF;
        
        -- Check profiles
        IF EXISTS(SELECT 1 FROM profiles WHERE user_id = user_uuid) THEN
            RAISE NOTICE '⚠ Found profile for this user';
        END IF;
        
        -- Check shopping items
        IF EXISTS(SELECT 1 FROM shopping_items WHERE user_id = user_uuid) THEN
            RAISE NOTICE '⚠ Found shopping items for this user';
        END IF;
    END IF;
    
    RAISE NOTICE '=== DIAGNOSIS COMPLETE ===';
END $$; 