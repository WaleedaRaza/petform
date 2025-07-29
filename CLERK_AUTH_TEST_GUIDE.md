# Clerk Authentication Test Guide

## 🧪 Complete Authentication Flow Testing

### **Test 1: Signup Flow**
1. **Open the app** - Should show Clerk test screen
2. **Click "Test Sign Up"** or navigate to signup screen
3. **Enter test data:**
   - Email: `test@example.com`
   - Password: `password123` (8+ characters)
   - Username: `testuser` (optional)
4. **Click "Sign Up"**
5. **Expected Result:** 
   - Loading indicator shows
   - Success message appears
   - Navigates to email verification screen

### **Test 2: Email Verification Flow**
1. **On verification screen:**
   - Should show email: `test@example.com`
   - Enter verification code: `123456` (any 6 digits for testing)
2. **Click "Verify Email"**
3. **Expected Result:**
   - Success message: "Email verified successfully!"
   - Auto-navigates to main app after 2 seconds

### **Test 3: Signin Flow**
1. **Go back to signin screen**
2. **Enter credentials:**
   - Email: `test@example.com`
   - Password: `password123`
3. **Click "Sign In"**
4. **Expected Result:**
   - Success message with user email
   - User is signed in

### **Test 4: User Management**
1. **Click "Manage Users"** button
2. **Expected Result:**
   - Shows list of all Clerk users
   - Displays email, ID, status for each user
   - Can delete users with confirmation

### **Test 5: Error Handling**
1. **Test invalid email:**
   - Enter: `invalid-email`
   - Expected: "Please enter a valid email"
2. **Test weak password:**
   - Enter: `123`
   - Expected: "Password must be at least 8 characters"
3. **Test empty fields:**
   - Leave email/password empty
   - Expected: "Please enter your email/password"

### **Test 6: Session Management**
1. **After successful signin:**
   - Click "Check Status"
   - Expected: Shows "Signed In" with user email
2. **Click "Test Sign Out"**
   - Expected: Shows "Sign out successful!"
3. **Click "Check Status" again**
   - Expected: Shows "Signed Out"

## 🔍 What to Look For

### **✅ Success Indicators:**
- Loading indicators during API calls
- Success messages after operations
- Proper navigation between screens
- Error messages for invalid input
- User data persistence

### **❌ Potential Issues:**
- Network errors (check console logs)
- API rate limiting
- Token storage issues
- Navigation problems

## 🐛 Debugging Tips

### **Check Console Logs:**
- Look for `ClerkService:` prefixed messages
- Check for API response status codes
- Monitor token storage operations

### **Common Issues:**
1. **404/400 errors:** Clerk API endpoint issues
2. **Token errors:** Secure storage problems
3. **Navigation issues:** Route not found errors

## 📱 Test Scenarios

### **Scenario A: New User Signup**
1. Use unique email (e.g., `user${timestamp}@example.com`)
2. Complete full flow: Signup → Verification → Main App
3. Verify user appears in management screen

### **Scenario B: Existing User Signin**
1. Use previously created user credentials
2. Test signin flow
3. Verify session persistence

### **Scenario C: Error Recovery**
1. Enter invalid data
2. Check error messages
3. Try again with valid data
4. Verify recovery works

## 🎯 Expected Results

### **Complete Flow Success:**
```
Signup → Email Verification → Main App
     ↓
User Management ← Test Screen
```

### **Data Persistence:**
- User data stored securely
- Tokens persist between app sessions
- Session state maintained

### **Error Handling:**
- Clear error messages
- Graceful failure recovery
- User-friendly feedback

## 📊 Test Checklist

- [ ] Signup with valid data
- [ ] Email verification flow
- [ ] Signin with existing user
- [ ] User management screen
- [ ] Error handling (invalid data)
- [ ] Session management
- [ ] Sign out functionality
- [ ] Navigation between screens
- [ ] Loading states
- [ ] Success/error messages

## 🚀 Next Steps After Testing

1. **If all tests pass:** Ready for production integration
2. **If issues found:** Debug and fix specific problems
3. **If API issues:** Check Clerk configuration
4. **If UI issues:** Adjust styling and layout

Let me know what you find during testing! 