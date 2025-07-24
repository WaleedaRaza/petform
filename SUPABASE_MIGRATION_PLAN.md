# 🚀 Supabase Migration Plan for Petform

## Overview
Complete migration from Firebase + Hive to Supabase for better scalability and to resolve Xcode storage issues.

## Current Issues
- Firestore storage crashes on iOS due to Xcode restrictions
- Hive local storage limitations
- Need for real-time features
- Better scalability requirements

## Migration Benefits
- ✅ No Xcode storage restrictions
- ✅ Real-time subscriptions
- ✅ Better scalability
- ✅ PostgreSQL database
- ✅ Built-in authentication
- ✅ Row Level Security (RLS)
- ✅ File storage included

---

## 📋 Phase 1: Setup & Infrastructure

### 1.1 Create Supabase Project
```bash
# Install Supabase CLI
npm install -g supabase

# Login to Supabase
supabase login

# Create new project
supabase projects create petform-app
```

### 1.2 Database Schema Design

#### Users Table
```sql
-- Enable RLS
ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

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

-- RLS Policies for profiles
CREATE POLICY "Users can view own profile" ON public.profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);
```

#### Pets Table
```sql
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

-- RLS Policies for pets
CREATE POLICY "Users can view own pets" ON public.pets
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own pets" ON public.pets
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own pets" ON public.pets
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own pets" ON public.pets
  FOR DELETE USING (auth.uid() = user_id);
```

#### Posts Table
```sql
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

-- RLS Policies for posts
CREATE POLICY "Anyone can view posts" ON public.posts
  FOR SELECT USING (true);

CREATE POLICY "Users can insert own posts" ON public.posts
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own posts" ON public.posts
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own posts" ON public.posts
  FOR DELETE USING (auth.uid() = user_id);
```

#### Comments Table
```sql
CREATE TABLE public.comments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  post_id UUID REFERENCES public.posts(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS Policies for comments
CREATE POLICY "Anyone can view comments" ON public.comments
  FOR SELECT USING (true);

CREATE POLICY "Users can insert own comments" ON public.comments
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own comments" ON public.comments
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own comments" ON public.comments
  FOR DELETE USING (auth.uid() = user_id);
```

#### Tracking Metrics Table
```sql
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

-- RLS Policies for tracking metrics
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
```

#### Tracking Entries Table
```sql
CREATE TABLE public.tracking_entries (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  metric_id UUID REFERENCES public.tracking_metrics(id) ON DELETE CASCADE NOT NULL,
  value DECIMAL(10,2) NOT NULL,
  notes TEXT,
  entry_date DATE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS Policies for tracking entries
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

### 1.3 Flutter Dependencies
```yaml
dependencies:
  supabase_flutter: ^2.3.4
  # Remove these after migration:
  # firebase_core: ^3.14.0
  # firebase_auth: ^5.3.3
  # hive: ^2.2.3
  # hive_flutter: ^1.1.0
```

---

## 📋 Phase 2: Core Migration

### 2.1 Supabase Configuration
```dart
// lib/config/supabase_config.dart
class SupabaseConfig {
  static const String url = 'YOUR_SUPABASE_URL';
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

### 2.2 Supabase Service
```dart
// lib/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;
  
  // Auth methods
  static Future<AuthResponse> signUp(String email, String password) async {
    return await client.auth.signUp(email: email, password: password);
  }
  
  static Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(email: email, password: password);
  }
  
  static Future<void> signOut() async {
    await client.auth.signOut();
  }
  
  // Database methods
  static Future<List<Map<String, dynamic>>> getPets() async {
    final response = await client
        .from('pets')
        .select()
        .eq('user_id', client.auth.currentUser!.id);
    return response;
  }
  
  static Future<void> createPet(Map<String, dynamic> petData) async {
    await client
        .from('pets')
        .insert(petData);
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
}
```

### 2.3 Updated Models
```dart
// lib/models/pet.dart (updated for Supabase)
class Pet {
  final String? id;
  final String userId;
  final String name;
  final String type;
  final String? breed;
  final DateTime? birthDate;
  final double? weight;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Pet({
    this.id,
    required this.userId,
    required this.name,
    required this.type,
    this.breed,
    this.birthDate,
    this.weight,
    this.imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    this.createdAt = createdAt ?? DateTime.now(),
    this.updatedAt = updatedAt ?? DateTime.now();

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      type: json['type'],
      breed: json['breed'],
      birthDate: json['birth_date'] != null 
          ? DateTime.parse(json['birth_date']) 
          : null,
      weight: json['weight']?.toDouble(),
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type,
      'breed': breed,
      'birth_date': birthDate?.toIso8601String(),
      'weight': weight,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
```

---

## 📋 Phase 3: Features Migration

### 3.1 Authentication Migration
- Replace Firebase Auth with Supabase Auth
- Update login/signup screens
- Handle email verification
- Password reset functionality

### 3.2 Data Migration Strategy
1. **Export current data** from Hive/SharedPreferences
2. **Transform data** to match Supabase schema
3. **Bulk insert** into Supabase
4. **Verify data integrity**

### 3.3 Real-time Features
- Live feed updates
- Real-time comments
- Live tracking data
- Instant notifications

---

## 📋 Phase 4: Testing & Polish

### 4.1 Testing Checklist
- [ ] Authentication flow
- [ ] CRUD operations for all entities
- [ ] Real-time subscriptions
- [ ] File uploads
- [ ] Offline handling
- [ ] Performance testing
- [ ] Error handling

### 4.2 Performance Optimization
- Implement caching strategies
- Optimize queries
- Add pagination
- Monitor performance

### 4.3 Error Handling
- Network errors
- Authentication errors
- Database errors
- File upload errors

---

## 🗓️ Timeline

### Week 1: Setup
- [ ] Create Supabase project
- [ ] Design and implement database schema
- [ ] Setup Flutter dependencies
- [ ] Create basic Supabase service

### Week 2: Core Migration
- [ ] Migrate authentication
- [ ] Update data models
- [ ] Create Supabase providers
- [ ] Basic CRUD operations

### Week 3: Features Migration
- [ ] Migrate pet management
- [ ] Migrate posts and comments
- [ ] Migrate tracking system
- [ ] Migrate shopping system

### Week 4: Testing & Polish
- [ ] Comprehensive testing
- [ ] Performance optimization
- [ ] Error handling
- [ ] Deployment preparation

---

## 🚨 Migration Risks & Mitigation

### Risks:
1. **Data loss during migration**
2. **Downtime during transition**
3. **Performance issues**
4. **User experience disruption**

### Mitigation:
1. **Backup all data** before migration
2. **Test thoroughly** in development
3. **Gradual rollout** with feature flags
4. **Rollback plan** ready

---

## 📊 Success Metrics

- [ ] Zero data loss
- [ ] Improved app performance
- [ ] No Xcode storage crashes
- [ ] Real-time features working
- [ ] User satisfaction maintained

---

## 🎯 Next Steps

1. **Create Supabase project**
2. **Design database schema**
3. **Setup development environment**
4. **Begin Phase 1 implementation**

Ready to start the migration? Let me know when you want to begin with Phase 1! 