-- VERIFICATION SCRIPT - Check that all fixes are working

-- Check that functions exist
SELECT 'Functions check:' as status;
SELECT routine_name, routine_type 
FROM information_schema.routines 
WHERE routine_name IN ('get_current_user_id', 'get_or_create_supabase_user_for_auth0');

-- Check that RLS is enabled
SELECT 'RLS status check:' as status;
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables 
WHERE tablename IN (
    'pets', 'shopping_items', 'posts', 'profiles', 
    'comments', 'tracking_metrics', 'tracking_entries', 'auth0_user_mappings'
);

-- Check that policies exist
SELECT 'Policy check:' as status;
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies 
WHERE tablename IN (
    'pets', 'shopping_items', 'posts', 'profiles', 
    'comments', 'tracking_metrics', 'tracking_entries', 'auth0_user_mappings'
);

-- Test the get_current_user_id function
SELECT 'Function test:' as status;
SELECT get_current_user_id() as current_user_id;
