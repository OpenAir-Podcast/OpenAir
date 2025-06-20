import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/scale.dart';
import 'package:openair/models/queue_model.dart';
import 'package:openair/providers/openair_provider.dart';

class QueueCard extends ConsumerStatefulWidget {
  const QueueCard({
    super.key,
    required this.item,
    required this.index,
    required this.isCurrentlyPlaying,
  });

  final QueueModel item;
  final int index;
  final bool isCurrentlyPlaying;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _QueueCardState();
}

class _QueueCardState extends ConsumerState<QueueCard> {
  @override
  Widget build(BuildContext context) {
    // final openAir = ref.watch(openAirProvider); // Less specific watch

    final double currentPositionMilliseconds;
    final String currentPositionString;
    final String currentRemainingString;
    final String audioState; // For play/pause icon

    if (widget.isCurrentlyPlaying) {
      currentPositionMilliseconds = ref.watch(openAirProvider
          .select((p) => p.podcastCurrentPositionInMilliseconds));
      currentPositionString = ref.watch(
          openAirProvider.select((p) => p.currentPlaybackPositionString));
      currentRemainingString = ref.watch(
          openAirProvider.select((p) => p.currentPlaybackRemainingTimeString));
      audioState = ref.watch(openAirProvider.select((p) => p.audioState));
    } else {
      currentPositionMilliseconds =
          widget.item.podcastCurrentPositionInMilliseconds;
      currentPositionString = widget.item.currentPlaybackPositionString;
      currentRemainingString = widget.item.currentPlaybackRemainingTimeString;
      audioState = 'Pause'; // Default for non-playing items
    }

    return Card(
      key: ValueKey(widget.item.guid),
      child: ListTile(
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
                  imageUrl: widget.item.image,
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
                        widget.item.datePublished,
                      ),
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  textAlign: TextAlign.left,
                ),
                const Text(' | '),
                Text(
                  widget.item.downloadSize,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
            Text(
              widget.item.title,
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
            widget.isCurrentlyPlaying && audioState == 'Play'
                ? Icons.pause_circle_outline_rounded
                : Icons.play_circle_outline_rounded,
            size: 40.0,
          ),
          onPressed: () {
            final openAir = ref.read(openAirProvider);
            final currentOpenAirState = ref
                .read(openAirProvider); // For reading current state if needed

            openAir.currentPodcast = widget.item
                .podcast; // This is okay, playerPlayButtonClicked will likely also set it and notify

            // FIXME Play the episode from the store position and not from the start

            if (widget.isCurrentlyPlaying) {
              if (audioState == 'Play') {
                // Use the selected audioState
                openAir.playerPauseButtonClicked();
              } else {
                // If paused and it's the current episode, play it
                openAir.playerPlayButtonClicked(
                    currentOpenAirState.currentEpisode!);
              }
            } else {
              // If it's a different episode, play it
              openAir.playerPlayButtonClicked(widget.item.toJson());
            }
          },
        ),
      ),
    );
  }
}
