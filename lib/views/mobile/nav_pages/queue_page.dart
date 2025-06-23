import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/components/no_queue.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/mobile/player/banner_audio_player.dart';
import 'package:openair/views/mobile/widgets/queue_card.dart';

class QueuePage extends ConsumerWidget {
  const QueuePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // By using a StreamProvider for the queue, the UI will automatically
    // update when the queue changes (e.g., after reordering). We use .stream
    // because sortedQueueListProvider is a StreamProvider.
    final queueStream = ref.watch(sortedQueueListProvider);

    final isPodcastSelected =
        ref.watch(openAirProvider.select((p) => p.isPodcastSelected));

    final currentPlayingGuid =
        ref.watch(openAirProvider.select((p) => p.currentEpisode?['guid']));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue'),
      ),
      body: queueStream.when(
        data: (queueData) {
          if (queueData.isEmpty) {
            return NoQueue();
          }

          return ReorderableListView.builder(
            buildDefaultDragHandles: false,
            itemBuilder: (context, index) {
              final item = queueData[index];
              final bool isQueueSelected = currentPlayingGuid == item.guid;

              return QueueCard(
                key: ValueKey(item.guid),
                item: item,
                index: index,
                isQueueSelected: isQueueSelected,
              );
            },
            itemCount: queueData.length,
            onReorder: (oldIndex, newIndex) {
              // This should trigger an update on the stream from the provider.
              ref.read(hiveServiceProvider).reorderQueue(oldIndex, newIndex);
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
