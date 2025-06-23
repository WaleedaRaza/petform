import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/app_state_provider.dart';
import '../widgets/status_bar.dart';
import 'community_feed_screen.dart';
import 'ask_ai_screen.dart';
import 'shopping_screen.dart';
import 'enhanced_tracking_screen.dart';
import 'profile_settings_screen.dart';
import 'welcome_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isInitialized = false;

  static final List<Widget> _pages = <Widget>[
    const CommunityFeedScreen(),
    const AskAiScreen(),
    const ShoppingScreen(),
    const EnhancedTrackingScreen(),
    const ProfileSettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Defer initialization to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAppState();
    });
  }

  Future<void> _initializeAppState() async {
    if (_isInitialized) return; // Prevent multiple initializations
    
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    await appState.initialize();
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

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

    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          const StatusBar(),
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
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