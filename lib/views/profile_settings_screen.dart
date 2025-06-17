import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'welcome_screen.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Email: ${userProvider.email ?? 'N/A'}'),
            ElevatedButton(
              onPressed: () {
                userProvider.clearUser();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WelcomeScreen()));
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}