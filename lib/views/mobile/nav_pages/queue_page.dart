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
  Map queueMap = {};
  bool once = false;

  @override
  Widget build(BuildContext context) {
    final queueStream = ref.watch(sortedProvider);

    final isPodcastSelected =
        ref.watch(auidoProvider.select((p) => p.isPodcastSelected));

    final currentPlayingGuid =
        ref.watch(auidoProvider.select((p) => p.currentEpisode?['guid']));

    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('queue')),
      ),
      body: queueStream.when(
        data: (queueData) {
          if (queueData.isEmpty) {
            return NoQueue();
          }

          if (!once) {
            once = true;
            queueMap = queueData;
          }

          return ReorderableListView.builder(
            buildDefaultDragHandles: false,
            itemBuilder: (context, index) {
              final Map<String, dynamic> item =
                  (queueData.entries.elementAt(index).value)
                      .cast<String, dynamic>();

              final bool isQueueSelected = currentPlayingGuid == item['guid'];

              return QueueCard(
                key: ValueKey(item['guid']),
                episodeItem: item,
                index: index,
                isQueueSelected: isQueueSelected,
              );
            },
            itemCount: queueData.length,
            onReorder: (oldIndex, newIndex) {
              // perform reorder in storage then refresh the provider so the UI updates
              final hive = ref.read(openAirProvider).hiveService;
              hive.reorderQueue(oldIndex, newIndex).then((_) {
                ref.invalidate(sortedProvider);
              }).catchError((e) {
                // optional: handle errors (kept minimal)
                debugPrint('Failed to reorder queue: $e');
              });
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
