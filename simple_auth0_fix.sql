-- Simple fix: Temporarily disable RLS for development
-- This allows Auth0 users to work while we figure out the proper JWT integration

-- Disable RLS on pets table temporarily
ALTER TABLE pets DISABLE ROW LEVEL SECURITY;

-- Disable RLS on posts table temporarily  
ALTER TABLE posts DISABLE ROW LEVEL SECURITY;

-- Disable RLS on shopping_items table temporarily
ALTER TABLE shopping_items DISABLE ROW LEVEL SECURITY;

-- Disable RLS on profiles table temporarily
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;

-- Keep auth0_users table with RLS enabled but allow all operations
-- (This is already set up in the previous migration) 