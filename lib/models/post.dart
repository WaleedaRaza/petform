import 'package:hive/hive.dart';
part 'post.g.dart';

@HiveType(typeId: 7)
class Comment extends HiveObject {
  @HiveField(0)
  final int? id;
  @HiveField(1)
  final String content;
  @HiveField(2)
  final String author;
  @HiveField(3)
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

@HiveType(typeId: 6)
class Post extends HiveObject {
  @HiveField(0)
  final String? id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String content;
  @HiveField(3)
  final String author;
  @HiveField(4)
  final String petType;
  @HiveField(5)
  final String? imageUrl;
  @HiveField(6)
  final int? upvotes;
  @HiveField(7)
  final DateTime createdAt;
  @HiveField(8)
  final DateTime? editedAt;
  @HiveField(9)
  final String postType;
  @HiveField(10)
  final String? redditUrl;
  @HiveField(11)
  final List<Comment> comments;
  @HiveField(13)
  final bool isSaved;

  Post({
    this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.petType,
    this.imageUrl,
    this.upvotes,
    required this.createdAt,
    this.editedAt,
    required this.postType,
    this.redditUrl,
    this.comments = const [],
    this.isSaved = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id']?.toString(),
      title: json['title'] as String,
      content: json['content'] as String,
      author: json['author'] as String,
      petType: json['petType'] as String,
      imageUrl: json['imageUrl'] as String?,
      upvotes: json['upvotes'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      editedAt: json['editedAt'] != null ? DateTime.parse(json['editedAt'] as String) : null,
      postType: json['postType'] as String,
      redditUrl: json['redditUrl'] as String?,
      comments: (json['comments'] as List<dynamic>?)
          ?.map((c) => Comment.fromJson(c as Map<String, dynamic>))
          .toList() ?? [],
      isSaved: json['isSaved'] as bool? ?? false,
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
      'editedAt': editedAt?.toIso8601String(),
      'postType': postType,
      'redditUrl': redditUrl,
      'comments': comments.map((c) => c.toJson()).toList(),
      'isSaved': isSaved,
    };
  }

  Post copyWith({
    String? id,
    String? title,
    String? content,
    String? author,
    String? petType,
    String? imageUrl,
    int? upvotes,
    DateTime? createdAt,
    DateTime? editedAt,
    String? postType,
    String? redditUrl,
    List<Comment>? comments,
    bool? isSaved,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      author: author ?? this.author,
      petType: petType ?? this.petType,
      imageUrl: imageUrl ?? this.imageUrl,
      upvotes: upvotes ?? this.upvotes,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
      postType: postType ?? this.postType,
      redditUrl: redditUrl ?? this.redditUrl,
      comments: comments ?? this.comments,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}