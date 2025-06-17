import 'package:flutter/material.dart';
import 'package:petform/models/pet_ai_post.dart';

class PostDetailScreen extends StatelessWidget {
  final PetAIPost post;

  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(post.title ?? 'Post')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Author: ${post.author ?? 'Unknown'}'),
            const SizedBox(height: 10),
            Text('Posted on: ${post.createdUtc?.toString() ?? 'Unknown'}'),
            const SizedBox(height: 20),
            Text(post.selftext ?? 'No content available'),
          ],
        ),
      ),
    );
  }
}