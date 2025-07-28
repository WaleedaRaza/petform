import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/feed_provider.dart';
import '../providers/app_state_provider.dart';
import '../widgets/enhanced_post_card.dart';
import '../widgets/video_background.dart';
import 'create_post_screen.dart';
import '../models/pet_types.dart';
import '../models/post.dart';
import '../models/reddit_post.dart';
import '../services/api_service.dart';

class FeedFilter extends StatelessWidget {
  const FeedFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final feedProvider = Provider.of<FeedProvider>(context);
    final dropdownPetTypes = ['All', ...petTypes];
    const postTypes = ['All', 'Reddit', 'Community'];

    return Container(
      padding: const EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Posts',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pet Type',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[700]!),
                      ),
                      child: DropdownButton<String>(
                        value: feedProvider.selectedPetType,
                        isExpanded: true,
                        underline: const SizedBox.shrink(),
                        dropdownColor: Colors.grey[800],
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        menuMaxHeight: 400,
                        items: dropdownPetTypes.map((type) {
                          return DropdownMenuItem(value: type, child: Text(type));
                        }).toList(),
                        onChanged: (value) {
                          print('Pet type changed to: $value');
                          if (value != null) {
                            feedProvider.setPetType(value);
                            feedProvider.fetchPosts(context, forceRefresh: false); // Use cache for filters
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Post Type',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[700]!),
                      ),
                      child: DropdownButton<String>(
                        value: feedProvider.selectedPostType,
                        isExpanded: true,
                        underline: const SizedBox.shrink(),
                        dropdownColor: Colors.grey[800],
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        menuMaxHeight: 200,
                        items: postTypes.map((type) {
                          return DropdownMenuItem(value: type, child: Text(type));
                        }).toList(),
                        onChanged: (value) {
                          print('Post type changed to: $value');
                          if (value != null) {
                            feedProvider.setPostType(value);
                            feedProvider.fetchPosts(context, forceRefresh: false); // Use cache for filters
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CommunityFeedScreen extends StatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  State<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Defer initialization to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAppState();
    });
  }

  Future<void> _initializeAppState() async {
    if (_isInitialized) return;
    
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);
    
    await appState.initialize();
    await feedProvider.fetchPosts(context, forceRefresh: false); // Use cache for initialization
    
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('CommunityFeedScreen: Building screen, _isInitialized: $_isInitialized');
    }
    
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Consumer2<FeedProvider, AppStateProvider>(
        builder: (context, feedProvider, appState, child) {
        if (kDebugMode) {
          print('CommunityFeedScreen: Consumer builder called, posts count: ${feedProvider.posts.length}');
        }
        
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: VideoBackground(
            videoPath: 'lib/assets/animation2.mp4',
            child: Column(
              children: [
                // Add Post button at the top without padding
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ElevatedButton.icon(
                    onPressed: feedProvider.isLoading ? null : () async {
                      if (kDebugMode) {
                        print('CommunityFeedScreen: Add Post button pressed - starting navigation');
                      }
                      
                      // Temporary test to see if button is clickable
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Button pressed!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                      
                      try {
                        if (kDebugMode) {
                          print('CommunityFeedScreen: Navigating to CreatePostScreen');
                        }
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CreatePostScreen()),
                        );
                        if (kDebugMode) {
                          print('CommunityFeedScreen: Returned from CreatePostScreen with result: $result');
                        }
                        // If a post was created, refresh the feed
                        if (result == true) {
                          await feedProvider.fetchPosts(context, forceRefresh: false); // Use cache after creating post
                          if (kDebugMode) {
                            print('Post created, refreshed feed. Posts count: ${feedProvider.posts.length}');
                          }
                        }
                      } catch (e) {
                        if (kDebugMode) {
                          print('CommunityFeedScreen: Error creating post: $e');
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: feedProvider.isLoading 
                          ? Colors.grey[600] 
                          : Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(
                      feedProvider.isLoading ? 'Loading...' : 'Add Post',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                // Feed content
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      try {
                        await Future.wait([
                          feedProvider.fetchPosts(context, forceRefresh: true), // Force refresh Reddit posts
                          appState.initialize(),
                        ]);
                      } catch (e) {
                        if (kDebugMode) {
                          print('CommunityFeedScreen: Error during refresh: $e');
                        }
                      }
                    },
                    child: Column(
                      children: [
                        const FeedFilter(),
                        Expanded(
                          child: feedProvider.isLoading
                              ? ListView.builder(
                                  itemCount: 5,
                                  itemBuilder: (context, index) {
                                    return Shimmer.fromColors(
                                      baseColor: Colors.grey[700]!,
                                      highlightColor: Colors.grey[600]!,
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        height: 200,
                                        decoration: BoxDecoration(
                                        color: Colors.grey[850],
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : feedProvider.posts.isEmpty
                                  ? const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.feed,
                                            size: 64,
                                            color: Colors.grey,
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            'No posts found for this filter.',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Try adjusting your filters or check back later!',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: feedProvider.posts.length,
                                      itemBuilder: (context, index) {
                                        if (kDebugMode) {
                                          print('CommunityFeedScreen: Building post ${index + 1}/${feedProvider.posts.length}: ${feedProvider.posts[index].title}');
                                        }
                                        return EnhancedPostCard(
                                          post: feedProvider.posts[index],
                                        );
                                      },
                                      padding: const EdgeInsets.only(top: 4, bottom: 16),
                                    ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: feedProvider.isLoading ? null : () async {
              if (kDebugMode) {
                print('CommunityFeedScreen: Add Post button pressed from FAB');
              }
              try {
                final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreatePostScreen()),
                );
                // If a post was created, refresh the feed
                if (result == true) {
                  await feedProvider.fetchPosts(context);
                  if (kDebugMode) {
                    print('Post created, refreshed feed. Posts count: ${feedProvider.posts.length}');
                  }
                }
              } catch (e) {
                if (kDebugMode) {
                  print('CommunityFeedScreen: Error creating post: $e');
                }
              }
            },
            backgroundColor: feedProvider.isLoading 
                ? Colors.grey[600] 
                : Theme.of(context).colorScheme.secondary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: Text(
              feedProvider.isLoading ? 'Loading...' : 'Add Post',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        );
        },
    );
  }
}