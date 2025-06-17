class PetAIPost {
  final String? title;
  final String? selftext;
  final DateTime? createdUtc;
  final String? author;

  PetAIPost({
    this.title,
    this.selftext,
    this.createdUtc,
    this.author,
  });

  factory PetAIPost.fromJson(Map<String, dynamic> json) {
    return PetAIPost(
      title: json['title'] as String?,
      selftext: json['selftext'] as String?,
      createdUtc: json['created_utc'] != null
          ? DateTime.fromMillisecondsSinceEpoch((json['created_utc'] as num).toInt() * 1000)
          : null,
      author: json['author'] as String?,
    );
  }

Map<String, dynamic> toJson() {
  return {
    'title': title,
    'selftext': selftext,
    'created_utc': createdUtc != null ? createdUtc!.millisecondsSinceEpoch ~/ 1000 : null,
    'author': author,
  };
}}