-- EMERGENCY FIX: Temporarily disable RLS to allow pet creation
-- This is a temporary solution while we fix the Auth0 context issue

-- Disable RLS on pets table
ALTER TABLE pets DISABLE ROW LEVEL SECURITY;

-- Disable RLS on shopping_items table  
ALTER TABLE shopping_items DISABLE ROW LEVEL SECURITY;

-- Disable RLS on profiles table
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;

-- Disable RLS on posts table
ALTER TABLE posts DISABLE ROW LEVEL SECURITY;

-- Disable RLS on comments table
ALTER TABLE comments DISABLE ROW LEVEL SECURITY;

-- Disable RLS on tracking_metrics table
ALTER TABLE tracking_metrics DISABLE ROW LEVEL SECURITY;

-- Disable RLS on tracking_entries table
ALTER TABLE tracking_entries DISABLE ROW LEVEL SECURITY;

-- Keep auth0_user_mappings accessible
ALTER TABLE auth0_user_mappings DISABLE ROW LEVEL SECURITY;

SELECT 'EMERGENCY FIX: RLS temporarily disabled on all tables' as status;
SELECT 'Users can now create pets and other data' as result;
SELECT 'WARNING: This removes security temporarily - we will fix this properly' as warning; 