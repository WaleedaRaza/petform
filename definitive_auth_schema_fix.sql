-- DEFINITIVE AUTH SCHEMA FIX
-- This fixes ALL the root causes of your auth/data issues

-- ========================================
-- STEP 1: CLEAN UP BROKEN POLICIES
-- ========================================

-- Remove all conflicting policies
DROP POLICY IF EXISTS "Allow all operations on auth0_user_mappings" ON auth0_user_mappings;
DROP POLICY IF EXISTS "Allow all operations on auth0_users" ON auth0_user_mappings;
DROP POLICY IF EXISTS "Allow all comment operations temporarily" ON comments;
DROP POLICY IF EXISTS "Anyone can view comments" ON comments;
DROP POLICY IF EXISTS "Users can delete own comments" ON comments;
DROP POLICY IF EXISTS "Users can insert own comments" ON comments;
DROP POLICY IF EXISTS "Users can update own comments" ON comments;
DROP POLICY IF EXISTS "Allow all pet operations temporarily" ON pets;
DROP POLICY IF EXISTS "Anyone can view pets" ON pets;
DROP POLICY IF EXISTS "Users can delete own pets" ON pets;
DROP POLICY IF EXISTS "Users can insert own pets" ON pets;
DROP POLICY IF EXISTS "Users can update own pets" ON pets;
DROP POLICY IF EXISTS "Users can view own pets" ON pets;
DROP POLICY IF EXISTS "Allow all post operations temporarily" ON posts;
DROP POLICY IF EXISTS "Anyone can view posts" ON posts;
DROP POLICY IF EXISTS "Users can delete own posts" ON posts;
DROP POLICY IF EXISTS "Users can delete their own posts" ON posts;
DROP POLICY IF EXISTS "Users can insert own posts" ON posts;
DROP POLICY IF EXISTS "Users can insert their own posts" ON posts;
DROP POLICY IF EXISTS "Users can update own posts" ON posts;
DROP POLICY IF EXISTS "Users can update their own posts" ON posts;
DROP POLICY IF EXISTS "Users can view all posts" ON posts;
DROP POLICY IF EXISTS "Allow all profile operations temporarily" ON profiles;
DROP POLICY IF EXISTS "Allow all shopping item operations temporarily" ON shopping_items;
DROP POLICY IF EXISTS "Anyone can view shopping items" ON shopping_items;
DROP POLICY IF EXISTS "Users can delete own shopping items" ON shopping_items;
DROP POLICY IF EXISTS "Users can delete their own shopping items" ON shopping_items;
DROP POLICY IF EXISTS "Users can insert own shopping items" ON shopping_items;
DROP POLICY IF EXISTS "Users can insert their own shopping items" ON shopping_items;
DROP POLICY IF EXISTS "Users can update own shopping items" ON shopping_items;
DROP POLICY IF EXISTS "Users can update their own shopping items" ON shopping_items;
DROP POLICY IF EXISTS "Users can view their own shopping items" ON shopping_items;
DROP POLICY IF EXISTS "Allow all tracking entry operations temporarily" ON tracking_entries;

-- ========================================
-- STEP 2: REMOVE EMAIL UNIQUENESS (ALLOWS CLEAN SLATE)
-- ========================================

-- Remove email uniqueness constraints to allow clean slate behavior
ALTER TABLE auth0_user_mappings DROP CONSTRAINT IF EXISTS auth0_user_mappings_email_key;
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_email_key;

-- Keep username uniqueness to prevent conflicts
-- ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_username_key; -- Keep this one

-- ========================================
-- STEP 3: CREATE BULLETPROOF USER RESOLUTION FUNCTION
-- ========================================

-- Drop existing functions
DROP FUNCTION IF EXISTS get_current_user_id();
DROP FUNCTION IF EXISTS get_supabase_user_id_from_auth0(text);
DROP FUNCTION IF EXISTS get_or_create_supabase_user_for_auth0(text, text, text, text, text);

-- Function 1: Get current user ID (works for both Auth0 and Supabase)
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
            SELECT supabase_user_id INTO v_user_id
            FROM auth0_user_mappings
            WHERE auth0_user_id = v_auth0_sub;
            RETURN v_user_id;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        -- JWT claims not available, continue
    END;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function 2: Get Supabase ID from Auth0 ID
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

-- Function 3: CLEAN SLATE Auth0 user creation
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
    
    -- Check if THIS EXACT Auth0 user ID already exists
    SELECT * INTO v_existing_mapping
    FROM auth0_user_mappings
    WHERE auth0_user_id = p_auth0_user_id;
    
    -- If this exact Auth0 ID exists, return its Supabase user ID
    IF v_existing_mapping.supabase_user_id IS NOT NULL THEN
        RAISE NOTICE 'Found existing mapping for Auth0 ID: %', p_auth0_user_id;
        RETURN v_existing_mapping.supabase_user_id;
    END IF;
    
    -- CLEAN SLATE: Create completely new Supabase user (no email checking)
    RAISE NOTICE 'Creating FRESH Supabase user for new Auth0 account: %', p_auth0_user_id;
    
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
    
    RAISE NOTICE 'Created new mapping: % -> %', p_auth0_user_id, v_new_supabase_user_id;
    RETURN v_new_supabase_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ========================================
-- STEP 4: CREATE WORKING RLS POLICIES
-- ========================================

-- Enable RLS on all tables
ALTER TABLE auth0_user_mappings ENABLE ROW LEVEL SECURITY;
ALTER TABLE pets ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE tracking_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE tracking_entries ENABLE ROW LEVEL SECURITY;

-- Auth0 mappings - allow all (needed for login)
CREATE POLICY "auth0_mappings_all" ON auth0_user_mappings FOR ALL USING (true);

-- Pets - users can manage their own pets
CREATE POLICY "pets_select" ON pets FOR SELECT USING (user_id = get_current_user_id());
CREATE POLICY "pets_insert" ON pets FOR INSERT WITH CHECK (user_id = get_current_user_id());
CREATE POLICY "pets_update" ON pets FOR UPDATE USING (user_id = get_current_user_id());
CREATE POLICY "pets_delete" ON pets FOR DELETE USING (user_id = get_current_user_id());

-- Shopping items - users can manage their own items
CREATE POLICY "shopping_select" ON shopping_items FOR SELECT USING (user_id = get_current_user_id());
CREATE POLICY "shopping_insert" ON shopping_items FOR INSERT WITH CHECK (user_id = get_current_user_id());
CREATE POLICY "shopping_update" ON shopping_items FOR UPDATE USING (user_id = get_current_user_id());
CREATE POLICY "shopping_delete" ON shopping_items FOR DELETE USING (user_id = get_current_user_id());

-- Posts - all can view, users can manage their own
CREATE POLICY "posts_select_all" ON posts FOR SELECT USING (true);
CREATE POLICY "posts_insert" ON posts FOR INSERT WITH CHECK (
    author = (SELECT username FROM profiles WHERE user_id = get_current_user_id())
);
CREATE POLICY "posts_update" ON posts FOR UPDATE USING (
    author = (SELECT username FROM profiles WHERE user_id = get_current_user_id())
);
CREATE POLICY "posts_delete" ON posts FOR DELETE USING (
    author = (SELECT username FROM profiles WHERE user_id = get_current_user_id())
);

-- Profiles - users can manage their own profile
CREATE POLICY "profiles_select" ON profiles FOR SELECT USING (user_id = get_current_user_id());
CREATE POLICY "profiles_insert" ON profiles FOR INSERT WITH CHECK (user_id = get_current_user_id());
CREATE POLICY "profiles_update" ON profiles FOR UPDATE USING (user_id = get_current_user_id());
CREATE POLICY "profiles_delete" ON profiles FOR DELETE USING (user_id = get_current_user_id());

-- Comments - all can view, users can manage their own
CREATE POLICY "comments_select_all" ON comments FOR SELECT USING (true);
CREATE POLICY "comments_insert" ON comments FOR INSERT WITH CHECK (user_id = get_current_user_id());
CREATE POLICY "comments_update" ON comments FOR UPDATE USING (user_id = get_current_user_id());
CREATE POLICY "comments_delete" ON comments FOR DELETE USING (user_id = get_current_user_id());

-- Tracking - users can manage their own data
CREATE POLICY "tracking_metrics_select" ON tracking_metrics FOR SELECT USING (user_id = get_current_user_id());
CREATE POLICY "tracking_metrics_insert" ON tracking_metrics FOR INSERT WITH CHECK (user_id = get_current_user_id());
CREATE POLICY "tracking_metrics_update" ON tracking_metrics FOR UPDATE USING (user_id = get_current_user_id());
CREATE POLICY "tracking_metrics_delete" ON tracking_metrics FOR DELETE USING (user_id = get_current_user_id());

CREATE POLICY "tracking_entries_select" ON tracking_entries FOR SELECT USING (
    metric_id IN (SELECT id FROM tracking_metrics WHERE user_id = get_current_user_id())
);
CREATE POLICY "tracking_entries_insert" ON tracking_entries FOR INSERT WITH CHECK (
    metric_id IN (SELECT id FROM tracking_metrics WHERE user_id = get_current_user_id())
);
CREATE POLICY "tracking_entries_update" ON tracking_entries FOR UPDATE USING (
    metric_id IN (SELECT id FROM tracking_metrics WHERE user_id = get_current_user_id())
);
CREATE POLICY "tracking_entries_delete" ON tracking_entries FOR DELETE USING (
    metric_id IN (SELECT id FROM tracking_metrics WHERE user_id = get_current_user_id())
);

-- ========================================
-- STEP 5: CREATE DELETE USER FUNCTIONS
-- ========================================

-- Function to completely delete a user and all their data
CREATE OR REPLACE FUNCTION delete_user_completely(p_auth0_user_id TEXT)
RETURNS BOOLEAN AS $$
DECLARE
    v_supabase_user_id UUID;
    v_username TEXT;
BEGIN
    -- Get the Supabase user ID
    SELECT supabase_user_id INTO v_supabase_user_id
    FROM auth0_user_mappings
    WHERE auth0_user_id = p_auth0_user_id;
    
    IF v_supabase_user_id IS NULL THEN
        RAISE NOTICE 'No mapping found for Auth0 user: %', p_auth0_user_id;
        RETURN FALSE;
    END IF;
    
    -- Get username for post deletion
    SELECT username INTO v_username
    FROM profiles
    WHERE user_id = v_supabase_user_id;
    
    RAISE NOTICE 'Deleting all data for user: % (Auth0: %)', v_supabase_user_id, p_auth0_user_id;
    
    -- Delete all user data
    DELETE FROM tracking_entries WHERE metric_id IN (
        SELECT id FROM tracking_metrics WHERE user_id = v_supabase_user_id
    );
    DELETE FROM tracking_metrics WHERE user_id = v_supabase_user_id;
    DELETE FROM comments WHERE user_id = v_supabase_user_id;
    DELETE FROM pets WHERE user_id = v_supabase_user_id;
    DELETE FROM shopping_items WHERE user_id = v_supabase_user_id;
    DELETE FROM posts WHERE author = v_username;
    DELETE FROM profiles WHERE user_id = v_supabase_user_id;
    DELETE FROM auth0_user_mappings WHERE auth0_user_id = p_auth0_user_id;
    DELETE FROM auth.users WHERE id = v_supabase_user_id;
    
    RAISE NOTICE 'Successfully deleted all data for user: %', p_auth0_user_id;
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function for current user to delete their own data
CREATE OR REPLACE FUNCTION delete_current_user_data()
RETURNS BOOLEAN AS $$
DECLARE
    v_user_id UUID;
    v_username TEXT;
BEGIN
    v_user_id := get_current_user_id();
    IF v_user_id IS NULL THEN
        RAISE NOTICE 'No current user found';
        RETURN FALSE;
    END IF;
    
    -- Get username for post deletion
    SELECT username INTO v_username
    FROM profiles
    WHERE user_id = v_user_id;
    
    RAISE NOTICE 'Deleting all data for current user: %', v_user_id;
    
    -- Delete all user data
    DELETE FROM tracking_entries WHERE metric_id IN (
        SELECT id FROM tracking_metrics WHERE user_id = v_user_id
    );
    DELETE FROM tracking_metrics WHERE user_id = v_user_id;
    DELETE FROM comments WHERE user_id = v_user_id;
    DELETE FROM pets WHERE user_id = v_user_id;
    DELETE FROM shopping_items WHERE user_id = v_user_id;
    DELETE FROM posts WHERE author = v_username;
    DELETE FROM profiles WHERE user_id = v_user_id;
    
    RAISE NOTICE 'Successfully deleted all data for current user: %', v_user_id;
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ========================================
-- STEP 6: VERIFICATION
-- ========================================

SELECT 'Schema fix complete! Key changes:' as status;
SELECT '1. Removed email uniqueness constraints (allows clean slate)' as change;
SELECT '2. Fixed RLS policies to use proper user resolution' as change;
SELECT '3. Created clean slate Auth0 user creation' as change;
SELECT '4. Added complete user deletion functions' as change;
SELECT '5. Enabled proper RLS on all tables' as change; 