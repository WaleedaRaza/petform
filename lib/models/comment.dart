import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String postId;
  final String userId;
  final String userEmail;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userEmail,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'userId': userId,
      'userEmail': userEmail,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json, String id) {
    return Comment(
      id: id,
      postId: json['postId'] ?? '',
      userId: json['userId'] ?? '',
      userEmail: json['userEmail'] ?? '',
      content: json['content'] ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: json['updatedAt'] != null 
          ? (json['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Comment copyWith({
    String? id,
    String? postId,
    String? userId,
    String? userEmail,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 