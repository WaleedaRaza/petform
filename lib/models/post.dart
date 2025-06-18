class Post {
  final int? id;
  final String title;
  final String content;
  final String author;
  final String petType; // e.g., Dog, Cat, Turtle
  final String? imageUrl; // For Reddit/community images
  final int? upvotes; // For Reddit-style interactions
  final DateTime createdAt;

  Post({
    this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.petType,
    this.imageUrl,
    this.upvotes,
    required this.createdAt,
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
    };
  }
}