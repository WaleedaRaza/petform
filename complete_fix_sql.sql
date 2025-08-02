-- Complete fix for Auth0 integration - handles all RLS policies and constraints

-- Step 1: Drop ALL possible RLS policies (comprehensive list)
-- Pets table policies
DROP POLICY IF EXISTS "Users can view their own pets" ON pets;
DROP POLICY IF EXISTS "Users can insert their own pets" ON pets;
DROP POLICY IF EXISTS "Users can update their own pets" ON pets;
DROP POLICY IF EXISTS "Users can delete their own pets" ON pets;
DROP POLICY IF EXISTS "Users can view own pets" ON pets;
DROP POLICY IF EXISTS "Users can insert own pets" ON pets;
DROP POLICY IF EXISTS "Users can update own pets" ON pets;
DROP POLICY IF EXISTS "Users can delete own pets" ON pets;

-- Posts table policies
DROP POLICY IF EXISTS "Users can view all posts" ON posts;
DROP POLICY IF EXISTS "Users can insert their own posts" ON posts;
DROP POLICY IF EXISTS "Users can update their own posts" ON posts;
DROP POLICY IF EXISTS "Users can delete their own posts" ON posts;
DROP POLICY IF EXISTS "Users can view own posts" ON posts;
DROP POLICY IF EXISTS "Users can insert own posts" ON posts;
DROP POLICY IF EXISTS "Users can update own posts" ON posts;
DROP POLICY IF EXISTS "Users can delete own posts" ON posts;

-- Shopping items table policies
DROP POLICY IF EXISTS "Users can view their own shopping items" ON shopping_items;
DROP POLICY IF EXISTS "Users can insert their own shopping items" ON shopping_items;
DROP POLICY IF EXISTS "Users can update their own shopping items" ON shopping_items;
DROP POLICY IF EXISTS "Users can delete their own shopping items" ON shopping_items;
DROP POLICY IF EXISTS "Users can view own shopping items" ON shopping_items;
DROP POLICY IF EXISTS "Users can insert own shopping items" ON shopping_items;
DROP POLICY IF EXISTS "Users can update own shopping items" ON shopping_items;
DROP POLICY IF EXISTS "Users can delete own shopping items" ON shopping_items;

-- Profiles table policies
DROP POLICY IF EXISTS "Users can view their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can delete their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can delete own profile" ON profiles;

-- Step 2: Disable RLS on all tables
ALTER TABLE pets DISABLE ROW LEVEL SECURITY;
ALTER TABLE posts DISABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_items DISABLE ROW LEVEL SECURITY;
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;

-- Step 3: Drop all foreign key constraints
ALTER TABLE pets DROP CONSTRAINT IF EXISTS pets_user_id_fkey;
ALTER TABLE posts DROP CONSTRAINT IF EXISTS posts_user_id_fkey;
ALTER TABLE shopping_items DROP CONSTRAINT IF EXISTS shopping_items_user_id_fkey;
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_id_fkey;

-- Step 4: Change column types to TEXT
ALTER TABLE pets ALTER COLUMN user_id TYPE TEXT;
ALTER TABLE posts ALTER COLUMN user_id TYPE TEXT;
ALTER TABLE shopping_items ALTER COLUMN user_id TYPE TEXT;
ALTER TABLE profiles ALTER COLUMN id TYPE TEXT;

-- Step 5: Add new foreign key constraints to auth0_users
ALTER TABLE pets ADD CONSTRAINT pets_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth0_users(id) ON DELETE CASCADE;

ALTER TABLE posts ADD CONSTRAINT posts_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth0_users(id) ON DELETE CASCADE;

ALTER TABLE shopping_items ADD CONSTRAINT shopping_items_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth0_users(id) ON DELETE CASCADE;

ALTER TABLE profiles ADD CONSTRAINT profiles_id_fkey 
    FOREIGN KEY (id) REFERENCES auth0_users(id) ON DELETE CASCADE;

-- Step 6: Verify the changes
SELECT 'Pets table user_id type:' as info, data_type 
FROM information_schema.columns 
WHERE table_name = 'pets' AND column_name = 'user_id';

SELECT 'Posts table user_id type:' as info, data_type 
FROM information_schema.columns 
WHERE table_name = 'posts' AND column_name = 'user_id';

SELECT 'Shopping_items table user_id type:' as info, data_type 
FROM information_schema.columns 
WHERE table_name = 'shopping_items' AND column_name = 'user_id';

SELECT 'Profiles table id type:' as info, data_type 
FROM information_schema.columns 
WHERE table_name = 'profiles' AND column_name = 'id'; 