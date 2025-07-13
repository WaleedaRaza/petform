// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_metric.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrackingMetricAdapter extends TypeAdapter<TrackingMetric> {
  @override
  final int typeId = 3;

  @override
  TrackingMetric read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrackingMetric(
      id: fields[0] as String,
      name: fields[1] as String,
      frequency: fields[2] as String,
      petId: fields[3] as String,
      targetValue: fields[4] as double,
      currentValue: fields[5] as double,
      createdAt: fields[6] as DateTime?,
      lastUpdated: fields[7] as DateTime?,
      history: (fields[8] as List?)?.cast<TrackingEntry>(),
      description: fields[9] as String?,
      isActive: fields[10] as bool,
      category: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TrackingMetric obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.frequency)
      ..writeByte(3)
      ..write(obj.petId)
      ..writeByte(4)
      ..write(obj.targetValue)
      ..writeByte(5)
      ..write(obj.currentValue)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.lastUpdated)
      ..writeByte(8)
      ..write(obj.history)
      ..writeByte(9)
      ..write(obj.description)
      ..writeByte(10)
      ..write(obj.isActive)
      ..writeByte(11)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackingMetricAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TrackingEntryAdapter extends TypeAdapter<TrackingEntry> {
  @override
  final int typeId = 4;

  @override
  TrackingEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrackingEntry(
      value: fields[0] as double,
      timestamp: fields[1] as DateTime,
      notes: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TrackingEntry obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.value)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackingEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
