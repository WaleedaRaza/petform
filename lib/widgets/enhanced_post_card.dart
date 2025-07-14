import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/app_state_provider.dart';
import '../models/post.dart';
import '../views/post_detail_screen.dart';
import '../views/comment_screen.dart';
import '../services/api_service.dart';
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
              if (kDebugMode) {
                print('EnhancedPostCard: Save button pressed for post ${post.id}');
                print('EnhancedPostCard: Current saved state: $isSaved');
              }
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
          
          // Delete button (only for community posts by current user)
          if (post.postType == 'community' && post.author == _getCurrentUserEmail(context))
            IconButton(
              onPressed: () => _showDeleteDialog(context, post),
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
                size: 20,
              ),
              tooltip: 'Delete post',
          ),
        ],
      ),
    );
  }



  Widget _buildFooter(BuildContext context, AppStateProvider appState, bool isSaved) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
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

  String _getCurrentUserEmail(BuildContext context) {
    // Get current user email from Firebase Auth
    final user = FirebaseAuth.instance.currentUser;
    return user?.email ?? 'Anonymous';
  }

  void _showDeleteDialog(BuildContext context, Post post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deletePost(context, post);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePost(BuildContext context, Post post) async {
    try {
      final currentUser = _getCurrentUserEmail(context);
      
      // Use API service to delete post
      await Provider.of<ApiService>(context, listen: false).deletePost(
        postId: post.id!,
        author: currentUser,
      );
      
      // Refresh the feed by triggering a rebuild
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete post: $e')),
        );
      }
    }
  }
} 