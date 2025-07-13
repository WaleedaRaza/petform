// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PetAdapter extends TypeAdapter<Pet> {
  @override
  final int typeId = 1;

  @override
  Pet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Pet(
      id: fields[0] as int?,
      name: fields[1] as String,
      species: fields[2] as String,
      breed: fields[3] as String?,
      age: fields[4] as int?,
      personality: fields[5] as String?,
      foodSource: fields[6] as String?,
      favoritePark: fields[7] as String?,
      leashSource: fields[8] as String?,
      litterType: fields[9] as String?,
      waterProducts: fields[10] as String?,
      tankSize: fields[11] as String?,
      cageSize: fields[12] as String?,
      favoriteToy: fields[13] as String?,
      photoUrl: fields[14] as String?,
      customFields: (fields[15] as Map?)?.cast<String, dynamic>(),
      shoppingList: (fields[16] as List).cast<ShoppingItem>(),
      trackingMetrics: (fields[17] as List).cast<TrackingMetric>(),
    );
  }

  @override
  void write(BinaryWriter writer, Pet obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.species)
      ..writeByte(3)
      ..write(obj.breed)
      ..writeByte(4)
      ..write(obj.age)
      ..writeByte(5)
      ..write(obj.personality)
      ..writeByte(6)
      ..write(obj.foodSource)
      ..writeByte(7)
      ..write(obj.favoritePark)
      ..writeByte(8)
      ..write(obj.leashSource)
      ..writeByte(9)
      ..write(obj.litterType)
      ..writeByte(10)
      ..write(obj.waterProducts)
      ..writeByte(11)
      ..write(obj.tankSize)
      ..writeByte(12)
      ..write(obj.cageSize)
      ..writeByte(13)
      ..write(obj.favoriteToy)
      ..writeByte(14)
      ..write(obj.photoUrl)
      ..writeByte(15)
      ..write(obj.customFields)
      ..writeByte(16)
      ..write(obj.shoppingList)
      ..writeByte(17)
      ..write(obj.trackingMetrics);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
