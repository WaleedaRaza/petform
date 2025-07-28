class Comment {
  final String? id;
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
      id: json['id']?.toString(),
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
  final String? id;
  final String title;
  final String content;
  final String author;
  String petType; // Remove final to allow assignment
  final String? imageUrl;
  final int? upvotes;
  final DateTime createdAt;
  final DateTime? editedAt;
  final String postType;
  final String? redditUrl;
  final List<Comment> comments;
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

  // Add setter for petType
  set setPetType(String value) {
    petType = value;
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id']?.toString(),
      title: json['title'] as String? ?? 'Unknown Title',
      content: json['content'] as String? ?? '',
      author: json['author'] as String? ?? 'Unknown Author',
      petType: json['pet_type'] as String? ?? json['petType'] as String? ?? 'All',
      imageUrl: json['imageUrl'] as String?,
      upvotes: json['upvotes'] as int?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : json['createdAt'] != null 
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      editedAt: json['editedAt'] != null ? DateTime.parse(json['editedAt'] as String) : null,
      postType: json['post_type'] as String? ?? json['postType'] as String? ?? 'community',
      redditUrl: json['reddit_url'] as String? ?? json['redditUrl'] as String?,
      comments: (json['comments'] as List<dynamic>?)
          ?.map((c) => Comment.fromJson(c as Map<String, dynamic>))
          .toList() ?? [],
      isSaved: json['is_saved'] as bool? ?? json['isSaved'] as bool? ?? false,
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