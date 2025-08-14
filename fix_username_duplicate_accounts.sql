-- FIX USERNAME SYSTEM CREATING DUPLICATE ACCOUNTS
-- Make the Auth0 login flow reuse existing accounts instead of creating new ones

-- Step 1: Update get_or_create_supabase_user_for_auth0 to be EMAIL-FIRST
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
    
    RAISE NOTICE 'Processing Auth0 user: % with email: %', p_auth0_user_id, v_user_email;
    
    -- FIRST: Check if this EMAIL already has a mapping (email-first approach)
    SELECT * INTO v_existing_email_mapping 
    FROM auth0_user_mappings 
    WHERE email = v_user_email;
    
    -- If email exists, UPDATE the mapping to use the latest Auth0 session
    IF v_existing_email_mapping.auth0_user_id IS NOT NULL THEN
        RAISE NOTICE 'Email % already exists with Auth0 ID: %, updating to: %', 
                     v_user_email, v_existing_email_mapping.auth0_user_id, p_auth0_user_id;
        
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
        
        RAISE NOTICE 'Updated existing mapping for email % to Supabase ID: %', v_user_email, v_new_supabase_user_id;
        RETURN v_new_supabase_user_id;
    END IF;
    
    -- SECOND: Check if mapping already exists for this exact Auth0 user ID
    SELECT * INTO v_existing_mapping 
    FROM auth0_user_mappings 
    WHERE auth0_user_id = p_auth0_user_id;
    
    -- If mapping exists, return the Supabase user ID
    IF v_existing_mapping.supabase_user_id IS NOT NULL THEN
        RAISE NOTICE 'Auth0 ID % already mapped to Supabase ID: %', p_auth0_user_id, v_existing_mapping.supabase_user_id;
        RETURN v_existing_mapping.supabase_user_id;
    END IF;
    
    -- THIRD: Check if a Supabase user with this email already exists
    SELECT id INTO v_new_supabase_user_id
    FROM auth.users 
    WHERE email = v_user_email;
    
    -- If no existing user found, create a REAL Supabase user
    IF v_new_supabase_user_id IS NULL THEN
        RAISE NOTICE 'Creating new Supabase user for email: %', v_user_email;
        
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
        
        RAISE NOTICE 'Created new Supabase user with ID: %', v_new_supabase_user_id;
    ELSE
        RAISE NOTICE 'Found existing Supabase user for email % with ID: %', v_user_email, v_new_supabase_user_id;
    END IF;
    
    -- Create new mapping
    RAISE NOTICE 'Creating new Auth0 mapping: % -> %', p_auth0_user_id, v_new_supabase_user_id;
    
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
    
    RAISE NOTICE 'Successfully created/updated mapping for Auth0 ID: %', p_auth0_user_id;
    RETURN v_new_supabase_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 2: Update get_or_create_username to be EMAIL-FIRST as well
DROP FUNCTION IF EXISTS get_or_create_username(uuid, text, text);
CREATE OR REPLACE FUNCTION get_or_create_username(
    p_user_id UUID,
    p_email TEXT,
    p_display_name TEXT DEFAULT NULL
)
RETURNS TEXT AS $$
DECLARE
    v_username TEXT;
    v_base_username TEXT;
    v_counter INTEGER := 1;
    v_existing_profile RECORD;
BEGIN
    RAISE NOTICE 'get_or_create_username called with user_id: %, email: %', p_user_id, p_email;
    
    -- FIRST: Check if this EMAIL already has a profile (email-first approach)
    SELECT * INTO v_existing_profile
    FROM profiles
    WHERE email = p_email;
    
    -- If profile exists for this email, return existing username
    IF v_existing_profile.username IS NOT NULL AND v_existing_profile.username != '' THEN
        RAISE NOTICE 'Found existing profile for email % with username: %', p_email, v_existing_profile.username;
        
        -- Update the user_id to match current session (handles Auth0 session changes)
        UPDATE profiles 
        SET user_id = p_user_id, updated_at = NOW()
        WHERE email = p_email;
        
        RETURN v_existing_profile.username;
    END IF;
    
    -- SECOND: Check by user_id (fallback)
    SELECT username INTO v_username
    FROM profiles
    WHERE user_id = p_user_id;
    
    -- If username exists for this user_id, return it
    IF v_username IS NOT NULL AND v_username != '' THEN
        RAISE NOTICE 'Found existing username for user_id %: %', p_user_id, v_username;
        RETURN v_username;
    END IF;
    
    RAISE NOTICE 'Creating new username for user_id: %, email: %', p_user_id, p_email;
    
    -- Generate base username from email or display name
    IF p_display_name IS NOT NULL AND p_display_name != '' THEN
        v_base_username := lower(regexp_replace(p_display_name, '[^a-zA-Z0-9]', '', 'g'));
    ELSE
        v_base_username := split_part(p_email, '@', 1);
    END IF;
    
    -- Ensure username is not empty
    IF v_base_username IS NULL OR v_base_username = '' THEN
        v_base_username := 'user_' || substr(p_user_id::text, 1, 8);
    END IF;
    
    -- Try to find unique username
    v_username := v_base_username;
    WHILE EXISTS(SELECT 1 FROM profiles WHERE username = v_username AND user_id != p_user_id) LOOP
        v_username := v_base_username || v_counter::text;
        v_counter := v_counter + 1;
        
        -- Prevent infinite loop
        IF v_counter > 100 THEN
            v_username := 'user_' || substr(p_user_id::text, 1, 8) || v_counter::text;
            EXIT;
        END IF;
    END LOOP;
    
    RAISE NOTICE 'Generated unique username: %', v_username;
    
    -- Insert or update profile with username
    INSERT INTO profiles (user_id, email, username, display_name, created_at, updated_at)
    VALUES (p_user_id, p_email, v_username, COALESCE(p_display_name, v_username), NOW(), NOW())
    ON CONFLICT (user_id) 
    DO UPDATE SET 
        username = EXCLUDED.username,
        display_name = COALESCE(EXCLUDED.display_name, EXCLUDED.username),
        email = EXCLUDED.email,
        updated_at = NOW();
    
    RAISE NOTICE 'Successfully created/updated profile for user_id: %', p_user_id;
    RETURN v_username;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 3: Show current state for debugging
SELECT 'Current duplicate analysis:' as info;
SELECT 
    email,
    COUNT(*) as auth0_accounts,
    array_agg(auth0_user_id ORDER BY created_at) as auth0_ids
FROM auth0_user_mappings 
WHERE email IS NOT NULL
GROUP BY email 
ORDER BY COUNT(*) DESC;