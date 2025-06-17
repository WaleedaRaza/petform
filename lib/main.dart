import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'views/welcome_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
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
        scaffoldBackgroundColor: Colors.white,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
} 