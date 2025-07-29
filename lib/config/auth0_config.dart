class Auth0Config {
  // Auth0 Configuration
  // You'll need to create an Auth0 application and get these values
  
  // Your Auth0 Domain (e.g., dev-xyz.us.auth0.com)
  static const String domain = 'dev-xxxxx.us.auth0.com'; // REPLACE WITH YOUR DOMAIN
  
  // Your Auth0 Client ID
  static const String clientId = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'; // REPLACE WITH YOUR CLIENT ID
  
  // Your Auth0 Client Secret (for server-side operations)
  static const String clientSecret = 'YOUR_AUTH0_CLIENT_SECRET';
  
  // Redirect URI for your app
  static const String redirectUri = 'com.petform.app://login-callback';
  
  // Audience (optional, for API access)
  static const String audience = 'YOUR_API_AUDIENCE';
  
  // Scope for user permissions
  static const String scope = 'openid profile email';
  
  // Auth0 Management API URL
  static const String managementApiUrl = 'https://$domain/api/v2';
  
  // Auth0 API URL
  static const String apiUrl = 'https://$domain';
}

// Example Auth0 setup instructions:
/*
1. Go to https://auth0.com and create an account
2. Create a new application
3. Choose "Native" as the application type
4. Get your Domain and Client ID
5. Configure your app's callback URLs
6. Update the values above with your actual Auth0 credentials
*/ 