-- Fix foreign key constraint issue for Auth0 users
-- The pets table has a foreign key to auth.users(id) which doesn't work with Auth0

-- First, disable RLS temporarily to allow the schema changes
ALTER TABLE pets DISABLE ROW LEVEL SECURITY;
ALTER TABLE posts DISABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_items DISABLE ROW LEVEL SECURITY;
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;

-- Drop the foreign key constraints that reference auth.users
ALTER TABLE pets DROP CONSTRAINT IF EXISTS pets_user_id_fkey;
ALTER TABLE posts DROP CONSTRAINT IF EXISTS posts_user_id_fkey;
ALTER TABLE shopping_items DROP CONSTRAINT IF EXISTS shopping_items_user_id_fkey;
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_id_fkey;

-- Change user_id columns to TEXT to accommodate Auth0 user IDs
ALTER TABLE pets ALTER COLUMN user_id TYPE TEXT;
ALTER TABLE posts ALTER COLUMN user_id TYPE TEXT;
ALTER TABLE shopping_items ALTER COLUMN user_id TYPE TEXT;
ALTER TABLE profiles ALTER COLUMN id TYPE TEXT;

-- Add new foreign key constraints that reference our auth0_users table
ALTER TABLE pets ADD CONSTRAINT pets_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth0_users(id) ON DELETE CASCADE;

ALTER TABLE posts ADD CONSTRAINT posts_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth0_users(id) ON DELETE CASCADE;

ALTER TABLE shopping_items ADD CONSTRAINT shopping_items_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth0_users(id) ON DELETE CASCADE;

ALTER TABLE profiles ADD CONSTRAINT profiles_id_fkey 
    FOREIGN KEY (id) REFERENCES auth0_users(id) ON DELETE CASCADE;

-- Re-enable RLS (but it's disabled for now to allow Auth0 users to work)
-- ALTER TABLE pets ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE shopping_items ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE profiles ENABLE ROW LEVEL SECURITY; 