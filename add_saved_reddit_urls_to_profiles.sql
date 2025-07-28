-- Add saved_reddit_urls column to profiles table
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS saved_reddit_urls JSONB DEFAULT '[]'::jsonb; 