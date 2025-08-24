import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
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
                onTap: () {
                  // TODO: Add file picker here
                },
              ),
              ListTile(
                title: Text(Translations.of(context).text('exportDatabase')),
                subtitle: Text(
                  Translations.of(context).text('exportDatabaseSubtitle'),
                ),
                onTap: () {
                  // TODO: Add file picker here
                },
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
                title: Text(Translations.of(context).text('importDatabase')),
                subtitle: Text(
                  Translations.of(context).text('importDatabaseSubtitle'),
                ),
                onTap: () {
                  // TODO: Add file picker here
                },
              ),
              ListTile(
                title: Text(Translations.of(context).text('exportDatabase')),
                subtitle: Text(
                  Translations.of(context).text('exportDatabaseSubtitle'),
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
