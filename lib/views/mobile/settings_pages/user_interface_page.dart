import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_localizations_plus/localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:theme_provider/theme_provider.dart';

final FutureProvider<Map?> userInterfaceSettingsDataProvider =
    FutureProvider((ref) async {
  final hiveService = ref.watch(hiveServiceProvider);

  Map? userInterfaceSettings = await hiveService.getUserInterfaceSettings();

  if (userInterfaceSettings == null) {
    userInterfaceSettings = {
      'fontSizeFactor': 1.0,
      'themeMode': 'System',
      'language': 'English',
      'locale': 'en_US',
      'voice': 'System',
      'speechRate': 'Medium',
      'pitch': 'Medium',
    };

    hiveService.saveUserInterfaceSettings(userInterfaceSettings);
  }

  return userInterfaceSettings;
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

  late String fontSize;
  late String themeMode;
  late String language;

  late String voice;
  late String speechRate;
  late String pitch;

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
            case 0.875:
              fontSize = Translations.of(context).text('small');
              break;
            case 1.0:
              fontSize = Translations.of(context).text('medium');
              break;
            case 1.125:
              fontSize = Translations.of(context).text('large');
              break;
            case 1.25:
              fontSize = Translations.of(context).text('extraLarge');
              break;
            default:
              fontSize = Translations.of(context).text('medium');
              break;
          }

          switch (userInterface['themeMode']) {
            case 'System':
              themeMode = Translations.of(context).text('system');
              break;
            case 'Light':
              themeMode = Translations.of(context).text('light');
              break;
            case 'Dark':
              themeMode = Translations.of(context).text('dark');
              break;
            default:
              themeMode = Translations.of(context).text('system');
          }

          switch (userInterface['language']) {
            case 'English':
              language = Translations.of(context).text('english');
              break;
            case 'Spanish':
              language = Translations.of(context).text('spanish');
              break;
            case 'French':
              language = Translations.of(context).text('french');
              break;
            case 'German':
              language = Translations.of(context).text('german');
              break;
            case 'Italian':
              language = Translations.of(context).text('italian');
              break;
            case 'Portuguese':
              language = Translations.of(context).text('portuguese');
              break;
            case 'Russian':
              language = Translations.of(context).text('russian');
              break;
            case 'Chinese':
              language = Translations.of(context).text('chinese');
              break;
            case 'Japanese':
              language = Translations.of(context).text('japanese');
              break;
            case 'Korean':
              language = Translations.of(context).text('korean');
              break;
            case 'Arabic':
              language = Translations.of(context).text('arabic');
              break;
            case 'Hebrew':
              language = Translations.of(context).text('hebrew');
              break;
            case 'Dutch':
              language = Translations.of(context).text('dutch');
              break;
            case 'Swedish':
              language = Translations.of(context).text('swedish');
              break;
            default:
              language = Translations.of(context).text('english');
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

          return ListView(
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
                  width: 200.0,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    style: TextStyle(
                      color: ThemeProvider.themeOf(context).data.primaryColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                    value: themeMode,
                    onChanged: (String? newValue) {
                      setState(() {
                        String saveValue;

                        if (newValue ==
                            Translations.of(context).text('system')) {
                          saveValue = 'System';
                        } else if (newValue ==
                            Translations.of(context).text('light')) {
                          saveValue = 'Light';
                        } else if (newValue ==
                            Translations.of(context).text('dark')) {
                          saveValue = 'Dark';
                        } else {
                          saveValue = 'System';
                        }

                        userInterface['themeMode'] = saveValue;

                        ref
                            .read(hiveServiceProvider)
                            .saveUserInterfaceSettings(userInterface);
                      });

                      if (newValue == Translations.of(context).text('system')) {
                        if (platformBrightness == Brightness.dark) {
                          switch (data['fontSizeFactor']) {
                            case 0.875:
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_dark_small');
                              break;
                            case 1.0:
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_dark_medium');
                              break;
                            case 1.125:
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_dark_large');
                              break;
                            case 1.25:
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_dark_extra_large');
                              break;
                            default:
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_dark_medium');
                          }
                        } else if (platformBrightness == Brightness.light) {
                          switch (data['fontSizeFactor']) {
                            case 0.875:
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_light_small');
                              break;
                            case 1.0:
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_light_medium');
                              break;
                            case 1.125:
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_light_large');
                              break;
                            case 1.25:
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_light_extra_large');
                              break;
                            default:
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_light_medium');
                          }
                        }
                      } else if (newValue ==
                          Translations.of(context).text('light')) {
                        switch (userInterface['fontSizeFactor']) {
                          case 0.875:
                            ThemeProvider.controllerOf(context)
                                .setTheme('blue_accent_light_small');
                            break;
                          case 1.0:
                            ThemeProvider.controllerOf(context)
                                .setTheme('blue_accent_light_medium');
                            break;
                          case 1.125:
                            ThemeProvider.controllerOf(context)
                                .setTheme('blue_accent_light_large');
                            break;
                          case 1.25:
                            ThemeProvider.controllerOf(context)
                                .setTheme('blue_accent_light_extra_large');
                            break;
                          default:
                            ThemeProvider.controllerOf(context)
                                .setTheme('blue_accent_light_medium');
                        }
                      } else if (newValue ==
                          Translations.of(context).text('dark')) {
                        switch (userInterface['fontSizeFactor']) {
                          case 0.875:
                            ThemeProvider.controllerOf(context)
                                .setTheme('blue_accent_dark_small');
                            break;
                          case 1.0:
                            ThemeProvider.controllerOf(context)
                                .setTheme('blue_accent_dark_medium');
                            break;
                          case 1.125:
                            ThemeProvider.controllerOf(context)
                                .setTheme('blue_accent_dark_large');
                            break;
                          case 1.25:
                            ThemeProvider.controllerOf(context)
                                .setTheme('blue_accent_dark_extra_large');
                            break;
                          default:
                            ThemeProvider.controllerOf(context)
                                .setTheme('blue_accent_dark_medium');
                        }
                      }
                    },
                    items: <String>[
                      Translations.of(context).text('system'),
                      Translations.of(context).text('light'),
                      Translations.of(context).text('dark'),
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
              SizedBox(height: settingsSpacer),
              ListTile(
                title: Text(Translations.of(context).text('fontSize')),
                trailing: SizedBox(
                  width: 200.0,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    style: TextStyle(
                      color: ThemeProvider.themeOf(context).data.primaryColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                    value: fontSize,
                    onChanged: (String? newValue) {
                      setState(() {
                        fontSize = newValue!;
                        double scaleFactor;

                        if (newValue ==
                            Translations.of(context).text('small')) {
                          scaleFactor = 0.875;
                        } else if (newValue ==
                            Translations.of(context).text('medium')) {
                          scaleFactor = 1.0;
                        } else if (newValue ==
                            Translations.of(context).text('large')) {
                          scaleFactor = 1.125;
                        } else if (newValue ==
                            Translations.of(context).text('extraLarge')) {
                          scaleFactor = 1.25;
                        } else {
                          scaleFactor = 1.0;
                        }

                        userInterface['fontSizeFactor'] = scaleFactor;
                        ref
                            .read(hiveServiceProvider)
                            .saveUserInterfaceSettings(userInterface);

                        switch (
                            ThemeProvider.themeOf(context).data.brightness) {
                          case Brightness.dark:
                            switch (scaleFactor) {
                              case 0.875:
                                ThemeProvider.controllerOf(context)
                                    .setTheme('blue_accent_dark_small');
                                break;
                              case 1.0:
                                ThemeProvider.controllerOf(context)
                                    .setTheme('blue_accent_dark_medium');
                                break;
                              case 1.125:
                                ThemeProvider.controllerOf(context)
                                    .setTheme('blue_accent_dark_large');
                                break;
                              case 1.25:
                                ThemeProvider.controllerOf(context)
                                    .setTheme('blue_accent_dark_extra_large');
                                break;
                              default:
                                ThemeProvider.controllerOf(context)
                                    .setTheme('blue_accent_dark_medium');
                            }
                            break;
                          case Brightness.light:
                            switch (scaleFactor) {
                              case 0.875:
                                ThemeProvider.controllerOf(context)
                                    .setTheme('blue_accent_light_small');
                                break;
                              case 1.0:
                                ThemeProvider.controllerOf(context)
                                    .setTheme('blue_accent_light_medium');
                                break;
                              case 1.125:
                                ThemeProvider.controllerOf(context)
                                    .setTheme('blue_accent_light_large');
                                break;
                              case 1.25:
                                ThemeProvider.controllerOf(context)
                                    .setTheme('blue_accent_light_extra_large');
                                break;
                              default:
                                ThemeProvider.controllerOf(context)
                                    .setTheme('blue_accent_light_medium');
                            }
                            break;
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
              SizedBox(height: settingsSpacer),
              ListTile(
                title: Text(Translations.of(context).text('language')),
                trailing: SizedBox(
                  width: 200.0,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    style: TextStyle(
                      color: ThemeProvider.themeOf(context).data.primaryColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                    value: language,
                    onChanged: (String? newValue) {
                      String saveValue;
                      String locale;

                      if (newValue ==
                          Translations.of(context).text('english')) {
                        saveValue = 'English';
                        locale = Localization.en_US;
                      } else if (newValue ==
                          Translations.of(context).text('spanish')) {
                        saveValue = 'Spanish';
                        locale = Localization.es_ES;
                      } else if (newValue ==
                          Translations.of(context).text('french')) {
                        saveValue = 'French';
                        locale = Localization.fr_FR;
                      } else if (newValue ==
                          Translations.of(context).text('german')) {
                        saveValue = 'German';
                        locale = Localization.de_DE;
                      } else if (newValue ==
                          Translations.of(context).text('italian')) {
                        saveValue = 'Italian';
                        locale = Localization.it_IT;
                      } else if (newValue ==
                          Translations.of(context).text('portuguese')) {
                        saveValue = 'Portuguese';
                        locale = Localization.pt_PT;
                      } else if (newValue ==
                          Translations.of(context).text('russian')) {
                        saveValue = 'Russian';
                        locale = Localization.ru_RU;
                      } else if (newValue ==
                          Translations.of(context).text('chinese')) {
                        saveValue = 'Chinese';
                        locale = Localization.zh_CN;
                      } else if (newValue ==
                          Translations.of(context).text('japanese')) {
                        saveValue = 'Japanese';
                        locale = Localization.ja_JP;
                      } else if (newValue ==
                          Translations.of(context).text('korean')) {
                        saveValue = 'Korean';
                        locale = Localization.ko_KR;
                      } else if (newValue ==
                          Translations.of(context).text('arabic')) {
                        saveValue = 'Arabic';
                        locale = Localization.ar_AE;
                      } else if (newValue ==
                          Translations.of(context).text('hebrew')) {
                        saveValue = 'Hebrew';
                        locale = Localization.he_IL;
                      } else if (newValue ==
                          Translations.of(context).text('dutch')) {
                        saveValue = 'Dutch';
                        locale = Localization.nl_NL;
                      } else if (newValue ==
                          Translations.of(context).text('swedish')) {
                        saveValue = 'Swedish';
                        locale = Localization.sv_SE;
                      } else {
                        saveValue = 'English';
                        locale = Localization.en_US;
                      }

                      setState(() {
                        userInterface['language'] = saveValue;
                        userInterface['locale'] = locale;
                        localeSettings = locale;
                        onChanged = false;

                        Translations.changeLanguage(locale);

                        ref
                            .read(hiveServiceProvider)
                            .saveUserInterfaceSettings(userInterface);
                      });
                    },
                    items: <String>[
                      Translations.of(context).text('english'),
                      Translations.of(context).text('spanish'),
                      Translations.of(context).text('french'),
                      Translations.of(context).text('german'),
                      Translations.of(context).text('italian'),
                      Translations.of(context).text('portuguese'),
                      Translations.of(context).text('russian'),
                      Translations.of(context).text('chinese'),
                      Translations.of(context).text('japanese'),
                      Translations.of(context).text('korean'),
                      Translations.of(context).text('arabic'),
                      Translations.of(context).text('hebrew'),
                      Translations.of(context).text('dutch'),
                      Translations.of(context).text('swedish'),
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
              SizedBox(height: settingsSpacer),
              Divider(),
              ListTile(
                title: Text(
                  Translations.of(context).text('voice'),
                  style: TextStyle(color: Colors.blueGrey),
                ),
                trailing: SizedBox(
                  width: 200.0,
                ),
              ),
              SizedBox(height: settingsSpacer),
              ListTile(
                title: Text(Translations.of(context).text('voice')),
                trailing: SizedBox(
                  width: 200.0,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    style: TextStyle(
                      color: ThemeProvider.themeOf(context).data.primaryColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                    value: voice,
                    onChanged: (String? newValue) {
                      setState(() {
                        String saveValue;

                        if (newValue ==
                            Translations.of(context).text('system')) {
                          saveValue = 'System';
                        } else if (newValue ==
                            Translations.of(context).text('male')) {
                          saveValue = 'Male';
                        } else if (newValue ==
                            Translations.of(context).text('female')) {
                          saveValue = 'Female';
                        } else {
                          saveValue = 'System';
                        }

                        userInterface['voice'] = saveValue;

                        ref
                            .read(hiveServiceProvider)
                            .saveUserInterfaceSettings(userInterface);
                      });
                    },
                    items: <String>[
                      Translations.of(context).text('system'),
                      Translations.of(context).text('male'),
                      Translations.of(context).text('female'),
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
              SizedBox(height: settingsSpacer),
              ListTile(
                title: Text(Translations.of(context).text('speechRate')),
                trailing: SizedBox(
                  width: 200.0,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    style: TextStyle(
                      color: ThemeProvider.themeOf(context).data.primaryColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                    value: speechRate,
                    onChanged: (String? newValue) {
                      setState(() {
                        userInterface['speechRate'] = newValue!;
                        ref
                            .read(hiveServiceProvider)
                            .saveUserInterfaceSettings(userInterface);
                      });
                    },
                    items: <String>[
                      Translations.of(context).text('slow'),
                      Translations.of(context).text('medium'),
                      Translations.of(context).text('fast'),
                      'Extra Fast',
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
              SizedBox(height: settingsSpacer),
              ListTile(
                title: Text(Translations.of(context).text('pitch')),
                trailing: SizedBox(
                  width: 200.0,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    style: TextStyle(
                      color: ThemeProvider.themeOf(context).data.primaryColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                    value: pitch,
                    onChanged: (String? newValue) {
                      setState(() {
                        userInterface['pitch'] = newValue!;
                        ref
                            .read(hiveServiceProvider)
                            .saveUserInterfaceSettings(userInterface);
                      });
                    },
                    items: <String>[
                      Translations.of(context).text('low'),
                      Translations.of(context).text('medium'),
                      Translations.of(context).text('high'),
                      Translations.of(context).text('extraHigh'),
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
