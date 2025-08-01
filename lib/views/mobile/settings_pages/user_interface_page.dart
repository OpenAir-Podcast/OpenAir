import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/mobile/nav_pages/settings_page.dart';
import 'package:theme_provider/theme_provider.dart';

class UserInterface extends ConsumerStatefulWidget {
  const UserInterface({super.key});

  @override
  ConsumerState<UserInterface> createState() => _UserInterfaceState();
}

class _UserInterfaceState extends ConsumerState<UserInterface> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsDataProvider);
    late String fontSize;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Interface'),
      ),
      body: settings.when(
        data: (data) {
          switch (data!.getFontSizeFactor) {
            case 0.875:
              fontSize = 'Small';
              break;
            case 1.0:
              fontSize = 'Medium';
              break;
            case 1.125:
              fontSize = 'Large';
              break;
            case 1.25:
              fontSize = 'Extra Large';
              break;
            default:
              fontSize = 'Medium';
              break;
          }

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
                    value: data.getThemeMode,
                    onChanged: (String? newValue) {
                      setState(() {
                        data.setThemeMode = newValue!;
                        ref.watch(hiveServiceProvider).saveSettings(data);
                      });

                      if (newValue == 'System') {
                        Brightness platformBrightness = View.of(context)
                            .platformDispatcher
                            .platformBrightness;

                        if (platformBrightness == Brightness.dark) {
                          ThemeProvider.controllerOf(context)
                              .setTheme('blue_accent_dark');
                        } else {
                          ThemeProvider.controllerOf(context)
                              .setTheme('blue_accent_light');
                        }

                        ThemeProvider.controllerOf(context).saveThemeToDisk();
                      } else if (newValue == 'Light') {
                        ThemeProvider.controllerOf(context)
                            .setTheme('blue_accent_light');

                        ThemeProvider.controllerOf(context).saveThemeToDisk();
                      } else if (newValue == 'Dark') {
                        ThemeProvider.controllerOf(context)
                            .setTheme('blue_accent_dark');

                        ThemeProvider.controllerOf(context).saveThemeToDisk();
                      } else if (newValue == 'Black/AMOLED') {
                        ThemeProvider.controllerOf(context)
                            .setTheme('blue_accent_amoled');

                        ThemeProvider.controllerOf(context).saveThemeToDisk();
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
                    value: fontSize,
                    onChanged: (String? newValue) {
                      setState(() {
                        fontSize = newValue!;

                        double scaleFactor;

                        switch (newValue) {
                          case 'Small':
                            scaleFactor = 0.875;
                            break;
                          case 'Medium':
                            scaleFactor = 1.0;
                            break;
                          case 'Large':
                            scaleFactor = 1.125;
                            break;
                          case 'Extra Large':
                            scaleFactor = 1.25;
                            break;
                          default:
                            scaleFactor = 1.0;
                        }

                        data.setFontSizeFactor = scaleFactor;
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
                    value: data.setLanguage,
                    onChanged: (String? newValue) {
                      setState(() {
                        data.setLanguage = newValue!;
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
                    value: data.getVoice,
                    onChanged: (String? newValue) {
                      setState(() {
                        data.setVoice = newValue!;
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
                    value: data.getSpeechRate,
                    onChanged: (String? newValue) {
                      setState(() {
                        data.setSpeechRate = newValue!;
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
                    value: data.getPitch,
                    onChanged: (String? newValue) {
                      setState(() {
                        data.setPitch = newValue!;
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
