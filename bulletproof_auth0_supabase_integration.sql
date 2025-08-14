-- BULLETPROOF AUTH0-SUPABASE INTEGRATION
-- This completely fixes the identity chaos and creates a robust, App Store-ready system

-- ========================================
-- STEP 1: NUCLEAR CLEANUP - Remove ALL existing chaos
-- ========================================

-- Drop all broken policies
DROP POLICY IF EXISTS "Allow all operations on auth0_user_mappings" ON auth0_user_mappings;
DROP POLICY IF EXISTS "Users can view own pets" ON pets;
DROP POLICY IF EXISTS "Users can insert own pets" ON pets;
DROP POLICY IF EXISTS "Users can update own pets" ON pets;
DROP POLICY IF EXISTS "Users can delete own pets" ON pets;
DROP POLICY IF EXISTS "Users can view all posts" ON posts;
DROP POLICY IF EXISTS "Users can insert their own posts" ON posts;
DROP POLICY IF EXISTS "Users can update their own posts" ON posts;
DROP POLICY IF EXISTS "Users can delete their own posts" ON posts;
DROP POLICY IF EXISTS "Users can view their own shopping items" ON shopping_items;
DROP POLICY IF EXISTS "Users can insert their own shopping items" ON shopping_items;
DROP POLICY IF EXISTS "Users can update their own shopping items" ON shopping_items;
DROP POLICY IF EXISTS "Users can delete their own shopping items" ON shopping_items;

-- Drop broken functions
DROP FUNCTION IF EXISTS get_supabase_user_id_from_auth0(text);
DROP FUNCTION IF EXISTS get_or_create_supabase_user_for_auth0(text, text, text, text, text);
DROP FUNCTION IF EXISTS get_or_create_username(uuid, text, text);

-- ========================================
-- STEP 2: CLEAN SLATE - Recreate tables properly
-- ========================================

-- Recreate auth0_user_mappings with proper constraints
DROP TABLE IF EXISTS auth0_user_mappings CASCADE;
CREATE TABLE auth0_user_mappings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    auth0_user_id TEXT UNIQUE NOT NULL,
    supabase_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL, -- CRITICAL: EMAIL MUST BE UNIQUE
    name TEXT,
    nickname TEXT,
    picture_url TEXT,
    auth0_provider TEXT, -- Track if social vs email/password
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_auth0_user_mappings_auth0_id ON auth0_user_mappings(auth0_user_id);
CREATE INDEX idx_auth0_user_mappings_supabase_id ON auth0_user_mappings(supabase_user_id);
CREATE INDEX idx_auth0_user_mappings_email ON auth0_user_mappings(email);

-- Enable RLS
ALTER TABLE auth0_user_mappings ENABLE ROW LEVEL SECURITY;

-- Simple policy - anyone can read/write (we control access in functions)
CREATE POLICY "Allow all operations on auth0_user_mappings" ON auth0_user_mappings
    FOR ALL USING (true);

-- ========================================
-- STEP 3: BULLETPROOF FUNCTIONS
-- ========================================

-- Function 1: Get Supabase ID from Auth0 ID (simple lookup)
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

-- Function 2: BULLETPROOF Auth0 to Supabase integration
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
    v_supabase_user_id UUID;
    v_auth0_provider TEXT;
BEGIN
    -- Validate inputs
    IF p_auth0_user_id IS NULL OR p_auth0_email IS NULL THEN
        RAISE EXCEPTION 'Auth0 user ID and email are required';
    END IF;
    
    -- Determine provider type
    IF p_auth0_user_id LIKE 'google-oauth2|%' THEN
        v_auth0_provider := 'google';
    ELSIF p_auth0_user_id LIKE 'auth0|%' THEN
        v_auth0_provider := 'email';
    ELSE
        v_auth0_provider := 'unknown';
    END IF;
    
    RAISE NOTICE 'Processing Auth0 user: % (%) with email: %', p_auth0_user_id, v_auth0_provider, p_auth0_email;
    
    -- CRITICAL: Check if this EMAIL already exists (EMAIL IS THE PRIMARY IDENTITY)
    SELECT * INTO v_existing_mapping
    FROM auth0_user_mappings
    WHERE email = p_auth0_email;
    
    -- If email exists with different Auth0 ID, this is the SAME PERSON with different login method
    IF v_existing_mapping.id IS NOT NULL AND v_existing_mapping.auth0_user_id != p_auth0_user_id THEN
        RAISE NOTICE 'SAME PERSON - Email % exists with different Auth0 ID. Old: %, New: %', 
                     p_auth0_email, v_existing_mapping.auth0_user_id, p_auth0_user_id;
        
        -- UPDATE to use the most recent Auth0 session (prefer social login if available)
        IF v_auth0_provider = 'google' OR v_existing_mapping.auth0_provider != 'google' THEN
            UPDATE auth0_user_mappings
            SET 
                auth0_user_id = p_auth0_user_id,
                auth0_provider = v_auth0_provider,
                name = COALESCE(p_auth0_name, name),
                nickname = COALESCE(p_auth0_nickname, nickname),
                picture_url = COALESCE(p_auth0_picture, picture_url),
                updated_at = NOW()
            WHERE email = p_auth0_email;
            
            RAISE NOTICE 'Updated existing mapping to use Auth0 ID: %', p_auth0_user_id;
        ELSE
            RAISE NOTICE 'Keeping existing Google login for email: %', p_auth0_email;
        END IF;
        
        RETURN v_existing_mapping.supabase_user_id;
    END IF;
    
    -- If exact Auth0 ID already exists, return it
    IF v_existing_mapping.auth0_user_id = p_auth0_user_id THEN
        RAISE NOTICE 'Exact Auth0 mapping already exists for: %', p_auth0_user_id;
        RETURN v_existing_mapping.supabase_user_id;
    END IF;
    
    -- Check if Supabase user exists for this email
    SELECT id INTO v_supabase_user_id
    FROM auth.users
    WHERE email = p_auth0_email;
    
    -- Create Supabase user if doesn't exist
    IF v_supabase_user_id IS NULL THEN
        RAISE NOTICE 'Creating new Supabase user for email: %', p_auth0_email;
        
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
            p_auth0_email,
            NOW(),
            NOW(),
            NOW(),
            jsonb_build_object(
                'provider', 'auth0',
                'providers', ARRAY['auth0'],
                'auth0_provider', v_auth0_provider
            ),
            jsonb_build_object(
                'name', COALESCE(p_auth0_name, p_auth0_nickname, 'User'),
                'nickname', COALESCE(p_auth0_nickname, p_auth0_name),
                'picture', p_auth0_picture,
                'auth0_user_id', p_auth0_user_id
            ),
            false,
            ''
        ) RETURNING id INTO v_supabase_user_id;
    END IF;
    
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
        v_supabase_user_id,
        p_auth0_email,
        p_auth0_name,
        p_auth0_nickname,
        p_auth0_picture,
        v_auth0_provider
    );
    
    RAISE NOTICE 'Created new mapping: % -> %', p_auth0_user_id, v_supabase_user_id;
    RETURN v_supabase_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function 3: Email-first username creation
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
    -- Check if profile exists for this email (EMAIL-FIRST)
    SELECT username INTO v_username
    FROM profiles
    WHERE email = p_email;
    
    -- If username exists for this email, update user_id and return
    IF v_username IS NOT NULL AND v_username != '' THEN
        UPDATE profiles 
        SET user_id = p_user_id, updated_at = NOW()
        WHERE email = p_email;
        RETURN v_username;
    END IF;
    
    -- Generate base username
    IF p_display_name IS NOT NULL AND p_display_name != '' THEN
        v_base_username := lower(regexp_replace(p_display_name, '[^a-zA-Z0-9]', '', 'g'));
    ELSE
        v_base_username := split_part(p_email, '@', 1);
    END IF;
    
    IF v_base_username IS NULL OR v_base_username = '' THEN
        v_base_username := 'user_' || substr(p_user_id::text, 1, 8);
    END IF;
    
    -- Find unique username
    v_username := v_base_username;
    WHILE EXISTS(SELECT 1 FROM profiles WHERE username = v_username AND email != p_email) LOOP
        v_username := v_base_username || v_counter::text;
        v_counter := v_counter + 1;
        
        IF v_counter > 100 THEN
            v_username := 'user_' || substr(p_user_id::text, 1, 8) || v_counter::text;
            EXIT;
        END IF;
    END LOOP;
    
    -- Insert or update profile
    INSERT INTO profiles (user_id, email, username, display_name, created_at, updated_at)
    VALUES (p_user_id, p_email, v_username, COALESCE(p_display_name, v_username), NOW(), NOW())
    ON CONFLICT (email) 
    DO UPDATE SET 
        user_id = EXCLUDED.user_id,
        username = EXCLUDED.username,
        display_name = COALESCE(EXCLUDED.display_name, EXCLUDED.username),
        updated_at = NOW();
    
    RETURN v_username;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ========================================
-- STEP 4: BULLETPROOF POLICIES
-- ========================================

-- Helper function for getting current user ID (Auth0 or Supabase)
CREATE OR REPLACE FUNCTION get_current_user_id()
RETURNS UUID AS $$
DECLARE
    v_user_id UUID;
    v_auth0_sub TEXT;
BEGIN
    -- Try Supabase auth first
    v_user_id := auth.uid();
    IF v_user_id IS NOT NULL THEN
        RETURN v_user_id;
    END IF;
    
    -- Try Auth0 via JWT claims
    BEGIN
        v_auth0_sub := current_setting('request.jwt.claims', true)::json->>'sub';
        IF v_auth0_sub IS NOT NULL THEN
            RETURN get_supabase_user_id_from_auth0(v_auth0_sub);
        END IF;
    EXCEPTION WHEN OTHERS THEN
        -- JWT claims not available
    END;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Pets policies
CREATE POLICY "Users can view own pets" ON pets
    FOR SELECT USING (user_id = get_current_user_id());

CREATE POLICY "Users can insert own pets" ON pets
    FOR INSERT WITH CHECK (user_id = get_current_user_id());

CREATE POLICY "Users can update own pets" ON pets
    FOR UPDATE USING (user_id = get_current_user_id());

CREATE POLICY "Users can delete own pets" ON pets
    FOR DELETE USING (user_id = get_current_user_id());

-- Shopping items policies
CREATE POLICY "Users can view their own shopping items" ON shopping_items
    FOR SELECT USING (user_id = get_current_user_id());

CREATE POLICY "Users can insert their own shopping items" ON shopping_items
    FOR INSERT WITH CHECK (user_id = get_current_user_id());

CREATE POLICY "Users can update their own shopping items" ON shopping_items
    FOR UPDATE USING (user_id = get_current_user_id());

CREATE POLICY "Users can delete their own shopping items" ON shopping_items
    FOR DELETE USING (user_id = get_current_user_id());

-- Posts policies
CREATE POLICY "Users can view all posts" ON posts
    FOR SELECT USING (true);

CREATE POLICY "Users can insert their own posts" ON posts
    FOR INSERT WITH CHECK (author = (
        SELECT username FROM profiles WHERE user_id = get_current_user_id()
    ));

CREATE POLICY "Users can update their own posts" ON posts
    FOR UPDATE USING (author = (
        SELECT username FROM profiles WHERE user_id = get_current_user_id()
    ));

CREATE POLICY "Users can delete their own posts" ON posts
    FOR DELETE USING (author = (
        SELECT username FROM profiles WHERE user_id = get_current_user_id()
    ));

-- ========================================
-- STEP 5: VERIFICATION
-- ========================================

-- Show current state
SELECT 'Migration complete. Current mappings:' as status;
SELECT 
    email,
    auth0_user_id,
    auth0_provider,
    supabase_user_id
FROM auth0_user_mappings
ORDER BY email, created_at;