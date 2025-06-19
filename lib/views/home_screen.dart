import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'community_feed_screen.dart';
import 'ask_ai_screen.dart';
import 'shopping_list_screen.dart';
import 'tracking_screen.dart';
import 'profile_settings_screen.dart';
import 'welcome_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const CommunityFeedScreen(),
    const AskAiScreen(),
    const ShoppingListScreen(),
    const TrackingScreen(),
    const ProfileSettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      print('HomeScreen: Navigated to index $index');
    });
  }

  @override
  Widget build(BuildContext context) {
    print('HomeScreen: Building UI, selectedIndex: $_selectedIndex');
    final userProvider = Provider.of<UserProvider>(context);
    
    // Redirect to WelcomeScreen only if user is not logged in and not a guest
    if (!userProvider.isLoggedIn) {
      return const WelcomeScreen();
    }

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.feed), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.question_answer), label: 'Ask AI'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Shopping'),
          BottomNavigationBarItem(icon: Icon(Icons.track_changes), label: 'Tracking'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}