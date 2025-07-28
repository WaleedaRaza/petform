-- Create saved_reddit_posts table for storing user's saved Reddit posts
CREATE TABLE IF NOT EXISTS saved_reddit_posts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    reddit_url TEXT NOT NULL,
    title TEXT NOT NULL,
    pet_type TEXT NOT NULL,
    saved_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_saved_reddit_posts_user_id ON saved_reddit_posts(user_id);
CREATE INDEX IF NOT EXISTS idx_saved_reddit_posts_reddit_url ON saved_reddit_posts(reddit_url);

-- Enable RLS (Row Level Security)
ALTER TABLE saved_reddit_posts ENABLE ROW LEVEL SECURITY;

-- Add unique constraint to prevent duplicate saves
ALTER TABLE saved_reddit_posts 
ADD CONSTRAINT unique_user_reddit_url 
UNIQUE (user_id, reddit_url); 