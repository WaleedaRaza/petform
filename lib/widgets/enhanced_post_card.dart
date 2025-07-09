import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/app_state_provider.dart';
import '../models/post.dart';
import '../views/post_detail_screen.dart';
import '../views/comment_screen.dart';
import 'package:flutter/foundation.dart';

class EnhancedPostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;

  const EnhancedPostCard({
    super.key,
    required this.post,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        final isSaved = appState.isPostSaved(post);
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            onTap: onTap ?? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostDetailScreen(post: post),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with author info and save button
                _buildHeader(context, appState, isSaved),
                
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                // Single image if available
                if (post.imageUrl != null) _buildImage(),
                
                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Text(
                    post.content,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                // Footer with stats and actions
                _buildFooter(context, appState, isSaved),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AppStateProvider appState, bool isSaved) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Author avatar with Reddit indicator
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: _getPetTypeColor(),
                child: post.postType.toLowerCase() == 'reddit' 
                  ? Image.asset(
                      'lib/assets/reddit.png',
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                    )
                  : Text(
                      post.author.isNotEmpty ? post.author[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              ),
              // Reddit logo indicator
              if (post.postType.toLowerCase() == 'reddit')
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.reddit,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(width: 12),
          
          // Author info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.author.contains('@') ? post.author.split('@')[0] : post.author, // Show username part of email or full username
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        post.petType,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getPostTypeColor(),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        post.postType.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (post.editedAt != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '(edited)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          // Save button
          IconButton(
            onPressed: () {
              if (isSaved) {
                appState.unsavePost(post);
              } else {
                appState.savePost(post);
              }
            },
            icon: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: isSaved ? Colors.orange : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (post.imageUrl == null || post.imageUrl!.isEmpty) return const SizedBox.shrink();
    
    // Debug logging for Reddit posts
    if (post.postType.toLowerCase() == 'reddit' && kDebugMode) {
      print('Reddit post image URL: ${post.imageUrl}');
    }
    
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: post.imageUrl!,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[300],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          errorWidget: (context, url, error) {
            // For Reddit posts, show a Reddit-themed placeholder
            if (post.postType.toLowerCase() == 'reddit') {
              return Container(
                color: Colors.grey[300],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'lib/assets/reddit.png',
                      width: 48,
                      height: 48,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Reddit Image',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    if (kDebugMode) ...[
                      const SizedBox(height: 4),
                      Text(
                        'URL: ${post.imageUrl}',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              );
            }
            // For other posts, show generic error
            return Container(
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, AppStateProvider appState, bool isSaved) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Upvotes
          Row(
            children: [
              Icon(Icons.thumb_up, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${post.upvotes ?? 0}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          
          const SizedBox(width: 16),
          
          // Comments
          if (post.postType == 'community') ...[
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CommentScreen(post: post),
                  ),
                );
              },
              child: Row(
              children: [
                Icon(Icons.comment, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${post.comments.length}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
              ),
            ),
            const SizedBox(width: 16),
          ],
          
          // Date
          Expanded(
            child: Text(
              _formatDate(post.createdAt),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
          
          // Share button
          IconButton(
            onPressed: () {
              // TODO: Implement share functionality
            },
            icon: Icon(
              Icons.share,
              size: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPetTypeColor() {
    switch (post.petType.toLowerCase()) {
      case 'dog':
        return Colors.blue;
      case 'cat':
        return Colors.orange;
      case 'bird':
        return Colors.green;
      case 'fish':
        return Colors.cyan;
      default:
        return Colors.purple;
    }
  }

  Color _getPostTypeColor() {
    switch (post.postType.toLowerCase()) {
      case 'reddit':
        return Colors.orange;
      case 'community':
        return Colors.blue;
      case 'ai':
        return Colors.purple;
      default:
        return Colors.grey;
    }
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
} 