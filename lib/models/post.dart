class Comment {
  final int? id;
  final String content;
  final String author;
  final DateTime createdAt;

  Comment({
    this.id,
    required this.content,
    required this.author,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int?,
      content: json['content'] as String,
      author: json['author'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'author': author,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class Post {
  final int? id;
  final String title;
  final String content;
  final String author;
  final String petType;
  final String? imageUrl;
  final int? upvotes;
  final DateTime createdAt;
  final String postType;
  final String? redditUrl;
  final List<Comment> comments;

  Post({
    this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.petType,
    this.imageUrl,
    this.upvotes,
    required this.createdAt,
    required this.postType,
    this.redditUrl,
    this.comments = const [],
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int?,
      title: json['title'] as String,
      content: json['content'] as String,
      author: json['author'] as String,
      petType: json['petType'] as String,
      imageUrl: json['imageUrl'] as String?,
      upvotes: json['upvotes'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      postType: json['postType'] as String,
      redditUrl: json['redditUrl'] as String?,
      comments: (json['comments'] as List<dynamic>?)
          ?.map((c) => Comment.fromJson(c as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author': author,
      'petType': petType,
      'imageUrl': imageUrl,
      'upvotes': upvotes,
      'createdAt': createdAt.toIso8601String(),
      'postType': postType,
      'redditUrl': redditUrl,
      'comments': comments.map((c) => c.toJson()).toList(),
    };
  }
}