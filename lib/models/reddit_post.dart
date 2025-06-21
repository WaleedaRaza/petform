import 'post.dart';

class RedditPost extends Post {
  final String subreddit;
  final String thumbnail;

  RedditPost({
    required String title,
    required String subreddit,
    required String author,
    required String url,
    required this.thumbnail,
    required String content,
  })  : subreddit = subreddit,
        super(
          id: 0,  // Or pass the proper ID from Reddit API
          title: title,
          content: content,
          author: author,
          petType: 'Reddit',  // Or another appropriate value
          postType: 'reddit',
          redditUrl: url,
          imageUrl: null,
          upvotes: 0,
          createdAt: DateTime.now(),
        );
}
