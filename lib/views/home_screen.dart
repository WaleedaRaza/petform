import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/app_state_provider.dart';
import '../services/supabase_auth_service.dart';
import '../widgets/status_bar.dart';
import '../widgets/video_background.dart';
import 'community_feed_screen.dart';
import 'ask_ai_screen.dart';
import 'shopping_screen.dart';
import 'enhanced_tracking_screen.dart';
import 'profile_settings_screen.dart';
import 'welcome_screen.dart';
import 'pet_profile_creation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isInitialized = false;
  final GlobalKey _statusBarKey = GlobalKey();
  double _statusBarHeight = 0;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAppState();
      _measureStatusBar();
    });
  }

  void _measureStatusBar() {
    final context = _statusBarKey.currentContext;
    if (context != null) {
      final box = context.findRenderObject() as RenderBox?;
      if (box != null && mounted) {
        setState(() {
          _statusBarHeight = box.size.height;
        });
      }
    }
  }

  Future<void> _initializeAppState() async {
    if (_isInitialized) return;
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    await appState.initialize();
    
    // Check if user has pets and prompt to create one if not
    if (mounted && appState.pets.isEmpty) {
      _showPetCreationPrompt();
    }
    
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _showPetCreationPrompt() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: const Text(
            'Welcome to Petform! 🐾',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Let\'s get started by creating a profile for your first pet. This will help personalize your experience.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PetProfileCreationScreen(),
                  ),
                );
              },
              child: const Text(
                'Create Pet Profile',
                style: TextStyle(color: Colors.orange),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Skip for Now',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = SupabaseAuthService().currentUser != null;
    if (!isLoggedIn) {
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
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        children: [
          const VideoBackground(
            videoPath: 'lib/assets/animation2.mp4',
            child: SizedBox.shrink(),
          ),
          const StatusBar(),
          Padding(
            padding: const EdgeInsets.only(top: 225), // Move main content down by 100 pixels
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