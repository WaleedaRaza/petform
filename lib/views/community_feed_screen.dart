import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/api_service.dart';
import '../models/post.dart';
import 'post_detail_screen.dart';
import 'create_post_screen.dart';

class FeedProvider with ChangeNotifier {
  String _selectedPetType = 'All';
  String _selectedPostType = 'All';
  List<Post> _posts = [];
  bool _isLoading = false;

  String get selectedPetType => _selectedPetType;
  String get selectedPostType => _selectedPostType;
  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;

  void setPetType(String petType) {
    _selectedPetType = petType;
    notifyListeners();
  }

  void setPostType(String postType) {
    _selectedPostType = postType;
    notifyListeners();
  }

  Future<void> fetchPosts(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      _posts = await apiService.getPosts(
        petType: _selectedPetType == 'All' ? null : _selectedPetType,
        postType: _selectedPostType == 'All' ? null : _selectedPostType,
      );
      if (kDebugMode) {
        print('FeedProvider: Fetched ${_posts.length} posts');
      }
    } catch (e) {
      _posts = [];
      if (kDebugMode) {
        print('FeedProvider: Error fetching posts: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
  }
}

class FeedFilter extends StatelessWidget {
  const FeedFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final feedProvider = Provider.of<FeedProvider>(context);
    const petTypes = ['All', 'Dog', 'Cat', 'Turtle'];
    const postTypes = ['All', 'Reddit', 'Community'];

    return Container(
      padding: const EdgeInsets.only(top: 48.0, left: 16.0, right: 16.0, bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: feedProvider.selectedPetType,
              decoration: const InputDecoration(
                labelText: 'Filter by Pet',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                filled: true,
              ),
              items: petTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  feedProvider.setPetType(value);
                  feedProvider.fetchPosts(context);
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: feedProvider.selectedPostType,
              decoration: const InputDecoration(
                labelText: 'Filter by Post Type',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                filled: true,
              ),
              items: postTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  feedProvider.setPostType(value);
                  feedProvider.fetchPosts(context);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PostDetailScreen(post: post)),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(child: Text(post.author[0])),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.author,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${post.petType} • ${post.postType[0].toUpperCase()}${post.postType.substring(1)}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                post.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              if (post.imageUrl != null)
                CachedNetworkImage(
                  imageUrl: post.imageUrl!,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const SizedBox.shrink(),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 4),
              Text(post.content, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.thumb_up, size: 16, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text('${post.upvotes ?? 0}'),
                  if (post.postType == 'community') ...[
                    const SizedBox(width: 16),
                    Icon(Icons.comment, size: 16, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text('${post.comments.length}'),
                  ],
                  const Spacer(),
                  Text(
                    '${post.createdAt.day}/${post.createdAt.month}/${post.createdAt.year}',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
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

class CommunityFeedScreen extends StatelessWidget {
  const CommunityFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FeedProvider()..fetchPosts(context),
      child: Consumer<FeedProvider>(
        builder: (context, feedProvider, child) {
          return Scaffold(
            body: RefreshIndicator(
              onRefresh: () => feedProvider.fetchPosts(context),
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
                                  height: 150,
                                  color: Colors.grey[850],
                                ),
                              );
                            },
                          )
                        : feedProvider.posts.isEmpty
                            ? const Center(child: Text('No posts found'))
                            : ListView.builder(
                                itemCount: feedProvider.posts.length,
                                itemBuilder: (context, index) {
                                  return PostCard(post: feedProvider.posts[index]);
                                },
                              ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreatePostScreen()),
              ),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}