import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/clerk_service.dart';
import '../services/clerk_token_service.dart';

class ClerkDebugScreen extends StatefulWidget {
  const ClerkDebugScreen({Key? key}) : super(key: key);

  @override
  State<ClerkDebugScreen> createState() => _ClerkDebugScreenState();
}

class _ClerkDebugScreenState extends State<ClerkDebugScreen> {
  Map<String, dynamic> _debugInfo = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  Future<void> _loadDebugInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user info
      final currentUser = ClerkService.instance.currentUser;
      final isSignedIn = ClerkService.instance.isSignedIn;
      final currentUserId = ClerkService.instance.currentUserId;
      final currentUserEmail = ClerkService.instance.currentUserEmail;
      final currentUsername = ClerkService.instance.currentUsername;

      // Get token info
      final token = await ClerkTokenService.getToken();
      final userData = await ClerkTokenService.getUser();
      final isAuthenticated = await ClerkTokenService.isAuthenticated();

      // Token validation
      bool isTokenValid = false;
      DateTime? tokenExpiration;
      if (token != null) {
        isTokenValid = ClerkTokenService.isTokenValid(token);
        tokenExpiration = ClerkTokenService.getTokenExpiration(token);
      }

      setState(() {
        _debugInfo = {
          'Clerk Service': {
            'Is Signed In': isSignedIn,
            'Current User ID': currentUserId,
            'Current User Email': currentUserEmail,
            'Current Username': currentUsername,
            'Current User Data': currentUser?.toString() ?? 'None',
          },
          'Token Service': {
            'Has Token': token != null,
            'Token Valid': isTokenValid,
            'Token Expiration': tokenExpiration?.toString() ?? 'None',
            'Is Authenticated': isAuthenticated,
            'User Data Stored': userData != null,
          },
          'Token Details': {
            'Token Length': token?.length ?? 0,
            'Token Preview': token != null ? '${token.substring(0, 20)}...' : 'None',
          },
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _debugInfo = {
          'Error': {
            'Message': e.toString(),
          },
        };
        _isLoading = false;
      });
    }
  }

  Future<void> _clearAllData() async {
    try {
      await ClerkTokenService.clearAll();
      await ClerkService.instance.signOut();
      await _loadDebugInfo();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data cleared')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error clearing data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Clerk Debug'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDebugInfo,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF3B82F6),
              Color(0xFF60A5FA),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.bug_report, size: 32, color: Color(0xFF3B82F6)),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Clerk Debug Info',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Authentication state and token info',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Debug info
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: _debugInfo.length,
                        itemBuilder: (context, index) {
                          final section = _debugInfo.entries.elementAt(index);
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ExpansionTile(
                              title: Text(
                                section.key,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: section.value.entries.map((entry) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 120,
                                              child: Text(
                                                '${entry.key}:',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFF6B7280),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                entry.value.toString(),
                                                style: const TextStyle(
                                                  fontFamily: 'monospace',
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              // Action buttons
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _loadDebugInfo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                      ),
                      child: const Text('Refresh'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _clearAllData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Clear All'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 