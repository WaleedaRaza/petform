# Clerk.dev Migration Plan

## Overview
Migrate from Supabase Auth to Clerk.dev for better authentication experience and features.

## Steps for Migration

### 1. Setup Clerk.dev
1. Create account at https://clerk.dev
2. Create new application
3. Get API keys (Publishable Key and Secret Key)
4. Configure authentication methods (Email, Google, etc.)

### 2. Install Clerk Flutter SDK
```bash
flutter pub add clerk_sdk_flutter
```

### 3. Update Configuration
- Replace Supabase auth configuration with Clerk configuration
- Update environment variables
- Configure Clerk webhook endpoints

### 4. Create Clerk Service
Create `lib/services/clerk_service.dart` to replace `supabase_auth_service.dart`

### 5. Update Authentication Flow
- Replace Supabase auth methods with Clerk methods
- Update signup/login screens
- Update user profile management
- Update session management

### 6. Update Database Integration
- Keep Supabase for database (posts, comments, profiles)
- Update user ID references to use Clerk user IDs
- Update RLS policies to work with Clerk user IDs

### 7. Update User Management
- Replace Supabase user metadata with Clerk user attributes
- Update profile creation/update logic
- Update username reservation system

### 8. Testing
- Test signup flow
- Test login flow
- Test profile updates
- Test session persistence
- Test user data migration

## Benefits of Clerk.dev
- Better UI components
- More authentication providers
- Better session management
- Built-in user management dashboard
- Better security features
- Easier to implement social logins

## Migration Strategy
1. **Phase 1**: Setup Clerk and create new service
2. **Phase 2**: Update authentication screens
3. **Phase 3**: Update user management
4. **Phase 4**: Test and deploy
5. **Phase 5**: Migrate existing users (optional)

## Files to Update
- `lib/services/supabase_auth_service.dart` → `lib/services/clerk_service.dart`
- `lib/views/login_screen.dart`
- `lib/views/signup_screen.dart`
- `lib/views/profile_settings_screen.dart`
- `lib/providers/user_provider.dart`
- `lib/main.dart` (configuration)
- `pubspec.yaml` (dependencies) 