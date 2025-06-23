import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // For URL launch
import 'package:petform/models/post.dart';  // Import the Post model
import 'package:petform/models/reddit_post.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PostDetailScreen extends StatelessWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final isReddit = post.postType == 'reddit';
    final redditPost = isReddit && post is RedditPost ? post as RedditPost : null;
    return Scaffold(
      appBar: AppBar(
        title: Text(post.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
            
            // Show post image if available
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
            
            // Post content
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
            
            // Reddit link button
            if (isReddit && post.redditUrl != null)
              Container(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final url = post.redditUrl!;
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url)); // Open Reddit post
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
          ],
        ),
      ),
    );
  }
}
