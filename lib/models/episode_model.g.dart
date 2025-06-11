// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episode_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EpisodeAdapter extends TypeAdapter<Episode> {
  @override
  final typeId = 1;

  @override
  Episode read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Episode(
      guid: fields[0] as String,
      image: fields[1] as String,
      title: fields[2] as String,
      author: fields[3] as String,
      datePublished: (fields[4] as num).toInt(),
      description: fields[5] as String,
      feedUrl: fields[6] as String,
      duration: fields[7] as String,
      size: fields[8] as String,
      podcastId: fields[9] as String,
      enclosureLength: (fields[10] as num).toInt(),
      enclosureUrl: fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Episode obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.guid)
      ..writeByte(1)
      ..write(obj.image)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.author)
      ..writeByte(4)
      ..write(obj.datePublished)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.feedUrl)
      ..writeByte(7)
      ..write(obj.duration)
      ..writeByte(8)
      ..write(obj.size)
      ..writeByte(9)
      ..write(obj.podcastId)
      ..writeByte(10)
      ..write(obj.enclosureLength)
      ..writeByte(11)
      ..write(obj.enclosureUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EpisodeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
