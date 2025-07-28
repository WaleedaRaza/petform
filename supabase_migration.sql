-- Add missing columns to pets table
ALTER TABLE pets 
ADD COLUMN IF NOT EXISTS age INTEGER,
ADD COLUMN IF NOT EXISTS personality TEXT,
ADD COLUMN IF NOT EXISTS foodSource TEXT,
ADD COLUMN IF NOT EXISTS favoritePark TEXT,
ADD COLUMN IF NOT EXISTS leashSource TEXT,
ADD COLUMN IF NOT EXISTS litterType TEXT,
ADD COLUMN IF NOT EXISTS waterProducts TEXT,
ADD COLUMN IF NOT EXISTS tankSize TEXT,
ADD COLUMN IF NOT EXISTS cageSize TEXT,
ADD COLUMN IF NOT EXISTS favoriteToy TEXT,
ADD COLUMN IF NOT EXISTS photoUrl TEXT,
ADD COLUMN IF NOT EXISTS customFields JSONB;

-- Add comments for documentation
COMMENT ON COLUMN pets.age IS 'Pet age in years';
COMMENT ON COLUMN pets.personality IS 'Pet personality description';
COMMENT ON COLUMN pets.foodSource IS 'Preferred food source';
COMMENT ON COLUMN pets.favoritePark IS 'Favorite park or location';
COMMENT ON COLUMN pets.leashSource IS 'Leash source for dogs';
COMMENT ON COLUMN pets.litterType IS 'Litter type for cats';
COMMENT ON COLUMN pets.waterProducts IS 'Water products for fish/reptiles';
COMMENT ON COLUMN pets.tankSize IS 'Tank size for fish/reptiles';
COMMENT ON COLUMN pets.cageSize IS 'Cage size for small animals';
COMMENT ON COLUMN pets.favoriteToy IS 'Favorite toy';
COMMENT ON COLUMN pets.photoUrl IS 'URL to pet photo';
COMMENT ON COLUMN pets.customFields IS 'Additional custom fields as JSON'; 