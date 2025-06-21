import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post.dart';
import '../models/reddit_post.dart';
import '../providers/feed_provider.dart';
import 'post_detail_screen.dart';
import 'create_post_screen.dart';
import '../models/pet_types.dart';

class FeedFilter extends StatelessWidget {
  const FeedFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final feedProvider = Provider.of<FeedProvider>(context);
    final dropdownPetTypes = ['All', ...petTypes];
    const postTypes = ['All', 'Reddit', 'Community'];

    return Container(
      padding: const EdgeInsets.only(top: 48, left: 16, right: 16, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: feedProvider.selectedPetType,
              decoration: const InputDecoration(
                labelText: 'Filter by Pet',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                filled: true,
              ),
              items: dropdownPetTypes.map((type) {
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
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

  bool _isValidThumbnail(String? url) {
    if (url == null || url.isEmpty) return false;
    final invalids = ['self', 'default', 'nsfw', 'image', 'spoiler'];
    if (invalids.contains(url)) return false;
    return url.startsWith('http');
  }

  @override
  Widget build(BuildContext context) {
    final isReddit = post.postType == 'reddit';
    final redditPost = isReddit && post is RedditPost ? post as RedditPost : null;
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (isReddit)
                    Image.asset('lib/assets/reddit.png', width: 24, height: 24),
                  if (!isReddit)
                    CircleAvatar(child: Text(post.author.isNotEmpty ? post.author[0] : '?')),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.author,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isReddit && redditPost != null)
                          Text('r/${redditPost.subreddit}', style: TextStyle(color: Colors.orange[300], fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                        if (!isReddit)
                          Text(
                            '${post.petType} • ${post.postType[0].toUpperCase()}${post.postType.substring(1)}',
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                post.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              if (isReddit && redditPost != null && _isValidThumbnail(redditPost.thumbnail))
                Image.network(
                  redditPost.thumbnail,
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset('lib/assets/reddit.png', width: 48, height: 48, color: Colors.grey[400]),
                ),
              if (!isReddit && post.imageUrl != null)
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
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
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
                            ? const Center(child: Text('No posts found for this pet type. Try another or check Reddit!'))
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