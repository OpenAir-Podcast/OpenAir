import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/settings_pages/notifications_page.dart';
import 'package:path_provider/path_provider.dart';

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
  Widget _buildCard(Widget child, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 0.5,
              ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required BuildContext context,
    Color? iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (iconColor ?? Theme.of(context).colorScheme.primary)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: iconColor ?? Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.5),
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required String label,
    required bool value,
    required Function(bool) onChanged,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    if (mounted) {
      if (!Platform.isAndroid && !Platform.isIOS) {
        ref.read(notificationServiceProvider).showNotification(
              'OpenAir ${Translations.of(context).text('notification')}',
              message,
            );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      if (!Platform.isAndroid && !Platform.isIOS) {
        ref.read(notificationServiceProvider).showNotification(
              'OpenAir ${Translations.of(context).text('notification')}',
              message,
            );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }

  void importDatabase() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      dialogTitle: Translations.of(context).text('importDatabase'),
      type: FileType.custom,
      allowedExtensions: ['db'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      await ref.read(openAirProvider).importFromDb(file);

      if (mounted) {
        _showSuccessMessage(
            Translations.of(context).text('databaseImportedRestartApp'));
      }
    }
  }

  void exportDatabase(BuildContext context) async {
    final String date = DateTime.now().toIso8601String().split('T')[0];
    String fileName = 'openair-backup-$date.db';

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String getOpenAirPath = '${appDocDir.path}/OpenAir';

    if (context.mounted) {
      String? outputFile = await FilePicker.saveFile(
          dialogTitle: Translations.of(context).text('exportDatabase'),
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['db'],
          initialDirectory: getOpenAirPath);

      if (outputFile != null) {
        ref.read(openAirProvider).exportToDb(outputFile);
        _showSuccessMessage(Translations.of(context).text('databaseExported'));
      }
    }
  }

  void importOpml() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      dialogTitle: Translations.of(context).text('importOpml'),
      type: FileType.custom,
      allowedExtensions: ['opml', 'xml'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      final hiveService = ref.read(openAirProvider).hiveService;
      await hiveService.importOpml(file);
      _showSuccessMessage(
          Translations.of(context).text('opmlImportedRestartApp'));
    }
  }

  void exportOpml(BuildContext context) async {
    final String date = DateTime.now().toIso8601String().split('T')[0];
    String fileName = 'openair-backup-$date.opml';

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String getOpenAirPath = '${appDocDir.path}/OpenAir';

    if (context.mounted) {
      String? outputFile = await FilePicker.saveFile(
        dialogTitle: Translations.of(context).text('exportOpml'),
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['opml', 'xml'],
        initialDirectory: getOpenAirPath,
      );

      if (outputFile != null) {
        final hiveService = ref.read(openAirProvider).hiveService;
        await hiveService.exportOpml(outputFile);
        _showSuccessMessage(Translations.of(context).text('opmlExported'));
      }
    }
  }

  void _showRssUrlDialog() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController textInputControl = TextEditingController();

        return AlertDialog(
          title: Text(
            Translations.of(context).text('addPodcastByRssUrl'),
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            child: TextField(
              maxLength: 256,
              autofocus: true,
              controller: textInputControl,
              keyboardType: TextInputType.url,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              decoration: InputDecoration(
                icon: Icon(
                  Icons.link_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                labelText: Translations.of(context).text('rssUrl'),
                suffix: IconButton(
                  onPressed: () {
                    textInputControl.text = '';
                    textInputControl.clear();
                  },
                  icon: const Icon(Icons.clear_rounded),
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
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
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

                  bool success = await ref
                      .watch(audioProvider)
                      .addPodcastByRssUrl(textInputControl.text, context);

                  if (context.mounted) {
                    if (success) {
                      _showSuccessMessage(
                          Translations.of(context).text('subscribed'));
                    } else {
                      _showErrorMessage(
                          Translations.of(context).text('errorAddingPodcast'));
                    }
                  }
                },
                child: Text(
                  Translations.of(context).text('add'),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteEpisodesDialog() async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(
          Translations.of(context).text('deleteAllEpisode'),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        content: Text(
          Translations.of(context).text('deleteAllEpisodeConfirmation'),
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white70
                : Colors.black87,
            fontSize: 16,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(Translations.of(context).text('cancel')),
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
          ),
          TextButton(
            child: Text(
              Translations.of(context).text('delete'),
              style: const TextStyle(color: Colors.red),
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await ref.read(openAirProvider).hiveService.deleteEpisodes();
      if (context.mounted) {
        _showSuccessMessage(
            Translations.of(context).text('allPodcastsCleared'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final importExport = ref.watch(importExportSettingsDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Translations.of(context).text('importExport'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: importExport.when(
        data: (data) {
          final importExportData = data!;
          final automaticExportDatabase =
              importExportData['autoBackup'] ?? true;

          return ListView(
            children: [
              _buildSectionHeader('database', context),
              _buildCard(
                Column(
                  children: [
                    _buildActionTile(
                      icon: Icons.upload_file_rounded,
                      title: Translations.of(context).text('importDatabase'),
                      subtitle: Translations.of(context)
                          .text('importDatabaseSubtitle'),
                      onTap: importDatabase,
                      context: context,
                    ),
                    Divider(
                        height: 1,
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.15)),
                    _buildActionTile(
                      icon: Icons.download_rounded,
                      title: Translations.of(context).text('exportDatabase'),
                      subtitle: Translations.of(context)
                          .text('exportDatabaseSubtitle'),
                      onTap: () => exportDatabase(context),
                      context: context,
                    ),
                    Divider(
                        height: 1,
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.15)),
                    _buildToggleTile(
                      label: Translations.of(context)
                          .text('automaticExportDatabase'),
                      value: automaticExportDatabase,
                      onChanged: (value) {
                        importExportData['autoBackup'] = value;
                        automaticExportDatabaseConfig = value;
                        ref
                            .watch(openAirProvider)
                            .hiveService
                            .saveImportExportSettings(importExportData);
                        setState(() {});
                      },
                      context: context,
                    ),
                  ],
                ),
                context,
              ),
              _buildSectionHeader('opml', context),
              _buildCard(
                Column(
                  children: [
                    _buildActionTile(
                      icon: Icons.upload_file_rounded,
                      title: Translations.of(context).text('importOpml'),
                      subtitle:
                          Translations.of(context).text('importOpmlSubtitle'),
                      onTap: importOpml,
                      context: context,
                    ),
                    Divider(
                        height: 1,
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.15)),
                    _buildActionTile(
                      icon: Icons.download_rounded,
                      title: Translations.of(context).text('exportOpml'),
                      subtitle:
                          Translations.of(context).text('exportOpmlSubtitle'),
                      onTap: () => exportOpml(context),
                      context: context,
                    ),
                  ],
                ),
                context,
              ),
              _buildSectionHeader('rssFeed', context),
              _buildCard(
                Column(
                  children: [
                    _buildActionTile(
                      icon: Icons.link_rounded,
                      title:
                          Translations.of(context).text('addPodcastByRssUrl'),
                      onTap: _showRssUrlDialog,
                      context: context,
                      iconColor: Colors.green,
                    ),
                  ],
                ),
                context,
              ),
              _buildSectionHeader('userData', context),
              _buildCard(
                Column(
                  children: [
                    _buildActionTile(
                      icon: Icons.delete_forever_rounded,
                      title: Translations.of(context).text('deleteAllEpisode'),
                      subtitle: Translations.of(context)
                          .text('deleteAllEpisodeSubtitle'),
                      onTap: _showDeleteEpisodesDialog,
                      context: context,
                      iconColor: Colors.red,
                    ),
                  ],
                ),
                context,
              ),
              const SizedBox(height: 24),
            ],
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Text(Translations.of(context).text('oopsAnErrorOccurred')),
          );
        },
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
