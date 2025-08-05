-- Add username support to profiles table
-- This ensures usernames are properly stored and managed

-- First, let's check if username column exists
DO $$
BEGIN
    -- Add username column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' AND column_name = 'username'
    ) THEN
        ALTER TABLE profiles ADD COLUMN username TEXT;
        RAISE NOTICE 'Added username column to profiles table';
    ELSE
        RAISE NOTICE 'Username column already exists in profiles table';
    END IF;
    
    -- Add unique constraint on username (optional, for uniqueness)
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'profiles_username_unique'
    ) THEN
        ALTER TABLE profiles ADD CONSTRAINT profiles_username_unique UNIQUE (username);
        RAISE NOTICE 'Added unique constraint on username';
    ELSE
        RAISE NOTICE 'Username unique constraint already exists';
    END IF;
END $$;

-- Update existing profiles to have usernames if they don't have one
UPDATE profiles 
SET username = COALESCE(
    username,
    CASE 
        WHEN email IS NOT NULL THEN split_part(email, '@', 1)
        ELSE 'user_' || substr(id::text, 1, 8)
    END
)
WHERE username IS NULL OR username = '';

-- Create function to get or create username
CREATE OR REPLACE FUNCTION get_or_create_username(
    p_user_id UUID,
    p_email TEXT,
    p_display_name TEXT DEFAULT NULL
)
RETURNS TEXT AS $$
DECLARE
    v_username TEXT;
    v_base_username TEXT;
    v_counter INTEGER := 1;
BEGIN
    -- Try to get existing username
    SELECT username INTO v_username
    FROM profiles
    WHERE user_id = p_user_id;
    
    -- If username exists, return it
    IF v_username IS NOT NULL AND v_username != '' THEN
        RETURN v_username;
    END IF;
    
    -- Generate base username from email or display name
    IF p_display_name IS NOT NULL AND p_display_name != '' THEN
        v_base_username := lower(regexp_replace(p_display_name, '[^a-zA-Z0-9]', '', 'g'));
    ELSE
        v_base_username := split_part(p_email, '@', 1);
    END IF;
    
    -- Ensure username is not empty
    IF v_base_username IS NULL OR v_base_username = '' THEN
        v_base_username := 'user_' || substr(p_user_id::text, 1, 8);
    END IF;
    
    -- Try to find unique username
    v_username := v_base_username;
    WHILE EXISTS(SELECT 1 FROM profiles WHERE username = v_username AND user_id != p_user_id) LOOP
        v_username := v_base_username || v_counter::text;
        v_counter := v_counter + 1;
    END LOOP;
    
    -- Insert or update profile with username
    INSERT INTO profiles (user_id, email, username, display_name, created_at, updated_at)
    VALUES (p_user_id, p_email, v_username, COALESCE(p_display_name, v_username), NOW(), NOW())
    ON CONFLICT (user_id) 
    DO UPDATE SET 
        username = EXCLUDED.username,
        display_name = COALESCE(EXCLUDED.display_name, EXCLUDED.username),
        updated_at = NOW();
    
    RETURN v_username;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to update display name
CREATE OR REPLACE FUNCTION update_display_name(
    p_user_id UUID,
    p_new_display_name TEXT
)
RETURNS TEXT AS $$
DECLARE
    v_username TEXT;
BEGIN
    -- Update the display name
    UPDATE profiles 
    SET display_name = p_new_display_name, updated_at = NOW()
    WHERE user_id = p_user_id;
    
    -- Return the updated display name
    SELECT display_name INTO v_username
    FROM profiles
    WHERE user_id = p_user_id;
    
    RETURN v_username;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER; 