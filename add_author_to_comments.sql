-- Add author column to comments table
ALTER TABLE comments ADD COLUMN IF NOT EXISTS author TEXT;

-- Update existing comments to have a default author if they don't have one
UPDATE comments SET author = 'Anonymous' WHERE author IS NULL; 