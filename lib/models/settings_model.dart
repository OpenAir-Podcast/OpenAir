import 'package:hive_ce/hive.dart';
import 'package:openair/config/hive_types.dart';

part 'settings_model.g.dart';

@HiveType(typeId: settingsTypeId)
class SettingsModel extends HiveObject {
  SettingsModel({
    required this.language,
    required this.theme,
  });

  @HiveField(0)
  String language;

  @HiveField(1)
  String theme;

  factory SettingsModel.fromJson(Map<String, dynamic> json) => SettingsModel(
        language: json['language'],
        theme: json['theme'],
      );

  Map<String, dynamic> toJson() => {
        'language': language,
        'theme': theme,
      };
}
