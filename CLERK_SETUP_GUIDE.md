# Clerk.dev Setup Guide

## Step 1: Create Clerk Account

1. **Go to https://clerk.dev**
2. **Sign up for a free account**
3. **Create a new application**
4. **Choose your application name** (e.g., "Petform")

## Step 2: Get Your API Keys

1. **Go to your Clerk Dashboard**
2. **Navigate to API Keys section**
3. **Copy your keys:**
   - **Publishable Key** (starts with `pk_`)
   - **Secret Key** (starts with `sk_`)
   - **Application ID** (found in the URL or settings)

## Step 3: Configure Your Application

1. **Update `lib/config/clerk_config.dart`:**
   ```dart
   static const String publishableKey = 'pk_your_actual_key_here';
   static const String secretKey = 'sk_your_actual_key_here';
   static const String applicationId = 'your_app_id_here';
   ```

2. **Configure Authentication Methods:**
   - Go to **User & Authentication** → **Email, Phone, Username**
   - Enable **Email address**
   - Enable **Username** (optional)
   - Configure **Password requirements**

3. **Configure Social Logins (Optional):**
   - Go to **User & Authentication** → **Social Connections**
   - Enable **Google**, **Apple**, etc.

## Step 4: Test the Setup

1. **Run your Flutter app**
2. **Test signup flow**
3. **Test signin flow**
4. **Test email verification**

## Step 5: Update Your App

1. **Replace Supabase Auth with Clerk in your screens**
2. **Update user management logic**
3. **Test all authentication flows**

## Clerk Dashboard Features

- **User Management**: View and manage all users
- **Analytics**: Track signups, logins, etc.
- **Webhooks**: Handle user events
- **Customization**: Brand your auth flows
- **Security**: Advanced security features

## Next Steps

1. **Complete the setup above**
2. **Update your authentication screens**
3. **Test the integration**
4. **Deploy with Clerk**

## Support

- **Clerk Documentation**: https://clerk.dev/docs
- **API Reference**: https://clerk.dev/docs/reference
- **Community**: https://clerk.dev/community 