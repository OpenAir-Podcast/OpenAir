import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/hive_models/queue_model.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/mobile/main_pages/episode_detail.dart';

class QueueCard extends ConsumerStatefulWidget {
  const QueueCard({
    super.key,
    required this.episodeItem,
    required this.index,
    required this.isQueueSelected,
  });

  final QueueModel episodeItem;
  final int index;
  final bool isQueueSelected;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _QueueCardState();
}

class _QueueCardState extends ConsumerState<QueueCard> {
  @override
  Widget build(BuildContext context) {
    final openAirNotifier = ref.read(openAirProvider.notifier);
    // Watch the provider to get live updates for the active card.
    final openAir = ref.watch(openAirProvider);

    final double currentPositionMilliseconds;
    final String currentPositionString;
    final String currentRemainingString;
    final String audioState;

    // If this card is the selected one (playing or paused), get its state
    // from the provider. Otherwise, get the saved state from the item model.
    if (widget.isQueueSelected) {
      currentPositionMilliseconds =
          openAir.podcastCurrentPositionInMilliseconds;
      currentPositionString = openAir.currentPlaybackPositionString;
      currentRemainingString = openAir.currentPlaybackRemainingTimeString;
      audioState = openAir.audioState;
    } else {
      // This is an inactive item in the queue. Show its saved progress.
      currentPositionMilliseconds =
          widget.episodeItem.podcastCurrentPositionInMilliseconds;
      currentPositionString = widget.episodeItem.currentPlaybackPositionString;
      currentRemainingString =
          widget.episodeItem.currentPlaybackRemainingTimeString;
      audioState = 'Pause'; // Represents a "playable" state
    }

    return Card(
      key: ValueKey(widget.episodeItem.guid),
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EpisodeDetail(
                episodeItem: widget.episodeItem.toJson(),
                podcast: widget.episodeItem.podcast,
              ),
            ),
          );
        },
        leading: ReorderableDragStartListener(
          index: widget.index,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.drag_handle),
              const SizedBox(width: 8),
              Container(
                width: 62.0,
                height: 62.0,
                decoration: BoxDecoration(
                  color: cardImageShadow,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: CachedNetworkImage(
                  memCacheHeight: 52,
                  memCacheWidth: 52,
                  imageUrl: widget.episodeItem.image,
                  fit: BoxFit.fill,
                  errorWidget: (context, url, error) => Icon(
                    Icons.error,
                    size: 56.0,
                  ),
                ),
              ),
            ],
          ),
        ),
        title: Column(
          children: [
            Row(
              children: [
                Text(
                  ref.read(openAirProvider).getPodcastPublishedDateFromEpoch(
                        widget.episodeItem.datePublished,
                      ),
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  textAlign: TextAlign.left,
                ),
                const Text(' | '),
                Text(
                  widget.episodeItem.downloadSize,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
            Text(
              widget.episodeItem.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.left,
            ),
          ],
        ),
        subtitle: Column(
          children: [
            // Seek bar
            Padding(
              padding: const EdgeInsets.fromLTRB(
                5.0,
                10.0,
                5.0,
                10.0,
              ),
              child: LinearProgressIndicator(
                value: currentPositionMilliseconds,
              ),
            ),
            // Seek positions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currentPositionString,
                  ),
                  //
                  // Spacer
                  //
                  Text(
                    '-$currentRemainingString',
                  ),
                ],
              ),
            ),
          ],
        ),
        trailing: IconButton(
          iconSize: 40.0,
          icon: Icon(
            widget.isQueueSelected && audioState == 'Play'
                ? Icons.pause_circle_outline_rounded
                : Icons.play_circle_outline_rounded,
            size: 40.0,
          ),
          onPressed: () {
            if (widget.isQueueSelected &&
                openAir.isPlaying == PlayingStatus.playing) {
              openAirNotifier.playerPauseButtonClicked();
              debugPrint('Pausing');
            } else if (widget.isQueueSelected &&
                openAir.isPlaying == PlayingStatus.paused) {
              debugPrint('Resuming');
              openAirNotifier.playerResumeButtonClicked();
            } else if (!widget.isQueueSelected) {
              if (openAir.currentEpisode!.isNotEmpty) {
                openAirNotifier.updateCurrentQueueCard(
                  openAir.currentEpisode!['guid'],
                  openAir.podcastCurrentPositionInMilliseconds,
                  openAir.currentPlaybackPositionString,
                  openAir.currentPlaybackRemainingTimeString,
                  openAir.playerPosition,
                );
              }

              openAir.playerPosition = widget.episodeItem.playerPosition!;

              openAir.currentPodcast = widget.episodeItem.podcast;
              openAir.currentEpisode = widget.episodeItem.toJson();

              openAirNotifier.playNewQueueItem(widget.episodeItem);
            }
          },
        ),
      ),
    );
  }
}
