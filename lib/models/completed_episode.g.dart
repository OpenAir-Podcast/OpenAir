// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'completed_episode.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CompletedEpisodeAdapter extends TypeAdapter<CompletedEpisode> {
  @override
  final typeId = 6;

  @override
  CompletedEpisode read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CompletedEpisode(
      guid: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CompletedEpisode obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.guid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletedEpisodeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
