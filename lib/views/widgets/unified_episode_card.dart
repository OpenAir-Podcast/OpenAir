import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/model/hive_models/podcast_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/main_pages/episode_detail.dart';
import 'package:openair/views/widgets/play_button_widget.dart';
import 'package:openair/views/widgets/podcast_image.dart';

class UnifiedEpisodeCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> episodeItem;
  final PodcastModel podcast;
  final String title;
  final String? author;
  final bool showAuthor;

  const UnifiedEpisodeCard({
    super.key,
    required this.episodeItem,
    required this.podcast,
    required this.title,
    this.author,
    this.showAuthor = true,
  });

  @override
  ConsumerState<UnifiedEpisodeCard> createState() => _UnifiedEpisodeCardState();
}

class _UnifiedEpisodeCardState extends ConsumerState<UnifiedEpisodeCard> {
  late bool isQueued;
  late bool isFavorite;

  String _formatDuration(int? seconds) {
    if (seconds == null || seconds <= 0) return '';
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final audioState = ref.watch(audioProvider);
    final podcastDate = audioState
        .getPodcastPublishedDateFromEpoch(widget.episodeItem['datePublished']);

    final duration = _formatDuration(widget.episodeItem['duration']);
    final author = widget.author ??
        widget.podcast.author ??
        Translations.of(context).text('unknown');

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EpisodeDetail(
              episodeItem: widget.episodeItem,
              podcast: widget.podcast,
              author: widget.author,
            ),
          ),
        );
      },
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          // Added padding for better spacing
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize
                .min, // Prevents Column from trying to take infinite height
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start, // Align to top
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 72,
                      height: 72,
                      color: theme.cardColor,
                      child: podcastImage(
                        widget.episodeItem['feedImage'] ??
                            widget.episodeItem['image'] ??
                            widget.podcast.imageUrl,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (widget.showAuthor) ...[
                          Wrap(
                            // Using Wrap instead of Row prevents overflow on small screens
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.person,
                                      size: 12, color: Colors.grey[500]),
                                  const SizedBox(width: 2),
                                  Flexible(
                                    child: Text(
                                      author,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              if (duration.isNotEmpty) ...[
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.access_time,
                                        size: 12, color: Colors.grey[500]),
                                    const SizedBox(width: 2),
                                    Text(
                                      duration,
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.calendar_month,
                                      size: 12, color: Colors.grey[500]),
                                  const SizedBox(width: 2),
                                  Text(
                                    podcastDate,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (widget.episodeItem['description'] != null) ...[
                const SizedBox(height: 8),
                _buildDescriptionPreview(
                  widget.episodeItem['description'],
                  theme,
                ),
              ],
              const SizedBox(height: 12),
              _buildPlayButton(context, ref),
              const SizedBox(height: 8),
              _buildActionButtons(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionPreview(String html, ThemeData theme) {
    final text = _stripHtml(html);
    if (text.isEmpty) return const SizedBox.shrink();

    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodySmall?.copyWith(
        height: 1.2,
      ),
    );
  }

  Widget _buildPlayButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          backgroundColor:
              ref.watch(audioProvider).currentEpisode == widget.episodeItem
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.secondary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: const Size.fromHeight(36),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () {
          if (ref.read(audioProvider).currentEpisode != widget.episodeItem) {
            ref
                .read(audioProvider.notifier)
                .playerPlayButtonClicked(widget.episodeItem, context);
            ref.read(audioProvider).currentEpisode!['author'] =
                widget.author ?? widget.podcast.author ?? '';
          }
        },
        child: PlayButtonWidget(
          episodeItem: widget.episodeItem,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Queue button
        _buildQueueButton(context, ref),
        const SizedBox(width: 4),
        // Download button
        if (!kIsWeb) _buildDownloadButton(context, ref),
        const SizedBox(width: 4),
        // Favorite button
        _buildFavoriteButton(context, ref),
        const SizedBox(width: 4),
        // Share button
        IconButton(
          icon: const Icon(Icons.share_outlined, size: 18),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          visualDensity: VisualDensity.compact,
          onPressed: () {
            ref.read(openAirProvider).shareEpisode(
                  context,
                  widget.episodeItem,
                  widget.episodeItem['title'],
                );
          },
        ),
      ],
    );
  }

  Widget _buildQueueButton(BuildContext context, WidgetRef ref) {
    final queueListAsync = ref.watch(getQueueProvider);

    return queueListAsync.when(
      data: (data) {
        isQueued = data.containsKey(widget.episodeItem['guid']);
        return IconButton(
          icon: Icon(
            isQueued ? Icons.playlist_add_check : Icons.playlist_add,
            size: 18,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          visualDensity: VisualDensity.compact,
          tooltip: Translations.of(context).text('addToQueue'),
          onPressed: () {
            isQueued
                ? ref
                    .read(audioProvider)
                    .removeFromQueue(widget.episodeItem['guid'])
                : ref.read(audioProvider).addToQueue(
                      widget.episodeItem,
                      widget.podcast,
                      context,
                    );
            ref.invalidate(getQueueProvider);
          },
        );
      },
      loading: () => const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, __) => const Icon(Icons.error, size: 18),
    );
  }

  Widget _buildDownloadButton(BuildContext context, WidgetRef ref) {
    final downloadedListProvider = ref.watch(getDownloadsProvider);

    return downloadedListProvider.when(
      data: (downloads) {
        final isDownloaded = downloads.any(
          (d) => d.guid == widget.episodeItem['guid'],
        );
        final isDownloading = ref.watch(audioProvider.select(
          (p) => p.downloadingPodcasts.contains(widget.episodeItem['guid']),
        ));

        if (isDownloading) {
          return const IconButton(
            onPressed: null,
            icon: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        return IconButton(
          icon: Icon(
            isDownloaded ? Icons.download_done : Icons.download_outlined,
            size: 18,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          visualDensity: VisualDensity.compact,
          tooltip: isDownloaded
              ? Translations.of(context).text('deleteDownload')
              : Translations.of(context).text('downloadEpisode'),
          onPressed: isDownloaded
              ? () => _showDeleteDialog(context, ref)
              : () => _downloadEpisode(context, ref),
        );
      },
      loading: () => const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, __) => const Icon(Icons.error, size: 18),
    );
  }

  Widget _buildFavoriteButton(BuildContext context, WidgetRef ref) {
    final favoriteListAsync = ref.watch(getFavoriteProvider);

    return favoriteListAsync.when(
      data: (data) {
        isFavorite = data.containsKey(widget.episodeItem['guid']);
        return IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            size: 18,
            color: isFavorite ? Colors.red : null,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          visualDensity: VisualDensity.compact,
          tooltip: Translations.of(context).text('favourite'),
          onPressed: () async {
            if (isFavorite) {
              ref.read(audioProvider).removeEpisodeFromFavorite(
                    widget.episodeItem['guid'],
                  );
            } else {
              ref.read(audioProvider).addEpisodeToFavorite(
                    widget.episodeItem,
                    widget.podcast,
                    author: widget.author,
                  );
              ref.invalidate(getFavoriteProvider);
            }
          },
        );
      },
      loading: () => const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, __) => const Icon(Icons.error, size: 18),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(Translations.of(dialogContext).text('confirmDeletion')),
          content: Text(
            '${Translations.of(dialogContext).text('areYouSureYouWantToRemoveDownload')} \'${widget.episodeItem['title']}\'?',
          ),
          actions: [
            TextButton(
              child: Text(Translations.of(dialogContext).text('cancel')),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(Translations.of(dialogContext).text('remove')),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await ref
                    .read(audioProvider.notifier)
                    .removeDownload(widget.episodeItem);
                ref.invalidate(getDownloadsProvider);
              },
            ),
          ],
        );
      },
    );
  }

  void _downloadEpisode(BuildContext context, WidgetRef ref) {
    widget.episodeItem['author'] = widget.author;
    widget.podcast.author = widget.author;

    ref.read(audioProvider.notifier).downloadEpisode(
          widget.episodeItem,
          widget.podcast,
          context,
        );
  }
}
