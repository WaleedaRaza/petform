class SupabaseConfig {
  // Supabase project credentials
  static const String url = 'https://qpyiugmianjimjfxadcm.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFweWl1Z21pYW5qaW1qZnhhZGNtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI1OTEwNTQsImV4cCI6MjA2ODE2NzA1NH0.w1m-vxIgaZJPbhzgPESFU8PC1DUuGElYxtRIqNiJrms';
  
  // Service role key (keep secret - only for admin operations)
  static const String serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFweWl1Z21pYW5qaW1qZnhhZGNtIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MjU5MTA1NCwiZXhwIjoyMDY4MTY3MDU0fQ.HcAFZyMubWRYTzT9NqNKCWNSET-u2NyC3l3HqcEDrrg';
  
  // URL scheme for deep links
  static const String urlScheme = 'com.waleedraza.petform';
  static const String redirectUrl = 'com.waleedraza.petform://login-callback';
  
  // Email confirmation redirect URL
  static const String emailConfirmationRedirect = 'com.waleedraza.petform://login-callback';
} 