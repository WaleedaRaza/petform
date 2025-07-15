import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'providers/app_state_provider.dart';
import 'providers/feed_provider.dart';
import 'services/api_service.dart';
import 'views/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/user.dart';
import 'models/pet.dart';
import 'models/shopping_item.dart';
import 'models/tracking_metric.dart';
import 'models/post.dart';
import 'models/reddit_post.dart';
import 'models/username_reservation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kDebugMode) {
    print('Main: Initializing Firebase...');
  }
  
  // Check if Firebase is already initialized
  try {
    Firebase.app();
    if (kDebugMode) {
      print('Main: Firebase already initialized');
    }
  } catch (e) {
    // Firebase not initialized, initialize it
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (kDebugMode) {
    print('Main: Firebase initialized successfully');
    print('Main: Firebase app name: ${Firebase.app().name}');
    print('Main: Firebase app options: ${Firebase.app().options.projectId}');
  }
  }

  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(PetAdapter());
  Hive.registerAdapter(ShoppingItemAdapter());
  Hive.registerAdapter(TrackingMetricAdapter());
  Hive.registerAdapter(TrackingEntryAdapter());
  Hive.registerAdapter(PostAdapter());
  Hive.registerAdapter(CommentAdapter());
  Hive.registerAdapter(RedditPostAdapter());
  Hive.registerAdapter(UsernameReservationAdapter());

  // Open boxes for each model
  await Hive.openBox<User>('users');
  await Hive.openBox<Pet>('pets');
  await Hive.openBox<ShoppingItem>('shoppingItems');
  await Hive.openBox<TrackingMetric>('trackingMetrics');
  await Hive.openBox<Post>('posts');
  await Hive.openBox<UsernameReservation>('usernameReservations');
  await Hive.openBox<Comment>('comments');
  await Hive.openBox<RedditPost>('redditPosts');
  
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
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: Colors.blue[800]!,
          secondary: Colors.orange,
          surface: Colors.grey[900]!,
        ),
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.grey[850],
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.grey[400],
          selectedLabelStyle: const TextStyle(color: Colors.orange),
          unselectedLabelStyle: TextStyle(color: Colors.grey[400]),
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          menuStyle: MenuStyle(
            backgroundColor: WidgetStateProperty.all(Colors.grey[800]),
            surfaceTintColor: WidgetStateProperty.all(Colors.grey[800]),
          ),
          textStyle: const TextStyle(color: Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[800],
          hintStyle: TextStyle(color: Colors.grey[400]),
          labelStyle: const TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[700]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[700]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.grey[850],
          surfaceTintColor: Colors.grey[850],
        ),
        popupMenuTheme: PopupMenuThemeData(
          color: Colors.grey[800],
          textStyle: const TextStyle(color: Colors.white),
          surfaceTintColor: Colors.grey[800],
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        textTheme: ThemeData.dark().textTheme.copyWith(
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white70),
              headlineLarge: TextStyle(color: Colors.white),
            ),
      ),
      home: const BackdropWrapper(child: WelcomeScreen()),
    );
  }
}

class BackdropWrapper extends StatelessWidget {
  final Widget child;
  
  const BackdropWrapper({super.key, required this.child});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/petform_backdrop.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: child,
      ),
    );
  }
}