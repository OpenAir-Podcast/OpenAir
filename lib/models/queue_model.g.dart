// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QueueModelAdapter extends TypeAdapter<QueueModel> {
  @override
  final typeId = 3;

  @override
  QueueModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QueueModel(
      guid: fields[0] as String,
      image: fields[1] as String,
      title: fields[2] as String,
      author: fields[3] as String,
      datePublished: (fields[4] as num).toInt(),
      description: fields[5] as String,
      feedUrl: fields[6] as String,
      duration: fields[7] as Duration,
      downloadSize: fields[8] as String,
      enclosureType: fields[16] as String?,
      podcast: (fields[9] as Map).cast<String, dynamic>(),
      enclosureLength: (fields[10] as num).toInt(),
      enclosureUrl: fields[11] as String,
      pos: (fields[12] as num).toInt(),
      podcastCurrentPositionInMilliseconds: (fields[13] as num).toDouble(),
      currentPlaybackPositionString: fields[14] as String,
      currentPlaybackRemainingTimeString: fields[15] as String,
    );
  }

  @override
  void write(BinaryWriter writer, QueueModel obj) {
    writer
      ..writeByte(17)
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
      ..write(obj.downloadSize)
      ..writeByte(9)
      ..write(obj.podcast)
      ..writeByte(10)
      ..write(obj.enclosureLength)
      ..writeByte(11)
      ..write(obj.enclosureUrl)
      ..writeByte(12)
      ..write(obj.pos)
      ..writeByte(13)
      ..write(obj.podcastCurrentPositionInMilliseconds)
      ..writeByte(14)
      ..write(obj.currentPlaybackPositionString)
      ..writeByte(15)
      ..write(obj.currentPlaybackRemainingTimeString)
      ..writeByte(16)
      ..write(obj.enclosureType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QueueModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
