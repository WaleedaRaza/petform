-- Simple fix: Add a column to track saved Reddit posts in the existing posts table
ALTER TABLE posts ADD COLUMN IF NOT EXISTS is_saved_reddit BOOLEAN DEFAULT FALSE;
ALTER TABLE posts ADD COLUMN IF NOT EXISTS reddit_url TEXT;
ALTER TABLE posts ADD COLUMN IF NOT EXISTS original_title TEXT; 