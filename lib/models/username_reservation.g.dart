// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'username_reservation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UsernameReservationAdapter extends TypeAdapter<UsernameReservation> {
  @override
  final int typeId = 10;

  @override
  UsernameReservation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UsernameReservation(
      username: fields[0] as String,
      userId: fields[1] as String,
      email: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UsernameReservation obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.username)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.email);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsernameReservationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
