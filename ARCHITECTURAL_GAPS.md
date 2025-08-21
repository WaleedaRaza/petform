# ARCHITECTURAL GAPS & DEPRECATIONS

## 🚨 CURRENT PROBLEMS

### 1. **WORKAROUND APPROACH** (Current)
```dart
// main.dart - This is a WORKAROUND, not official integration
await Supabase.initialize(
  accessToken: () async {
    final credentials = await auth0.credentialsManager.credentials();
    return credentials.accessToken;  // ❌ This bypasses Supabase auth
  },
);
```

### 2. **DEPRECATED FUNCTIONS** (Still in code)
```dart
// supabase_service.dart - These call SQL functions that may not exist
static Future<bool> deleteAuth0UserAccount() async {
  final result = await client.rpc('delete_user_completely', params: {
    'p_auth0_user_id': auth0User.sub,  // ❌ Deprecated approach
  });
}
```

### 3. **MISSING OFFICIAL INTEGRATION**
- ❌ Auth0 not properly configured as 3rd party provider in Supabase
- ❌ No proper JWT role claims
- ❌ No webhook handling for user creation

## ✅ OFFICIAL APPROACH NEEDED

### 1. **SUPABASE AUTH0 PROVIDER SETUP**
```sql
-- In Supabase Dashboard: Authentication > Providers > Auth0
-- Domain: dev-2lm6p70udixry057.us.auth0.com
-- Client ID: 1wC0uAnPpxCMC9LRBJRoBVgZJSelm5ky
-- Client Secret: [from Auth0]
```

### 2. **AUTH0 ACTION FOR JWT CLAIMS**
```javascript
// Auth0 Action: Post Login
exports.onExecutePostLogin = async (event, api) => {
  if (event.client.client_id === '1wC0uAnPpxCMC9LRBJRoBVgZJSelm5ky') {
    api.accessToken.setCustomClaim('role', 'authenticated');
  }
};
```

### 3. **FLUTTER CODE CHANGES NEEDED**
```dart
// ❌ REMOVE: accessToken callback approach
// ✅ ADD: Direct Supabase auth with Auth0 provider
await Supabase.initialize(
  url: SupabaseConfig.url,
  anonKey: SupabaseConfig.anonKey,
  // No accessToken callback needed
);
```

## 🔧 IMMEDIATE FIXES NEEDED

### 1. **REMOVE DEPRECATED CODE**
- [ ] Remove `deleteAuth0UserAccount()` function
- [ ] Remove `delete_user_completely` SQL function calls
- [ ] Clean up Auth0 mapping references

### 2. **IMPLEMENT OFFICIAL INTEGRATION**
- [ ] Configure Auth0 provider in Supabase Dashboard
- [ ] Set up Auth0 Action for JWT claims
- [ ] Update Flutter code to use direct Supabase auth

### 3. **TEST INTEGRATION**
- [ ] Verify Auth0 login creates Supabase user
- [ ] Test RLS policies work correctly
- [ ] Verify all features work (pets, posts, etc.)

## 🎯 END GOAL
**Auth0 users should automatically become Supabase users through official provider integration, not workarounds.**
