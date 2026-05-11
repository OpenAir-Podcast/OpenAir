// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_cache_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SearchCacheModelAdapter extends TypeAdapter<SearchCacheModel> {
  @override
  final typeId = 10;

  @override
  SearchCacheModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SearchCacheModel(
      query: fields[0] as String,
      results: (fields[1] as Map).cast<String, dynamic>(),
      timestamp: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SearchCacheModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.query)
      ..writeByte(1)
      ..write(obj.results)
      ..writeByte(2)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchCacheModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
