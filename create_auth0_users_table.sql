-- Create auth0_users table to map Auth0 user IDs to UUIDs
CREATE TABLE IF NOT EXISTS auth0_users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    auth0_user_id TEXT UNIQUE NOT NULL,
    email TEXT,
    name TEXT,
    nickname TEXT,
    picture_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_auth0_users_auth0_id ON auth0_users(auth0_user_id);
CREATE INDEX IF NOT EXISTS idx_auth0_users_email ON auth0_users(email);

-- Enable RLS
ALTER TABLE auth0_users ENABLE ROW LEVEL SECURITY;

-- RLS Policies - allow all operations for now since this is just a mapping table
CREATE POLICY "Allow all operations on auth0_users" ON auth0_users
    FOR ALL USING (true);

-- Function to get or create Auth0 user UUID
CREATE OR REPLACE FUNCTION get_auth0_user_uuid(auth0_id TEXT, user_email TEXT DEFAULT NULL, user_name TEXT DEFAULT NULL, user_nickname TEXT DEFAULT NULL, user_picture TEXT DEFAULT NULL)
RETURNS UUID AS $$
DECLARE
    user_uuid UUID;
BEGIN
    -- Try to find existing user
    SELECT id INTO user_uuid FROM auth0_users WHERE auth0_user_id = auth0_id;
    
    -- If not found, create new user
    IF user_uuid IS NULL THEN
        INSERT INTO auth0_users (auth0_user_id, email, name, nickname, picture_url)
        VALUES (auth0_id, user_email, user_name, user_nickname, user_picture)
        RETURNING id INTO user_uuid;
    END IF;
    
    RETURN user_uuid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER; 