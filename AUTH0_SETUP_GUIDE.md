# Auth0 Setup Guide for PetForm

## 🚀 Quick Setup Steps

### **Step 1: Create Auth0 Account**
1. Go to [https://auth0.com](https://auth0.com)
2. Sign up for a free account
3. Choose "Developer" plan (free tier)

### **Step 2: Create Application**
1. In Auth0 Dashboard, go to **Applications**
2. Click **"Create Application"**
3. Choose **"Native"** as application type
4. Name it "PetForm Mobile App"

### **Step 3: Configure Application**
1. Go to **Settings** tab
2. Copy your **Domain** and **Client ID**
3. Add these **Allowed Callback URLs**:
   ```
   com.petform.app://login-callback
   ```
4. Add these **Allowed Logout URLs**:
   ```
   com.petform.app://logout-callback
   ```
5. Save changes

### **Step 4: Enable Social Connections (Optional)**
1. Go to **Authentication > Social**
2. Enable **Google** connection
3. Configure Google OAuth credentials

### **Step 5: Update App Configuration**
1. Open `lib/config/auth0_config.dart`
2. Replace placeholder values:
   ```dart
   static const String domain = 'your-domain.auth0.com';
   static const String clientId = 'your-client-id';
   ```

### **Step 6: Configure iOS (if needed)**
1. Add URL scheme to `ios/Runner/Info.plist`:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleURLName</key>
       <string>com.petform.app</string>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>com.petform.app</string>
       </array>
     </dict>
   </array>
   ```

## 🔧 Configuration Details

### **Auth0 Application Settings**
- **Application Type**: Native
- **Token Endpoint Authentication Method**: None
- **Grant Types**: Authorization Code, Refresh Token
- **Response Type**: Code

### **Required Permissions**
- `openid` - OpenID Connect
- `profile` - User profile
- `email` - Email address

### **Social Login Setup**
1. **Google OAuth**:
   - Create Google Cloud Console project
   - Enable Google+ API
   - Create OAuth 2.0 credentials
   - Add authorized redirect URIs

2. **Other Providers**:
   - Facebook, Twitter, GitHub, etc.
   - Follow Auth0 documentation for each

## 🧪 Testing Your Setup

### **Test Authentication Flow**
1. Run the app
2. Try email/password signup
3. Try email/password signin
4. Try Google signin (if configured)
5. Test sign out

### **Debug Common Issues**
1. **"Invalid redirect URI"**:
   - Check callback URLs in Auth0 dashboard
   - Verify URL scheme in iOS config

2. **"Application not found"**:
   - Verify domain and client ID
   - Check Auth0 application settings

3. **"Social login not working"**:
   - Verify social connection is enabled
   - Check OAuth credentials

## 📱 App Integration

### **Features Available**
- ✅ Email/password authentication
- ✅ Social login (Google, Facebook, etc.)
- ✅ Secure token storage
- ✅ User profile management
- ✅ Session management
- ✅ Password reset (via Auth0)

### **User Management**
- View users in Auth0 Dashboard
- Manage user profiles
- Configure user metadata
- Set up user roles and permissions

## 🔒 Security Features

### **Built-in Security**
- JWT token validation
- Secure token storage
- Automatic token refresh
- Session management
- Password policies

### **Additional Security**
- Multi-factor authentication
- Passwordless login
- Risk-based authentication
- User blocking/suspension

## 📊 Monitoring & Analytics

### **Auth0 Dashboard**
- User signups/logins
- Failed authentication attempts
- Social login usage
- Device/browser statistics

### **Logs & Events**
- Authentication events
- User management events
- Security events
- Custom events

## 🚀 Production Deployment

### **Before Going Live**
1. **Update callback URLs** for production domain
2. **Configure custom domain** (optional)
3. **Set up monitoring** and alerts
4. **Test all authentication flows**
5. **Configure password policies**
6. **Set up user roles** and permissions

### **Security Checklist**
- [ ] Custom domain configured
- [ ] Password policies set
- [ ] MFA enabled (if needed)
- [ ] User roles defined
- [ ] Monitoring configured
- [ ] Backup procedures in place

## 📞 Support

### **Auth0 Resources**
- [Auth0 Documentation](https://auth0.com/docs)
- [Auth0 Community](https://community.auth0.com)
- [Auth0 Support](https://support.auth0.com)

### **Flutter Auth0 Resources**
- [Auth0 Flutter SDK](https://github.com/auth0/auth0-flutter)
- [Flutter Auth0 Examples](https://github.com/auth0/auth0-flutter/tree/main/example)

## 🎯 Next Steps

1. **Complete Auth0 setup** with your credentials
2. **Test authentication flow** in the app
3. **Configure social login** (optional)
4. **Integrate with existing app** features
5. **Set up user management** and roles
6. **Deploy to production**

Let me know when you have your Auth0 credentials and I'll help you integrate them! 