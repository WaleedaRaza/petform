import 'pet.dart';

class User {
  final int id;
  final String email;
  final String username;
  final String? profilePhotoUrl;
  final List<Pet> pets;

  User({required this.id, required this.email, required this.username, this.profilePhotoUrl, required this.pets});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      username: json['username'] as String? ?? json['email'] as String, // Fallback to email if no username
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      pets: (json['pets'] as List<dynamic>? ?? []).map((p) => Pet.fromJson(p)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'profilePhotoUrl': profilePhotoUrl,
      'pets': pets.map((p) => p.toJson()).toList(),
    };
  }
}
