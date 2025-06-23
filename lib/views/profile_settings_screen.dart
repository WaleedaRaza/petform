import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/pet.dart';
import '../models/post.dart';
import '../providers/user_provider.dart';
import '../providers/app_state_provider.dart';
import '../providers/theme_provider.dart';
import 'welcome_screen.dart';
import 'pet_profile_creation_screen.dart';
import '../widgets/rounded_button.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  Future<List<Post>> _loadUserPosts(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final posts = jsonDecode(prefs.getString('posts') ?? '[]') as List;
    return posts
        .map((p) => Post.fromJson(p as Map<String, dynamic>))
        .where((post) => post.author == email)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header with title
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Profile',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // User Info Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userProvider.email ?? 'N/A',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Pet Owner',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Settings Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Toggle dark/light theme'),
                    value: themeProvider.themeMode == ThemeMode.dark,
                    onChanged: (value) => themeProvider.toggleTheme(),
                    activeColor: Theme.of(context).colorScheme.secondary,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Pet Management Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Pets',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PetProfileCreationScreen(),
                            ),
                          );
                          if (result == true) {
                            setState(() {}); // Refresh the pets list
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Pet'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Consumer<AppStateProvider>(
                    builder: (context, appState, child) {
                      if (appState.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      final pets = appState.pets;
                      
                      if (pets.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Icon(
                                Icons.pets,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Pets Added',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add your first pet to start tracking their health and activities',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return Column(
                        children: pets.map((pet) => _buildPetCard(context, pet)).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // User Activity Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Activity',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<Post>>(
                    future: _loadUserPosts(userProvider.email ?? ''),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      final posts = snapshot.data ?? [];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Posts (${posts.length})',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (posts.isEmpty)
                            Text(
                              'No posts yet',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[500],
                              ),
                            )
                          else
                            ...posts.take(3).map((post) => Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '• ${post.title}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            )),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Account Actions Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: RoundedButton(
                      text: 'Sign Out',
                      onPressed: () async {
                        try {
                          await userProvider.signOut();
                          if (!mounted) return;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Sign out failed: $e')),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: RoundedButton(
                      text: 'Delete Account',
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Account'),
                            content: const Text(
                              'Are you sure you want to delete your account? This action cannot be undone.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                        
                        if (confirm == true) {
                          try {
                            await userProvider.deleteAccount();
                            if (!mounted) return;
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Delete account failed: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildPetCard(BuildContext context, Pet pet) {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: _getPetTypeColor(pet.species),
                  child: Icon(
                    _getPetTypeIcon(pet.species),
                    color: Colors.white,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        pet.species,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[400],
                        ),
                      ),
                      if (pet.breed != null && pet.breed!.isNotEmpty)
                        Text(
                          pet.breed!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) async {
                    switch (value) {
                      case 'edit':
                        // TODO: Navigate to edit pet screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Edit functionality coming soon!')),
                        );
                        break;
                      case 'delete':
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Remove Pet'),
                            content: Text('Are you sure you want to remove ${pet.name}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Remove',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                        
                        if (confirm == true) {
                          try {
                            await appState.removePet(pet);
                            setState(() {}); // Refresh the list
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Removed ${pet.name}')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to remove pet: $e')),
                            );
                          }
                        }
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Remove', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (pet.customFields?.isNotEmpty ?? false) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Details',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              ...pet.customFields!.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '${entry.key}: ${entry.value}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[400],
                  ),
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Color _getPetTypeColor(String species) {
    switch (species.toLowerCase()) {
      case 'dog':
        return Colors.blue;
      case 'cat':
        return Colors.orange;
      case 'bird':
        return Colors.green;
      case 'fish':
        return Colors.cyan;
      case 'hamster':
      case 'guinea pig':
      case 'rabbit':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getPetTypeIcon(String species) {
    switch (species.toLowerCase()) {
      case 'dog':
        return Icons.pets;
      case 'cat':
        return Icons.pets;
      case 'bird':
        return Icons.flutter_dash;
      case 'fish':
        return Icons.water;
      case 'hamster':
      case 'guinea pig':
      case 'rabbit':
        return Icons.pets;
      default:
        return Icons.pets;
    }
  }
}
