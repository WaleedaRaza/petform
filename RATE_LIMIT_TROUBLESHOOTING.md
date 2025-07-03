# Rate Limit Troubleshooting Guide

## Common Causes of Rate Limit Errors

### 1. API Key Issues
- **Wrong API Key**: Make sure you're using the correct API key from your OpenAI account
- **Organization Limits**: Your API key might be from an organization with strict rate limits
- **Free Tier Limits**: Free OpenAI accounts have very low rate limits (3 requests per minute)

### 2. Multiple Requests
- **Rapid Succession**: Making requests too quickly
- **Background Requests**: App might be making multiple requests simultaneously
- **Cached Requests**: Old requests might still be processing

### 3. API Key Format
Your current API key starts with `sk-proj-` which suggests it might be:
- From a different OpenAI service
- From an organization account with different limits
- From a third-party service

## Solutions

### 1. Check Your OpenAI Account
1. Go to [OpenAI Platform](https://platform.openai.com/)
2. Check your usage and rate limits
3. Verify you're using the correct API key

### 2. Get a New API Key
1. Go to [OpenAI API Keys](https://platform.openai.com/api-keys)
2. Create a new API key
3. Make sure it starts with `sk-` (not `sk-proj-`)
4. Update `lib/config/ai_config.dart`

### 3. Check Rate Limits
- **Free Tier**: 3 requests per minute
- **Paid Tier**: Higher limits based on your plan
- **Organization**: Depends on organization settings

### 4. Test the Connection
Use the "Test Connection" button in the app to:
- Verify API key is valid
- Check rate limits
- See detailed error messages

### 5. Wait and Retry
- Wait 1-2 minutes between requests
- Don't make multiple requests simultaneously
- Check the console logs for detailed error information

## Debugging Steps

1. **Run the app** and go to the Ask AI tab
2. **Click "Test Connection"** to check basic connectivity
3. **Check console logs** for detailed error messages
4. **Try a simple query** and wait 2 minutes before trying again
5. **Verify your OpenAI account** has sufficient credits

## Alternative Solutions

### 1. Use a Different API Key
If your current key has strict limits, try:
- Creating a new personal API key
- Using a different OpenAI account
- Upgrading your OpenAI plan

### 2. Implement Better Rate Limiting
The app now includes rate limiting, but you can:
- Increase the delay between requests
- Add exponential backoff
- Implement request queuing

### 3. Use a Different Model
- Try `gpt-3.5-turbo-16k` for higher rate limits
- Consider using a different AI service
- Implement local LLM fallback

## Console Logs to Check

When you run the app, check the console for these messages:
- `AI Service: Sending request to OpenAI...`
- `AI Service: Response status: XXX`
- `AI Service: Response body: ...`
- `AI Service: Rate limit exceeded`

These logs will help identify the exact issue. 