// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fetch_data_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FetchDataModelAdapter extends TypeAdapter<FetchDataModel> {
  @override
  final typeId = 9;

  @override
  FetchDataModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FetchDataModel(
      count: (fields[2] as num).toInt(),
      feeds: (fields[1] as List).cast<PodcastModel>(),
      status: fields[0] as String,
      max: (fields[3] as num).toInt(),
      since: (fields[4] as num).toInt(),
      description: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FetchDataModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.status)
      ..writeByte(1)
      ..write(obj.feeds)
      ..writeByte(2)
      ..write(obj.count)
      ..writeByte(3)
      ..write(obj.max)
      ..writeByte(4)
      ..write(obj.since)
      ..writeByte(5)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FetchDataModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
