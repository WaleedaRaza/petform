class RedditPost {
  final String title;
  final String subreddit;
  final String author;
  final String url;
  final String thumbnail;

  RedditPost({
    required this.title,
    required this.subreddit,
    required this.author,
    required this.url,
    required this.thumbnail,
  });

  factory RedditPost.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return RedditPost(
      title: data['title'] ?? '',
      subreddit: data['subreddit'] ?? '',
      author: data['author'] ?? '',
      url: 'https://www.reddit.com${data['permalink']}',
      thumbnail: data['thumbnail'] ?? '',
    );
  }
}
