// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DownloadModelAdapter extends TypeAdapter<DownloadModel> {
  @override
  final typeId = 4;

  @override
  DownloadModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DownloadModel(
      guid: fields[0] as String,
      image: fields[1] as String,
      title: fields[2] as String,
      author: fields[3] as String,
      datePublished: (fields[4] as num).toInt(),
      description: fields[5] as String,
      feedUrl: fields[6] as String,
      duration: fields[7] as Duration,
      size: fields[8] as String,
      podcastId: fields[9] as String,
      enclosureLength: (fields[10] as num).toInt(),
      enclosureUrl: fields[11] as String,
      downloadDate: fields[12] as DateTime,
      fileName: fields[13] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DownloadModel obj) {
    writer
      ..writeByte(14)
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
      ..write(obj.enclosureUrl)
      ..writeByte(12)
      ..write(obj.downloadDate)
      ..writeByte(13)
      ..write(obj.fileName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
