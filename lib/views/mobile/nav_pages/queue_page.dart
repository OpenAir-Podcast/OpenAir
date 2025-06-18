import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/components/no_queue.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/mobile/player/banner_audio_player.dart';
import 'package:openair/views/mobile/widgets/queue_card.dart';

class QueuePage extends ConsumerStatefulWidget {
  const QueuePage({super.key});

  @override
  ConsumerState createState() => _QueuePageState();
}

class _QueuePageState extends ConsumerState<QueuePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue'),
      ),
      // FIXME always show the loading widget when a queue card is playing
      body: ref.watch(sortedQueueListProvider).when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Text('Error loading queue: $error'),
            ),
            data: (queueData) {
              if (queueData.isEmpty) {
                return NoQueue(title: 'Queue');
              }

              final currentPlayingGuid =
                  ref.watch(openAirProvider).currentEpisode?['guid'];

              return ReorderableListView.builder(
                buildDefaultDragHandles: false,
                itemBuilder: (context, index) {
                  final item = queueData.elementAt(index);
                  final bool isCurrentlyPlaying =
                      currentPlayingGuid == item.guid;

                  return QueueCard(
                    key: ValueKey(item.guid),
                    item: item,
                    index: index,
                    isCurrentlyPlaying: isCurrentlyPlaying,
                  );
                },
                itemCount: queueData.length,
                onReorder: (oldIndex, newIndex) {
                  ref
                      .read(hiveServiceProvider)
                      .reorderQueue(oldIndex, newIndex);
                },
              );

              //
            },
          ),
      bottomNavigationBar: SizedBox(
        height: ref.watch(openAirProvider.select((p) => p.isPodcastSelected))
            ? 80.0
            : 0.0,
        child: ref.watch(openAirProvider.select((p) => p.isPodcastSelected))
            ? const BannerAudioPlayer()
            : const SizedBox.shrink(),
      ),
    );
  }
}
