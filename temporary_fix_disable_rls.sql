-- TEMPORARY FIX: Disable RLS to get the app working immediately
-- This will allow Auth0 users to create pets while we implement the proper mapping

-- Disable RLS on all tables temporarily
ALTER TABLE pets DISABLE ROW LEVEL SECURITY;
ALTER TABLE posts DISABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_items DISABLE ROW LEVEL SECURITY;
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE tracking_metrics DISABLE ROW LEVEL SECURITY;
ALTER TABLE tracking_entries DISABLE ROW LEVEL SECURITY;
ALTER TABLE comments DISABLE ROW LEVEL SECURITY;

-- Drop all existing policies to avoid conflicts
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

DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;

DROP POLICY IF EXISTS "Users can view own pet metrics" ON tracking_metrics;
DROP POLICY IF EXISTS "Users can insert own pet metrics" ON tracking_metrics;
DROP POLICY IF EXISTS "Users can update own pet metrics" ON tracking_metrics;
DROP POLICY IF EXISTS "Users can delete own pet metrics" ON tracking_metrics;

DROP POLICY IF EXISTS "Users can view own pet tracking entries" ON tracking_entries;
DROP POLICY IF EXISTS "Users can insert own pet tracking entries" ON tracking_entries;
DROP POLICY IF EXISTS "Users can update own pet tracking entries" ON tracking_entries;
DROP POLICY IF EXISTS "Users can delete own pet tracking entries" ON tracking_entries;

DROP POLICY IF EXISTS "Users can view all comments" ON comments;
DROP POLICY IF EXISTS "Users can insert their own comments" ON comments;
DROP POLICY IF EXISTS "Users can update their own comments" ON comments;
DROP POLICY IF EXISTS "Users can delete their own comments" ON comments;

-- Create simple policies that allow all operations (temporary)
CREATE POLICY "Allow all operations on pets" ON pets FOR ALL USING (true);
CREATE POLICY "Allow all operations on posts" ON posts FOR ALL USING (true);
CREATE POLICY "Allow all operations on shopping_items" ON shopping_items FOR ALL USING (true);
CREATE POLICY "Allow all operations on profiles" ON profiles FOR ALL USING (true);
CREATE POLICY "Allow all operations on tracking_metrics" ON tracking_metrics FOR ALL USING (true);
CREATE POLICY "Allow all operations on tracking_entries" ON tracking_entries FOR ALL USING (true);
CREATE POLICY "Allow all operations on comments" ON comments FOR ALL USING (true);

-- Re-enable RLS with the simple policies
ALTER TABLE pets ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE tracking_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE tracking_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY; 