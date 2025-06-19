import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/post.dart';
import 'comment_screen.dart';
import '../widgets/rounded_button.dart';

class PostDetailScreen extends StatelessWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  Future<void> _launchRedditUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(post.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text(post.author[0])),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.author,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${post.petType} • ${post.postType[0].toUpperCase()}${post.postType.substring(1)}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              post.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (post.imageUrl != null)
              CachedNetworkImage(
                imageUrl: post.imageUrl!,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const SizedBox.shrink(),
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 8),
            Text(post.content, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            if (post.postType == 'reddit' && post.redditUrl != null)
              RoundedButton(
                text: 'Open in Reddit',
                onPressed: () => _launchRedditUrl(post.redditUrl!),
              ),
            if (post.postType == 'community')
              RoundedButton(
                text: 'View Comments',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CommentScreen(post: post)),
                ),
              ),
            ],
          ),
        ),
      
    );
  }
}