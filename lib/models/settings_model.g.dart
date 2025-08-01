// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsModelAdapter extends TypeAdapter<SettingsModel> {
  @override
  final typeId = 7;

  @override
  SettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsModel(
      themeMode: fields[0] as String,
      accentColor: fields[1] as String,
      fontSizeFactor: (fields[2] as num).toDouble(),
      language: fields[3] as String,
      voice: fields[4] as String,
      speechRate: fields[5] as String,
      pitch: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.themeMode)
      ..writeByte(1)
      ..write(obj.accentColor)
      ..writeByte(2)
      ..write(obj.fontSizeFactor)
      ..writeByte(3)
      ..write(obj.language)
      ..writeByte(4)
      ..write(obj.voice)
      ..writeByte(5)
      ..write(obj.speechRate)
      ..writeByte(6)
      ..write(obj.pitch);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
