// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QueueAdapter extends TypeAdapter<Queue> {
  @override
  final typeId = 3;

  @override
  Queue read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Queue(
      guid: fields[0] as String,
      pos: (fields[1] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, Queue obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.guid)
      ..writeByte(1)
      ..write(obj.pos);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QueueAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
