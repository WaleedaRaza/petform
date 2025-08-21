# OFFICIAL AUTH0 + SUPABASE INTEGRATION PLAN

## 🎯 GOAL
Replace the workaround approach with official Supabase Auth0 provider integration.

## 🔄 CURRENT STATE (WORKAROUND)
```dart
// ❌ Current approach in main.dart
await Supabase.initialize(
  accessToken: () async {
    final credentials = await auth0.credentialsManager.credentials();
    return credentials.accessToken;  // Bypasses Supabase auth
  },
);
```

## ✅ TARGET STATE (OFFICIAL)
```dart
// ✅ Official approach
await Supabase.initialize(
  url: SupabaseConfig.url,
  anonKey: SupabaseConfig.anonKey,
  // Auth0 handled by Supabase provider
);
```

## 📋 IMPLEMENTATION STEPS

### STEP 1: SUPABASE DASHBOARD SETUP
1. **Go to Supabase Dashboard** → Authentication → Providers
2. **Enable Auth0 provider**
3. **Configure:**
   - Domain: `dev-2lm6p70udixry057.us.auth0.com`
   - Client ID: `1wC0uAnPpxCMC9LRBJRoBVgZJSelm5ky`
   - Client Secret: [Get from Auth0 Dashboard]

### STEP 2: AUTH0 DASHBOARD SETUP
1. **Go to Auth0 Dashboard** → Applications → Petform
2. **Add callback URL:** `https://qpyiugmianjimjfxadcm.supabase.co/auth/v1/callback`
3. **Create Auth0 Action:**
   ```javascript
   exports.onExecutePostLogin = async (event, api) => {
     if (event.client.client_id === '1wC0uAnPpxCMC9LRBJRoBVgZJSelm5ky') {
       api.accessToken.setCustomClaim('role', 'authenticated');
     }
   };
   ```

### STEP 3: FLUTTER CODE CHANGES

#### 3.1 Remove Auth0 Flutter SDK
```bash
flutter pub remove auth0_flutter
```

#### 3.2 Update main.dart
```dart
// Remove Auth0 initialization
// Remove accessToken callback
await Supabase.initialize(
  url: SupabaseConfig.url,
  anonKey: SupabaseConfig.anonKey,
);
```

#### 3.3 Create new auth service
```dart
// lib/services/supabase_auth_service.dart
class SupabaseAuthService {
  static Future<AuthResponse> signInWithAuth0() async {
    return await Supabase.instance.client.auth.signInWithOAuth(
      Provider.auth0,
      redirectTo: 'com.waleedraza.petform://auth/callback',
    );
  }
}
```

#### 3.4 Update welcome_screen.dart
```dart
// Replace Auth0Service.instance.signIn() with:
final response = await SupabaseAuthService.signInWithAuth0();
```

### STEP 4: CLEAN UP DEPRECATED CODE
- [ ] Remove `Auth0Service` class
- [ ] Remove `deleteAuth0UserAccount()` function
- [ ] Remove Auth0 mapping SQL functions
- [ ] Update all references to use Supabase auth

### STEP 5: TEST INTEGRATION
- [ ] Test Auth0 login creates Supabase user
- [ ] Test RLS policies work
- [ ] Test all features (pets, posts, etc.)

## 🚨 CRITICAL CHANGES NEEDED

### 1. **REMOVE DEPENDENCIES**
```yaml
# pubspec.yaml - Remove these
dependencies:
  auth0_flutter: ^2.0.0  # ❌ Remove
```

### 2. **UPDATE IMPORTS**
```dart
// Remove from all files:
import 'package:auth0_flutter/auth0_flutter.dart';
import '../services/auth0_service.dart';
```

### 3. **UPDATE AUTH FLOW**
```dart
// Old: Auth0Service.instance.signIn()
// New: SupabaseAuthService.signInWithAuth0()
```

## 🎯 BENEFITS OF OFFICIAL INTEGRATION
1. **Automatic user creation** in Supabase
2. **Proper JWT handling** with role claims
3. **RLS policies work** correctly
4. **No manual mapping** required
5. **Official support** from Supabase

## ⚠️ RISKS
1. **Breaking changes** to existing auth flow
2. **User data migration** may be needed
3. **Testing required** for all features

## 📊 TIMELINE
- **Step 1-2:** 10 minutes (Dashboard setup)
- **Step 3:** 30 minutes (Code changes)
- **Step 4:** 15 minutes (Cleanup)
- **Step 5:** 20 minutes (Testing)
- **Total:** ~75 minutes
