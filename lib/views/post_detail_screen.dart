import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // For URL launch
import 'package:petform/models/post.dart';  // Import the Post model
import 'package:petform/models/reddit_post.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../providers/user_provider.dart';
import '../providers/feed_provider.dart';
import '../services/api_service.dart';
import '../services/auth0_jwt_service.dart';
import '../services/supabase_service.dart';
import '../widgets/video_background.dart';
import 'create_post_screen.dart';
import 'user_detail_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final feedProvider = Provider.of<FeedProvider>(context, listen: false);
      
      // Use SupabaseService for adding comments
      final userEmail = Auth0JWTService.instance.currentUserEmail ?? 'Anonymous';
      final username = userProvider.currentUsername ?? userEmail.split('@')[0];
      
      await SupabaseService.createComment(
        widget.post.id!,
        _commentController.text,
        username,
      );
      
      // Refresh both providers to get updated post with comments
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      await appState.loadPosts();
      await feedProvider.fetchPosts(context);
      
      if (!mounted) return;
      _commentController.clear();
      
      // Refresh the UI to show the new comment
      setState(() {});
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment added successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add comment: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteComment(Comment comment) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userEmail = Auth0JWTService.instance.currentUserEmail ?? 'Anonymous';
    final currentUsername = userProvider.currentUsername ?? userEmail.split('@')[0];
    
    // Only allow deletion if the user is the author of the comment
    if (comment.author != currentUsername) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only delete your own comments')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
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
      setState(() => _isLoading = true);
      try {
        final feedProvider = Provider.of<FeedProvider>(context, listen: false);
        
        // Use API service to delete comment
        await SupabaseService.deleteComment(
          widget.post.id!,
          comment.id!,
        );
        
        // Refresh feed provider to update the post in the feed
        await feedProvider.fetchPosts(context);
        
        if (!mounted) return;
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment deleted')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete comment: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deletePost(Post post) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
                              final userEmail = Auth0JWTService.instance.currentUserEmail ?? 'Anonymous';
    final currentUsername = userProvider.currentUsername ?? userEmail.split('@')[0];
    
    // Only allow deletion if the user is the author of the post
    if (post.author != currentUsername) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only delete your own posts')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
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
      setState(() => _isLoading = true);
      try {
        final feedProvider = Provider.of<FeedProvider>(context, listen: false);
        
        // Use API service to delete post
        await SupabaseService.deletePost(post.id!);
        
        // Refresh feed provider to update the posts in the feed
        await feedProvider.fetchPosts(context);
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted')),
        );
        // Navigate back to the feed
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete post: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedProvider = Provider.of<FeedProvider>(context);
    final appState = Provider.of<AppStateProvider>(context);
    
    // Get the updated post from both providers, fallback to widget.post
    final post = feedProvider.posts.firstWhere(
      (p) => p.id == widget.post.id,
      orElse: () => appState.posts.firstWhere(
        (p) => p.id == widget.post.id,
        orElse: () => widget.post,
      ),
    );
    final isReddit = post.postType == 'reddit';
    final redditPost = isReddit && post is RedditPost ? post as RedditPost : null;
    return VideoBackground(
      videoPath: 'lib/assets/backdrop2.mp4',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(post.title, maxLines: 2, overflow: TextOverflow.ellipsis),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            if (post.postType == 'community') ...[
              if (() {
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                                    final email = Auth0JWTService.instance.currentUserEmail ?? 'Anonymous';
                final name = userProvider.currentUsername ?? email.split('@')[0];
                return post.author == name;
              }()) ...[
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreatePostScreen(postToEdit: post),
                    ),
                  );
                },
                tooltip: 'Edit post',
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deletePost(post),
                tooltip: 'Delete post',
              ),],
            ],
          ],
        ),
        body: Padding(
        padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isReddit) ...[
              Row(
                children: [
                  Image.asset('lib/assets/reddit.png', width: 32, height: 32),
                  const SizedBox(width: 8),
                  Text(
                    'Reddit Post',
                    style: TextStyle(
                      color: Colors.orange[300],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (redditPost != null && redditPost.subreddit.isNotEmpty)
                Text(
                  'r/${redditPost.subreddit}',
                  style: TextStyle(color: Colors.orange[300], fontSize: 14),
                ),
              const SizedBox(height: 16),
            ] else if (post.postType == 'community') ...[
              // Community post author info
              GestureDetector(
                onTap: () async {
                  try {
                    final userId = await SupabaseService.getUserIdByUsername(post.author);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserDetailScreen(
                          username: post.author,
                          userId: userId,
                        ),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not load user profile: $e')),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        child: Text(
                          post.author.isNotEmpty ? post.author[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.author,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            Text(
                              'Community Member • Tap to view profile',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
              Container(
                width: double.infinity,
                height: 200,
                margin: const EdgeInsets.only(bottom: 16),
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
                      if (isReddit) {
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
                            ],
                          ),
                        );
                      }
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),
            if (isReddit && (redditPost == null || redditPost.content.isEmpty))
              const Text(
                'No text content. View on Reddit for more.',
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            if (!isReddit || (redditPost != null && redditPost.content.isNotEmpty))
              Text(
                post.content,
                softWrap: true,
                overflow: TextOverflow.visible,
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 16),
            if (isReddit && post.redditUrl != null)
              Container(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final url = post.redditUrl!;
                    if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url));
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  icon: Image.asset('lib/assets/reddit.png', width: 20, height: 20),
                  label: const Text('View on Reddit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
                if (post.postType == 'community') ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Comments (${post.comments.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (post.comments.isEmpty)
                    const Text(
                      'No comments yet. Be the first to comment!',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    )
                  else
                    ...post.comments.map((comment) {
                      final userProvider = Provider.of<UserProvider>(context, listen: false);
                      final userEmail = Auth0JWTService.instance.currentUserEmail ?? 'Anonymous';
                      final currentUsername = userProvider.currentUsername ?? userEmail.split('@')[0];
                      final isAuthor = comment.author == currentUsername;
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.grey[300],
                                    child: Text(
                                      comment.author.isNotEmpty ? comment.author[0].toUpperCase() : '?',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          comment.author,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          _formatDate(comment.createdAt),
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isAuthor)
                                    IconButton(
                                      onPressed: () => _deleteComment(comment),
                                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                      tooltip: 'Delete comment',
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(comment.content),
                            ],
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: 'Add a comment...',
                            border: OutlineInputBorder(),
                            filled: true,
                          ),
                          onSubmitted: (_) => _addComment(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: _addComment,
                            ),
                    ],
                  ),
                ],
              ],
            ),
        ),
      ),
      ),
    );
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
