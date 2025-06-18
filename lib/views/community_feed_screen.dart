import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/api_service.dart';
import '../models/post.dart';
import 'post_detail_screen.dart';

// --- Providers ---

class FeedProvider with ChangeNotifier {
  String _selectedPetType = 'All'; // Default filter
  List<Post> _posts = [];
  bool _isLoading = false;

  String get selectedPetType => _selectedPetType;
  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;

  void setPetType(String petType) {
    _selectedPetType = petType;
    notifyListeners();
  }

  Future<void> fetchPosts(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      _posts = await apiService.getPosts(petType: _selectedPetType);
    } catch (e) {
      _posts = []; // Clear posts on error
    }

    _isLoading = false;
    notifyListeners();
  }
}

// --- Widgets ---

class PetFilterDropdown extends StatelessWidget {
  const PetFilterDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final feedProvider = Provider.of<FeedProvider>(context);
    const petTypes = ['All', 'Dog', 'Cat', 'Turtle'];

    return Container(
      padding: const EdgeInsets.only(top: 54.0, left: 16.0, right: 16.0, bottom: 2.0), // Adjusted for notch
      child: DropdownButtonFormField<String>(
        value: feedProvider.selectedPetType,
        decoration: InputDecoration(
          labelText: 'Filter by Pet',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true, // Rely on inputDecorationTheme.fillColor
        ),
        items: petTypes.map((type) {
          return DropdownMenuItem(
            value: type,
            child: Text(type),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            feedProvider.setPetType(value);
            feedProvider.fetchPosts(context);
          }
        },
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
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(post: post),
          ),
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
                  CircleAvatar(
                    child: Text(post.author[0]), // Mock avatar
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.author,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        post.petType,
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                post.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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
              Text(
                post.content,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.thumb_up, size: 16, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text('${post.upvotes ?? 0}'),
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

// --- Screen ---

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
                  const PetFilterDropdown(),
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
                            ? const Center(child: Text('No posts found for this pet type'))
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
          );
        },
      ),
    );
  }
}