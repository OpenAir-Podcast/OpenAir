import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:openair/config/scale.dart';
import 'package:openair/models/settings_model.dart';
import 'package:openair/providers/hive_provider.dart';

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
              SizedBox(height: settingsSpacer),
              ListTile(
                title: Text('Theme Mode'),
                trailing: SizedBox(
                  width: 200.0,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                    value: data.themeModeString,
                    onChanged: (String? newValue) {
                      setState(() {
                        data.themeModeString = newValue!;
                        ref.watch(hiveServiceProvider).saveSettings(data);
                      });
                    },
                    items: <String>['System', 'Light', 'Dark', 'Black/AMOLED']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: settingsSpacer),
              ListTile(
                title: Text('Accent Color'),
                trailing: SizedBox(
                  width: 200.0,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                    value: data.accentColorString,
                    onChanged: (String? newValue) {
                      data.accentColorString = newValue!;
                      ref.watch(hiveServiceProvider).saveSettings(data);
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
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: settingsSpacer),
              ListTile(
                title: Text('Font Size'),
                trailing: SizedBox(
                  width: 200.0,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    style: TextStyle(
                      color: Colors.black,
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
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: settingsSpacer),
              ListTile(
                title: Text('Language'),
                trailing: SizedBox(
                  width: 200.0,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    style: TextStyle(
                      color: Colors.black,
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
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: settingsSpacer),
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
              SizedBox(height: settingsSpacer),
              ListTile(
                title: Text('Voice'),
                trailing: SizedBox(
                  width: 200.0,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    style: TextStyle(
                      color: Colors.black,
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
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: settingsSpacer),
              ListTile(
                title: Text('Speech Rate'),
                trailing: SizedBox(
                  width: 200.0,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    style: TextStyle(
                      color: Colors.black,
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
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: settingsSpacer),
              ListTile(
                title: Text('Pitch'),
                trailing: SizedBox(
                  width: 200.0,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    style: TextStyle(
                      color: Colors.black,
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
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: settingsSpacer),
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
                      style: TextStyle(color: Colors.white),
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
