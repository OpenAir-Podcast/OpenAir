import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/model/hive_models/podcast_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/views/main_pages/episode_detail.dart';

class QueueCard extends ConsumerStatefulWidget {
  const QueueCard({
    super.key,
    required this.episodeItem,
    required this.index,
    required this.isQueueSelected,
  });

  final Map<String, dynamic> episodeItem;
  final int index;
  final bool isQueueSelected;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _QueueCardState();
}

class _QueueCardState extends ConsumerState<QueueCard> {
  @override
  Widget build(BuildContext context) {
    final audioProviderNotifier = ref.read(audioProvider.notifier);
    final openAir = ref.watch(audioProvider);

    final double currentPositionMilliseconds;
    final String currentPositionString;
    final String audioState;

    if (widget.isQueueSelected) {
      currentPositionMilliseconds =
          openAir.podcastCurrentPositionInMilliseconds;
      currentPositionString = openAir.currentPlaybackPositionString;
      audioState = openAir.audioState;
    } else {
      currentPositionMilliseconds =
          widget.episodeItem['podcastCurrentPositionInMilliseconds'] ?? 0;
      currentPositionString =
          widget.episodeItem['currentPlaybackPositionString'] ?? '';
      audioState = 'Pause';
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final date = ref.read(audioProvider).getPodcastPublishedDateFromEpoch(
          widget.episodeItem['datePublished'],
        );
    final size = widget.episodeItem['downloadSize'] ?? '';

    return Container(
      key: ValueKey(widget.episodeItem['guid']),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: widget.isQueueSelected
            ? colorScheme.primaryContainer.withValues(alpha: 0.7)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: widget.isQueueSelected
            ? Border.all(
                color: colorScheme.primary.withValues(alpha: 0.3), width: 1.5)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EpisodeDetail(
                  episodeItem: (widget.episodeItem).cast<String, dynamic>(),
                  podcast: PodcastModel.fromJson(
                      widget.episodeItem['podcast'].cast<String, dynamic>()),
                  author: widget.episodeItem['author'],
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle + artwork
                ReorderableDragStartListener(
                  index: widget.index,
                  child: SizedBox(
                    width: 56,
                    child: Icon(
                      Icons.drag_handle_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Artwork
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 56,
                    height: 56,
                    color: colorScheme.surfaceContainerHighest,
                    child: CachedNetworkImage(
                      memCacheHeight: 56,
                      memCacheWidth: 56,
                      imageUrl: widget.episodeItem['image'] ?? '',
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Icon(
                        Icons.podcasts_rounded,
                        size: 28,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Meta info
                      Row(
                        children: [
                          Text(
                            date,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (size.isNotEmpty) ...[
                            Text(
                              ' • ',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              size,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Title
                      Text(
                        widget.episodeItem['title'] ?? '',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Progress bar
                      LinearProgressIndicator(
                        value: currentPositionMilliseconds,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.isQueueSelected && audioState == 'Play'
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.5),
                        ),
                        minHeight: 3,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      const SizedBox(height: 6),
                      // Time info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            currentPositionString,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontFeatures: const [
                                FontFeature.tabularFigures()
                              ],
                            ),
                          ),
                          Text(
                            openAir.formatCurrentPlaybackPosition(
                              Duration(
                                seconds: widget.episodeItem['duration'] ?? 0,
                              ),
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontFeatures: const [
                                FontFeature.tabularFigures()
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Play/Pause button
                IconButton(
                  icon: Icon(
                    widget.isQueueSelected && audioState == 'Play'
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_filled_rounded,
                    size: 40,
                    color: widget.isQueueSelected && audioState == 'Play'
                        ? colorScheme.primary
                        : colorScheme.primary.withValues(alpha: 0.8),
                  ),
                  onPressed: () {
                    if (widget.isQueueSelected &&
                        openAir.isPlaying == PlayingStatus.playing) {
                      audioProviderNotifier.playerPauseButtonClicked();
                    } else if (widget.isQueueSelected &&
                        openAir.isPlaying == PlayingStatus.paused) {
                      audioProviderNotifier.playerResumeButtonClicked();
                    } else if (!widget.isQueueSelected) {
                      if (openAir.currentEpisode != null &&
                          openAir.currentEpisode!.isNotEmpty) {
                        audioProviderNotifier.updateCurrentQueueCard(
                          openAir.currentEpisode!['guid'],
                          openAir.podcastCurrentPositionInMilliseconds,
                          openAir.currentPlaybackPositionString,
                          openAir.currentPlaybackRemainingTimeString,
                          openAir.playerPosition,
                        );
                      }

                      openAir.playerPosition =
                          widget.episodeItem['playerPosition'] ?? 0;
                      openAir.currentPodcast =
                          PodcastModel.fromJson(widget.episodeItem);
                      openAir.currentEpisode = widget.episodeItem;

                      audioProviderNotifier.playNewQueueItem(
                        widget.episodeItem,
                        context,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
