import 'package:hive_ce/hive.dart';
import 'package:openair/config/hive_types.dart';

part 'settings_model.g.dart';

@HiveType(typeId: settingsTypeId)
class SettingsModel extends HiveObject {
  SettingsModel({
    required this.themeMode,
    required this.accentColor,
    required this.fontSize,
    required this.language,
    required this.voice,
    required this.speechRate,
    required this.pitch,
  });

  @HiveField(0)
  String themeMode;

  @HiveField(1)
  String accentColor;

  @HiveField(2)
  String fontSize;

  @HiveField(3)
  String language;

  @HiveField(4)
  String voice;

  @HiveField(5)
  String speechRate;

  @HiveField(6)
  String pitch;

  factory SettingsModel.defaultSettings() {
    return SettingsModel(
      themeMode: 'System',
      accentColor: 'Blue',
      fontSize: 'Medium',
      language: 'English',
      voice: 'System',
      speechRate: 'Medium',
      pitch: 'Medium',
    );
  }

  String get themeModeString => themeMode;
  String get accentColorString => accentColor;
  String get fontSizeString => fontSize;
  String get languageString => language;
  String get voiceString => voice;
  String get speechRateString => speechRate;
  String get pitchString => pitch;

  set themeModeString(String value) => themeMode = value;
  set accentColorString(String value) => accentColor = value;
  set fontSizeString(String value) => fontSize = value;
  set languageString(String value) => language = value;
  set voiceString(String value) => voice = value;
  set speechRateString(String value) => speechRate = value;
  set pitchString(String value) => pitch = value;

  @override
  String toString() {
    return 'themeMode: $themeMode, accentColor: $accentColor, fontSize: $fontSize, language: $language, voice: $voice, speechRate: $speechRate, pitch: $pitch';
  }
}
