-- Check if posts table exists and create it if it doesn't
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'posts') THEN
        -- Create posts table for community posts and saved Reddit posts
        CREATE TABLE posts (
            id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
            user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
            title TEXT NOT NULL,
            content TEXT,
            pet_type TEXT,
            post_type TEXT DEFAULT 'community',
            author TEXT,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            is_saved BOOLEAN DEFAULT FALSE,
            is_saved_reddit BOOLEAN DEFAULT FALSE,
            reddit_url TEXT,
            original_title TEXT
        );

        -- Create indexes for better performance
        CREATE INDEX idx_posts_user_id ON posts(user_id);
        CREATE INDEX idx_posts_pet_type ON posts(pet_type);
        CREATE INDEX idx_posts_post_type ON posts(post_type);
        CREATE INDEX idx_posts_created_at ON posts(created_at);

        -- Enable Row Level Security
        ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

        -- RLS Policies
        CREATE POLICY "Users can view all posts" ON posts
            FOR SELECT USING (true);

        CREATE POLICY "Users can insert their own posts" ON posts
            FOR INSERT WITH CHECK (auth.uid() = user_id);

        CREATE POLICY "Users can update their own posts" ON posts
            FOR UPDATE USING (auth.uid() = user_id);

        CREATE POLICY "Users can delete their own posts" ON posts
            FOR DELETE USING (auth.uid() = user_id);
            
        RAISE NOTICE 'Posts table created successfully';
    ELSE
        RAISE NOTICE 'Posts table already exists';
    END IF;
END $$; 