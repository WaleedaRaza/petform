// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShoppingItemAdapter extends TypeAdapter<ShoppingItem> {
  @override
  final int typeId = 2;

  @override
  ShoppingItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShoppingItem(
      id: fields[0] as String,
      name: fields[1] as String,
      category: fields[2] as String,
      priority: fields[3] as String,
      estimatedCost: fields[4] as double,
      petId: fields[5] as String?,
      description: fields[6] as String?,
      brand: fields[7] as String?,
      store: fields[8] as String?,
      isCompleted: fields[9] as bool,
      createdAt: fields[10] as DateTime?,
      completedAt: fields[11] as DateTime?,
      tags: (fields[12] as List?)?.cast<String>(),
      imageUrl: fields[13] as String?,
      quantity: fields[14] as int,
      notes: fields[15] as String?,
      chewyUrl: fields[16] as String?,
      rating: fields[17] as double?,
      reviewCount: fields[18] as int?,
      inStock: fields[19] as bool?,
      autoShip: fields[20] as bool?,
      freeShipping: fields[21] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, ShoppingItem obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.priority)
      ..writeByte(4)
      ..write(obj.estimatedCost)
      ..writeByte(5)
      ..write(obj.petId)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.brand)
      ..writeByte(8)
      ..write(obj.store)
      ..writeByte(9)
      ..write(obj.isCompleted)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.completedAt)
      ..writeByte(12)
      ..write(obj.tags)
      ..writeByte(13)
      ..write(obj.imageUrl)
      ..writeByte(14)
      ..write(obj.quantity)
      ..writeByte(15)
      ..write(obj.notes)
      ..writeByte(16)
      ..write(obj.chewyUrl)
      ..writeByte(17)
      ..write(obj.rating)
      ..writeByte(18)
      ..write(obj.reviewCount)
      ..writeByte(19)
      ..write(obj.inStock)
      ..writeByte(20)
      ..write(obj.autoShip)
      ..writeByte(21)
      ..write(obj.freeShipping);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShoppingItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
