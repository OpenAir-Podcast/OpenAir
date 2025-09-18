import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/openair_provider.dart';

final FutureProvider<Map?> importExportSettingsDataProvider =
    FutureProvider((ref) async {
  final hiveService = ref.watch(openAirProvider).hiveService;
  return await hiveService.getImportExportSettings();
});

class ImportExportPage extends ConsumerStatefulWidget {
  const ImportExportPage({super.key});

  @override
  ConsumerState<ImportExportPage> createState() => ImportExportPageState();
}

class ImportExportPageState extends ConsumerState<ImportExportPage> {
  late Map importExportData;

  late bool automaticExportDatabase;

  void importDatabase() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Import database file',
      type: FileType.custom,
      allowedExtensions: ['db'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      await ref.read(openAirProvider).importFromDb(file);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Translations.of(context).text('databaseImportedRestartApp'),
            ),
          ),
        );
      }
    }
  }

  void exportDatabase() async {
    final String date = DateTime.now().toIso8601String().split('T')[0];
    String fileName = 'OpenAirBackup-$date.db';

    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      fileName: fileName,
    );

    if (outputFile != null) {
      ref.read(openAirProvider).exportToDb(outputFile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Translations.of(context).text('databaseExportedRestartApp'),
            ),
          ),
        );
      }
    }
  }

  void importOpml() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['opml', 'xml'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      final hiveService = ref.read(openAirProvider).hiveService;
      await hiveService.importOpml(file);
    }
  }

  void exportOpml() async {
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      fileName: 'openair.opml',
    );

    if (outputFile != null) {
      final hiveService = ref.read(openAirProvider).hiveService;
      await hiveService.exportOpml(outputFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final importExport = ref.watch(importExportSettingsDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('importExport')),
      ),
      body: importExport.when(
        data: (data) {
          importExportData = data!;

          automaticExportDatabase = importExportData['autoBackup'] ?? true;

          return Column(
            spacing: settingsSpacer,
            children: [
              ListTile(
                title: Text(
                  Translations.of(context).text('database'),
                  style: TextStyle(color: Colors.blueGrey),
                ),
                trailing: SizedBox(
                  width: 200.0,
                ),
              ),
              ListTile(
                title: Text(Translations.of(context).text('importDatabase')),
                subtitle: Text(
                  Translations.of(context).text('importDatabaseSubtitle'),
                ),
                onTap: importDatabase,
              ),
              ListTile(
                title: Text(Translations.of(context).text('exportDatabase')),
                subtitle: Text(
                  Translations.of(context).text('exportDatabaseSubtitle'),
                ),
                onTap: exportDatabase,
              ),
              ListTile(
                title: Text(
                    Translations.of(context).text('automaticExportDatabase')),
                trailing: SizedBox(
                    child: ToggleButtons(
                  isSelected: [
                    automaticExportDatabase,
                    !automaticExportDatabase
                  ],
                  onPressed: (int index) {
                    setState(() {
                      automaticExportDatabase = !automaticExportDatabase;
                      importExportData['autoBackup'] = automaticExportDatabase;
                      automaticExportDatabaseConfig = automaticExportDatabase;

                      ref
                          .watch(openAirProvider)
                          .hiveService
                          .saveImportExportSettings(importExportData);
                    });
                  },
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        Translations.of(context).text('on'),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        Translations.of(context).text('off'),
                      ),
                    ),
                  ],
                )),
              ),
              Divider(),
              ListTile(
                title: Text(
                  Translations.of(context).text('opml'),
                  style: TextStyle(color: Colors.blueGrey),
                ),
                trailing: SizedBox(
                  width: 200.0,
                ),
              ),
              ListTile(
                title: Text(Translations.of(context).text('importOpml')),
                subtitle: Text(
                  Translations.of(context).text('importOpmlSubtitle'),
                ),
                onTap: importOpml,
              ),
              ListTile(
                title: Text(Translations.of(context).text('exportOpml')),
                subtitle: Text(
                  Translations.of(context).text('exportOpmlSubtitle'),
                ),
                onTap: exportOpml,
              ),
              Divider(),
              ListTile(
                title: Text(
                  Translations.of(context).text('rssUrl'),
                  style: TextStyle(color: Colors.blueGrey),
                ),
                trailing: SizedBox(
                  width: 200.0,
                ),
              ),
              ListTile(
                title: Text(
                  Translations.of(context).text('addPodcastByRssUrl'),
                ),
                onTap: () => showDialog(
                  context: context,
                  builder: (context) {
                    TextEditingController textInputControl =
                        TextEditingController();

                    return AlertDialog(
                      title: Text(
                        Translations.of(context).text('addPodcastByRssUrl'),
                        textAlign: TextAlign.start,
                      ),
                      content: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: TextField(
                          maxLength: 256,
                          autofocus: true,
                          controller: textInputControl,
                          keyboardType: TextInputType.url,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            icon: Icon(
                              Icons.link_rounded,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            labelText: Translations.of(context).text('rssUrl'),
                            suffix: IconButton(
                              onPressed: () {
                                setState(() {
                                  textInputControl.text = '';
                                  textInputControl.clear();
                                });
                              },
                              icon: Icon(Icons.clear_rounded),
                            ),
                          ),
                        ),
                      ),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              Translations.of(context).text('cancel'),
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextButton(
                            onPressed: () async {
                              Navigator.pop(context);

                              if (textInputControl.text.isEmpty) {
                                return;
                              }

                              bool i = await ref
                                  .watch(audioProvider)
                                  .addPodcastByRssUrl(textInputControl.text);

                              if (context.mounted) {
                                if (i == true) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        Translations.of(context)
                                            .text('subscribed'),
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        Translations.of(context)
                                            .text('errorAddingPodcast'),
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            child: Text(
                              Translations.of(context).text('add'),
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Divider(),
              ListTile(
                title: Text(
                  Translations.of(context).text('userData'),
                  style: TextStyle(color: Colors.blueGrey),
                ),
                trailing: SizedBox(
                  width: 200.0,
                ),
              ),
              ListTile(
                title: Text(Translations.of(context).text('deleteAllEpisode')),
                subtitle: Text(
                  Translations.of(context).text('deleteAllEpisodeSubtitle'),
                ),
                onTap: () {
                  // TODO: Add file picker here
                },
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
