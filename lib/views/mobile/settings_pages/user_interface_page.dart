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
                              case 'small':
                                ThemeProvider.controllerOf(context)
                                    .setTheme('blue_accent_dark_small');
                                break;
                              case 'medium':
                                ThemeProvider.controllerOf(context)
                                    .setTheme('blue_accent_dark_medium');
                                break;
                              case 'large':
                                ThemeProvider.controllerOf(context)
                                    .setTheme('blue_accent_dark_large');
                                break;
                              case 'extraLarge':
                                ThemeProvider.controllerOf(context)
                                    .setTheme('blue_accent_dark_extra_large');
                                break;
                              default:
                                ThemeProvider.controllerOf(context)
                                    .setTheme('blue_accent_dark_medium');
                            }
                          } else if (platformBrightness == Brightness.light) {
                            switch (data['fontSizeFactor']) {
                              case 'small':
                                ThemeProvider.controllerOf(context)
                                    .setTheme('blue_accent_light_small');
                                break;
                              case 'medium':
                                ThemeProvider.controllerOf(context)
                                    .setTheme('blue_accent_light_medium');
                                break;
                              case 'large':
                                ThemeProvider.controllerOf(context)
                                    .setTheme('blue_accent_light_large');
                                break;
                              case 'extraLarge':
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
                            case 'small':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_light_small');
                              break;
                            case 'medium':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_light_medium');
                              break;
                            case 'large':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_light_large');
                              break;
                            case 'extraLarge':
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
                            case 'small':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_dark_small');
                              break;
                            case 'medium':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_dark_medium');
                              break;
                            case 'large':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_dark_large');
                              break;
                            case 'extraLarge':
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
                    style: TextStyle(
                      color: ThemeProvider.themeOf(context).data.primaryColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
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
                        languageConfig = userInterface['language'];
                        localeConfig = userInterface['locale'];

                        final localeParts = locale.split('_');
                        final languageCode = localeParts[0];
                        final countryCode = localeParts[1];
                        final newLocale = Locale(languageCode, countryCode);
                        ref.read(localeProvider.notifier).setLocale(newLocale);

                        ref
                            .watch(openAirProvider)
                            .hiveService
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
