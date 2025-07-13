import 'package:hive/hive.dart';
part 'username_reservation.g.dart';

@HiveType(typeId: 10)
class UsernameReservation extends HiveObject {
  @HiveField(0)
  final String username;
  @HiveField(1)
  final String userId;
  @HiveField(2)
  final String email;

  UsernameReservation({required this.username, required this.userId, required this.email});
} 