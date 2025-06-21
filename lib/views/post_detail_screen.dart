import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // For URL launch
import 'package:petform/models/post.dart';  // Import the Post model
import 'package:petform/models/reddit_post.dart';

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
              Image.asset('lib/assets/reddit.png', width: 32, height: 32),
              const SizedBox(height: 8),
              if (redditPost != null && redditPost.subreddit.isNotEmpty)
                Text('r/${redditPost.subreddit}', style: TextStyle(color: Colors.orange[300], fontSize: 16)),
              if (redditPost != null && redditPost.thumbnail.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Image.network(redditPost.thumbnail, width: double.infinity, height: 180, fit: BoxFit.cover),
                ),
            ],
            const SizedBox(height: 16),
            if (isReddit && (redditPost == null || redditPost.content.isEmpty))
              const Text('No text content. View on Reddit for more.', style: TextStyle(fontStyle: FontStyle.italic)),
            if (!isReddit || (redditPost != null && redditPost.content.isNotEmpty))
              Text(
                post.content,
                softWrap: true,
                overflow: TextOverflow.visible,
                style: const TextStyle(fontSize: 16),
              ), // Full content of the post
            const SizedBox(height: 16),
            if (isReddit && post.redditUrl != null)
              TextButton(
                onPressed: () async {
                  final url = post.redditUrl!;
                  if (await canLaunch(url)) {
                    await launch(url); // Open Reddit post
                  } else {
                    throw 'Could not launch $url';
                  }
                },
                child: const Text('Visit Reddit Post'),
              ),
          ],
        ),
      ),
    );
  }
}
