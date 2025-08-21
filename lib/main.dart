import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'providers/app_state_provider.dart';
import 'providers/feed_provider.dart';
import 'services/api_service.dart';
import 'services/supabase_service.dart';
import 'services/auth0_jwt_service.dart';
import 'views/welcome_screen.dart';
import 'views/main_screen.dart';
import 'views/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  print('Petform: App starting...'); // Simple debug print
  try {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kDebugMode) {
      print('Main: Flutter binding initialized');
      print('Main: Starting integrated Auth0 + Supabase initialization...');
  }
  
    // Initialize Auth0 JWT service
    try {
      await Auth0JWTService.instance.initialize();
      if (kDebugMode) {
        print('Main: Auth0 JWT service initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Main: Error initializing Auth0 JWT service: $e');
      }
      // Continue without Auth0 for now
    }

    // Initialize Supabase (Auth0 will be handled as 3rd party provider)
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
      
      if (kDebugMode) {
        print('Main: Supabase initialized successfully');
        print('Main: Supabase URL: ${SupabaseConfig.url}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Main: Error initializing Supabase: $e');
      }
      // Continue without Supabase for now
    }
    
    if (kDebugMode) {
      print('Main: Starting app...');
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
    
    if (kDebugMode) {
      print('Main: App started successfully');
    }
  } catch (e, stackTrace) {
    if (kDebugMode) {
      print('Main: Critical error during app startup: $e');
      print('Main: Stack trace: $stackTrace');
    }
    // Re-throw to see the error in the console
    rethrow;
  }
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
      // Handle deep links for email confirmation
      onGenerateRoute: (settings) {
        if (kDebugMode) {
          print('Main: Deep link received: ${settings.name}');
        }
        
        // Handle routes
        switch (settings.name) {
          case '/auth0-login':
            return MaterialPageRoute(
              builder: (context) => const BackdropWrapper(child: WelcomeScreen()),
            );

          case '/home':
            return MaterialPageRoute(
              builder: (context) => const BackdropWrapper(child: HomeScreen()),
            );
        }
        
        // Handle email confirmation links
        if (settings.name?.startsWith('com.waleedraza.petform://') == true) {
          if (kDebugMode) {
            print('Main: Handling petform deep link: ${settings.name}');
          }
          // Navigate to welcome screen which will handle auth state
          return MaterialPageRoute(
            builder: (context) => const BackdropWrapper(child: WelcomeScreen()),
          );
        }
        
        return null;
      },
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
          color: Colors.black,
        ),
        child: child,
      ),
    );
  }
}