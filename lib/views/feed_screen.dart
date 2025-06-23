import 'package:flutter/material.dart';
import 'package:petform/services/api_service.dart';
import 'package:petform/models/post.dart';
import 'package:petform/views/post_detail_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final ApiService _apiService = ApiService();
  List<Post> _posts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final posts = await _apiService.getPosts();
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load posts: $e';
      });
    }
  }

  // Truncate the content for the preview in the feed
  String truncateContent(String content, {int maxLength = 50}) {
    return content.length > maxLength ? content.substring(0, maxLength) + '...' : content;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pet Community Feed')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                      ElevatedButton(
                        onPressed: _fetchPosts,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchPosts,
                  child: ListView.builder(
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      final post = _posts[index];
                      final previewText = truncateContent(post.content); // Truncate here

                      return ListTile(
                        title: Text(post.title),
                        subtitle: Text(previewText), // Show truncated preview
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostDetailScreen(post: post), // Pass full content
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
    );
  }
}
