import 'package:hive/hive.dart';
part 'user.g.dart';

@HiveType(typeId: 5)
class User extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String email;
  @HiveField(2)
  final String username;
  @HiveField(3)
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
