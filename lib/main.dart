import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'services/api_service.dart';
import 'views/welcome_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        Provider(create: (context) => ApiService()),
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
        brightness: Brightness.dark, // Enable dark mode
        colorScheme: ColorScheme.dark(
          primary: Colors.blue[800]!, // Darker blue for primary color
          secondary: Colors.orange, // Orange as accent color
          surface: Colors.grey[900]!, // Unified dark grey for surfaces
        ),
        scaffoldBackgroundColor: Colors.grey[900], // Unified dark grey background
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900], // Match headers to scaffold
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.grey[850], // Consistent dark grey for dock
          selectedItemColor: Colors.orange, // Orange for selected items
          unselectedItemColor: Colors.grey[400], // Light grey for unselected
          selectedLabelStyle: const TextStyle(color: Colors.orange),
          unselectedLabelStyle: TextStyle(color: Colors.grey[400]),
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          menuStyle: MenuStyle(
            backgroundColor: WidgetStateProperty.all(Colors.grey[800]), // Dark grey for dropdowns
            surfaceTintColor: WidgetStateProperty.all(Colors.grey[800]),
          ),
          textStyle: const TextStyle(color: Colors.white), // White text in dropdowns
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[800], // Dark grey for text boxes
          hintStyle: TextStyle(color: Colors.grey[400]), // Light grey hints
          labelStyle: const TextStyle(color: Colors.white), // White labels
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[700]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[700]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange), // Orange focus border
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.grey[850], // Slightly lighter grey for cards
          surfaceTintColor: Colors.grey[850],
        ),
        popupMenuTheme: PopupMenuThemeData(
          color: Colors.grey[800], // Dark grey for popup menus
          textStyle: const TextStyle(color: Colors.white),
          surfaceTintColor: Colors.grey[800],
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.orange, // Orange FAB
          foregroundColor: Colors.white, // White icon on FAB
        ),
        textTheme: ThemeData.dark().textTheme.copyWith(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          headlineLarge: TextStyle(color: Colors.white),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}