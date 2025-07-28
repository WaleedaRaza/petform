import 'post.dart';

class RedditPost extends Post {
  final String subreddit;
  final String thumbnail;

  RedditPost({
    String? id,
    String? title,
    required this.subreddit,
    String? author,
    String? url,
    required this.thumbnail,
    String? content,
    String? petType, // Add petType parameter
  }) : super(
          id: id ?? '',
          title: title ?? '',
          content: content ?? '',
          author: author ?? '',
          petType: petType ?? 'All', // Use provided petType or default to 'All'
          postType: 'reddit',
          redditUrl: url,
          imageUrl: thumbnail.isNotEmpty ? thumbnail : null,
          upvotes: 0,
          createdAt: DateTime.now(),
        );

  // Add setter for petType
  set petType(String value) {
    super.petType = value;
  }

  factory RedditPost.fromJson(Map<String, dynamic> json) {
    return RedditPost(
      id: json['id']?.toString(),
      title: json['title'] as String? ?? '',
      subreddit: json['subreddit'] as String? ?? '',
      author: json['author'] as String? ?? '',
      url: json['url'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
      content: json['content'] as String? ?? '',
      petType: json['petType'] as String? ?? 'All',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subreddit': subreddit,
      'author': author,
      'url': redditUrl,
      'thumbnail': thumbnail,
      'content': content,
      'petType': petType,
    };
  }
}
