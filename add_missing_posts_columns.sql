-- Add missing columns to existing posts table
-- This script adds the columns that are missing from the current posts table

-- Add author column if it doesn't exist
ALTER TABLE posts ADD COLUMN IF NOT EXISTS author TEXT;

-- Add pet_type column if it doesn't exist
ALTER TABLE posts ADD COLUMN IF NOT EXISTS pet_type TEXT;

-- Add post_type column if it doesn't exist
ALTER TABLE posts ADD COLUMN IF NOT EXISTS post_type TEXT DEFAULT 'community';

-- Add updated_at column if it doesn't exist
ALTER TABLE posts ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Add is_saved column if it doesn't exist
ALTER TABLE posts ADD COLUMN IF NOT EXISTS is_saved BOOLEAN DEFAULT FALSE;

-- Add is_saved_reddit column if it doesn't exist
ALTER TABLE posts ADD COLUMN IF NOT EXISTS is_saved_reddit BOOLEAN DEFAULT FALSE;

-- Add reddit_url column if it doesn't exist
ALTER TABLE posts ADD COLUMN IF NOT EXISTS reddit_url TEXT;

-- Add original_title column if it doesn't exist
ALTER TABLE posts ADD COLUMN IF NOT EXISTS original_title TEXT;

-- Create indexes if they don't exist
CREATE INDEX IF NOT EXISTS idx_posts_user_id ON posts(user_id);
CREATE INDEX IF NOT EXISTS idx_posts_pet_type ON posts(pet_type);
CREATE INDEX IF NOT EXISTS idx_posts_post_type ON posts(post_type);
CREATE INDEX IF NOT EXISTS idx_posts_created_at ON posts(created_at);

-- Enable RLS if not already enabled
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist and recreate them
DROP POLICY IF EXISTS "Users can view all posts" ON posts;
DROP POLICY IF EXISTS "Users can insert their own posts" ON posts;
DROP POLICY IF EXISTS "Users can update their own posts" ON posts;
DROP POLICY IF EXISTS "Users can delete their own posts" ON posts;

-- Create RLS Policies
CREATE POLICY "Users can view all posts" ON posts
    FOR SELECT USING (true);

CREATE POLICY "Users can insert their own posts" ON posts
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own posts" ON posts
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own posts" ON posts
    FOR DELETE USING (auth.uid() = user_id); 