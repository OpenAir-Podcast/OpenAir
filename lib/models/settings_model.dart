import 'package:hive_ce/hive.dart';
import 'package:openair/config/hive_types.dart';

part 'settings_model.g.dart';

@HiveType(typeId: settingsTypeId)
class SettingsModel extends HiveObject {
  SettingsModel({
    required this.themeMode,
    required this.accentColor,
    required this.fontSizeFactor,
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
  double fontSizeFactor;

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
      fontSizeFactor: 1.0,
      language: 'English',
      voice: 'System',
      speechRate: 'Medium',
      pitch: 'Medium',
    );
  }

  String get getThemeMode => themeMode;
  String get getAccentColor => accentColor;
  double get getFontSizeFactor => fontSizeFactor;
  String get setLanguage => language;
  String get getVoice => voice;
  String get getSpeechRate => speechRate;
  String get getPitch => pitch;

  set setThemeMode(String value) => themeMode = value;
  set setAccentColor(String value) => accentColor = value;
  set setFontSizeFactor(double value) => fontSizeFactor = value;
  set setLanguage(String value) => language = value;
  set setVoice(String value) => voice = value;
  set setSpeechRate(String value) => speechRate = value;
  set setPitch(String value) => pitch = value;

  @override
  String toString() {
    return 'themeMode: $themeMode, accentColor: $accentColor, fontSize: $fontSizeFactor, language: $language, voice: $voice, speechRate: $speechRate, pitch: $pitch';
  }
}
