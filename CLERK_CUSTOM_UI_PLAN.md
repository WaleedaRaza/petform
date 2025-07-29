# Clerk Custom UI + Server API Integration Plan

## Overview
Build custom Flutter authentication UI that communicates with Clerk's REST API for server-side operations. This approach gives us full control over the UI while using Clerk's robust backend.

## Architecture

### Frontend (Flutter)
- Custom signup/signin screens
- Token management and storage
- User session handling
- Profile management UI

### Backend (Clerk API)
- User creation and management
- Authentication verification
- Session management
- User data storage

## Implementation Steps

### Step 1: Token Management System
```dart
// lib/services/clerk_token_service.dart
class ClerkTokenService {
  static const String _tokenKey = 'clerk_token';
  static const String _userKey = 'clerk_user';
  
  // Store JWT token securely
  Future<void> storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }
  
  // Retrieve stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  
  // Clear stored data
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
```

### Step 2: Updated Clerk Service
```dart
// lib/services/clerk_service.dart
class ClerkService {
  // Custom signup with email verification
  Future<Map<String, dynamic>> signUpWithEmail({
    required String email,
    required String password,
    String? username,
  }) async {
    // 1. Create user via Clerk API
    // 2. Send verification email
    // 3. Return user data
  }
  
  // Verify email with code
  Future<bool> verifyEmail(String code) async {
    // 1. Verify email with Clerk API
    // 2. Activate user account
    // 3. Return success status
  }
  
  // Sign in with email/password
  Future<Map<String, dynamic>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    // 1. Authenticate with Clerk API
    // 2. Get JWT token
    // 3. Store token securely
    // 4. Return user data
  }
  
  // Update user profile
  Future<void> updateUserProfile({
    String? username,
    String? displayName,
    String? firstName,
    String? lastName,
  }) async {
    // 1. Update user via Clerk API
    // 2. Refresh local user data
  }
}
```

### Step 3: Custom Authentication Screens

#### Signup Screen
```dart
// lib/views/clerk_signup_screen.dart
class ClerkSignupScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Email input
          // Password input
          // Username input (optional)
          // Signup button
          // Link to signin
        ],
      ),
    );
  }
}
```

#### Signin Screen
```dart
// lib/views/clerk_signin_screen.dart
class ClerkSigninScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Email input
          // Password input
          // Signin button
          // Forgot password link
          // Link to signup
        ],
      ),
    );
  }
}
```

#### Email Verification Screen
```dart
// lib/views/clerk_verification_screen.dart
class ClerkVerificationScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Verification code input
          // Verify button
          // Resend code button
        ],
      ),
    );
  }
}
```

### Step 4: API Integration

#### User Creation Flow
1. **Frontend**: User enters email/password/username
2. **API Call**: POST to Clerk `/users` endpoint
3. **Response**: User created, verification email sent
4. **Frontend**: Show verification screen
5. **User**: Enters verification code
6. **API Call**: Verify email with Clerk
7. **Success**: User activated, redirect to app

#### Authentication Flow
1. **Frontend**: User enters email/password
2. **API Call**: Authenticate with Clerk
3. **Response**: JWT token + user data
4. **Frontend**: Store token securely
5. **Success**: User signed in, redirect to app

### Step 5: Session Management

#### Token Storage
```dart
// Secure token storage using flutter_secure_storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureTokenStorage {
  static const _storage = FlutterSecureStorage();
  
  static Future<void> storeToken(String token) async {
    await _storage.write(key: 'clerk_token', value: token);
  }
  
  static Future<String?> getToken() async {
    return await _storage.read(key: 'clerk_token');
  }
  
  static Future<void> clearToken() async {
    await _storage.delete(key: 'clerk_token');
  }
}
```

#### Auto-login on App Start
```dart
// Check for existing token on app start
Future<bool> checkExistingSession() async {
  final token = await SecureTokenStorage.getToken();
  if (token != null) {
    // Validate token with Clerk API
    // Return true if valid, false if expired
  }
  return false;
}
```

### Step 6: Error Handling

#### Common Error Scenarios
1. **Invalid email format**
2. **Weak password**
3. **Email already exists**
4. **Invalid verification code**
5. **Network errors**
6. **Token expiration**

#### Error Response Handling
```dart
class ClerkError {
  final String message;
  final String code;
  final String? field;
  
  ClerkError({
    required this.message,
    required this.code,
    this.field,
  });
  
  factory ClerkError.fromJson(Map<String, dynamic> json) {
    return ClerkError(
      message: json['message'] ?? 'Unknown error',
      code: json['code'] ?? 'unknown',
      field: json['field'],
    );
  }
}
```

### Step 7: Integration with Existing App

#### Update User Provider
```dart
// lib/providers/user_provider.dart
class UserProvider with ChangeNotifier {
  // Replace Supabase auth with Clerk
  // Update user management methods
  // Handle Clerk user data format
}
```

#### Update Authentication Flow
```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Check for existing Clerk session
  final hasSession = await checkExistingSession();
  
  runApp(MyApp(hasSession: hasSession));
}
```

## Benefits of This Approach

✅ **Full UI Control**: Custom Flutter screens  
✅ **No Token Issues**: Proper JWT handling  
✅ **Secure**: Server-side authentication  
✅ **Scalable**: Easy to add features  
✅ **Reliable**: Clerk's robust backend  
✅ **Flexible**: Can add social logins later  

## Implementation Timeline

### Phase 1 (Week 1)
- [ ] Set up token management
- [ ] Create basic Clerk service
- [ ] Build signup screen
- [ ] Test user creation

### Phase 2 (Week 2)
- [ ] Build signin screen
- [ ] Implement email verification
- [ ] Add session management
- [ ] Test authentication flow

### Phase 3 (Week 3)
- [ ] Integrate with existing app
- [ ] Update user provider
- [ ] Add profile management
- [ ] Test complete flow

### Phase 4 (Week 4)
- [ ] Add error handling
- [ ] Implement password reset
- [ ] Add social logins (optional)
- [ ] Final testing and polish

## Next Steps

1. **Install dependencies** (flutter_secure_storage)
2. **Create token management system**
3. **Build first authentication screen**
4. **Test with Clerk API**

Would you like to start with Phase 1? 