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
import '../services/firebase_auth_service.dart';
import '../widgets/video_background.dart';
import 'create_post_screen.dart';

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
      
      // Use API service directly for adding comments to global posts
      await Provider.of<ApiService>(context, listen: false).addComment(
        postId: widget.post.id!,
        content: _commentController.text,
        author: FirebaseAuthService().currentUser?.email ?? 'Anonymous',
      );
      
      // Refresh feed provider to update the post in the feed
      await feedProvider.fetchPosts(context);
      
      if (!mounted) return;
      _commentController.clear();
      setState(() {});
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
    final currentUser = FirebaseAuthService().currentUser?.email ?? 'Anonymous';
    
    // Only allow deletion if the user is the author of the comment
    if (comment.author != currentUser) {
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
        await Provider.of<ApiService>(context, listen: false).deleteComment(
          postId: widget.post.id!,
          commentId: comment.id!,
          author: currentUser,
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
    final currentUser = FirebaseAuthService().currentUser?.email ?? 'Anonymous';
    
    // Only allow deletion if the user is the author of the post
    if (post.author != currentUser) {
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
        await Provider.of<ApiService>(context, listen: false).deletePost(
          postId: post.id!,
          author: currentUser,
        );
        
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
    // Get the updated post from feed provider, fallback to widget.post
    final post = feedProvider.posts.firstWhere(
      (p) => p.id == widget.post.id,
      orElse: () => widget.post,
    );
    final isReddit = post.postType == 'reddit';
    final redditPost = isReddit && post is RedditPost ? post as RedditPost : null;
    return VideoBackground(
      videoPath: 'lib/assets/animation2.mp4',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(post.title, maxLines: 2, overflow: TextOverflow.ellipsis),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            if (post.postType == 'community' && post.author == FirebaseAuthService().currentUser?.email) ...[
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
              ),
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
                      final currentUser = FirebaseAuthService().currentUser?.email ?? 'Anonymous';
                      final isAuthor = comment.author == currentUser;
                      
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
                                          comment.author.contains('@') ? comment.author.split('@')[0] : comment.author,
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
