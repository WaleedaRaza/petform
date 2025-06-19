import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../providers/user_provider.dart';
import '../widgets/rounded_button.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(comment.author, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(comment.content),
                        trailing: Text(
                          '${comment.createdAt.day}/${comment.createdAt.month}/${comment.createdAt.year}',
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
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
    );
  }
}