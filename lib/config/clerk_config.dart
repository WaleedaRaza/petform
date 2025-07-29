class ClerkConfig {
  // Your actual Clerk API keys from your Clerk dashboard
  static const String publishableKey = 'pk_test_Z3JhbmQteWFrLTkwLmNsZXJrLmFjY291bnRzLmRldiQ';
  static const String secretKey = 'sk_test_cWoxP2bzh3iw1oBM2OGsF2SU0Yg58H6Zl3kKl9MpCS';
  
  // Clerk API base URL
  static const String baseUrl = 'https://api.clerk.dev/v1';
  
  // Your Clerk application ID (found in your Clerk dashboard)
  static const String applicationId = 'YOUR_CLERK_APPLICATION_ID';
  
  // Webhook endpoint (if you want to handle webhooks)
  static const String webhookEndpoint = 'YOUR_WEBHOOK_ENDPOINT';
  
  // Authentication settings
  static const bool requireEmailVerification = true;
  static const bool allowSocialLogins = true;
  
  // Available social login providers
  static const List<String> socialProviders = [
    'google',
    'apple',
    'github',
    'discord',
  ];
} 