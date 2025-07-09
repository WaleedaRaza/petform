import 'pet.dart';

class User {
  final String id;
  final String email;
  final String username;
  final List<String> pets;

  User({required this.id, required this.email, required this.username, required this.pets});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      pets: List<String>.from(json['pets'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'pets': pets,
    };
  }
}
