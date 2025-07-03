# App Store Preparation Guide for Petform

## Prerequisites
- ✅ Apple Developer Program membership (paid)
- ✅ Xcode installed on macOS
- ✅ Flutter development environment set up
- ✅ Firebase project configured

## Step 1: Update App Configuration

### 1.1 Update pubspec.yaml
```yaml
name: petform
description: Your comprehensive pet management companion. Track health, get AI advice, shop for supplies, and connect with the pet community.

version: 1.0.0+1  # Keep this for first release
```

### 1.2 Update iOS Bundle Identifier
1. Open `ios/Runner.xcodeproj` in Xcode
2. Select "Runner" project
3. Go to "General" tab
4. Change Bundle Identifier to: `com.yourcompany.petform` (replace with your domain)
5. Update Display Name if needed

### 1.3 Update Info.plist
Add these required keys to `ios/Runner/Info.plist`:

```xml
<!-- Privacy descriptions for camera/photo access -->
<key>NSCameraUsageDescription</key>
<string>Petform needs camera access to take photos of your pets for their profiles.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Petform needs photo library access to select pet photos for their profiles.</string>

<!-- URL schemes for Google Sign-In -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.yourcompany.petform</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR_GOOGLE_CLIENT_ID</string>
        </array>
    </dict>
</array>

<!-- App Transport Security -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>api.openai.com</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <false/>
            <key>NSExceptionMinimumTLSVersion</key>
            <string>TLSv1.2</string>
        </dict>
    </dict>
</dict>
```

## Step 2: App Store Connect Setup

### 2.1 Create App Record
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click "My Apps" → "+" → "New App"
3. Fill in:
   - **Platforms**: iOS
   - **Name**: Petform
   - **Primary Language**: English
   - **Bundle ID**: Select your bundle identifier
   - **SKU**: petform-ios-001 (unique identifier)
   - **User Access**: Full Access

### 2.2 App Information
Fill in the app details:
- **Subtitle**: Your pet management companion
- **Keywords**: pet,management,health,tracking,ai,community,shopping
- **Description**: Write a compelling description (see template below)
- **Support URL**: Your website or support page
- **Marketing URL**: Your app's marketing page

### 2.3 App Description Template
```
Petform - Your Comprehensive Pet Management Companion

Transform your pet care experience with Petform, the all-in-one app designed to help you provide the best care for your furry, feathered, or finned friends.

KEY FEATURES:
🐾 AI-Powered Pet Advice: Get personalized recommendations from our PetPal AI assistant
📊 Health Tracking: Monitor weight, exercise, feeding schedules, and more
🛒 Smart Shopping: Discover and track pet supplies from Chewy and other retailers
👥 Community Feed: Connect with fellow pet owners and share experiences
📱 Multi-Pet Support: Manage profiles for all your pets in one place
🔔 Reminders & Alerts: Never miss important pet care tasks

WHY PETFORM?
• Personalized care recommendations based on your pet's specific needs
• Comprehensive health tracking with visual progress charts
• Integration with popular pet supply retailers
• AI-powered advice for health, behavior, and nutrition questions
• Beautiful, intuitive interface designed for pet owners

Perfect for dog owners, cat lovers, bird enthusiasts, fish keepers, and anyone who wants to provide the best care for their pets.

Download Petform today and give your pets the care they deserve!
```

## Step 3: App Store Assets

### 3.1 App Icon
- Create a 1024x1024 pixel app icon
- Save as PNG format
- Replace `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png`

### 3.2 Screenshots
Take screenshots of your app on different devices:
- iPhone 6.7" (iPhone 14 Pro Max)
- iPhone 6.5" (iPhone 11 Pro Max)
- iPhone 5.5" (iPhone 8 Plus)
- iPad Pro 12.9" (if supporting iPad)

Required screenshots:
1. Welcome/Login screen
2. Home/Feed screen
3. AI Chat screen
4. Pet tracking screen
5. Shopping screen
6. Profile screen

### 3.3 App Preview Video (Optional)
Create a 30-second video showcasing your app's key features.

## Step 4: Build and Archive

### 4.1 Clean and Build
```bash
# Clean the project
flutter clean

# Get dependencies
flutter pub get

# Build for iOS
flutter build ios --release
```

### 4.2 Archive in Xcode
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select "Any iOS Device" as target
3. Go to Product → Archive
4. Wait for archiving to complete

### 4.3 Upload to App Store Connect
1. In Xcode Organizer, select your archive
2. Click "Distribute App"
3. Select "App Store Connect"
4. Choose "Upload"
5. Follow the upload process

## Step 5: App Store Review Preparation

### 5.1 TestFlight Testing
1. In App Store Connect, go to your app
2. Click "TestFlight" tab
3. Upload your build
4. Add internal testers
5. Test thoroughly before submission

### 5.2 Privacy Policy
Create a privacy policy covering:
- Data collection and usage
- Firebase Analytics
- Google Sign-In
- Apple Sign-In
- OpenAI API usage
- User data rights

### 5.3 App Review Guidelines Compliance
Ensure your app follows:
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- No crashes or bugs
- Proper error handling
- Clear user interface
- Appropriate content

## Step 6: Submit for Review

### 6.1 Final Checklist
- [ ] App builds and runs without crashes
- [ ] All features work correctly
- [ ] Privacy policy is accessible
- [ ] App description is complete
- [ ] Screenshots are uploaded
- [ ] App icon is set
- [ ] Bundle identifier is correct
- [ ] Version number is set
- [ ] Firebase configuration is production-ready
- [ ] OpenAI API key is configured

### 6.2 Submit for Review
1. In App Store Connect, go to your app
2. Click "Prepare for Submission"
3. Fill in all required fields
4. Upload your build
5. Submit for review

## Step 7: Post-Submission

### 7.1 Monitor Review Status
- Review typically takes 24-48 hours
- Check App Store Connect for status updates
- Respond to any review team questions

### 7.2 Common Rejection Reasons
- Missing privacy policy
- Incomplete app description
- App crashes during review
- Missing required permissions
- Inappropriate content

### 7.3 After Approval
- App will be available on App Store
- Monitor user feedback and ratings
- Plan for future updates

## Additional Resources

### Firebase Production Setup
1. Create production Firebase project
2. Update `GoogleService-Info.plist` with production config
3. Enable App Store distribution in Firebase Console

### Analytics Setup
Consider adding:
- Firebase Analytics
- Crashlytics for crash reporting
- Performance monitoring

### Support Documentation
Create:
- User guide
- FAQ page
- Contact information
- Support email

## Version Management
For future updates:
1. Increment version in `pubspec.yaml`
2. Update build number
3. Test thoroughly
4. Submit new build

Example version progression:
- 1.0.0+1 (Initial release)
- 1.0.1+2 (Bug fixes)
- 1.1.0+3 (New features)
- 1.2.0+4 (Major update)

Good luck with your App Store submission! 🚀 