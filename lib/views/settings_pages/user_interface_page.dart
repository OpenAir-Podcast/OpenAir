import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_localizations_plus/localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';

import 'package:openair/providers/hive_provider.dart';
import 'package:openair/providers/locale_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:theme_provider/theme_provider.dart';

final FutureProvider<Map?> userInterfaceSettingsDataProvider =
    FutureProvider((ref) async {
  final hiveService = ref.watch(hiveServiceProvider);
  return await hiveService.getUserInterfaceSettings();
});

enum ThemeMode {
  system,
  light,
  dark,
}

class UserInterface extends ConsumerStatefulWidget {
  const UserInterface({super.key});

  @override
  ConsumerState<UserInterface> createState() => _UserInterfaceState();
}

class _UserInterfaceState extends ConsumerState<UserInterface> {
  late Map userInterface;

  late String fontSizeVal;
  late String themeMode;
  late String language;

  late String voice;
  late String speechRate;
  late String pitch;

  late bool systemTheme;
  late bool lightTheme;
  late bool darkTheme;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(userInterfaceSettingsDataProvider);

    Brightness platformBrightness =
        View.of(context).platformDispatcher.platformBrightness;

    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('userInterface')),
      ),
      body: settings.when(
        data: (data) {
          userInterface = data!;

          switch (userInterface['fontSizeFactor']) {
            case 'Small':
              fontSizeVal = Translations.of(context).text('small');
              break;
            case 'Medium':
              fontSizeVal = Translations.of(context).text('medium');
              break;
            case 'Large':
              fontSizeVal = Translations.of(context).text('large');
              break;
            case 'Extra Large':
              fontSizeVal = Translations.of(context).text('extraLarge');
              break;
            default:
              fontSizeVal = Translations.of(context).text('medium');
              break;
          }

          switch (userInterface['themeMode']) {
            case 'System':
              themeMode = Translations.of(context).text('system');
              systemTheme = true;
              lightTheme = false;
              darkTheme = false;
              break;
            case 'Light':
              themeMode = Translations.of(context).text('light');
              systemTheme = false;
              lightTheme = true;
              darkTheme = false;
              break;
            case 'Dark':
              themeMode = Translations.of(context).text('dark');
              systemTheme = false;
              lightTheme = false;
              darkTheme = true;
              break;
            default:
              themeMode = Translations.of(context).text('system');
              systemTheme = true;
              lightTheme = false;
              darkTheme = false;
          }

          switch (userInterface['language']) {
            case 'English':
              language = "English";
              break;
            case 'Spanish':
              language = "Español";
              break;
            case 'French':
              language = "Français";
              break;
            case 'German':
              language = "Deutsch";
              break;
            case 'Italian':
              language = "Italiano";
              break;
            case 'Portuguese':
              language = "Português";
              break;
            case 'Russian':
              language = "Русский";
              break;
            case 'Chinese':
              language = "中文";
              break;
            case 'Japanese':
              language = "日本語";
              break;
            case 'Korean':
              language = "한국어";
              break;
            case 'Arabic':
              language = "العربية";
              break;
            case 'Hebrew':
              language = "עברית";
              break;
            case 'Dutch':
              language = "Nederlands";
              break;
            case 'Swedish':
              language = "Svenska";
              break;
            default:
              language = "English";
          }

          switch (userInterface['voice']) {
            case 'System':
              voice = Translations.of(context).text('system');
              break;
            case 'Male':
              voice = Translations.of(context).text('male');
              break;
            case 'Female':
              voice = Translations.of(context).text('female');
              break;
            default:
              voice = Translations.of(context).text('system');
          }

          switch (userInterface['speechRate']) {
            case 'Slow':
              speechRate = Translations.of(context).text('slow');
              break;
            case 'Medium':
              speechRate = Translations.of(context).text('medium');
              break;
            case 'Fast':
              speechRate = Translations.of(context).text('fast');
              break;
            case 'Extra Fast':
              speechRate = Translations.of(context).text('extraFast');
              break;
            default:
              speechRate = Translations.of(context).text('medium');
          }

          switch (userInterface['pitch']) {
            case 'Low':
              pitch = Translations.of(context).text('low');
              break;
            case 'Medium':
              pitch = Translations.of(context).text('medium');
              break;
            case 'High':
              pitch = Translations.of(context).text('high');
              break;
            case 'Extra High':
              pitch = Translations.of(context).text('extraHigh');
              break;
            default:
              pitch = Translations.of(context).text('medium');
          }

          return Column(
            spacing: settingsSpacer,
            children: [
              ListTile(
                title: Text(
                  Translations.of(context).text('display'),
                  style: TextStyle(color: Colors.blueGrey),
                ),
                trailing: SizedBox(
                  width: 200.0,
                ),
              ),
              ListTile(
                title: Text(Translations.of(context).text('themeMode')),
                trailing: SizedBox(
                    child: ToggleButtons(
                  isSelected: [systemTheme, lightTheme, darkTheme],
                  onPressed: (int index) {
                    setState(() {
                      switch (index) {
                        case 0:
                          userInterface['themeMode'] = 'System';

                          if (platformBrightness == Brightness.dark) {
                            switch (data['fontSizeFactor']) {
                              case 'Small':
                                ThemeProvider.controllerOf(context)
                                    .setTheme('blue_accent_dark_small');
                                break;
                              case 'Medium':
                                ThemeProvider.controllerOf(context)
                                    .setTheme('blue_accent_dark_medium');
                                break;
                              case 'Large':
                                ThemeProvider.controllerOf(context)
                                    .setTheme('blue_accent_dark_large');
                                break;
                              case 'Extra Large':
                                ThemeProvider.controllerOf(context)
                                    .setTheme('blue_accent_dark_extra_large');
                                break;
                              default:
                                ThemeProvider.controllerOf(context)
                                    .setTheme('blue_accent_dark_medium');
                            }
                          } else if (platformBrightness == Brightness.light) {
                            switch (data['fontSizeFactor']) {
                              case 'Small':
                                ThemeProvider.controllerOf(context)
                                    .setTheme('blue_accent_light_small');
                                break;
                              case 'Medium':
                                ThemeProvider.controllerOf(context)
                                    .setTheme('blue_accent_light_medium');
                                break;
                              case 'Large':
                                ThemeProvider.controllerOf(context)
                                    .setTheme('blue_accent_light_large');
                                break;
                              case 'Extra Large':
                                ThemeProvider.controllerOf(context)
                                    .setTheme('blue_accent_light_extra_large');
                                break;
                              default:
                                ThemeProvider.controllerOf(context)
                                    .setTheme('blue_accent_light_medium');
                            }
                          }

                          break;
                        case 1:
                          userInterface['themeMode'] = 'Light';

                          switch (userInterface['fontSizeFactor']) {
                            case 'Small':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_light_small');
                              break;
                            case 'Medium':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_light_medium');
                              break;
                            case 'Large':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_light_large');
                              break;
                            case 'Extra Large':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_light_extra_large');
                              break;
                            default:
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_light_medium');
                          }

                          break;
                        case 2:
                          userInterface['themeMode'] = 'Dark';

                          switch (userInterface['fontSizeFactor']) {
                            case 'Small':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_dark_small');
                              break;
                            case 'Medium':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_dark_medium');
                              break;
                            case 'Large':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_dark_large');
                              break;
                            case 'Extra Large':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_dark_extra_large');
                              break;
                            default:
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_dark_medium');
                          }

                          break;
                      }

                      themeModeConfig = userInterface['themeMode'];

                      ref
                          .watch(openAirProvider)
                          .hiveService
                          .saveUserInterfaceSettings(userInterface);
                    });
                  },
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        Translations.of(context).text('system'),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        Translations.of(context).text('light'),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        Translations.of(context).text('dark'),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )),
              ),
              ListTile(
                title: Text(Translations.of(context).text('fontSize')),
                trailing: SizedBox(
                  width: 200.0,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color:
                              ThemeProvider.themeOf(context).data.primaryColor,
                        ),
                    value: fontSizeVal,
                    onChanged: (String? newValue) {
                      setState(() {
                        fontSizeVal = newValue!;
                        String scaleFactor;

                        if (newValue ==
                            Translations.of(context).text('small')) {
                          scaleFactor = 'Small';
                        } else if (newValue ==
                            Translations.of(context).text('medium')) {
                          scaleFactor = 'Medium';
                        } else if (newValue ==
                            Translations.of(context).text('large')) {
                          scaleFactor = 'Large';
                        } else if (newValue ==
                            Translations.of(context).text('extraLarge')) {
                          scaleFactor = 'Extra Large';
                        } else {
                          scaleFactor = 'Medium';
                        }

                        userInterface['fontSizeFactor'] = scaleFactor;
                        fontSizeConfig = userInterface['fontSizeFactor'];

                        ref
                            .watch(openAirProvider)
                            .hiveService
                            .saveUserInterfaceSettings(userInterface);

                        // Apply the theme change immediately
                        if (themeModeConfig == 'Dark') {
                          if (scaleFactor == 'Small') {
                            ThemeProvider.controllerOf(context)
                                .setTheme('blue_accent_dark_small');
                          } else if (scaleFactor == 'Medium') {
                            ThemeProvider.controllerOf(context)
                                .setTheme('blue_accent_dark_medium');
                          } else if (scaleFactor == 'Large') {
                            ThemeProvider.controllerOf(context)
                                .setTheme('blue_accent_dark_large');
                          } else if (scaleFactor == 'Extra Large') {
                            ThemeProvider.controllerOf(context)
                                .setTheme('blue_accent_dark_extra_large');
                          }
                        } else if (themeModeConfig == 'Light') {
                          if (scaleFactor == 'Small') {
                            ThemeProvider.controllerOf(context)
                                .setTheme('blue_accent_light_small');
                          } else if (scaleFactor == 'Medium') {
                            ThemeProvider.controllerOf(context)
                                .setTheme('blue_accent_light_medium');
                          } else if (scaleFactor == 'Large') {
                            ThemeProvider.controllerOf(context)
                                .setTheme('blue_accent_light_large');
                          } else if (scaleFactor == 'Extra Large') {
                            ThemeProvider.controllerOf(context)
                                .setTheme('blue_accent_light_extra_large');
                          }
                        }
                        // System Theme
                        else {
                          if (platformBrightness == Brightness.dark) {
                            if (scaleFactor == 'Small') {
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_dark_small');
                            } else if (scaleFactor == 'Medium') {
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_dark_medium');
                            } else if (scaleFactor == 'Large') {
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_dark_large');
                            } else if (scaleFactor == 'Extra Large') {
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_dark_extra_large');
                            }
                          } else if (platformBrightness == Brightness.light) {
                            if (scaleFactor == 'Small') {
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_light_small');
                            } else if (scaleFactor == 'Medium') {
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_light_medium');
                            } else if (scaleFactor == 'Large') {
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_light_large');
                            } else if (scaleFactor == 'Extra Large') {
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_light_extra_large');
                            }
                          }
                        }
                      });
                    },
                    items: <String>[
                      Translations.of(context).text('small'),
                      Translations.of(context).text('medium'),
                      Translations.of(context).text('large'),
                      Translations.of(context).text('extraLarge'),
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              ListTile(
                title: Text(Translations.of(context).text('language')),
                trailing: SizedBox(
                  width: 200.0,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color:
                              ThemeProvider.themeOf(context).data.primaryColor,
                        ),
                    value: language,
                    onChanged: (String? newValue) {
                      String saveValue;
                      String localeStr;
                      late Locale locale;

                      if (newValue == "English") {
                        saveValue = 'English';
                        localeStr = Localization.en_US;
                        locale = const Locale('en', 'US');
                      } else if (newValue == "Español") {
                        saveValue = 'Spanish';
                        localeStr = Localization.es_ES;
                        locale = const Locale('es', 'ES');
                      } else if (newValue == "Français") {
                        saveValue = 'French';
                        localeStr = Localization.fr_FR;
                        locale = const Locale('fr', 'FR');
                      } else if (newValue == "Deutsch") {
                        saveValue = 'German';
                        localeStr = Localization.de_DE;
                        locale = const Locale('de', 'DE');
                      } else if (newValue == "Italiano") {
                        saveValue = 'Italian';
                        localeStr = Localization.it_IT;
                        locale = const Locale('it', 'IT');
                      } else if (newValue == "Português") {
                        saveValue = 'Portuguese';
                        localeStr = Localization.pt_PT;
                        locale = const Locale('pt', 'PT');
                      } else if (newValue == "Русский") {
                        saveValue = 'Russian';
                        localeStr = Localization.ru_RU;
                        locale = const Locale('ru', 'RU');
                      } else if (newValue == "中文") {
                        saveValue = 'Chinese';
                        localeStr = Localization.zh_CN;
                        locale = const Locale('zh', 'CN');
                      } else if (newValue == "日本語") {
                        saveValue = 'Japanese';
                        localeStr = Localization.ja_JP;
                        locale = const Locale('ja', 'JP');
                      } else if (newValue == "한국어") {
                        saveValue = 'Korean';
                        localeStr = Localization.ko_KR;
                        locale = const Locale('ko', 'KR');
                      } else if (newValue == "العربية") {
                        saveValue = 'Arabic';
                        localeStr = Localization.ar_AE;
                        locale = const Locale('ar', 'AE');
                      } else if (newValue == "עברית") {
                        saveValue = 'Hebrew';
                        localeStr = Localization.he_IL;
                        locale = const Locale('he', 'IL');
                      } else if (newValue == "Nederlands") {
                        saveValue = 'Dutch';
                        localeStr = Localization.nl_NL;
                        locale = const Locale('nl', 'NL');
                      } else if (newValue == "Svenska") {
                        saveValue = 'Swedish';
                        localeStr = Localization.sv_SE;
                        locale = const Locale('sv', 'SE');
                      } else {
                        saveValue = 'English';
                        localeStr = Localization.en_US;
                        locale = const Locale('en', 'US');
                      }

                      setState(() {
                        userInterface['language'] = saveValue;
                        userInterface['locale'] = localeStr;
                        languageConfig = saveValue;
                        localeConfig = localeStr;

                        localeSettings = localeStr;
                        onChanged = false;

                        Translations.changeLanguage(localeStr);

                        // Update the locale provider to trigger UI refresh
                        ref.read(localeProvider.notifier).setLocale(locale);

                        ref
                            .watch(openAirProvider)
                            .hiveService
                            .saveUserInterfaceSettings(userInterface);
                      });
                    },
                    items: <String>[
                      "English",
                      "Español",
                      "Français",
                      "Deutsch",
                      "Italiano",
                      "Português",
                      "Русский",
                      "中文",
                      "日本語",
                      "한국어",
                      "العربية",
                      "עברית",
                      "Nederlands",
                      "Svenska",
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
        },
        error: (error, stackTrace) {
          return Text(Translations.of(context).text('oopsAnErrorOccurred'));
        },
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
