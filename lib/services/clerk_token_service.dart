import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class ClerkTokenService {
  static const _storage = FlutterSecureStorage();
  static const String _tokenKey = 'clerk_token';
  static const String _userKey = 'clerk_user';
  static const String _refreshTokenKey = 'clerk_refresh_token';
  
  // Store JWT token securely
  static Future<void> storeToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
      if (kDebugMode) {
        print('ClerkTokenService: Token stored successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('ClerkTokenService: Error storing token: $e');
      }
      rethrow;
    }
  }
  
  // Store refresh token
  static Future<void> storeRefreshToken(String refreshToken) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
      if (kDebugMode) {
        print('ClerkTokenService: Refresh token stored successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('ClerkTokenService: Error storing refresh token: $e');
      }
      rethrow;
    }
  }
  
  // Retrieve stored token
  static Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      if (kDebugMode) {
        print('ClerkTokenService: Token retrieved: ${token != null ? 'Found' : 'Not found'}');
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('ClerkTokenService: Error retrieving token: $e');
      }
      return null;
    }
  }
  
  // Retrieve refresh token
  static Future<String?> getRefreshToken() async {
    try {
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      if (kDebugMode) {
        print('ClerkTokenService: Refresh token retrieved: ${refreshToken != null ? 'Found' : 'Not found'}');
      }
      return refreshToken;
    } catch (e) {
      if (kDebugMode) {
        print('ClerkTokenService: Error retrieving refresh token: $e');
      }
      return null;
    }
  }
  
  // Store user data
  static Future<void> storeUser(Map<String, dynamic> userData) async {
    try {
      final userJson = jsonEncode(userData);
      await _storage.write(key: _userKey, value: userJson);
      if (kDebugMode) {
        print('ClerkTokenService: User data stored successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('ClerkTokenService: Error storing user data: $e');
      }
      rethrow;
    }
  }
  
  // Retrieve user data
  static Future<Map<String, dynamic>?> getUser() async {
    try {
      final userJson = await _storage.read(key: _userKey);
      if (userJson != null) {
        final userData = jsonDecode(userJson) as Map<String, dynamic>;
        if (kDebugMode) {
          print('ClerkTokenService: User data retrieved successfully');
        }
        return userData;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('ClerkTokenService: Error retrieving user data: $e');
      }
      return null;
    }
  }
  
  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    try {
      final token = await getToken();
      return token != null;
    } catch (e) {
      if (kDebugMode) {
        print('ClerkTokenService: Error checking authentication: $e');
      }
      return false;
    }
  }
  
  // Clear all stored data
  static Future<void> clearAll() async {
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _userKey);
      await _storage.delete(key: _refreshTokenKey);
      if (kDebugMode) {
        print('ClerkTokenService: All data cleared successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('ClerkTokenService: Error clearing data: $e');
      }
      rethrow;
    }
  }
  
  // Validate token (basic check)
  static bool isTokenValid(String token) {
    try {
      // Basic JWT validation - check if it's not expired
      final parts = token.split('.');
      if (parts.length != 3) return false;
      
      // Decode payload
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      final payloadMap = jsonDecode(resp);
      
      // Check expiration
      final exp = payloadMap['exp'] as int?;
      if (exp == null) return false;
      
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return exp > now;
    } catch (e) {
      if (kDebugMode) {
        print('ClerkTokenService: Error validating token: $e');
      }
      return false;
    }
  }
  
  // Get token expiration time
  static DateTime? getTokenExpiration(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      final payloadMap = jsonDecode(resp);
      
      final exp = payloadMap['exp'] as int?;
      if (exp == null) return null;
      
      return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    } catch (e) {
      if (kDebugMode) {
        print('ClerkTokenService: Error getting token expiration: $e');
      }
      return null;
    }
  }
} 