import 'package:hive/hive.dart';
import 'post.dart';
part 'reddit_post.g.dart';

@HiveType(typeId: 8)
class RedditPost extends Post {
  @HiveField(12)
  final String subreddit;
  @HiveField(14)
  final String thumbnail;

  RedditPost({
    String? id,
    String? title,
    required this.subreddit,
    String? author,
    String? url,
    required this.thumbnail,
    String? content,
  }) : super(
          id: id ?? '',
          title: title ?? '',
          content: content ?? '',
          author: author ?? '',
          petType: 'Reddit',
          postType: 'reddit',
          redditUrl: url,
          imageUrl: thumbnail.isNotEmpty ? thumbnail : null,
          upvotes: 0,
          createdAt: DateTime.now(),
        );

  factory RedditPost.fromJson(Map<String, dynamic> json) {
    return RedditPost(
      id: json['id']?.toString(),
      title: json['title'] as String? ?? '',
      subreddit: json['subreddit'] as String? ?? '',
      author: json['author'] as String? ?? '',
      url: json['url'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
      content: json['content'] as String? ?? '',
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
    };
  }
}
