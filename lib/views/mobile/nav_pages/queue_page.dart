import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/components/no_queue.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/mobile/player/banner_audio_player.dart';
import 'package:openair/views/mobile/widgets/queue_card.dart';

// FutureProvider for sorted Queue List
final sortedProvider = FutureProvider(
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
  @override
  Widget build(BuildContext context) {
    final queueStream = ref.watch(sortedProvider);

    final isPodcastSelected =
        ref.watch(audioProvider.select((p) => p.isPodcastSelected));

    final currentPlayingGuid =
        ref.watch(audioProvider.select((p) => p.currentEpisode?['guid']));

    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('queue')),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) => AlertDialog(
                  title: Text(Translations.of(context).text('clearQueue')),
                  content: Text(
                      Translations.of(context).text('areYouSureClearQueue')),
                  actions: <Widget>[
                    TextButton(
                      child: Text(Translations.of(context).text('cancel')),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                    TextButton(
                      child: Text(Translations.of(context).text('clear')),
                      onPressed: () async {
                        Navigator.of(dialogContext).pop();

                        ref.read(openAirProvider).hiveService.clearQueue();
                        ref.invalidate(sortedProvider);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                Translations.of(context).text('queueCleared'),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.delete_outline_rounded),
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
            onReorder: (oldIndex, newIndex) async {
              // Show loading indicator or disable interaction during reorder
              try {
                final hive = ref.read(openAirProvider).hiveService;
                await hive.reorderQueue(oldIndex, newIndex);
                // Refresh the provider to update the UI
                ref.invalidate(sortedProvider);
              } catch (e) {
                // Optionally show a snackbar or error message to the user
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to reorder queue: $e')),
                  );
                }
              }
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          return Center(child: Text('Error loading queue: $error'));
        },
      ),
      bottomNavigationBar: SizedBox(
        height: isPodcastSelected ? 80.0 : 0.0,
        child: isPodcastSelected
            ? const BannerAudioPlayer()
            : const SizedBox.shrink(),
      ),
    );
  }
}
