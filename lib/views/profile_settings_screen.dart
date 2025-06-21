import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/pet.dart';
import '../models/post.dart';
import '../models/comment.dart' as user_comment;
import '../models/shopping_item.dart';
import '../providers/user_provider.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';
import 'welcome_screen.dart';
import '../widgets/rounded_button.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  Future<Pet?> _loadPet() async {
    final prefs = await SharedPreferences.getInstance();
    final pets = prefs.getString('pets') ?? '[]';
    final petsList = jsonDecode(pets) as List;
    if (petsList.isEmpty) return null;
    return Pet.fromJson(petsList.first as Map<String, dynamic>);
  }

  Future<List<Post>> _loadUserPosts(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final posts = jsonDecode(prefs.getString('posts') ?? '[]') as List;
    return posts
        .map((p) => Post.fromJson(p as Map<String, dynamic>))
        .where((post) => post.author == email)
        .toList();
  }

  Future<List<user_comment.Comment>> _loadUserComments(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final posts = jsonDecode(prefs.getString('posts') ?? '[]') as List;
    final comments = <user_comment.Comment>[];
    for (var post in posts) {
      final postComments = (post['comments'] as List<dynamic>?)
              ?.map((c) => user_comment.Comment.fromJson(c as Map<String, dynamic>))
              .where((comment) => comment.author == email)
              .toList() ??
          [];
      comments.addAll(postComments);
    }
    return comments;
  }

  Future<void> _addShoppingItem(BuildContext context, Pet pet) async {
    String name = '';
    String url = '';
    String category = '';
    int? quantity;
    String notes = '';
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Shopping Item'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(labelText: 'Item Name'),
                      onChanged: (value) => name = value,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(labelText: 'URL (Optional)'),
                      onChanged: (value) => url = value,
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Category (Optional)'),
                      onChanged: (value) => category = value,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Quantity (Optional)'),
                      onChanged: (value) => quantity = int.tryParse(value),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Notes (Optional)'),
                      onChanged: (value) => notes = value,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                TextButton(
                  onPressed: () {
                    if (name.trim().isNotEmpty) {
                      Navigator.pop(context, {
                        'name': name,
                        'url': url.isNotEmpty ? url : null,
                        'category': category.isNotEmpty ? category : null,
                        'quantity': quantity,
                        'notes': notes.isNotEmpty ? notes : null,
                      });
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      pet.shoppingList.add(ShoppingItem(
        name: result['name'] as String,
        url: result['url'] as String?,
        category: result['category'] as String?,
        quantity: result['quantity'] as int?,
        notes: result['notes'] as String?,
      ));
      await Provider.of<ApiService>(context, listen: false).updatePet(pet);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('User: ${userProvider.email ?? 'N/A'}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (value) => themeProvider.toggleTheme(),
            activeColor: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 16),
          FutureBuilder<Pet?>(
            future: _loadPet(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
              if (snapshot.hasError || !snapshot.hasData) return const Text('No pet added yet');
              final pet = snapshot.data!;
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Pet Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Name: ${pet.name}', style: const TextStyle(fontSize: 16)),
                Text('Species: ${pet.species}', style: const TextStyle(fontSize: 16)),
                if (pet.customFields?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 8),
                  const Text('Custom Fields', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ...?pet.customFields?.entries.map((e) => Text('${e.key}: ${e.value}', style: const TextStyle(fontSize: 16))),
                ],
              ]);
            },
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<Post>>(
            future: _loadUserPosts(userProvider.email ?? ''),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
              final posts = snapshot.data ?? [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your Posts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  if (posts.isEmpty)
                    const Text('No posts yet', style: TextStyle(fontSize: 16))
                  else
                    ...posts.map((post) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(post.title, style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 8),
                          ],
                        )),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<user_comment.Comment>>(
            future: _loadUserComments(userProvider.email ?? ''),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
              final comments = snapshot.data ?? [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your Comments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  if (comments.isEmpty)
                    const Text('No comments yet', style: TextStyle(fontSize: 16))
                  else
                    ...comments.map((comment) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(comment.content, style: const TextStyle(fontSize: 16)),
                            Text('Posted: ${comment.createdAt.day}/${comment.createdAt.month}/${comment.createdAt.year}',
                                style: const TextStyle(fontSize: 14)),
                            const SizedBox(height: 8),
                          ],
                        )),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          RoundedButton(
            text: 'Sign Out',
            onPressed: () async {
              try {
                await userProvider.signOut();
                if (!mounted) return;
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WelcomeScreen()));
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sign out failed: $e')),
                );
              }
            },
          ),
          const SizedBox(height: 16),
          RoundedButton(
            text: 'Delete Account',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Account'),
                  content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              
              if (confirm == true) {
                try {
                  await userProvider.deleteAccount();
                  if (!mounted) return;
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WelcomeScreen()));
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Delete account failed: $e')),
                  );
                }
              }
            },
          ),
        ]),
      ),
    );
  }
}
