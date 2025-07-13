import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // Added for kDebugMode

import '../models/pet.dart';
import '../models/post.dart';
import '../providers/user_provider.dart';
import '../providers/app_state_provider.dart';
import '../services/api_service.dart';
import '../services/image_service.dart';
import '../widgets/video_background.dart';
import 'welcome_screen.dart';
import 'pet_profile_creation_screen.dart';
import 'edit_pet_screen.dart';
import '../widgets/rounded_button.dart';
import 'post_detail_screen.dart';
import 'saved_posts_screen.dart';
import '../services/firebase_auth_service.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();

  Future<List<Post>> _loadUserPosts(String email) async {
    final prefs = await SharedPreferences.getInstance();
    // Use global posts key to get all posts, then filter by author
    final posts = jsonDecode(prefs.getString('global_posts') ?? '[]') as List;
    return posts
        .map((p) => Post.fromJson(p as Map<String, dynamic>))
        .where((post) => post.author == email)
        .toList();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = _authService.currentUser;
    final userEmail = currentUser?.email ?? 'N/A';
    final userDisplayName = currentUser?.displayName ?? userEmail;

    return VideoBackground(
      videoPath: 'lib/assets/animation2.mp4',
      child: Scaffold(
        backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                            child: Text(
                              userDisplayName.isNotEmpty ? userDisplayName[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                          color: Colors.white,
                              ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                  userDisplayName,
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

                      ListTile(
                        leading: const Icon(Icons.edit),
                        title: const Text('Edit Display Name'),
                        subtitle: Text(currentUser?.displayName ?? 'Not set'),
                        onTap: () => _showEditDisplayNameDialog(context),
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
                        future: _loadUserPosts(userEmail),
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
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => PostDetailScreen(post: post),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey[300]!),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                post.title,
                                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                post.content.length > 100 
                                                  ? '${post.content.substring(0, 100)}...' 
                                                  : post.content,
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: Colors.grey[600],
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(Icons.comment, size: 14, color: Colors.grey[500]),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${post.comments.length} comments',
                                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                      color: Colors.grey[500],
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Text(
                                                    _formatDate(post.createdAt),
                                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                      color: Colors.grey[500],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
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
          
          const SizedBox(height: 16),
          
          // Saved Posts Section
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
                        'Saved Posts',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Consumer<AppStateProvider>(
                        builder: (context, appState, child) {
                          return Text(
                            '${appState.savedPostsCount} saved',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Consumer<AppStateProvider>(
                    builder: (context, appState, child) {
                      final savedPosts = appState.savedPosts;
                      
                      if (savedPosts.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Icon(
                                Icons.bookmark_border,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Saved Posts',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Save posts from the community feed to view them here later',
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
                        children: savedPosts.take(5).map((post) => _buildSavedPostCard(context, post, appState)).toList(),
                      );
                    },
                  ),
                  if (Provider.of<AppStateProvider>(context, listen: false).savedPosts.length > 5)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Center(
                        child: TextButton(
                          onPressed: () => _showAllSavedPosts(context),
                          child: const Text('View All Saved Posts'),
                        ),
                      ),
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
                              await _authService.signOut();
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
                              text: 'Reset All Data',
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Reset All Data'),
                                    content: const Text(
                                      'This will clear all your pets, posts, and saved data. This action cannot be undone.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text(
                                          'Reset',
                                          style: TextStyle(color: Colors.orange),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                
                                if (confirm == true) {
                                  try {
                                    final appState = Provider.of<AppStateProvider>(context, listen: false);
                                    await appState.clearAllUserData();
                                    setState(() {}); // Refresh the UI
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('All data has been reset')),
                                    );
                                  } catch (e) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Reset failed: $e')),
                                    );
                                  }
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
                                await _authService.deleteAccount();
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
            ],
          ),
        ),
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
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditPetScreen(pet: pet),
                          ),
                        );
                        if (result == true) {
                          setState(() {}); // Refresh the pets list
                        }
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

  Widget _buildSavedPostCard(BuildContext context, Post post, AppStateProvider appState) {
    final isReddit = post.postType == 'reddit';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _viewPost(context, post),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Post type indicator
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isReddit ? Colors.orange : Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isReddit ? Icons.reddit : Icons.forum,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                              isReddit ? 'Reddit' : 'Community',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                              'by ${post.author}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[500],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${post.petType} • ${_formatDate(post.createdAt)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[400],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) async {
                      switch (value) {
                        case 'view':
                          _viewPost(context, post);
                          break;
                        case 'unsave':
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Unsave Post'),
                              content: const Text('Are you sure you want to unsave this post?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Unsave',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                          
                          if (confirm == true) {
                            try {
                              await appState.unsavePost(post);
                              setState(() {}); // Refresh the list
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Unsaved "${post.title}"')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to unsave post: $e')),
                              );
                            }
                          }
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility),
                            SizedBox(width: 8),
                            Text('View'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'unsave',
                        child: Row(
                          children: [
                            Icon(Icons.bookmark_remove, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Unsave', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _viewPost(BuildContext context, Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(post: post),
      ),
    );
  }

  void _showAllSavedPosts(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SavedPostsScreen(),
      ),
    );
  }

  void _showEditDisplayNameDialog(BuildContext context) {
    final controller = TextEditingController(text: _authService.currentUser?.displayName ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Display Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Display Name',
            border: OutlineInputBorder(),
            helperText: 'Your display name will be visible to other users',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                try {
                  await _authService.updateDisplayName(controller.text.trim());
                  if (context.mounted) {
                    Navigator.pop(context);
                    setState(() {}); // Refresh UI
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Display name updated successfully')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update display name: $e')),
                    );
                  }
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Display name cannot be empty')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _cleanupDuplicateUsernames(BuildContext context) async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      await apiService.cleanupDuplicateUsernames();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Duplicate usernames cleaned up successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cleaning up usernames: $e')),
        );
      }
    }
  }

}
