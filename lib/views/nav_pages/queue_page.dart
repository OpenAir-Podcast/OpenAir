import 'dart:io';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/components/no_queue.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/settings_pages/notifications_page.dart';
import 'package:openair/views/widgets/queue_card.dart';
import 'package:openair/views/navigation/list_drawer.dart';
import 'package:openair/views/widgets/toggle_banner.dart';

// FutureProvider for sorted Queue List
final sortedProvider = FutureProvider.autoDispose(
  (ref) {
    final hiveService = ref.watch(openAirProvider).hiveService;
    return hiveService.getQueue();
  },
);

class QueuePage extends ConsumerStatefulWidget {
  const QueuePage({super.key});

  @override
  ConsumerState<QueuePage> createState() => _QueuePageState();
}

class _QueuePageState extends ConsumerState<QueuePage> {
  void _showClearQueueDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final colorScheme = theme.colorScheme;

        return AlertDialog(
          icon: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.delete_outline_rounded,
              color: colorScheme.onErrorContainer,
              size: 28,
            ),
          ),
          title: Text(
            Translations.of(dialogContext).text('clearQueue'),
          ),
          content: Text(
            Translations.of(dialogContext).text('areYouSureClearQueue'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                Translations.of(dialogContext).text('cancel'),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(Translations.of(dialogContext).text('clear')),
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                await ref.read(openAirProvider).hiveService.clearQueue();

                ref.invalidate(queueCountProvider);
                ref.invalidate(sortedProvider);
                ref.invalidate(inboxCountProvider);

                if (!dialogContext.mounted) return;
                final scaffoldMessenger = ScaffoldMessenger.of(dialogContext);
                final translations = Translations.of(dialogContext);
                if (!Platform.isAndroid && !Platform.isIOS) {
                  ref.read(notificationServiceProvider).showNotification(
                        'OpenAir ${translations.text('notification')}',
                        translations.text('queueCleared'),
                      );
                } else {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        translations.text('queueCleared'),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _exportQueue() async {
    try {
      final hive = ref.read(openAirProvider).hiveService;
      final queue = await hive.getQueue();
      final list = queue.values
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList()
        ..sort((a, b) => (a['pos'] as int).compareTo(b['pos'] as int));
      final jsonStr = const JsonEncoder.withIndent('  ').convert(list);
      final path = await FilePicker.saveFile(
        dialogTitle: 'Export queue',
        fileName: 'openair_queue.json',
      );
      if (path == null) return;
      await File(path).writeAsString(jsonStr);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Queue exported')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  Future<void> _importQueue() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result.files.isEmpty) return;
      final str = await File(result.files.single.path!).readAsString();
      final decoded = jsonDecode(str);
      if (decoded is! List) return;
      final hive = ref.read(openAirProvider).hiveService;
      int pos = 1;
      for (final item in decoded) {
        if (item is Map) {
          final m = Map<String, dynamic>.from(item);
          m['pos'] = pos++;
          await hive.addToQueue(m);
        }
      }
      ref.invalidate(sortedProvider);
      ref.invalidate(queueCountProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Queue imported')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final queueStream = ref.watch(sortedProvider);

    final currentPlayingGuid =
        ref.watch(audioProvider.select((p) => p.currentEpisode?['guid']));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Translations.of(context).text('queue'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: IconButton(
              onPressed: _exportQueue,
              icon: const Icon(Icons.file_upload_outlined),
              tooltip: 'Export queue',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: IconButton(
              onPressed: _importQueue,
              icon: const Icon(Icons.file_download_outlined),
              tooltip: 'Import queue',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              onPressed: _showClearQueueDialog,
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: Translations.of(context).text('clearQueue'),
            ),
          ),
        ],
      ),
      body: queueStream.when(
        data: (queueData) {
          if (queueData.isEmpty) {
            return NoQueue();
          }

          // Convert to list and sort by position for consistent ordering
          final List<MapEntry<String, Map>> sortedQueueList = queueData.entries
              .map(
                  (e) => MapEntry<String, Map>(e.key as String, e.value as Map))
              .toList()
            ..sort((a, b) =>
                (a.value['pos'] as int).compareTo(b.value['pos'] as int));

          return ReorderableListView.builder(
            buildDefaultDragHandles: false,
            padding: const EdgeInsets.only(bottom: 16),
            itemBuilder: (context, index) {
              final MapEntry<String, Map> entry = sortedQueueList[index];
              final Map<String, dynamic> item =
                  entry.value.cast<String, dynamic>();

              final bool isQueueSelected = currentPlayingGuid == item['guid'];

              return QueueCard(
                key: ValueKey(item['guid']),
                episodeItem: item,
                index: index,
                isQueueSelected: isQueueSelected,
              );
            },
            itemCount: sortedQueueList.length,
            onReorderItem: (int oldIndex, int newIndex) async {
              try {
                final hive = ref.read(openAirProvider).hiveService;
                await hive.reorderQueue(oldIndex, newIndex);
                ref.invalidate(sortedProvider);
              } catch (e) {
                debugPrint('Failed to reorder queue: $e');

                if (context.mounted) {
                  if (!Platform.isAndroid && !Platform.isIOS) {
                    ref.read(notificationServiceProvider).showNotification(
                          'OpenAir ${Translations.of(context).text('notification')}',
                          '${Translations.of(context).text('oopsAnErrorOccurred')} - ${Translations.of(context).text('errorCode')}170',
                        );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${Translations.of(context).text('oopsAnErrorOccurred')} - ${Translations.of(context).text('errorCode')}170',
                        ),
                      ),
                    );
                  }
                }
              }
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: 60,
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    Translations.of(context).text('oopsTryAgainLater'),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => ref.invalidate(sortedProvider),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(Translations.of(context).text('retry')),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: ToggleBanner(),
    );
  }
}
