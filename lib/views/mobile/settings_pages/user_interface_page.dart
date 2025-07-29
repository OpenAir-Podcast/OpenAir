import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:openair/models/settings_model.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:theme_provider/theme_provider.dart';

final settingsDataProvider = FutureProvider(
  (ref) async {
    SettingsModel? settings = await ref.read(hiveServiceProvider).getSettings();
    return settings;
  },
);

class UserInterface extends ConsumerStatefulWidget {
  const UserInterface({super.key});

  @override
  ConsumerState<UserInterface> createState() => _UserInterfaceState();
}

class _UserInterfaceState extends ConsumerState<UserInterface> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Interface'),
      ),
      body: settings.when(
        data: (data) {
          return ListView(
            children: [
              ListTile(
                title: Text(
                  'Display',
                  style: TextStyle(color: Colors.blueGrey),
                ),
                trailing: SizedBox(
                  width: 200.0,
                ),
              ),
              SizedBox(height: ref.read(openAirProvider).config.settingsSpacer),
              ListTile(
                title: Text('Theme Mode'),
                trailing: SizedBox(
                  width: 200.0,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    style: TextStyle(
                      color: ThemeProvider.themeOf(context).data.primaryColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                    value: data.themeModeString,
                    onChanged: (String? newValue) {
                      setState(() {
                        data.themeModeString = newValue!;
                        ref.watch(hiveServiceProvider).saveSettings(data);
                      });

                      if (newValue == 'System') {
                        Brightness platformBrightness = View.of(context)
                            .platformDispatcher
                            .platformBrightness;

                        if (platformBrightness == Brightness.dark) {
                          switch (data.accentColorString) {
                            case 'Blue':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_dark');
                              break;
                            case 'Red':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('red_accent_dark');
                              break;
                            case 'Green':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('green_accent_dark');
                              break;
                            case 'Yellow':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('yellow_accent_dark');
                              break;
                            case 'Orange':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('orange_accent_dark');
                              break;
                            case 'Purple':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('purple_accent_dark');
                              break;
                            case 'Pink':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('pink_accent_dark');
                              break;
                            case 'Teal':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('teal_accent_dark');
                              break;
                            case 'Cyan':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('cyan_accent_dark');
                              break;
                            case 'Indigo':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('indigo_accent_dark');
                              break;
                            default:
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_dark');
                          }
                        } else {
                          switch (data.accentColorString) {
                            case 'Blue':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_light');
                              break;
                            case 'Red':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('red_accent_light');
                              break;
                            case 'Green':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('green_accent_light');
                              break;
                            case 'Yellow':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('yellow_accent_light');
                              break;
                            case 'Orange':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('orange_accent_light');
                              break;
                            case 'Purple':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('purple_accent_light');
                              break;
                            case 'Pink':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('pink_accent_light');
                              break;
                            case 'Teal':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('teal_accent_light');
                              break;
                            case 'Cyan':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('cyan_accent_light');
                              break;
                            case 'Indigo':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('indigo_accent_light');
                              break;
                            default:
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_light');
                          }
                        }

                        ThemeProvider.controllerOf(context).forgetSavedTheme();
                      } else if (newValue == 'Light') {
                        switch (data.accentColorString) {
                          case 'Blue':
                            ThemeProvider.controllerOf(context)
                                .setTheme('blue_accent_light');
                            break;
                          case 'Red':
                            ThemeProvider.controllerOf(context)
                                .setTheme('red_accent_light');
                            break;
                          case 'Green':
                            ThemeProvider.controllerOf(context)
                                .setTheme('green_accent_light');
                            break;
                          case 'Yellow':
                            ThemeProvider.controllerOf(context)
                                .setTheme('yellow_accent_light');
                            break;
                          case 'Orange':
                            ThemeProvider.controllerOf(context)
                                .setTheme('orange_accent_light');
                            break;
                          case 'Purple':
                            ThemeProvider.controllerOf(context)
                                .setTheme('purple_accent_light');
                            break;
                          case 'Pink':
                            ThemeProvider.controllerOf(context)
                                .setTheme('pink_accent_light');
                            break;
                          case 'Teal':
                            ThemeProvider.controllerOf(context)
                                .setTheme('teal_accent_light');
                            break;
                          case 'Cyan':
                            ThemeProvider.controllerOf(context)
                                .setTheme('cyan_accent_light');
                            break;
                          case 'Indigo':
                            ThemeProvider.controllerOf(context)
                                .setTheme('indigo_accent_light');
                            break;
                          default:
                            ThemeProvider.controllerOf(context)
                                .setTheme('blue_accent_light');
                        }

                        ThemeProvider.controllerOf(context).forgetSavedTheme();
                      } else if (newValue == 'Dark') {
                        switch (data.accentColorString) {
                          case 'Blue':
                            ThemeProvider.controllerOf(context)
                                .setTheme('blue_accent_dark');
                            break;
                          case 'Red':
                            ThemeProvider.controllerOf(context)
                                .setTheme('red_accent_dark');
                            break;
                          case 'Green':
                            ThemeProvider.controllerOf(context)
                                .setTheme('green_accent_dark');
                            break;
                          case 'Yellow':
                            ThemeProvider.controllerOf(context)
                                .setTheme('yellow_accent_dark');
                            break;
                          case 'Orange':
                            ThemeProvider.controllerOf(context)
                                .setTheme('orange_accent_dark');
                            break;
                          case 'Purple':
                            ThemeProvider.controllerOf(context)
                                .setTheme('purple_accent_dark');
                            break;
                          case 'Pink':
                            ThemeProvider.controllerOf(context)
                                .setTheme('pink_accent_dark');
                            break;
                          case 'Teal':
                            ThemeProvider.controllerOf(context)
                                .setTheme('teal_accent_dark');
                            break;
                          case 'Cyan':
                            ThemeProvider.controllerOf(context)
                                .setTheme('cyan_accent_dark');
                            break;
                          case 'Indigo':
                            ThemeProvider.controllerOf(context)
                                .setTheme('indigo_accent_dark');
                            break;
                          default:
                            ThemeProvider.controllerOf(context)
                                .setTheme('blue_accent_dark');
                        }

                        ThemeProvider.controllerOf(context).forgetSavedTheme();
                      } else if (newValue == 'Black/AMOLED') {
                        switch (data.accentColorString) {
                          case 'Blue':
                            ThemeProvider.controllerOf(context)
                                .setTheme('blue_accent_amoled');
                            break;
                          case 'Red':
                            ThemeProvider.controllerOf(context)
                                .setTheme('red_accent_amoled');
                            break;
                          case 'Green':
                            ThemeProvider.controllerOf(context)
                                .setTheme('green_accent_amoled');
                            break;
                          case 'Yellow':
                            ThemeProvider.controllerOf(context)
                                .setTheme('yellow_accent_amoled');
                            break;
                          case 'Orange':
                            ThemeProvider.controllerOf(context)
                                .setTheme('orange_accent_amoled');
                            break;
                          case 'Purple':
                            ThemeProvider.controllerOf(context)
                                .setTheme('purple_accent_amoled');
                            break;
                          case 'Pink':
                            ThemeProvider.controllerOf(context)
                                .setTheme('pink_accent_amoled');
                            break;
                          case 'Teal':
                            ThemeProvider.controllerOf(context)
                                .setTheme('teal_accent_amoled');
                            break;
                          case 'Cyan':
                            ThemeProvider.controllerOf(context)
                                .setTheme('cyan_accent_amoled');
                            break;
                          case 'Indigo':
                            ThemeProvider.controllerOf(context)
                                .setTheme('indigo_accent_amoled');
                            break;
                          default:
                            ThemeProvider.controllerOf(context)
                                .setTheme('blue_accent_amoled');
                        }

                        ThemeProvider.controllerOf(context).forgetSavedTheme();
                      }
                    },
                    items: <String>[
                      'System',
                      'Light',
                      'Dark',
                      'Black/AMOLED',
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
              SizedBox(height: ref.read(openAirProvider).config.settingsSpacer),
              ListTile(
                title: Text('Accent Color'),
                trailing: SizedBox(
                  width: 200.0,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    style: TextStyle(
                      color: ThemeProvider.themeOf(context).data.primaryColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                    value: data.accentColorString,
                    onChanged: (String? newValue) {
                      data.accentColorString = newValue!;
                      ref.watch(hiveServiceProvider).saveSettings(data);

                      if (data.themeModeString == 'System') {
                        Brightness platformBrightness = View.of(context)
                            .platformDispatcher
                            .platformBrightness;

                        if (platformBrightness == Brightness.dark) {
                          switch (newValue) {
                            case 'Blue':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_dark');
                              break;
                            case 'Red':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('red_accent_dark');
                              break;
                            case 'Green':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('green_accent_dark');
                              break;
                            case 'Yellow':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('yellow_accent_dark');
                              break;
                            case 'Orange':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('orange_accent_dark');
                              break;
                            case 'Purple':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('purple_accent_dark');
                              break;
                            case 'Pink':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('pink_accent_dark');
                              break;
                            case 'Teal':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('teal_accent_dark');
                              break;
                            case 'Cyan':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('cyan_accent_dark');
                              break;
                            case 'Indigo':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('indigo_accent_dark');
                              break;
                            default:
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_dark');
                          }
                        } else {
                          switch (newValue) {
                            case 'Blue':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_light');
                              break;
                            case 'Red':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('red_accent_light');
                              break;
                            case 'Green':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('green_accent_light');
                              break;
                            case 'Yellow':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('yellow_accent_light');
                              break;
                            case 'Orange':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('orange_accent_light');
                              break;
                            case 'Purple':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('purple_accent_light');
                              break;
                            case 'Pink':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('pink_accent_light');
                              break;
                            case 'Teal':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('teal_accent_light');
                              break;
                            case 'Cyan':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('cyan_accent_light');
                              break;
                            case 'Indigo':
                              ThemeProvider.controllerOf(context)
                                  .setTheme('indigo_accent_light');
                              break;
                            default:
                              ThemeProvider.controllerOf(context)
                                  .setTheme('blue_accent_light');
                          }
                        }
                      } else if (data.themeModeString == 'Light') {
                        switch (newValue) {
                          case 'Blue':
                            ThemeProvider.controllerOf(context)
                                .setTheme('blue_accent_light');
                            break;
                          case 'Red':
                            ThemeProvider.controllerOf(context)
                                .setTheme('red_accent_light');
                            break;
                          case 'Green':
                            ThemeProvider.controllerOf(context)
                                .setTheme('green_accent_light');
                            break;
                          case 'Yellow':
                            ThemeProvider.controllerOf(context)
                                .setTheme('yellow_accent_light');
                            break;
                          case 'Orange':
                            ThemeProvider.controllerOf(context)
                                .setTheme('orange_accent_light');
                            break;
                          case 'Purple':
                            ThemeProvider.controllerOf(context)
                                .setTheme('purple_accent_light');
                            break;
                          case 'Pink':
                            ThemeProvider.controllerOf(context)
                                .setTheme('pink_accent_light');
                            break;
                          case 'Teal':
                            ThemeProvider.controllerOf(context)
                                .setTheme('teal_accent_light');
                            break;
                          case 'Cyan':
                            ThemeProvider.controllerOf(context)
                                .setTheme('cyan_accent_light');
                            break;
                          case 'Indigo':
                            ThemeProvider.controllerOf(context)
                                .setTheme('indigo_accent_light');
                            break;
                          default:
                            ThemeProvider.controllerOf(context)
                                .setTheme('blue_accent_light');
                        }
                      } else if (data.themeModeString == 'Dark') {
                        switch (newValue) {
                          case 'Blue':
                            ThemeProvider.controllerOf(context)
                                .setTheme('blue_accent_dark');
                            break;
                          case 'Red':
                            ThemeProvider.controllerOf(context)
                                .setTheme('red_accent_dark');
                            break;
                          case 'Green':
                            ThemeProvider.controllerOf(context)
                                .setTheme('green_accent_dark');
                            break;
                          case 'Yellow':
                            ThemeProvider.controllerOf(context)
                                .setTheme('yellow_accent_dark');
                            break;
                          case 'Orange':
                            ThemeProvider.controllerOf(context)
                                .setTheme('orange_accent_dark');
                            break;
                          case 'Purple':
                            ThemeProvider.controllerOf(context)
                                .setTheme('purple_accent_dark');
                            break;
                          case 'Pink':
                            ThemeProvider.controllerOf(context)
                                .setTheme('pink_accent_dark');
                            break;
                          case 'Teal':
                            ThemeProvider.controllerOf(context)
                                .setTheme('teal_accent_dark');
                            break;
                          case 'Cyan':
                            ThemeProvider.controllerOf(context)
                                .setTheme('cyan_accent_dark');
                            break;
                          case 'Indigo':
                            ThemeProvider.controllerOf(context)
                                .setTheme('indigo_accent_dark');
                            break;
                          default:
                            ThemeProvider.controllerOf(context)
                                .setTheme('blue_accent_dark');
                        }
                      } else if (data.themeModeString == 'Black/AMOLED') {
                        switch (newValue) {
                          case 'Blue':
                            ThemeProvider.controllerOf(context)
                                .setTheme('blue_accent_amoled');
                            break;
                          case 'Red':
                            ThemeProvider.controllerOf(context)
                                .setTheme('red_accent_amoled');
                            break;
                          case 'Green':
                            ThemeProvider.controllerOf(context)
                                .setTheme('green_accent_amoled');
                            break;
                          case 'Yellow':
                            ThemeProvider.controllerOf(context)
                                .setTheme('yellow_accent_amoled');
                            break;
                          case 'Orange':
                            ThemeProvider.controllerOf(context)
                                .setTheme('orange_accent_amoled');
                            break;
                          case 'Purple':
                            ThemeProvider.controllerOf(context)
                                .setTheme('purple_accent_amoled');
                            break;
                          case 'Pink':
                            ThemeProvider.controllerOf(context)
                                .setTheme('pink_accent_amoled');
                            break;
                          case 'Teal':
                            ThemeProvider.controllerOf(context)
                                .setTheme('teal_accent_amoled');
                            break;
                          case 'Cyan':
                            ThemeProvider.controllerOf(context)
                                .setTheme('cyan_accent_amoled');
                            break;
                          case 'Indigo':
                            ThemeProvider.controllerOf(context)
                                .setTheme('indigo_accent_amoled');
                            break;
                          default:
                            ThemeProvider.controllerOf(context)
                                .setTheme('blue_accent_amoled');
                        }
                      }
                    },
                    items: <String>[
                      'Blue',
                      'Red',
                      'Green',
                      'Yellow',
                      'Orange',
                      'Purple',
                      'Pink',
                      'Teal',
                      'Cyan',
                      'Indigo'
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
              SizedBox(height: ref.read(openAirProvider).config.settingsSpacer),
              ListTile(
                title: Text('Font Size'),
                trailing: SizedBox(
                  width: 200.0,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    style: TextStyle(
                      color: ThemeProvider.themeOf(context).data.primaryColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                    value: data.fontSizeString,
                    onChanged: (String? newValue) {
                      setState(() {
                        data.fontSizeString = newValue!;
                        ref.watch(hiveServiceProvider).saveSettings(data);
                      });
                    },
                    items: <String>[
                      'Small',
                      'Medium',
                      'Large',
                      'Extra Large',
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
              SizedBox(height: ref.read(openAirProvider).config.settingsSpacer),
              ListTile(
                title: Text('Language'),
                trailing: SizedBox(
                  width: 200.0,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    style: TextStyle(
                      color: ThemeProvider.themeOf(context).data.primaryColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                    value: data.languageString,
                    onChanged: (String? newValue) {
                      setState(() {
                        data.languageString = newValue!;
                        ref.watch(hiveServiceProvider).saveSettings(data);
                      });
                    },
                    items: <String>[
                      'English',
                      'Spanish',
                      'French',
                      'German',
                      'Italian',
                      'Portuguese',
                      'Russian',
                      'Chinese',
                      'Japanese',
                      'Korean',
                      'Arabic',
                      'Hebrew',
                      'Dutch',
                      'Swedish',
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
              SizedBox(height: ref.read(openAirProvider).config.settingsSpacer),
              Divider(),
              ListTile(
                title: Text(
                  'Voice',
                  style: TextStyle(color: Colors.blueGrey),
                ),
                trailing: SizedBox(
                  width: 200.0,
                ),
              ),
              SizedBox(height: ref.read(openAirProvider).config.settingsSpacer),
              ListTile(
                title: Text('Voice'),
                trailing: SizedBox(
                  width: 200.0,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    style: TextStyle(
                      color: ThemeProvider.themeOf(context).data.primaryColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                    value: data.voiceString,
                    onChanged: (String? newValue) {
                      setState(() {
                        data.voiceString = newValue!;
                        ref.watch(hiveServiceProvider).saveSettings(data);
                      });
                    },
                    items: <String>['System', 'Male', 'Female']
                        .map<DropdownMenuItem<String>>((String value) {
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
              SizedBox(height: ref.read(openAirProvider).config.settingsSpacer),
              ListTile(
                title: Text('Speech Rate'),
                trailing: SizedBox(
                  width: 200.0,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    style: TextStyle(
                      color: ThemeProvider.themeOf(context).data.primaryColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                    value: data.speechRateString,
                    onChanged: (String? newValue) {
                      setState(() {
                        data.speechRateString = newValue!;
                        ref.watch(hiveServiceProvider).saveSettings(data);
                      });
                    },
                    items: <String>[
                      'Slow',
                      'Medium',
                      'Fast',
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
              SizedBox(height: ref.read(openAirProvider).config.settingsSpacer),
              ListTile(
                title: Text('Pitch'),
                trailing: SizedBox(
                  width: 200.0,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    style: TextStyle(
                      color: ThemeProvider.themeOf(context).data.primaryColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                    value: data.pitchString,
                    onChanged: (String? newValue) {
                      setState(() {
                        data.pitchString = newValue!;
                        ref.watch(hiveServiceProvider).saveSettings(data);
                      });
                    },
                    items: <String>[
                      'Low',
                      'Medium',
                      'High',
                      'Extra High',
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
              SizedBox(height: ref.read(openAirProvider).config.settingsSpacer),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 185.0,
                  vertical: 10.0,
                ),
                child: SizedBox(
                  height: 50.0,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.blue),
                    ),
                    onPressed: () {},
                    child: Text(
                      'Sample Voice',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              )
            ],
          );
        },
        error: (error, stackTrace) {
          return Text(error.toString());
        },
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
