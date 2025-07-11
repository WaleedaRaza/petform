import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/app_state_provider.dart';
import '../widgets/status_bar.dart';
import '../widgets/video_background.dart';
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
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
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