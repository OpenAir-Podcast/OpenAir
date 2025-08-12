import 'package:hive_ce/hive.dart';
import 'package:openair/config/hive_types.dart';

part 'settings_model.g.dart';

@HiveType(typeId: settingsTypeId)
class SettingsModel extends HiveObject {
  SettingsModel({
    required this.themeMode,
    required this.fontSizeFactor,
    required this.language,
    required this.voice,
    required this.speechRate,
    required this.pitch,
    required this.locale,
  });

  @HiveField(0)
  String themeMode;

  @HiveField(1)
  double fontSizeFactor;

  @HiveField(2)
  String language;

  @HiveField(3)
  String voice;

  @HiveField(4)
  String speechRate;

  @HiveField(5)
  String pitch;

  @HiveField(6)
  String locale;

  factory SettingsModel.defaultSettings() {
    return SettingsModel(
      themeMode: 'Light',
      fontSizeFactor: 1.0,
      language: 'English',
      voice: 'System',
      speechRate: 'Medium',
      pitch: 'Medium',
      locale: 'en_US',
    );
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) => SettingsModel(
        themeMode: json['themeMode'],
        fontSizeFactor: json['fontSize'],
        language: json['language'],
        voice: json['voice'],
        speechRate: json['speechRate'],
        pitch: json['pitch'],
        locale: json['locale'] ?? 'en_US',
      );

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode,
        'fontSize': fontSizeFactor,
        'language': language,
        'voice': voice,
        'speechRate': speechRate,
        'pitch': pitch,
        'locale': locale,
      };

  @override
  String toString() {
    return '''
    themeMode: $themeMode,
    fontSize: $fontSizeFactor,
    language: $language,
    voice: $voice,
    speechRate: $speechRate,
    pitch: $pitch,
    locale: $locale
    ''';
  }

  get getThemeMode => themeMode;

  set setThemeMode(String value) {
    themeMode = value;
  }

  get getFontSizeFactor => fontSizeFactor;

  set setFontSizeFactor(double value) {
    fontSizeFactor = value;
  }

  get getLanguage => language;

  set setLanguage(String value) {
    language = value;
  }

  get getVoice => voice;

  set setVoice(String value) {
    voice = value;
  }

  get getSpeechRate => speechRate;

  set setSpeechRate(String value) {
    speechRate = value;
  }

  get getPitch => pitch;

  set setPitch(String value) {
    pitch = value;
  }

  get getLocale => locale;

  set setLocale(String value) {
    locale = value;
  }
}
