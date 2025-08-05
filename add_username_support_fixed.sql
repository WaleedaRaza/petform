-- Add username support to profiles table (FIXED VERSION)
-- This handles the actual table structure

-- First, let's check what columns actually exist
DO $$
DECLARE
    has_user_id BOOLEAN;
    has_id BOOLEAN;
    user_column_name TEXT;
BEGIN
    -- Check if user_id column exists
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' AND column_name = 'user_id'
    ) INTO has_user_id;
    
    -- Check if id column exists
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' AND column_name = 'id'
    ) INTO has_id;
    
    -- Determine which column to use for user identification
    IF has_user_id THEN
        user_column_name := 'user_id';
        RAISE NOTICE 'Using user_id column for user identification';
    ELSIF has_id THEN
        user_column_name := 'id';
        RAISE NOTICE 'Using id column for user identification';
    ELSE
        RAISE EXCEPTION 'No user identification column found in profiles table';
    END IF;
    
    -- Add username column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' AND column_name = 'username'
    ) THEN
        EXECUTE format('ALTER TABLE profiles ADD COLUMN username TEXT');
        RAISE NOTICE 'Added username column to profiles table';
    ELSE
        RAISE NOTICE 'Username column already exists in profiles table';
    END IF;
    
    -- Add display_name column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' AND column_name = 'display_name'
    ) THEN
        EXECUTE format('ALTER TABLE profiles ADD COLUMN display_name TEXT');
        RAISE NOTICE 'Added display_name column to profiles table';
    ELSE
        RAISE NOTICE 'Display_name column already exists in profiles table';
    END IF;
    
    -- Add unique constraint on username (enforce uniqueness)
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'profiles_username_unique'
    ) THEN
        EXECUTE format('ALTER TABLE profiles ADD CONSTRAINT profiles_username_unique UNIQUE (username)');
        RAISE NOTICE 'Added unique constraint on username';
    ELSE
        RAISE NOTICE 'Username unique constraint already exists';
    END IF;
    
    -- Add unique constraint on email as well
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'profiles_email_unique'
    ) THEN
        EXECUTE format('ALTER TABLE profiles ADD CONSTRAINT profiles_email_unique UNIQUE (email)');
        RAISE NOTICE 'Added unique constraint on email';
    ELSE
        RAISE NOTICE 'Email unique constraint already exists';
    END IF;
    
    -- Store the column name for use in functions
    PERFORM set_config('app.user_column_name', user_column_name, false);
    
END $$;

-- Update existing profiles to have usernames if they don't have one
DO $$
DECLARE
    user_column_name TEXT;
BEGIN
    -- Get the column name we determined above
    user_column_name := current_setting('app.user_column_name', true);
    
    -- Update existing profiles to have usernames
    EXECUTE format('
        UPDATE profiles 
        SET username = COALESCE(
            username,
            CASE 
                WHEN email IS NOT NULL THEN split_part(email, ''@'', 1)
                ELSE ''user_'' || substr(%I::text, 1, 8)
            END
        )
        WHERE username IS NULL OR username = ''''
    ', user_column_name);
    
    RAISE NOTICE 'Updated existing profiles with usernames';
END $$;

-- Create function to get or create username (using correct column name)
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
    user_column_name TEXT;
BEGIN
    -- Get the correct column name
    user_column_name := current_setting('app.user_column_name', true);
    
    -- Try to get existing username
    EXECUTE format('SELECT username FROM profiles WHERE %I = $1', user_column_name)
    INTO v_username
    USING p_user_id;
    
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
    WHILE EXISTS(
        EXECUTE format('SELECT 1 FROM profiles WHERE username = $1 AND %I != $2', user_column_name)
        USING v_username, p_user_id
    ) LOOP
        v_username := v_base_username || v_counter::text;
        v_counter := v_counter + 1;
        
        -- Prevent infinite loop
        IF v_counter > 100 THEN
            v_username := 'user_' || substr(p_user_id::text, 1, 8) || v_counter::text;
            EXIT;
        END IF;
    END LOOP;
    
    -- Insert or update profile with username
    EXECUTE format('
        INSERT INTO profiles (%I, email, username, display_name, created_at, updated_at)
        VALUES ($1, $2, $3, $4, NOW(), NOW())
        ON CONFLICT (%I) 
        DO UPDATE SET 
            username = EXCLUDED.username,
            display_name = COALESCE(EXCLUDED.display_name, EXCLUDED.username),
            updated_at = NOW()
    ', user_column_name, user_column_name)
    USING p_user_id, p_email, v_username, COALESCE(p_display_name, v_username);
    
    RETURN v_username;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to update display name (using correct column name)
CREATE OR REPLACE FUNCTION update_display_name(
    p_user_id UUID,
    p_new_display_name TEXT
)
RETURNS TEXT AS $$
DECLARE
    v_display_name TEXT;
    user_column_name TEXT;
BEGIN
    -- Get the correct column name
    user_column_name := current_setting('app.user_column_name', true);
    
    -- Update the display name
    EXECUTE format('
        UPDATE profiles 
        SET display_name = $2, updated_at = NOW()
        WHERE %I = $1
    ', user_column_name)
    USING p_user_id, p_new_display_name;
    
    -- Return the updated display name
    EXECUTE format('
        SELECT display_name FROM profiles WHERE %I = $1
    ', user_column_name)
    INTO v_display_name
    USING p_user_id;
    
    RETURN v_display_name;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER; 