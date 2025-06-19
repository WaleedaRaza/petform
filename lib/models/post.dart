import 'comment.dart'; // ✅ Use the single source of truth

class Post {
  final int? id;
  final String title;
  final String content;
  final String author;
  final String petType;
  final String postType; // 'community' or 'reddit'
  final String? redditUrl;
  final String? imageUrl;
  final int upvotes;
  final DateTime createdAt;
  final List<Comment> comments; // ✅ Now references shared Comment model

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.petType,
    required this.postType,
    this.redditUrl,
    this.imageUrl,
    required this.upvotes,
    required this.createdAt,
    this.comments = const [],
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int?,
      title: json['title'] as String,
      content: json['content'] as String,
      author: json['author'] as String,
      petType: json['petType'] as String,
      postType: json['postType'] as String,
      redditUrl: json['redditUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      upvotes: json['upvotes'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      comments: (json['comments'] as List<dynamic>?)
              ?.map((c) => Comment.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author': author,
      'petType': petType,
      'postType': postType,
      'redditUrl': redditUrl,
      'imageUrl': imageUrl,
      'upvotes': upvotes,
      'createdAt': createdAt.toIso8601String(),
      'comments': comments.map((c) => c.toJson()).toList(),
    };
  }
}
