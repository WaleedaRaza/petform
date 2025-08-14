-- Fix shopping items public access
-- Ensure shopping items can be read by anyone for profile viewing

-- First, check current state
SELECT 'Current shopping_items policies:' as info;
SELECT policyname, cmd, qual FROM pg_policies WHERE tablename = 'shopping_items';

-- Drop all existing policies
DROP POLICY IF EXISTS "Users can view their own shopping items" ON public.shopping_items;
DROP POLICY IF EXISTS "Users can insert their own shopping items" ON public.shopping_items;
DROP POLICY IF EXISTS "Users can update their own shopping items" ON public.shopping_items;
DROP POLICY IF EXISTS "Users can delete their own shopping items" ON public.shopping_items;
DROP POLICY IF EXISTS "Anyone can view shopping items" ON public.shopping_items;
DROP POLICY IF EXISTS "Users can insert own shopping items" ON public.shopping_items;
DROP POLICY IF EXISTS "Users can update own shopping items" ON public.shopping_items;
DROP POLICY IF EXISTS "Users can delete own shopping items" ON public.shopping_items;

-- Create new policies for public access
CREATE POLICY "Public can view all shopping items" ON public.shopping_items
  FOR SELECT USING (true);

CREATE POLICY "Users can insert own shopping items" ON public.shopping_items
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own shopping items" ON public.shopping_items
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own shopping items" ON public.shopping_items
  FOR DELETE USING (auth.uid() = user_id);

-- Also fix pets table to be sure
DROP POLICY IF EXISTS "Users can view own pets" ON public.pets;
DROP POLICY IF EXISTS "Users can insert own pets" ON public.pets;
DROP POLICY IF EXISTS "Users can update own pets" ON public.pets;
DROP POLICY IF EXISTS "Users can delete own pets" ON public.pets;
DROP POLICY IF EXISTS "Anyone can view pets" ON public.pets;

CREATE POLICY "Public can view all pets" ON public.pets
  FOR SELECT USING (true);

CREATE POLICY "Users can insert own pets" ON public.pets
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own pets" ON public.pets
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own pets" ON public.pets
  FOR DELETE USING (auth.uid() = user_id);

-- Verify the new policies
SELECT 'New shopping_items policies:' as info;
SELECT policyname, cmd, qual FROM pg_policies WHERE tablename = 'shopping_items';

SELECT 'New pets policies:' as info;
SELECT policyname, cmd, qual FROM pg_policies WHERE tablename = 'pets';