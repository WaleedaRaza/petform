class ClerkError {
  final String message;
  final String code;
  final String? field;
  final String? traceId;
  
  ClerkError({
    required this.message,
    required this.code,
    this.field,
    this.traceId,
  });
  
  factory ClerkError.fromJson(Map<String, dynamic> json) {
    return ClerkError(
      message: json['message'] ?? 'Unknown error',
      code: json['code'] ?? 'unknown',
      field: json['field'],
      traceId: json['clerk_trace_id'],
    );
  }
  
  @override
  String toString() {
    return 'ClerkError(code: $code, message: $message, field: $field)';
  }
}

class ClerkApiResponse<T> {
  final T? data;
  final List<ClerkError>? errors;
  final bool success;
  
  ClerkApiResponse({
    this.data,
    this.errors,
    required this.success,
  });
  
  factory ClerkApiResponse.success(T data) {
    return ClerkApiResponse(
      data: data,
      success: true,
    );
  }
  
  factory ClerkApiResponse.error(List<ClerkError> errors) {
    return ClerkApiResponse(
      errors: errors,
      success: false,
    );
  }
  
  factory ClerkApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (json.containsKey('errors')) {
      final errorsList = json['errors'] as List;
      final errors = errorsList
          .map((e) => ClerkError.fromJson(e as Map<String, dynamic>))
          .toList();
      return ClerkApiResponse.error(errors);
    } else {
      final data = fromJson(json);
      return ClerkApiResponse.success(data);
    }
  }
}

// Common Clerk error codes
class ClerkErrorCodes {
  static const String invalidEmail = 'invalid_email';
  static const String emailAlreadyExists = 'email_already_exists';
  static const String weakPassword = 'weak_password';
  static const String invalidVerificationCode = 'invalid_verification_code';
  static const String userNotFound = 'user_not_found';
  static const String invalidCredentials = 'invalid_credentials';
  static const String tokenExpired = 'token_expired';
  static const String unauthorized = 'unauthorized';
  static const String rateLimited = 'rate_limited';
  static const String networkError = 'network_error';
}

// Helper function to handle common errors
String getErrorMessage(ClerkError error) {
  switch (error.code) {
    case ClerkErrorCodes.invalidEmail:
      return 'Please enter a valid email address';
    case ClerkErrorCodes.emailAlreadyExists:
      return 'An account with this email already exists';
    case ClerkErrorCodes.weakPassword:
      return 'Password must be at least 8 characters long';
    case ClerkErrorCodes.invalidVerificationCode:
      return 'Invalid verification code. Please try again';
    case ClerkErrorCodes.userNotFound:
      return 'No account found with this email address';
    case ClerkErrorCodes.invalidCredentials:
      return 'Invalid email or password';
    case ClerkErrorCodes.tokenExpired:
      return 'Your session has expired. Please sign in again';
    case ClerkErrorCodes.unauthorized:
      return 'You are not authorized to perform this action';
    case ClerkErrorCodes.rateLimited:
      return 'Too many attempts. Please try again later';
    case ClerkErrorCodes.networkError:
      return 'Network error. Please check your connection';
    default:
      return error.message;
  }
} 