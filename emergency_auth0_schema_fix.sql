-- EMERGENCY AUTH0 SCHEMA FIX
-- This will ensure the Auth0 integration works properly

-- Step 1: Ensure auth0_user_mappings table exists
CREATE TABLE IF NOT EXISTS auth0_user_mappings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    auth0_user_id TEXT UNIQUE NOT NULL,
    supabase_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT,
    name TEXT,
    nickname TEXT,
    picture_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_auth0_user_mappings_auth0_id ON auth0_user_mappings(auth0_user_id);
CREATE INDEX IF NOT EXISTS idx_auth0_user_mappings_supabase_id ON auth0_user_mappings(supabase_user_id);

-- Enable RLS
ALTER TABLE auth0_user_mappings ENABLE ROW LEVEL SECURITY;

-- Allow all operations
DROP POLICY IF EXISTS "Allow all operations on auth0_user_mappings" ON auth0_user_mappings;
CREATE POLICY "Allow all operations on auth0_user_mappings" ON auth0_user_mappings
    FOR ALL USING (true);

-- Step 2: Ensure the RPC function exists
DROP FUNCTION IF EXISTS get_supabase_user_id_from_auth0(text);
CREATE OR REPLACE FUNCTION get_supabase_user_id_from_auth0(p_auth0_user_id TEXT)
RETURNS UUID AS $$
DECLARE
    v_mapped_user_id UUID;
BEGIN
    SELECT supabase_user_id INTO v_mapped_user_id
    FROM auth0_user_mappings
    WHERE auth0_user_id = p_auth0_user_id;
    
    RETURN v_mapped_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 3: Ensure get_or_create_supabase_user_for_auth0 function exists
DROP FUNCTION IF EXISTS get_or_create_supabase_user_for_auth0(text, text, text, text);
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
    v_new_supabase_user_id UUID;
    v_user_email TEXT;
    v_user_name TEXT;
BEGIN
    -- Set the email
    v_user_email := COALESCE(p_auth0_email, p_auth0_user_id || '@auth0.local');
    v_user_name := COALESCE(p_auth0_name, p_auth0_nickname, 'Auth0 User');
    
    -- Check if mapping already exists
    SELECT * INTO v_existing_mapping 
    FROM auth0_user_mappings 
    WHERE auth0_user_id = p_auth0_user_id;
    
    -- If mapping exists, return the Supabase user ID
    IF v_existing_mapping.supabase_user_id IS NOT NULL THEN
        RETURN v_existing_mapping.supabase_user_id;
    END IF;
    
    -- Check if a user with this email already exists
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
    
    -- Create mapping
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

-- Step 4: Check current data
SELECT 'Current auth0_user_mappings count:' as info, COUNT(*) as count FROM auth0_user_mappings;
SELECT 'Current auth.users count:' as info, COUNT(*) as count FROM auth.users;

-- Step 5: Show any existing mappings for debugging
SELECT 'Existing mappings:' as info;
SELECT auth0_user_id, supabase_user_id, email FROM auth0_user_mappings;