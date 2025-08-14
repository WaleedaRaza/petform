-- Make pets and shopping items publicly readable for profile viewing
-- This allows users to see each other's pets and shopping lists

-- Update pets table RLS policies
DROP POLICY IF EXISTS "Users can view own pets" ON public.pets;
DROP POLICY IF EXISTS "Users can insert own pets" ON public.pets;
DROP POLICY IF EXISTS "Users can update own pets" ON public.pets;
DROP POLICY IF EXISTS "Users can delete own pets" ON public.pets;

-- Create new policies for pets
CREATE POLICY "Anyone can view pets" ON public.pets
  FOR SELECT USING (true);

CREATE POLICY "Users can insert own pets" ON public.pets
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own pets" ON public.pets
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own pets" ON public.pets
  FOR DELETE USING (auth.uid() = user_id);

-- Update shopping_items table RLS policies
DROP POLICY IF EXISTS "Users can view own shopping items" ON public.shopping_items;
DROP POLICY IF EXISTS "Users can insert own shopping items" ON public.shopping_items;
DROP POLICY IF EXISTS "Users can update own shopping items" ON public.shopping_items;
DROP POLICY IF EXISTS "Users can delete own shopping items" ON public.shopping_items;

-- Create new policies for shopping_items
CREATE POLICY "Anyone can view shopping items" ON public.shopping_items
  FOR SELECT USING (true);

CREATE POLICY "Users can insert own shopping items" ON public.shopping_items
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own shopping items" ON public.shopping_items
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own shopping items" ON public.shopping_items
  FOR DELETE USING (auth.uid() = user_id);