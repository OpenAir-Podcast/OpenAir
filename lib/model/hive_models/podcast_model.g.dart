// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PodcastModelAdapter extends TypeAdapter<PodcastModel> {
  @override
  final typeId = 8;

  @override
  PodcastModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PodcastModel(
      id: (fields[0] as num).toInt(),
      feedUrl: fields[1] as String,
      title: fields[2] as String,
      author: fields[3] as String?,
      imageUrl: fields[4] as String,
      artwork: fields[5] as String,
      description: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PodcastModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.feedUrl)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.author)
      ..writeByte(4)
      ..write(obj.imageUrl)
      ..writeByte(5)
      ..write(obj.artwork)
      ..writeByte(6)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PodcastModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
