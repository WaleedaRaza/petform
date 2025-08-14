import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/pet.dart';
import '../models/post.dart';
import '../models/shopping_item.dart';
import '../services/supabase_service.dart';
import '../widgets/video_background.dart';
import '../widgets/enhanced_post_card.dart';
import '../widgets/shopping_item_card.dart';
import 'post_detail_screen.dart';
import 'pet_detail_screen.dart';

class UserDetailScreen extends StatefulWidget {
  final String username;
  final String? userId;

  const UserDetailScreen({
    super.key,
    required this.username,
    this.userId,
  });

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Pet> _userPets = [];
  List<Post> _userPosts = [];
  List<ShoppingItem> _userShoppingItems = [];
  bool _isLoading = true;
  String? _userDisplayName;
  bool _isFollowing = false;
  int _followerCount = 0;
  int _followingCount = 0;
  bool _isOwnProfile = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load user profile to get display name
      _userDisplayName = widget.username;

      // Check if this is the current user's profile
      final currentUserId = await SupabaseService.getCurrentUserId();
      _isOwnProfile = currentUserId == widget.userId;

      // Load user's pets (public data - everyone can see everyone's pets)
      if (widget.userId != null) {
        try {
          if (_isOwnProfile) {
            // Use current user's method for own profile
            final petsData = await SupabaseService.getPets();
            _userPets = petsData.map((p) => Pet.fromJson(p)).toList();
          } else {
            // Use public method for other users' profiles
            final petsData = await SupabaseService.getPetsByUserId(widget.userId!);
            _userPets = petsData.map((p) => Pet.fromJson(p)).toList();
          }
        } catch (e) {
          if (kDebugMode) print('Error loading pets: $e');
          _userPets = [];
        }
      } else {
        _userPets = [];
      }

      // Load user's posts
      try {
        final postsData = await SupabaseService.getPosts();
        final posts = postsData.map((p) => Post.fromJson(p)).toList();
        _userPosts = posts
            .where((post) => 
                post.postType == 'community' && 
                post.author == widget.username)
            .toList();
      } catch (e) {
        if (kDebugMode) print('Error loading posts: $e');
        _userPosts = [];
      }

      // Load user's shopping items (public data - everyone can see everyone's shopping lists)
      if (widget.userId != null) {
        try {
          if (kDebugMode) {
            print('UserDetailScreen: Loading shopping items for user ${widget.username} (ID: ${widget.userId})');
            print('UserDetailScreen: Is own profile: $_isOwnProfile');
          }
          
          if (_isOwnProfile) {
            // Use current user's method for own profile
            final shoppingData = await SupabaseService.getShoppingItems();
            _userShoppingItems = shoppingData;
            if (kDebugMode) {
              print('UserDetailScreen: Loaded ${_userShoppingItems.length} shopping items for own profile');
            }
          } else {
            // Use public method for other users' profiles
            _userShoppingItems = await SupabaseService.getShoppingItemsByUserId(widget.userId!);
            if (kDebugMode) {
              print('UserDetailScreen: Loaded ${_userShoppingItems.length} shopping items for other user');
            }
          }
        } catch (e) {
          if (kDebugMode) print('Error loading shopping items: $e');
          _userShoppingItems = [];
        }
      } else {
        _userShoppingItems = [];
        if (kDebugMode) print('UserDetailScreen: No userId provided, cannot load shopping items');
      }

      // Load follow information
      if (widget.userId != null) {
        try {
          _isFollowing = await SupabaseService.isFollowing(widget.userId!);
          _followerCount = await SupabaseService.getFollowerCount(widget.userId!);
          _followingCount = await SupabaseService.getFollowingCount(widget.userId!);
        } catch (e) {
          if (kDebugMode) print('Error loading follow data: $e');
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error loading user data: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _toggleFollow() async {
    if (widget.userId == null) return;

    try {
      setState(() => _isLoading = true);
      
      if (_isFollowing) {
        await SupabaseService.unfollowUser(widget.userId!);
        setState(() {
          _isFollowing = false;
          _followerCount = _followerCount > 0 ? _followerCount - 1 : 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unfollowed ${widget.username}')),
        );
      } else {
        await SupabaseService.followUser(widget.userId!);
        setState(() {
          _isFollowing = true;
          _followerCount++;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Following ${widget.username}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return VideoBackground(
      videoPath: 'assets/backdrop2.mp4',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(_userDisplayName ?? widget.username),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                icon: const Icon(Icons.pets),
                text: 'Pets (${_userPets.length})',
              ),
              Tab(
                icon: const Icon(Icons.article),
                text: 'Posts (${_userPosts.length})',
              ),
              Tab(
                icon: const Icon(Icons.shopping_cart),
                text: 'Shopping (${_userShoppingItems.length})',
              ),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // User Info Header
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                              child: Text(
                                widget.username.isNotEmpty 
                                    ? widget.username[0].toUpperCase() 
                                    : 'U',
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
                                    _userDisplayName ?? widget.username,
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
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _buildStatChip('${_userPets.length} Pets'),
                                      const SizedBox(width: 8),
                                      _buildStatChip('${_userPosts.length} Posts'),
                                      const SizedBox(width: 8),
                                      _buildStatChip('$_followerCount Followers'),
                                      const SizedBox(width: 8),
                                      _buildStatChip('$_followingCount Following'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Follow Button (only show for other users)
                  if (widget.userId != null && !_isOwnProfile)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _toggleFollow,
                          icon: Icon(_isFollowing ? Icons.person_remove : Icons.person_add),
                          label: Text(_isFollowing ? 'Unfollow' : 'Follow'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isFollowing 
                                ? Colors.grey[600] 
                                : Theme.of(context).colorScheme.secondary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  // Tab Content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildPetsTab(),
                        _buildPostsTab(),
                        _buildShoppingTab(),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildStatChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.secondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPetsTab() {
    if (_userPets.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No pets to show',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _userPets.length,
      itemBuilder: (context, index) {
        final pet = _userPets[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Text(
                pet.name[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              pet.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${pet.species} • ${pet.breed ?? 'Mixed breed'}'),
            trailing: pet.age != null
                ? Text(
                    '${pet.age}y old',
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                : null,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PetDetailScreen(pet: pet),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPostsTab() {
    if (_userPosts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No posts to show',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _userPosts.length,
      itemBuilder: (context, index) {
        final post = _userPosts[index];
        return EnhancedPostCard(
          post: post,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostDetailScreen(post: post),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildShoppingTab() {
    if (_userShoppingItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No shopping items to show',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _userShoppingItems.length,
      itemBuilder: (context, index) {
        final item = _userShoppingItems[index];
        return ShoppingItemCard(
          item: item,
          onToggleComplete: null, // Read-only for other users
          onEdit: null, // Read-only for other users
          onDelete: null, // Read-only for other users
        );
      },
    );
  }
}