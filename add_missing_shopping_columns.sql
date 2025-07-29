-- Add missing columns to existing shopping_items table
-- This script adds the columns that are missing from the current table

-- Add priority column
ALTER TABLE shopping_items ADD COLUMN IF NOT EXISTS priority TEXT;

-- Add estimated_cost column (rename from price if it exists)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'shopping_items' AND column_name = 'price') THEN
        ALTER TABLE shopping_items RENAME COLUMN price TO estimated_cost;
    ELSE
        ALTER TABLE shopping_items ADD COLUMN IF NOT EXISTS estimated_cost DECIMAL(10,2);
    END IF;
END $$;

-- Add pet_id column
ALTER TABLE shopping_items ADD COLUMN IF NOT EXISTS pet_id UUID;

-- Add description column
ALTER TABLE shopping_items ADD COLUMN IF NOT EXISTS description TEXT;

-- Add brand column
ALTER TABLE shopping_items ADD COLUMN IF NOT EXISTS brand TEXT;

-- Add store column
ALTER TABLE shopping_items ADD COLUMN IF NOT EXISTS store TEXT;

-- Rename is_purchased to is_completed if it exists
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'shopping_items' AND column_name = 'is_purchased') THEN
        ALTER TABLE shopping_items RENAME COLUMN is_purchased TO is_completed;
    ELSE
        ALTER TABLE shopping_items ADD COLUMN IF NOT EXISTS is_completed BOOLEAN DEFAULT FALSE;
    END IF;
END $$;

-- Add completed_at column
ALTER TABLE shopping_items ADD COLUMN IF NOT EXISTS completed_at TIMESTAMP WITH TIME ZONE;

-- Add tags column
ALTER TABLE shopping_items ADD COLUMN IF NOT EXISTS tags TEXT[];

-- Add image_url column
ALTER TABLE shopping_items ADD COLUMN IF NOT EXISTS image_url TEXT;

-- Add quantity column
ALTER TABLE shopping_items ADD COLUMN IF NOT EXISTS quantity INTEGER DEFAULT 1;

-- Add notes column
ALTER TABLE shopping_items ADD COLUMN IF NOT EXISTS notes TEXT;

-- Add chewy_url column
ALTER TABLE shopping_items ADD COLUMN IF NOT EXISTS chewy_url TEXT;

-- Add rating column
ALTER TABLE shopping_items ADD COLUMN IF NOT EXISTS rating DECIMAL(3,2);

-- Add review_count column
ALTER TABLE shopping_items ADD COLUMN IF NOT EXISTS review_count INTEGER;

-- Add in_stock column
ALTER TABLE shopping_items ADD COLUMN IF NOT EXISTS in_stock BOOLEAN;

-- Add auto_ship column
ALTER TABLE shopping_items ADD COLUMN IF NOT EXISTS auto_ship BOOLEAN;

-- Add free_shipping column
ALTER TABLE shopping_items ADD COLUMN IF NOT EXISTS free_shipping BOOLEAN;

-- Add updated_at column if it doesn't exist
ALTER TABLE shopping_items ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Create indexes if they don't exist
CREATE INDEX IF NOT EXISTS idx_shopping_items_user_id ON shopping_items(user_id);
CREATE INDEX IF NOT EXISTS idx_shopping_items_category ON shopping_items(category);
CREATE INDEX IF NOT EXISTS idx_shopping_items_pet_id ON shopping_items(pet_id);

-- Enable RLS if not already enabled
ALTER TABLE shopping_items ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist and recreate them
DROP POLICY IF EXISTS "Users can view their own shopping items" ON shopping_items;
DROP POLICY IF EXISTS "Users can insert their own shopping items" ON shopping_items;
DROP POLICY IF EXISTS "Users can update their own shopping items" ON shopping_items;
DROP POLICY IF EXISTS "Users can delete their own shopping items" ON shopping_items;

-- Create RLS Policies
CREATE POLICY "Users can view their own shopping items" ON shopping_items
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own shopping items" ON shopping_items
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own shopping items" ON shopping_items
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own shopping items" ON shopping_items
    FOR DELETE USING (auth.uid() = user_id); 