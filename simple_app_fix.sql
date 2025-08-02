-- Simple fix: Just disable RLS temporarily for development
-- This allows Auth0 users to work without changing database schema

-- Disable RLS on all tables (temporary for development)
ALTER TABLE pets DISABLE ROW LEVEL SECURITY;
ALTER TABLE posts DISABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_items DISABLE ROW LEVEL SECURITY;
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE tracking_metrics DISABLE ROW LEVEL SECURITY;
ALTER TABLE tracking_entries DISABLE ROW LEVEL SECURITY;
ALTER TABLE comments DISABLE ROW LEVEL SECURITY;

-- That's it! No schema changes, no data loss
-- We can re-enable RLS later with proper Auth0 integration 