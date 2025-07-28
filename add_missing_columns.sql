-- Add missing columns to pets table one by one
-- This script adds each column individually to avoid conflicts

-- Add age column
ALTER TABLE pets ADD COLUMN IF NOT EXISTS age INTEGER;

-- Add personality column  
ALTER TABLE pets ADD COLUMN IF NOT EXISTS personality TEXT;

-- Add foodSource column
ALTER TABLE pets ADD COLUMN IF NOT EXISTS foodSource TEXT;

-- Add favoritePark column
ALTER TABLE pets ADD COLUMN IF NOT EXISTS favoritePark TEXT;

-- Add leashSource column
ALTER TABLE pets ADD COLUMN IF NOT EXISTS leashSource TEXT;

-- Add litterType column
ALTER TABLE pets ADD COLUMN IF NOT EXISTS litterType TEXT;

-- Add waterProducts column
ALTER TABLE pets ADD COLUMN IF NOT EXISTS waterProducts TEXT;

-- Add tankSize column
ALTER TABLE pets ADD COLUMN IF NOT EXISTS tankSize TEXT;

-- Add cageSize column
ALTER TABLE pets ADD COLUMN IF NOT EXISTS cageSize TEXT;

-- Add favoriteToy column
ALTER TABLE pets ADD COLUMN IF NOT EXISTS favoriteToy TEXT;

-- Add photoUrl column
ALTER TABLE pets ADD COLUMN IF NOT EXISTS photoUrl TEXT;

-- Add customFields column
ALTER TABLE pets ADD COLUMN IF NOT EXISTS customFields JSONB;

-- Verify all columns were added
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'pets' 
ORDER BY ordinal_position; 