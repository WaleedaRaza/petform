-- Quick User Deletion (Replace email)
-- Change the email below to the user you want to delete

-- Option 1: Delete by email
DELETE FROM auth.users WHERE email = 'user@example.com'; -- CHANGE THIS EMAIL

-- Option 2: Delete by Auth0 user ID
DELETE FROM auth0_user_mappings WHERE auth0_user_id = 'google-oauth2|111371369096261461369'; -- CHANGE THIS ID

-- Option 3: Delete all test users (BE CAREFUL!)
-- DELETE FROM auth.users WHERE email LIKE '%test%';
-- DELETE FROM auth.users WHERE email LIKE '%example%'; 