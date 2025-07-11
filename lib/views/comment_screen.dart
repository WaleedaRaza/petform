import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../providers/user_provider.dart';
import '../widgets/video_background.dart';

class CommentScreen extends StatefulWidget {
  final Post post;

  const CommentScreen({super.key, required this.post});

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final _commentController = TextEditingController();
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
      await Provider.of<ApiService>(context, listen: false).addComment(
        postId: widget.post.id!,
        content: _commentController.text,
        author: userProvider.email ?? 'Anonymous',
      );
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
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    // Try to get email from UserProvider first, then fallback to Firebase Auth
    final currentUser = userProvider.email ?? FirebaseAuth.instance.currentUser?.email ?? 'Anonymous';
    
    if (kDebugMode) {
      print('CommentScreen._deleteComment: Comment author: ${comment.author}');
      print('CommentScreen._deleteComment: Current user: $currentUser');
      print('CommentScreen._deleteComment: UserProvider email: ${userProvider.email}');
      print('CommentScreen._deleteComment: Firebase Auth email: ${FirebaseAuth.instance.currentUser?.email}');
    }
    
    // Only allow deletion if the user is the author of the comment
    if (comment.author != currentUser) {
      if (kDebugMode) {
        print('CommentScreen._deleteComment: Authorization failed - user cannot delete this comment');
      }
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
        await Provider.of<ApiService>(context, listen: false).deleteComment(
          postId: widget.post.id!,
          commentId: comment.id!,
          author: currentUser,
        );
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

  @override
  Widget build(BuildContext context) {
    return VideoBackground(
      videoPath: 'lib/assets/animation2.mp4',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Comments')),
        body: FutureBuilder<Post>(
          future: Provider.of<ApiService>(context, listen: false).getPost(widget.post.id!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return const Center(child: Text('Failed to load comments'));
            }
            final post = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: post.comments.length,
                    itemBuilder: (context, index) {
                      final comment = post.comments[index];
                      final userProvider = Provider.of<UserProvider>(context);
                      // Try to get email from UserProvider first, then fallback to Firebase Auth
                      String currentUser = userProvider.email ?? FirebaseAuth.instance.currentUser?.email ?? 'Anonymous';
                      final isAuthor = comment.author == currentUser;
                      
                      if (kDebugMode) {
                        print('CommentScreen: Comment author: ${comment.author}');
                        print('CommentScreen: Current user: $currentUser');
                        print('CommentScreen: Is author: $isAuthor');
                        print('CommentScreen: UserProvider email: ${userProvider.email}');
                        print('CommentScreen: Firebase Auth email: ${FirebaseAuth.instance.currentUser?.email}');
                      }
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(comment.author, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(comment.content),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${comment.createdAt.day}/${comment.createdAt.month}/${comment.createdAt.year}',
                                style: TextStyle(color: Colors.grey[400], fontSize: 12),
                              ),
                              if (isAuthor) ...[
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () => _deleteComment(comment),
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                  tooltip: 'Delete comment',
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
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
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}