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
                            feedProvider.fetchPosts(context);
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
                            feedProvider.fetchPosts(context);
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
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh saved posts when this screen becomes visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      appState.refreshSavedPosts();
    });
  }
  
  Future<void> _initializeAppState() async {
    if (_isInitialized) return; // Prevent multiple initializations
    
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);
    
    await appState.initialize();
    await feedProvider.fetchPosts(context);
    
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Consumer2<FeedProvider, AppStateProvider>(
        builder: (context, feedProvider, appState, child) {
        return VideoBackground(
          videoPath: 'lib/assets/animation2.mp4',
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: RefreshIndicator(
              onRefresh: () async {
                await Future.wait([
                  feedProvider.fetchPosts(context),
                  appState.refresh(),
                ]);
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
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
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
              },
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
            ),
          );
        },
    );
  }
}