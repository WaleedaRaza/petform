import 'pet.dart';

class User {
  final int id;
  final String email;
  final List<Pet> pets;

  User({required this.id, required this.email, required this.pets});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      pets: (json['pets'] as List<dynamic>? ?? []).map((p) => Pet.fromJson(p)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'pets': pets.map((p) => p.toJson()).toList(),
    };
  }
}