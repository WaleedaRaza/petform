-- Fix RLS policies for pets table to allow Auth0 users
-- First, drop the existing policies
DROP POLICY IF EXISTS "Users can view their own pets" ON pets;
DROP POLICY IF EXISTS "Users can insert their own pets" ON pets;
DROP POLICY IF EXISTS "Users can update their own pets" ON pets;
DROP POLICY IF EXISTS "Users can delete their own pets" ON pets;

-- Create new policies that work with both Supabase and Auth0 users
CREATE POLICY "Users can view their own pets" ON pets
    FOR SELECT USING (
        auth.uid() = user_id OR 
        user_id IN (
            SELECT id FROM auth0_users 
            WHERE auth0_user_id = current_setting('request.jwt.claims', true)::json->>'sub'
        )
    );

CREATE POLICY "Users can insert their own pets" ON pets
    FOR INSERT WITH CHECK (
        auth.uid() = user_id OR 
        user_id IN (
            SELECT id FROM auth0_users 
            WHERE auth0_user_id = current_setting('request.jwt.claims', true)::json->>'sub'
        )
    );

CREATE POLICY "Users can update their own pets" ON pets
    FOR UPDATE USING (
        auth.uid() = user_id OR 
        user_id IN (
            SELECT id FROM auth0_users 
            WHERE auth0_user_id = current_setting('request.jwt.claims', true)::json->>'sub'
        )
    );

CREATE POLICY "Users can delete their own pets" ON pets
    FOR DELETE USING (
        auth.uid() = user_id OR 
        user_id IN (
            SELECT id FROM auth0_users 
            WHERE auth0_user_id = current_setting('request.jwt.claims', true)::json->>'sub'
        )
    );

-- Also fix RLS policies for posts table
DROP POLICY IF EXISTS "Users can insert their own posts" ON posts;
DROP POLICY IF EXISTS "Users can update their own posts" ON posts;
DROP POLICY IF EXISTS "Users can delete their own posts" ON posts;

CREATE POLICY "Users can insert their own posts" ON posts
    FOR INSERT WITH CHECK (
        auth.uid() = user_id OR 
        user_id IN (
            SELECT id FROM auth0_users 
            WHERE auth0_user_id = current_setting('request.jwt.claims', true)::json->>'sub'
        )
    );

CREATE POLICY "Users can update their own posts" ON posts
    FOR UPDATE USING (
        auth.uid() = user_id OR 
        user_id IN (
            SELECT id FROM auth0_users 
            WHERE auth0_user_id = current_setting('request.jwt.claims', true)::json->>'sub'
        )
    );

CREATE POLICY "Users can delete their own posts" ON posts
    FOR DELETE USING (
        auth.uid() = user_id OR 
        user_id IN (
            SELECT id FROM auth0_users 
            WHERE auth0_user_id = current_setting('request.jwt.claims', true)::json->>'sub'
        )
    );

-- Fix RLS policies for shopping_items table
DROP POLICY IF EXISTS "Users can view their own shopping items" ON shopping_items;
DROP POLICY IF EXISTS "Users can insert their own shopping items" ON shopping_items;
DROP POLICY IF EXISTS "Users can update their own shopping items" ON shopping_items;
DROP POLICY IF EXISTS "Users can delete their own shopping items" ON shopping_items;

CREATE POLICY "Users can view their own shopping items" ON shopping_items
    FOR SELECT USING (
        auth.uid() = user_id OR 
        user_id IN (
            SELECT id FROM auth0_users 
            WHERE auth0_user_id = current_setting('request.jwt.claims', true)::json->>'sub'
        )
    );

CREATE POLICY "Users can insert their own shopping items" ON shopping_items
    FOR INSERT WITH CHECK (
        auth.uid() = user_id OR 
        user_id IN (
            SELECT id FROM auth0_users 
            WHERE auth0_user_id = current_setting('request.jwt.claims', true)::json->>'sub'
        )
    );

CREATE POLICY "Users can update their own shopping items" ON shopping_items
    FOR UPDATE USING (
        auth.uid() = user_id OR 
        user_id IN (
            SELECT id FROM auth0_users 
            WHERE auth0_user_id = current_setting('request.jwt.claims', true)::json->>'sub'
        )
    );

CREATE POLICY "Users can delete their own shopping items" ON shopping_items
    FOR DELETE USING (
        auth.uid() = user_id OR 
        user_id IN (
            SELECT id FROM auth0_users 
            WHERE auth0_user_id = current_setting('request.jwt.claims', true)::json->>'sub'
        )
    ); 