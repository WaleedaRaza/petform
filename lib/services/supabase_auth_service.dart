import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseAuthService {
  static SupabaseClient get client => Supabase.instance.client;

  // Get current user
  User? get currentUser => client.auth.currentUser;

  // Auth state changes stream
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  // Sign up with email and password
  Future<AuthResponse> signUpWithEmailAndPassword(String email, String password) async {
    try {
      if (kDebugMode) {
        print('SupabaseAuthService: Attempting to sign up user: $email');
      }
      
      final response = await client.auth.signUp(email: email, password: password);
      
      if (kDebugMode) {
        print('SupabaseAuthService: User signed up successfully: ${response.user?.email}');
        print('SupabaseAuthService: Session: ${response.session}');
        print('SupabaseAuthService: User ID: ${response.user?.id}');
      }
      
      // Since email confirmation is disabled, user should be automatically logged in
      if (response.user != null) {
        if (kDebugMode) {
          print('SupabaseAuthService: User is automatically logged in');
        }
      }
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseAuthService: Sign up error: $e');
      }
      throw _handleAuthException(e);
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signInWithEmailAndPassword(String email, String password) async {
    try {
      if (kDebugMode) {
        print('SupabaseAuthService: Attempting to sign in user: $email');
      }
      
      final response = await client.auth.signInWithPassword(email: email, password: password);
      
      if (kDebugMode) {
        print('SupabaseAuthService: User signed in successfully: ${response.user?.email}');
      }
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseAuthService: Sign in error: $e');
      }
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
      if (kDebugMode) {
        print('SupabaseAuthService: User signed out successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseAuthService: Sign out error: $e');
      }
      rethrow;
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      await client.auth.admin.deleteUser(client.auth.currentUser!.id);
      if (kDebugMode) {
        print('SupabaseAuthService: User account deleted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseAuthService: Delete account error: $e');
      }
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await client.auth.resetPasswordForEmail(email);
      if (kDebugMode) {
        print('SupabaseAuthService: Password reset email sent to $email');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseAuthService: Reset password error: $e');
      }
      rethrow;
    }
  }

  // Check if email is verified
  bool isEmailVerified() {
    return client.auth.currentUser?.emailConfirmedAt != null;
  }

  // Reload user to get latest verification status
  Future<void> reloadUser() async {
    await client.auth.refreshSession();
  }

  // Resend email verification
  Future<void> resendEmailVerification([String? email]) async {
    try {
      // If email is provided, use it directly
      // Otherwise, try to get it from current user
      final emailToUse = email ?? client.auth.currentUser?.email;
      
      if (emailToUse == null || emailToUse.isEmpty) {
        throw Exception('No email address available for resending verification');
      }
      
      if (kDebugMode) {
        print('SupabaseAuthService: Attempting to resend email to: $emailToUse');
      }
      
      await client.auth.resend(
        type: OtpType.signup,
        email: emailToUse,
      );
      if (kDebugMode) {
        print('SupabaseAuthService: Email verification resent to $emailToUse');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseAuthService: Resend email verification error: $e');
      }
      
      // Handle rate limit errors specifically
      if (e.toString().contains('rate limit') || e.toString().contains('too many requests')) {
        throw Exception('Rate limit exceeded. Please wait a few minutes before trying again, or consider setting up custom SMTP in Supabase dashboard.');
      }
      
      // Handle other common email errors
      if (e.toString().contains('email')) {
        throw Exception('Email service error. Please check your Supabase email configuration.');
      }
      
      rethrow;
    }
  }

  // Update display name
  Future<void> updateDisplayName(String displayName) async {
    try {
      final user = client.auth.currentUser;
      if (user == null) throw Exception('No user logged in');
      
      // Update auth user metadata
      await client.auth.updateUser(
        UserAttributes(
          data: {'display_name': displayName},
        ),
      );
      
      // Update profile in database
      await client.from('profiles').update({
        'display_name': displayName,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);
      
      if (kDebugMode) {
        print('SupabaseAuthService: Display name updated to: $displayName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseAuthService: Update display name error: $e');
      }
      rethrow;
    }
  }

  // Test Supabase connection and email configuration
  Future<Map<String, dynamic>> testSupabaseConnection() async {
    try {
      final result = <String, dynamic>{};
      
      // Test basic connection
      result['connection'] = 'Connected';
      result['url'] = 'https://qpyiugmianjimjfxadcm.supabase.co';
      result['currentUser'] = client.auth.currentUser?.email ?? 'No user';
      
      // Test if we can access auth
      try {
        final session = client.auth.currentSession;
        result['session'] = session != null ? 'Active' : 'No session';
      } catch (e) {
        result['session'] = 'Error: $e';
      }
      
      if (kDebugMode) {
        print('SupabaseAuthService: Connection test results: $result');
      }
      
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseAuthService: Connection test error: $e');
      }
      return {'error': e.toString()};
    }
  }

  // Test email sending with detailed logging
  Future<Map<String, dynamic>> testEmailSending(String testEmail) async {
    try {
      final result = <String, dynamic>{};
      
      if (kDebugMode) {
        print('SupabaseAuthService: Testing email sending to: $testEmail');
      }
      
      // Test signup with the test email
      final response = await client.auth.signUp(
        email: testEmail,
        password: 'testpassword123',
      );
      
      result['signup_success'] = response.user != null;
      result['email_confirmation_required'] = response.session == null;
      result['user_id'] = response.user?.id;
      result['email'] = response.user?.email;
      
      if (kDebugMode) {
        print('SupabaseAuthService: Test signup response: $result');
      }
      
      // Try to resend email verification
      try {
        await client.auth.resend(
          type: OtpType.signup,
          email: testEmail,
        );
        result['resend_success'] = true;
        if (kDebugMode) {
          print('SupabaseAuthService: Email resend successful');
        }
      } catch (resendError) {
        result['resend_success'] = false;
        result['resend_error'] = resendError.toString();
        if (kDebugMode) {
          print('SupabaseAuthService: Email resend failed: $resendError');
        }
      }
      
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseAuthService: Test email sending error: $e');
      }
      return {'error': e.toString()};
    }
  }

  // Debug email confirmation process
  Future<Map<String, dynamic>> debugEmailConfirmation(String email) async {
    try {
      final result = <String, dynamic>{};
      
      if (kDebugMode) {
        print('SupabaseAuthService: Debugging email confirmation for: $email');
      }
      
      // Check if user exists
      final user = client.auth.currentUser;
      result['current_user'] = user?.email ?? 'No current user';
      result['user_id'] = user?.id ?? 'No user ID';
      result['email_confirmed'] = user?.emailConfirmedAt != null;
      
      // Try to get session
      final session = client.auth.currentSession;
      result['has_session'] = session != null;
      
      // Check auth state
      result['auth_state'] = 'Checking...';
      
      if (kDebugMode) {
        print('SupabaseAuthService: Debug results: $result');
      }
      
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseAuthService: Debug error: $e');
      }
      return {'error': e.toString()};
    }
  }

  // Manually verify email with token
  Future<Map<String, dynamic>> verifyEmailWithToken(String tokenHash) async {
    try {
      final result = <String, dynamic>{};
      
      if (kDebugMode) {
        print('SupabaseAuthService: Attempting to verify email with token: $tokenHash');
      }
      
      // Try to verify the email
      final response = await client.auth.verifyOTP(
        tokenHash: tokenHash,
        type: OtpType.signup,
      );
      
      result['verification_success'] = response.user != null;
      result['user_id'] = response.user?.id;
      result['email'] = response.user?.email;
      result['session'] = response.session != null;
      
      if (kDebugMode) {
        print('SupabaseAuthService: Verification response: $result');
      }
      
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseAuthService: Verification error: $e');
      }
      return {'error': e.toString()};
    }
  }

  // Test SMTP configuration
  Future<Map<String, dynamic>> testSMTPConfiguration() async {
    try {
      final result = <String, dynamic>{};
      
      if (kDebugMode) {
        print('SupabaseAuthService: Testing SMTP configuration...');
      }
      
      // Try to send a test email
      final testEmail = 'test-${DateTime.now().millisecondsSinceEpoch}@example.com';
      
      try {
        final response = await client.auth.signUp(
          email: testEmail,
          password: 'testpassword123',
        );
        
        result['signup_success'] = response.user != null;
        result['email_confirmation_required'] = response.session == null;
        result['test_email'] = testEmail;
        
        if (kDebugMode) {
          print('SupabaseAuthService: Test signup successful: ${response.user?.email}');
        }
        
        // Check if we get rate limit error
        try {
          await client.auth.resend(
            type: OtpType.signup,
            email: testEmail,
          );
          result['resend_success'] = true;
          result['smtp_working'] = true;
          if (kDebugMode) {
            print('SupabaseAuthService: SMTP resend successful - custom SMTP is working');
          }
        } catch (resendError) {
          result['resend_success'] = false;
          result['resend_error'] = resendError.toString();
          result['smtp_working'] = false;
          if (kDebugMode) {
            print('SupabaseAuthService: SMTP resend failed: $resendError');
          }
        }
        
      } catch (signupError) {
        result['signup_success'] = false;
        result['signup_error'] = signupError.toString();
        if (kDebugMode) {
          print('SupabaseAuthService: Test signup failed: $signupError');
        }
      }
      
      if (kDebugMode) {
        print('SupabaseAuthService: SMTP test results: $result');
      }
      
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseAuthService: SMTP test error: $e');
      }
      return {'error': e.toString()};
    }
  }

  // Test SMTP connection with detailed error reporting
  Future<Map<String, dynamic>> testSMTPConnection() async {
    try {
      final result = <String, dynamic>{};
      
      if (kDebugMode) {
        print('SupabaseAuthService: Testing SMTP connection...');
      }
      
      // Try to send a test email with a unique email
      final testEmail = 'test-${DateTime.now().millisecondsSinceEpoch}@example.com';
      
      try {
        if (kDebugMode) {
          print('SupabaseAuthService: Attempting signup with: $testEmail');
        }
        
        final response = await client.auth.signUp(
          email: testEmail,
          password: 'testpassword123',
        );
        
        result['signup_success'] = response.user != null;
        result['email_confirmation_required'] = response.session == null;
        result['user_id'] = response.user?.id;
        result['test_email'] = testEmail;
        
        if (kDebugMode) {
          print('SupabaseAuthService: Signup successful, user ID: ${response.user?.id}');
        }
        
        // Wait a moment for the email to be sent
        await Future.delayed(const Duration(seconds: 2));
        
        // Try to resend email to test SMTP
        try {
          if (kDebugMode) {
            print('SupabaseAuthService: Testing email resend...');
          }
          
          await client.auth.resend(
            type: OtpType.signup,
            email: testEmail,
          );
          
          result['resend_success'] = true;
          result['smtp_working'] = true;
          result['error'] = null;
          
          if (kDebugMode) {
            print('SupabaseAuthService: SMTP resend successful - custom SMTP is working');
          }
          
        } catch (resendError) {
          result['resend_success'] = false;
          result['resend_error'] = resendError.toString();
          result['smtp_working'] = false;
          result['error'] = resendError.toString();
          
          if (kDebugMode) {
            print('SupabaseAuthService: SMTP resend failed: $resendError');
          }
        }
        
      } catch (signupError) {
        result['signup_success'] = false;
        result['signup_error'] = signupError.toString();
        result['smtp_working'] = false;
        result['error'] = signupError.toString();
        
        if (kDebugMode) {
          print('SupabaseAuthService: Signup failed: $signupError');
        }
      }
      
      if (kDebugMode) {
        print('SupabaseAuthService: SMTP test results: $result');
      }
      
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseAuthService: SMTP test error: $e');
      }
      return {'error': e.toString(), 'smtp_working': false};
    }
  }

  // Handle Supabase auth exceptions
  String _handleAuthException(dynamic e) {
    if (e is AuthException) {
      switch (e.message) {
        case 'Invalid login credentials':
          return 'Invalid email or password.';
        case 'Email not confirmed':
          return 'Please verify your email address.';
        case 'User already registered':
          return 'An account with this email already exists.';
        case 'Password should be at least 6 characters':
          return 'Password is too weak.';
        case 'Invalid email':
          return 'Invalid email address.';
        case 'Too many requests':
          return 'Too many failed attempts. Please try again later.';
        default:
          return 'Authentication failed: ${e.message}';
      }
    }
    return 'Authentication failed: $e';
  }

  // Handle email confirmation from deep link
  Future<Map<String, dynamic>> handleEmailConfirmation(String url) async {
    try {
      final result = <String, dynamic>{};
      
      if (kDebugMode) {
        print('SupabaseAuthService: Handling email confirmation from URL: $url');
      }
      
      // Extract token hash from URL
      final uri = Uri.parse(url);
      final tokenHash = uri.queryParameters['token_hash'];
      final type = uri.queryParameters['type'];
      
      result['token_hash'] = tokenHash;
      result['type'] = type;
      result['full_url'] = url;
      result['uri_parameters'] = uri.queryParameters.toString();
      
      if (kDebugMode) {
        print('SupabaseAuthService: Parsed URI: $uri');
        print('SupabaseAuthService: All query parameters: ${uri.queryParameters}');
        print('SupabaseAuthService: Token hash: $tokenHash');
        print('SupabaseAuthService: Type: $type');
      }
      
      // If no token_hash in query parameters, try to extract from URL path
      String? extractedTokenHash = tokenHash;
      if (extractedTokenHash == null || extractedTokenHash.isEmpty) {
        if (kDebugMode) {
          print('SupabaseAuthService: No token_hash in query parameters, checking URL path...');
        }
        
        // Try to extract token from URL path (common in Supabase links)
        final pathSegments = uri.pathSegments;
        for (final segment in pathSegments) {
          if (segment.contains('token_hash=')) {
            final tokenPart = segment.split('token_hash=').last;
            extractedTokenHash = tokenPart.split('&').first;
            if (kDebugMode) {
              print('SupabaseAuthService: Extracted token from path: $extractedTokenHash');
            }
            break;
          }
        }
        
        // If still no token, try to find it in the full URL
        if (extractedTokenHash == null || extractedTokenHash.isEmpty) {
          final tokenMatch = RegExp(r'token_hash=([^&]+)').firstMatch(url);
          if (tokenMatch != null) {
            extractedTokenHash = tokenMatch.group(1);
            if (kDebugMode) {
              print('SupabaseAuthService: Extracted token from regex: $extractedTokenHash');
            }
          }
        }
      }
      
      if (extractedTokenHash == null || extractedTokenHash.isEmpty) {
        result['error'] = 'No token hash found in URL';
        if (kDebugMode) {
          print('SupabaseAuthService: ERROR - No token hash found in URL: $url');
        }
        return result;
      }
      
      if (kDebugMode) {
        print('SupabaseAuthService: About to verify OTP with token hash: $extractedTokenHash');
      }
      
      // Verify the email
      final response = await client.auth.verifyOTP(
        tokenHash: extractedTokenHash,
        type: OtpType.signup,
      );
      
      result['verification_success'] = response.user != null;
      result['user_id'] = response.user?.id;
      result['email'] = response.user?.email;
      result['session'] = response.session != null;
      result['email_confirmed'] = response.user?.emailConfirmedAt != null;
      result['extracted_token_hash'] = extractedTokenHash;
      
      if (kDebugMode) {
        print('SupabaseAuthService: Email verification response: $result');
      }
      
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseAuthService: Email confirmation error: $e');
      }
      return {'error': e.toString()};
    }
  }

  // Manually test token hash verification
  Future<Map<String, dynamic>> testTokenHashVerification(String tokenHash) async {
    try {
      final result = <String, dynamic>{};
      
      if (kDebugMode) {
        print('SupabaseAuthService: Testing token hash verification: $tokenHash');
      }
      
      if (tokenHash.isEmpty) {
        result['error'] = 'Token hash is empty';
        return result;
      }
      
      // Try to verify the token hash
      final response = await client.auth.verifyOTP(
        tokenHash: tokenHash,
        type: OtpType.signup,
      );
      
      result['verification_success'] = response.user != null;
      result['user_id'] = response.user?.id;
      result['email'] = response.user?.email;
      result['session'] = response.session != null;
      result['email_confirmed'] = response.user?.emailConfirmedAt != null;
      
      if (kDebugMode) {
        print('SupabaseAuthService: Token hash verification result: $result');
      }
      
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseAuthService: Token hash verification error: $e');
      }
      return {'error': e.toString()};
    }
  }
  
  // Get user profile data
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = client.auth.currentUser;
      if (user == null) return null;
      
      final response = await client
          .from('profiles')
          .select('*')
          .eq('id', user.id)
          .single();
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseAuthService: Error getting user profile: $e');
      }
      return null;
    }
  }
} 