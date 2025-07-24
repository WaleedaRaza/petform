# 🚀 Phase 1 Implementation: Supabase Setup & Infrastructure

## Prerequisites
- Node.js installed
- Flutter development environment ready
- Git repository backed up (✅ Done)

---

## Step 1: Create Supabase Project

### 1.1 Install Supabase CLI
```bash
npm install -g supabase
```

### 1.2 Login to Supabase
```bash
supabase login
```

### 1.3 Create New Project
```bash
supabase projects create petform-app
```

### 1.4 Get Project Credentials
After project creation, you'll get:
- Project URL
- Anon Key
- Service Role Key (keep secret)

---

## Step 2: Setup Flutter Dependencies

### 2.1 Update pubspec.yaml
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.5
  shared_preferences: ^2.0.15
  cached_network_image: ^3.2.0
  shimmer: ^2.0.0
  url_launcher: ^6.0.3
  http: ^1.4.0
  image_picker: ^1.0.4
  image_cropper: ^5.0.1
  path_provider: ^2.1.1
  # NEW: Supabase
  supabase_flutter: ^2.3.4
  # REMOVE: Firebase (after migration)
  # firebase_core: ^3.14.0
  # firebase_auth: ^5.3.3
  # REMOVE: Hive (after migration)
  # hive: ^2.2.3
  # hive_flutter: ^1.1.0
  video_player: ^2.8.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_launcher_icons: ^0.13.1
  # REMOVE: Hive generators (after migration)
  # hive_generator: ^2.0.1
  build_runner: ^2.4.6
```

### 2.2 Install Dependencies
```bash
flutter pub get
```

---

## Step 3: Create Supabase Configuration

### 3.1 Create Config Directory
```bash
mkdir lib/config
```

### 3.2 Create Supabase Config
```dart
// lib/config/supabase_config.dart
class SupabaseConfig {
  // Replace with your actual Supabase credentials
  static const String url = 'YOUR_SUPABASE_URL';
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  // Optional: Service role key for admin operations
  static const String serviceRoleKey = 'YOUR_SERVICE_ROLE_KEY';
}
```

---

## Step 4: Initialize Supabase in Flutter

### 4.1 Update main.dart
```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'providers/user_provider.dart';
import 'providers/app_state_provider.dart';
import 'providers/feed_provider.dart';
import 'services/api_service.dart';
import 'views/welcome_screen.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kDebugMode) {
    print('Main: Initializing Supabase...');
  }
  
  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  
  if (kDebugMode) {
    print('Main: Supabase initialized successfully');
    print('Main: Supabase URL: ${SupabaseConfig.url}');
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        Provider(create: (context) => ApiService()),
        ChangeNotifierProvider(create: (context) => AppStateProvider()),
        ChangeNotifierProvider(create: (context) => FeedProvider()),
      ],
      child: const PetformApp(),
    ),
  );
}

class PetformApp extends StatelessWidget {
  const PetformApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Petform',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const WelcomeScreen(),
    );
  }
}
```

---

## Step 5: Create Database Schema

### 5.1 Access Supabase Dashboard
1. Go to your Supabase project dashboard
2. Navigate to SQL Editor
3. Create new query

### 5.2 Execute Schema Creation
```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create profiles table
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  username TEXT UNIQUE NOT NULL,
  display_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create pets table
CREATE TABLE public.pets (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  breed TEXT,
  birth_date DATE,
  weight DECIMAL(5,2),
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create posts table
CREATE TABLE public.posts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  image_url TEXT,
  likes_count INTEGER DEFAULT 0,
  is_saved BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create comments table
CREATE TABLE public.comments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  post_id UUID REFERENCES public.posts(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create tracking_metrics table
CREATE TABLE public.tracking_metrics (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  pet_id UUID REFERENCES public.pets(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  unit TEXT,
  target_value DECIMAL(10,2),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create tracking_entries table
CREATE TABLE public.tracking_entries (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  metric_id UUID REFERENCES public.tracking_metrics(id) ON DELETE CASCADE NOT NULL,
  value DECIMAL(10,2) NOT NULL,
  notes TEXT,
  entry_date DATE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 5.3 Enable Row Level Security (RLS)
```sql
-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tracking_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tracking_entries ENABLE ROW LEVEL SECURITY;
```

### 5.4 Create RLS Policies
```sql
-- Profiles policies
CREATE POLICY "Users can view own profile" ON public.profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Pets policies
CREATE POLICY "Users can view own pets" ON public.pets
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own pets" ON public.pets
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own pets" ON public.pets
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own pets" ON public.pets
  FOR DELETE USING (auth.uid() = user_id);

-- Posts policies
CREATE POLICY "Anyone can view posts" ON public.posts
  FOR SELECT USING (true);

CREATE POLICY "Users can insert own posts" ON public.posts
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own posts" ON public.posts
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own posts" ON public.posts
  FOR DELETE USING (auth.uid() = user_id);

-- Comments policies
CREATE POLICY "Anyone can view comments" ON public.comments
  FOR SELECT USING (true);

CREATE POLICY "Users can insert own comments" ON public.comments
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own comments" ON public.comments
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own comments" ON public.comments
  FOR DELETE USING (auth.uid() = user_id);

-- Tracking metrics policies
CREATE POLICY "Users can view own pet metrics" ON public.tracking_metrics
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.pets 
      WHERE pets.id = tracking_metrics.pet_id 
      AND pets.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert own pet metrics" ON public.tracking_metrics
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.pets 
      WHERE pets.id = tracking_metrics.pet_id 
      AND pets.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update own pet metrics" ON public.tracking_metrics
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.pets 
      WHERE pets.id = tracking_metrics.pet_id 
      AND pets.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete own pet metrics" ON public.tracking_metrics
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM public.pets 
      WHERE pets.id = tracking_metrics.pet_id 
      AND pets.user_id = auth.uid()
    )
  );

-- Tracking entries policies
CREATE POLICY "Users can view own pet tracking entries" ON public.tracking_entries
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.tracking_metrics tm
      JOIN public.pets p ON p.id = tm.pet_id
      WHERE tm.id = tracking_entries.metric_id 
      AND p.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert own pet tracking entries" ON public.tracking_entries
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.tracking_metrics tm
      JOIN public.pets p ON p.id = tm.pet_id
      WHERE tm.id = tracking_entries.metric_id 
      AND p.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update own pet tracking entries" ON public.tracking_entries
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.tracking_metrics tm
      JOIN public.pets p ON p.id = tm.pet_id
      WHERE tm.id = tracking_entries.metric_id 
      AND p.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete own pet tracking entries" ON public.tracking_entries
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM public.tracking_metrics tm
      JOIN public.pets p ON p.id = tm.pet_id
      WHERE tm.id = tracking_entries.metric_id 
      AND p.user_id = auth.uid()
    )
  );
```

---

## Step 6: Create Supabase Service

### 6.1 Create Supabase Service
```dart
// lib/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;
  
  // Auth methods
  static Future<AuthResponse> signUp(String email, String password) async {
    try {
      if (kDebugMode) {
        print('SupabaseService: Attempting to sign up user: $email');
      }
      
      final response = await client.auth.signUp(email: email, password: password);
      
      if (kDebugMode) {
        print('SupabaseService: User signed up successfully: ${response.user?.email}');
      }
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Sign up error: $e');
      }
      rethrow;
    }
  }
  
  static Future<AuthResponse> signIn(String email, String password) async {
    try {
      if (kDebugMode) {
        print('SupabaseService: Attempting to sign in user: $email');
      }
      
      final response = await client.auth.signInWithPassword(email: email, password: password);
      
      if (kDebugMode) {
        print('SupabaseService: User signed in successfully: ${response.user?.email}');
      }
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Sign in error: $e');
      }
      rethrow;
    }
  }
  
  static Future<void> signOut() async {
    try {
      await client.auth.signOut();
      if (kDebugMode) {
        print('SupabaseService: User signed out successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Sign out error: $e');
      }
      rethrow;
    }
  }
  
  static User? get currentUser => client.auth.currentUser;
  
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
  
  // Database methods
  static Future<List<Map<String, dynamic>>> getPets() async {
    try {
      final response = await client
          .from('pets')
          .select()
          .eq('user_id', client.auth.currentUser!.id);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error getting pets: $e');
      }
      rethrow;
    }
  }
  
  static Future<void> createPet(Map<String, dynamic> petData) async {
    try {
      await client
          .from('pets')
          .insert(petData);
      if (kDebugMode) {
        print('SupabaseService: Pet created successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error creating pet: $e');
      }
      rethrow;
    }
  }
  
  static Future<void> updatePet(String id, Map<String, dynamic> petData) async {
    try {
      await client
          .from('pets')
          .update(petData)
          .eq('id', id);
      if (kDebugMode) {
        print('SupabaseService: Pet updated successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error updating pet: $e');
      }
      rethrow;
    }
  }
  
  static Future<void> deletePet(String id) async {
    try {
      await client
          .from('pets')
          .delete()
          .eq('id', id);
      if (kDebugMode) {
        print('SupabaseService: Pet deleted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error deleting pet: $e');
      }
      rethrow;
    }
  }
  
  // Posts methods
  static Future<List<Map<String, dynamic>>> getPosts() async {
    try {
      final response = await client
          .from('posts')
          .select('*, profiles(username, display_name)')
          .order('created_at', ascending: false);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error getting posts: $e');
      }
      rethrow;
    }
  }
  
  static Future<void> createPost(Map<String, dynamic> postData) async {
    try {
      await client
          .from('posts')
          .insert(postData);
      if (kDebugMode) {
        print('SupabaseService: Post created successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error creating post: $e');
      }
      rethrow;
    }
  }
  
  // Real-time subscriptions
  static RealtimeChannel subscribeToPosts(Function(Map<String, dynamic>) onData) {
    return client
        .channel('posts')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'posts',
          callback: (payload) => onData(payload.newRecord),
        )
        .subscribe();
  }
  
  // File upload
  static Future<String> uploadFile(String bucket, String path, List<int> bytes) async {
    try {
      final response = await client.storage
          .from(bucket)
          .uploadBinary(path, bytes);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('SupabaseService: Error uploading file: $e');
      }
      rethrow;
    }
  }
  
  static String getPublicUrl(String bucket, String path) {
    return client.storage
        .from(bucket)
        .getPublicUrl(path);
  }
}
```

---

## Step 7: Test Basic Setup

### 7.1 Test Supabase Connection
```dart
// Add this to main.dart temporarily for testing
void testSupabaseConnection() async {
  try {
    final response = await SupabaseService.client
        .from('pets')
        .select('count')
        .limit(1);
    print('✅ Supabase connection successful');
  } catch (e) {
    print('❌ Supabase connection failed: $e');
  }
}
```

### 7.2 Run the App
```bash
flutter run
```

---

## Step 8: Create Storage Buckets

### 8.1 Create Storage Buckets in Supabase Dashboard
1. Go to Storage in Supabase Dashboard
2. Create buckets:
   - `pet-images` (for pet photos)
   - `post-images` (for post images)
   - `avatars` (for user avatars)

### 8.2 Set Storage Policies
```sql
-- Allow authenticated users to upload files
CREATE POLICY "Users can upload files" ON storage.objects
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Allow users to view their own files
CREATE POLICY "Users can view own files" ON storage.objects
  FOR SELECT USING (auth.uid()::text = (storage.foldername(name))[1]);

-- Allow users to update their own files
CREATE POLICY "Users can update own files" ON storage.objects
  FOR UPDATE USING (auth.uid()::text = (storage.foldername(name))[1]);

-- Allow users to delete their own files
CREATE POLICY "Users can delete own files" ON storage.objects
  FOR DELETE USING (auth.uid()::text = (storage.foldername(name))[1]);
```

---

## ✅ Phase 1 Checklist

- [ ] Create Supabase project
- [ ] Update Flutter dependencies
- [ ] Create Supabase configuration
- [ ] Initialize Supabase in Flutter
- [ ] Create database schema
- [ ] Enable RLS and create policies
- [ ] Create Supabase service
- [ ] Test basic connection
- [ ] Create storage buckets
- [ ] Set storage policies

---

## 🎯 Next Steps

Once Phase 1 is complete, we'll move to:
1. **Phase 2**: Migrate authentication and basic CRUD operations
2. **Phase 3**: Migrate all features (pets, posts, tracking, shopping)
3. **Phase 4**: Testing and optimization

Ready to start Phase 1? Let me know when you want to begin! 