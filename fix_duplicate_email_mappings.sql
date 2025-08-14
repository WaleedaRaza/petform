-- FIX DUPLICATE EMAIL MAPPINGS
-- Ensure only one Auth0 account can exist per email address

-- Step 1: First let's see the current duplicate situation
SELECT 'Duplicate email analysis:' as info;
SELECT 
    email,
    COUNT(*) as auth0_accounts,
    array_agg(auth0_user_id ORDER BY created_at) as auth0_ids,
    array_agg(supabase_user_id ORDER BY created_at) as supabase_ids
FROM auth0_user_mappings 
WHERE email IS NOT NULL
GROUP BY email 
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC;

-- Step 2: For each email with duplicates, keep only the OLDEST mapping and delete the rest
-- This preserves the original account and removes duplicate sessions

DO $$
DECLARE
    email_record RECORD;
    mapping_record RECORD;
    keep_mapping_id UUID;
BEGIN
    -- For each email that has duplicates
    FOR email_record IN 
        SELECT email, COUNT(*) as count_dupes
        FROM auth0_user_mappings 
        WHERE email IS NOT NULL
        GROUP BY email 
        HAVING COUNT(*) > 1
    LOOP
        RAISE NOTICE 'Processing email: % (% duplicates)', email_record.email, email_record.count_dupes;
        
        -- Find the OLDEST mapping for this email (keep the original account)
        SELECT id INTO keep_mapping_id
        FROM auth0_user_mappings 
        WHERE email = email_record.email
        ORDER BY created_at ASC 
        LIMIT 1;
        
        RAISE NOTICE 'Keeping mapping ID: %', keep_mapping_id;
        
        -- Delete all OTHER mappings for this email
        DELETE FROM auth0_user_mappings 
        WHERE email = email_record.email 
        AND id != keep_mapping_id;
        
        RAISE NOTICE 'Deleted duplicate mappings for: %', email_record.email;
    END LOOP;
END $$;

-- Step 3: Add unique constraint on email to prevent future duplicates
ALTER TABLE auth0_user_mappings DROP CONSTRAINT IF EXISTS unique_email_per_mapping;
ALTER TABLE auth0_user_mappings ADD CONSTRAINT unique_email_per_mapping UNIQUE (email);

-- Step 4: Update the get_or_create function to handle email uniqueness
DROP FUNCTION IF EXISTS get_or_create_supabase_user_for_auth0(text, text, text, text, text);
CREATE OR REPLACE FUNCTION get_or_create_supabase_user_for_auth0(
    p_auth0_user_id TEXT,
    p_auth0_email TEXT DEFAULT NULL,
    p_auth0_name TEXT DEFAULT NULL,
    p_auth0_nickname TEXT DEFAULT NULL,
    p_auth0_picture TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    v_existing_mapping auth0_user_mappings%ROWTYPE;
    v_existing_email_mapping auth0_user_mappings%ROWTYPE;
    v_new_supabase_user_id UUID;
    v_user_email TEXT;
    v_user_name TEXT;
BEGIN
    -- Set the email
    v_user_email := COALESCE(p_auth0_email, p_auth0_user_id || '@auth0.local');
    v_user_name := COALESCE(p_auth0_name, p_auth0_nickname, 'Auth0 User');
    
    -- Check if mapping already exists for this Auth0 user ID
    SELECT * INTO v_existing_mapping 
    FROM auth0_user_mappings 
    WHERE auth0_user_id = p_auth0_user_id;
    
    -- If mapping exists, return the Supabase user ID
    IF v_existing_mapping.supabase_user_id IS NOT NULL THEN
        RETURN v_existing_mapping.supabase_user_id;
    END IF;
    
    -- Check if this EMAIL already has a mapping (different Auth0 user)
    SELECT * INTO v_existing_email_mapping 
    FROM auth0_user_mappings 
    WHERE email = v_user_email;
    
    -- If email already exists with different Auth0 user, UPDATE the mapping
    -- This handles the case where user logged in with different Auth0 session
    IF v_existing_email_mapping.auth0_user_id IS NOT NULL AND 
       v_existing_email_mapping.auth0_user_id != p_auth0_user_id THEN
        
        -- Update the existing mapping to use the new Auth0 user ID
        UPDATE auth0_user_mappings 
        SET 
            auth0_user_id = p_auth0_user_id,
            name = COALESCE(p_auth0_name, name),
            nickname = COALESCE(p_auth0_nickname, nickname),
            picture_url = COALESCE(p_auth0_picture, picture_url),
            updated_at = NOW()
        WHERE email = v_user_email
        RETURNING supabase_user_id INTO v_new_supabase_user_id;
        
        RETURN v_new_supabase_user_id;
    END IF;
    
    -- Check if a Supabase user with this email already exists
    SELECT id INTO v_new_supabase_user_id
    FROM auth.users 
    WHERE email = v_user_email;
    
    -- If no existing user found, create a REAL Supabase user
    IF v_new_supabase_user_id IS NULL THEN
        INSERT INTO auth.users (
            id,
            email,
            email_confirmed_at,
            created_at,
            updated_at,
            raw_app_meta_data,
            raw_user_meta_data,
            is_super_admin,
            encrypted_password
        ) VALUES (
            gen_random_uuid(),
            v_user_email,
            NOW(),
            NOW(),
            NOW(),
            '{"provider": "auth0", "providers": ["auth0"]}'::jsonb,
            jsonb_build_object(
                'name', v_user_name,
                'nickname', COALESCE(p_auth0_nickname, p_auth0_name, 'auth0user'),
                'picture', p_auth0_picture
            ),
            false,
            '' -- No password for Auth0 users
        ) RETURNING id INTO v_new_supabase_user_id;
    END IF;
    
    -- Create new mapping
    INSERT INTO auth0_user_mappings (
        auth0_user_id,
        supabase_user_id,
        email,
        name,
        nickname,
        picture_url
    ) VALUES (
        p_auth0_user_id,
        v_new_supabase_user_id,
        p_auth0_email,
        p_auth0_name,
        p_auth0_nickname,
        p_auth0_picture
    ) ON CONFLICT (auth0_user_id) DO UPDATE SET
        supabase_user_id = EXCLUDED.supabase_user_id,
        email = EXCLUDED.email,
        name = EXCLUDED.name,
        nickname = EXCLUDED.nickname,
        picture_url = EXCLUDED.picture_url,
        updated_at = NOW();
    
    RETURN v_new_supabase_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 5: Verify the cleanup
SELECT 'After cleanup - duplicate email check:' as info;
SELECT 
    email,
    COUNT(*) as auth0_accounts
FROM auth0_user_mappings 
WHERE email IS NOT NULL
GROUP BY email 
HAVING COUNT(*) > 1;

SELECT 'Final mapping count:' as info, COUNT(*) as total_mappings FROM auth0_user_mappings;
SELECT 'Unique emails:' as info, COUNT(DISTINCT email) as unique_emails FROM auth0_user_mappings WHERE email IS NOT NULL;