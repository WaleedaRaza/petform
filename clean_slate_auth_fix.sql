-- CLEAN SLATE AUTH FIX
-- When user deletes Auth0 account and recreates it, they get a CLEAN SLATE
-- No old data should be restored

-- Drop the current bulletproof function
DROP FUNCTION IF EXISTS get_or_create_supabase_user_for_auth0(text, text, text, text, text);

-- Create NEW function that gives clean slate for new Auth0 accounts
CREATE OR REPLACE FUNCTION get_or_create_supabase_user_for_auth0(
    p_auth0_user_id TEXT,
    p_auth0_email TEXT,
    p_auth0_name TEXT DEFAULT NULL,
    p_auth0_nickname TEXT DEFAULT NULL,
    p_auth0_picture TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    v_existing_mapping auth0_user_mappings%ROWTYPE;
    v_new_supabase_user_id UUID;
    v_user_email TEXT;
    v_user_name TEXT;
BEGIN
    -- Validate inputs
    IF p_auth0_user_id IS NULL OR p_auth0_email IS NULL THEN
        RAISE EXCEPTION 'Auth0 user ID and email are required';
    END IF;
    
    v_user_email := p_auth0_email;
    v_user_name := COALESCE(p_auth0_name, p_auth0_nickname, 'User');
    
    RAISE NOTICE 'Processing Auth0 user: % with email: %', p_auth0_user_id, v_user_email;
    
    -- CRITICAL: Check if THIS EXACT Auth0 user ID already has a mapping
    SELECT * INTO v_existing_mapping
    FROM auth0_user_mappings
    WHERE auth0_user_id = p_auth0_user_id;
    
    -- If this EXACT Auth0 ID exists, return its Supabase user ID
    IF v_existing_mapping.supabase_user_id IS NOT NULL THEN
        RAISE NOTICE 'Existing Auth0 mapping found for: %', p_auth0_user_id;
        RETURN v_existing_mapping.supabase_user_id;
    END IF;
    
    -- CLEAN SLATE: This is a NEW Auth0 account, create NEW Supabase user
    -- Do NOT check for existing email - each Auth0 account gets fresh identity
    
    RAISE NOTICE 'Creating FRESH Supabase user for new Auth0 account: %', p_auth0_user_id;
    
    -- Create a completely new Supabase user
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
        jsonb_build_object(
            'provider', 'auth0',
            'providers', ARRAY['auth0'],
            'auth0_user_id', p_auth0_user_id
        ),
        jsonb_build_object(
            'name', v_user_name,
            'nickname', COALESCE(p_auth0_nickname, p_auth0_name),
            'picture', p_auth0_picture,
            'auth0_user_id', p_auth0_user_id
        ),
        false,
        ''
    ) RETURNING id INTO v_new_supabase_user_id;
    
    -- Create the Auth0 mapping
    INSERT INTO auth0_user_mappings (
        auth0_user_id,
        supabase_user_id,
        email,
        name,
        nickname,
        picture_url,
        auth0_provider
    ) VALUES (
        p_auth0_user_id,
        v_new_supabase_user_id,
        p_auth0_email,
        p_auth0_name,
        p_auth0_nickname,
        p_auth0_picture,
        CASE 
            WHEN p_auth0_user_id LIKE 'google-oauth2|%' THEN 'google'
            WHEN p_auth0_user_id LIKE 'auth0|%' THEN 'email'
            ELSE 'unknown'
        END
    );
    
    RAISE NOTICE 'Created NEW mapping: % -> %', p_auth0_user_id, v_new_supabase_user_id;
    RETURN v_new_supabase_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Also update the username function to NOT reuse old usernames
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
BEGIN
    RAISE NOTICE 'Creating username for NEW user_id: %, email: %', p_user_id, p_email;
    
    -- Check if THIS EXACT user_id already has a username
    SELECT username INTO v_username
    FROM profiles
    WHERE user_id = p_user_id;
    
    -- If username exists for this user_id, return it
    IF v_username IS NOT NULL AND v_username != '' THEN
        RAISE NOTICE 'Found existing username for user_id %: %', p_user_id, v_username;
        RETURN v_username;
    END IF;
    
    RAISE NOTICE 'Creating NEW username for user_id: %', p_user_id;
    
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
    
    -- Find unique username (check ALL existing usernames, not just for this email)
    v_username := v_base_username;
    WHILE EXISTS(SELECT 1 FROM profiles WHERE username = v_username) LOOP
        v_username := v_base_username || v_counter::text;
        v_counter := v_counter + 1;
        
        -- Prevent infinite loop
        IF v_counter > 100 THEN
            v_username := 'user_' || substr(p_user_id::text, 1, 8) || v_counter::text;
            EXIT;
        END IF;
    END LOOP;
    
    RAISE NOTICE 'Generated unique username: %', v_username;
    
    -- Insert NEW profile (do not update existing ones)
    INSERT INTO profiles (user_id, email, username, display_name, created_at, updated_at)
    VALUES (p_user_id, p_email, v_username, COALESCE(p_display_name, v_username), NOW(), NOW());
    
    RAISE NOTICE 'Created NEW profile for user_id: %', p_user_id;
    RETURN v_username;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Clean up any duplicate email constraints that prevent clean slate
ALTER TABLE auth0_user_mappings DROP CONSTRAINT IF EXISTS unique_email_per_mapping;
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_email_unique;

-- Show the result
SELECT 'Clean slate auth system is now active!' as status;