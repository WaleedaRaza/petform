-- Production-Ready Auth0 to Supabase Integration (FINAL - HANDLES EXISTING OBJECTS)
-- This creates a proper mapping system without breaking existing data

-- Step 1: Create Auth0 user mapping table (if not exists)
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

-- Create indexes for performance (if not exist)
CREATE INDEX IF NOT EXISTS idx_auth0_user_mappings_auth0_id ON auth0_user_mappings(auth0_user_id);
CREATE INDEX IF NOT EXISTS idx_auth0_user_mappings_supabase_id ON auth0_user_mappings(supabase_user_id);
CREATE INDEX IF NOT EXISTS idx_auth0_user_mappings_email ON auth0_user_mappings(email);

-- Enable RLS on mapping table
ALTER TABLE auth0_user_mappings ENABLE ROW LEVEL SECURITY;

-- Drop existing policy if exists, then create new one
DROP POLICY IF EXISTS "Allow all operations on auth0_user_mappings" ON auth0_user_mappings;
CREATE POLICY "Allow all operations on auth0_user_mappings" ON auth0_user_mappings
    FOR ALL USING (true);

-- Step 2: Create function to get or create Supabase user for Auth0 user
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
BEGIN
    -- Check if mapping already exists
    SELECT * INTO v_existing_mapping 
    FROM auth0_user_mappings 
    WHERE auth0_user_id = p_auth0_user_id;
    
    -- If mapping exists, return the Supabase user ID
    IF v_existing_mapping.supabase_user_id IS NOT NULL THEN
        RETURN v_existing_mapping.supabase_user_id;
    END IF;
    
    -- Create new Supabase user (this would be done via Auth0 webhook in production)
    -- For now, we'll create a placeholder user
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
        COALESCE(p_auth0_email, p_auth0_user_id || '@auth0.local'),
        NOW(),
        NOW(),
        NOW(),
        '{"provider": "auth0", "providers": ["auth0"]}'::jsonb,
        jsonb_build_object(
            'name', COALESCE(p_auth0_name, p_auth0_nickname, 'Auth0 User'),
            'nickname', COALESCE(p_auth0_nickname, p_auth0_name, 'auth0user'),
            'picture', p_auth0_picture
        ),
        false,
        '' -- No password for Auth0 users
    ) RETURNING id INTO v_new_supabase_user_id;
    
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
    );
    
    RETURN v_new_supabase_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 3: Create function to get Supabase user ID from Auth0 user ID
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

-- Step 4: Update RLS policies to work with both native Supabase users and Auth0 users
-- This allows both authentication methods to work seamlessly

-- Pets table policies
DROP POLICY IF EXISTS "Users can view own pets" ON pets;
DROP POLICY IF EXISTS "Users can insert own pets" ON pets;
DROP POLICY IF EXISTS "Users can update own pets" ON pets;
DROP POLICY IF EXISTS "Users can delete own pets" ON pets;

CREATE POLICY "Users can view own pets" ON pets
    FOR SELECT USING (
        auth.uid() = user_id OR 
        user_id = get_supabase_user_id_from_auth0(current_setting('request.jwt.claims', true)::json->>'sub')
    );

CREATE POLICY "Users can insert own pets" ON pets
    FOR INSERT WITH CHECK (
        auth.uid() = user_id OR 
        user_id = get_supabase_user_id_from_auth0(current_setting('request.jwt.claims', true)::json->>'sub')
    );

CREATE POLICY "Users can update own pets" ON pets
    FOR UPDATE USING (
        auth.uid() = user_id OR 
        user_id = get_supabase_user_id_from_auth0(current_setting('request.jwt.claims', true)::json->>'sub')
    );

CREATE POLICY "Users can delete own pets" ON pets
    FOR DELETE USING (
        auth.uid() = user_id OR 
        user_id = get_supabase_user_id_from_auth0(current_setting('request.jwt.claims', true)::json->>'sub')
    );

-- Posts table policies
DROP POLICY IF EXISTS "Users can view all posts" ON posts;
DROP POLICY IF EXISTS "Users can insert their own posts" ON posts;
DROP POLICY IF EXISTS "Users can update their own posts" ON posts;
DROP POLICY IF EXISTS "Users can delete their own posts" ON posts;

CREATE POLICY "Users can view all posts" ON posts
    FOR SELECT USING (true);

CREATE POLICY "Users can insert their own posts" ON posts
    FOR INSERT WITH CHECK (
        auth.uid() = user_id OR 
        user_id = get_supabase_user_id_from_auth0(current_setting('request.jwt.claims', true)::json->>'sub')
    );

CREATE POLICY "Users can update their own posts" ON posts
    FOR UPDATE USING (
        auth.uid() = user_id OR 
        user_id = get_supabase_user_id_from_auth0(current_setting('request.jwt.claims', true)::json->>'sub')
    );

CREATE POLICY "Users can delete their own posts" ON posts
    FOR DELETE USING (
        auth.uid() = user_id OR 
        user_id = get_supabase_user_id_from_auth0(current_setting('request.jwt.claims', true)::json->>'sub')
    );

-- Shopping items table policies
DROP POLICY IF EXISTS "Users can view their own shopping items" ON shopping_items;
DROP POLICY IF EXISTS "Users can insert their own shopping items" ON shopping_items;
DROP POLICY IF EXISTS "Users can update their own shopping items" ON shopping_items;
DROP POLICY IF EXISTS "Users can delete their own shopping items" ON shopping_items;

CREATE POLICY "Users can view their own shopping items" ON shopping_items
    FOR SELECT USING (
        auth.uid() = user_id OR 
        user_id = get_supabase_user_id_from_auth0(current_setting('request.jwt.claims', true)::json->>'sub')
    );

CREATE POLICY "Users can insert their own shopping items" ON shopping_items
    FOR INSERT WITH CHECK (
        auth.uid() = user_id OR 
        user_id = get_supabase_user_id_from_auth0(current_setting('request.jwt.claims', true)::json->>'sub')
    );

CREATE POLICY "Users can update their own shopping items" ON shopping_items
    FOR UPDATE USING (
        auth.uid() = user_id OR 
        user_id = get_supabase_user_id_from_auth0(current_setting('request.jwt.claims', true)::json->>'sub')
    );

CREATE POLICY "Users can delete their own shopping items" ON shopping_items
    FOR DELETE USING (
        auth.uid() = user_id OR 
        user_id = get_supabase_user_id_from_auth0(current_setting('request.jwt.claims', true)::json->>'sub')
    );

-- Profiles table policies
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;

CREATE POLICY "Users can view own profile" ON profiles
    FOR SELECT USING (
        auth.uid() = id OR 
        id = get_supabase_user_id_from_auth0(current_setting('request.jwt.claims', true)::json->>'sub')
    );

CREATE POLICY "Users can insert own profile" ON profiles
    FOR INSERT WITH CHECK (
        auth.uid() = id OR 
        id = get_supabase_user_id_from_auth0(current_setting('request.jwt.claims', true)::json->>'sub')
    );

CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (
        auth.uid() = id OR 
        id = get_supabase_user_id_from_auth0(current_setting('request.jwt.claims', true)::json->>'sub')
    );

-- Tracking metrics table policies (uses pet_id, not user_id)
DROP POLICY IF EXISTS "Users can view own pet metrics" ON tracking_metrics;
DROP POLICY IF EXISTS "Users can insert own pet metrics" ON tracking_metrics;
DROP POLICY IF EXISTS "Users can update own pet metrics" ON tracking_metrics;
DROP POLICY IF EXISTS "Users can delete own pet metrics" ON tracking_metrics;

CREATE POLICY "Users can view own pet metrics" ON tracking_metrics
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.pets 
            WHERE pets.id = tracking_metrics.pet_id 
            AND (pets.user_id = auth.uid() OR 
                 pets.user_id = get_supabase_user_id_from_auth0(current_setting('request.jwt.claims', true)::json->>'sub'))
        )
    );

CREATE POLICY "Users can insert own pet metrics" ON tracking_metrics
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.pets 
            WHERE pets.id = tracking_metrics.pet_id 
            AND (pets.user_id = auth.uid() OR 
                 pets.user_id = get_supabase_user_id_from_auth0(current_setting('request.jwt.claims', true)::json->>'sub'))
        )
    );

CREATE POLICY "Users can update own pet metrics" ON tracking_metrics
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.pets 
            WHERE pets.id = tracking_metrics.pet_id 
            AND (pets.user_id = auth.uid() OR 
                 pets.user_id = get_supabase_user_id_from_auth0(current_setting('request.jwt.claims', true)::json->>'sub'))
        )
    );

CREATE POLICY "Users can delete own pet metrics" ON tracking_metrics
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM public.pets 
            WHERE pets.id = tracking_metrics.pet_id 
            AND (pets.user_id = auth.uid() OR 
                 pets.user_id = get_supabase_user_id_from_auth0(current_setting('request.jwt.claims', true)::json->>'sub'))
        )
    );

-- Tracking entries table policies (uses metric_id, joins through metrics to pets)
DROP POLICY IF EXISTS "Users can view own pet tracking entries" ON tracking_entries;
DROP POLICY IF EXISTS "Users can insert own pet tracking entries" ON tracking_entries;
DROP POLICY IF EXISTS "Users can update own pet tracking entries" ON tracking_entries;
DROP POLICY IF EXISTS "Users can delete own pet tracking entries" ON tracking_entries;

CREATE POLICY "Users can view own pet tracking entries" ON tracking_entries
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.tracking_metrics tm
            JOIN public.pets p ON p.id = tm.pet_id
            WHERE tm.id = tracking_entries.metric_id 
            AND (p.user_id = auth.uid() OR 
                 p.user_id = get_supabase_user_id_from_auth0(current_setting('request.jwt.claims', true)::json->>'sub'))
        )
    );

CREATE POLICY "Users can insert own pet tracking entries" ON tracking_entries
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.tracking_metrics tm
            JOIN public.pets p ON p.id = tm.pet_id
            WHERE tm.id = tracking_entries.metric_id 
            AND (p.user_id = auth.uid() OR 
                 p.user_id = get_supabase_user_id_from_auth0(current_setting('request.jwt.claims', true)::json->>'sub'))
        )
    );

CREATE POLICY "Users can update own pet tracking entries" ON tracking_entries
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.tracking_metrics tm
            JOIN public.pets p ON p.id = tm.pet_id
            WHERE tm.id = tracking_entries.metric_id 
            AND (p.user_id = auth.uid() OR 
                 p.user_id = get_supabase_user_id_from_auth0(current_setting('request.jwt.claims', true)::json->>'sub'))
        )
    );

CREATE POLICY "Users can delete own pet tracking entries" ON tracking_entries
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM public.tracking_metrics tm
            JOIN public.pets p ON p.id = tm.pet_id
            WHERE tm.id = tracking_entries.metric_id 
            AND (p.user_id = auth.uid() OR 
                 p.user_id = get_supabase_user_id_from_auth0(current_setting('request.jwt.claims', true)::json->>'sub'))
        )
    );

-- Comments table policies
DROP POLICY IF EXISTS "Users can view all comments" ON comments;
DROP POLICY IF EXISTS "Users can insert their own comments" ON comments;
DROP POLICY IF EXISTS "Users can update their own comments" ON comments;
DROP POLICY IF EXISTS "Users can delete their own comments" ON comments;

CREATE POLICY "Users can view all comments" ON comments
    FOR SELECT USING (true);

CREATE POLICY "Users can insert their own comments" ON comments
    FOR INSERT WITH CHECK (
        auth.uid() = user_id OR 
        user_id = get_supabase_user_id_from_auth0(current_setting('request.jwt.claims', true)::json->>'sub')
    );

CREATE POLICY "Users can update their own comments" ON comments
    FOR UPDATE USING (
        auth.uid() = user_id OR 
        user_id = get_supabase_user_id_from_auth0(current_setting('request.jwt.claims', true)::json->>'sub')
    );

CREATE POLICY "Users can delete their own comments" ON comments
    FOR DELETE USING (
        auth.uid() = user_id OR 
        user_id = get_supabase_user_id_from_auth0(current_setting('request.jwt.claims', true)::json->>'sub')
    );

-- Step 5: Enable RLS on all tables
ALTER TABLE pets ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE tracking_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE tracking_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY; 