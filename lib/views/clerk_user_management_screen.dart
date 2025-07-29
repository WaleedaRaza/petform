import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/clerk_config.dart';
import '../models/clerk_error.dart';

class ClerkUserManagementScreen extends StatefulWidget {
  const ClerkUserManagementScreen({Key? key}) : super(key: key);

  @override
  State<ClerkUserManagementScreen> createState() => _ClerkUserManagementScreenState();
}

class _ClerkUserManagementScreenState extends State<ClerkUserManagementScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // For now, let's simulate loading users since Clerk's API is complex
      // In a real implementation, you'd fetch from Clerk's API
      final mockUsers = [
        {
          'id': 'user_1',
          'email_addresses': [
            {
              'email_address': 'test1@example.com',
              'verification': {'status': 'verified'},
            }
          ],
          'username': 'testuser1',
          'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        },
        {
          'id': 'user_2',
          'email_addresses': [
            {
              'email_address': 'test2@example.com',
              'verification': {'status': 'unverified'},
            }
          ],
          'username': 'testuser2',
          'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        },
      ];
      
      setState(() {
        _users = mockUsers;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading users: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteUser(String userId) async {
    try {
      // For now, let's simulate user deletion
      // In a real implementation, you'd call Clerk's API
      setState(() {
        _users.removeWhere((user) => user['id'] == userId);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting user: $e')),
        );
      }
    }
  }

  String _getUserEmail(Map<String, dynamic> user) {
    final emailAddresses = user['email_addresses'] as List?;
    if (emailAddresses?.isNotEmpty == true) {
      return emailAddresses!.first['email_address'] ?? 'No email';
    }
    return user['email_address'] ?? 'No email';
  }

  String _getUserStatus(Map<String, dynamic> user) {
    final emailAddresses = user['email_addresses'] as List?;
    if (emailAddresses?.isNotEmpty == true) {
      final emailAddress = emailAddresses!.first;
      return emailAddress['verification']?['status'] ?? 'Unknown';
    }
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
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
                      const Icon(Icons.people, size: 32, color: Color(0xFF3B82F6)),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Clerk Users',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_users.length} users found',
                            style: const TextStyle(
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

              // Error message
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 14,
                    ),
                  ),
                ),

              // Users list
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _users.isEmpty
                        ? const Center(
                            child: Text(
                              'No users found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _users.length,
                            itemBuilder: (context, index) {
                              final user = _users[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFF3B82F6),
                                    child: Text(
                                      _getUserEmail(user).substring(0, 1).toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    _getUserEmail(user),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('ID: ${user['id']}'),
                                      Text('Status: ${_getUserStatus(user)}'),
                                      if (user['username'] != null)
                                        Text('Username: ${user['username']}'),
                                    ],
                                  ),
                                  trailing: PopupMenuButton(
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Delete User'),
                                          ],
                                        ),
                                      ),
                                    ],
                                    onSelected: (value) {
                                      if (value == 'delete') {
                                        _showDeleteConfirmation(user);
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
          'Are you sure you want to delete ${_getUserEmail(user)}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteUser(user['id']);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 