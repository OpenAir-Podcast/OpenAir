import 'package:cached_network_image/cached_network_image.dart';
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

class EpisodeCardList extends ConsumerStatefulWidget {
  final Map<String, dynamic> episodeItem;
  final PodcastModel podcast;
  final String title;
  final String author;

  const EpisodeCardList({
    super.key,
    required this.episodeItem,
    required this.title,
    required this.podcast,
    required this.author,
  });

  @override
  ConsumerState<EpisodeCardList> createState() => _EpisodeCardListState();
}

class _EpisodeCardListState extends ConsumerState<EpisodeCardList> {
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
    final podcastDate = ref
        .read(audioProvider)
        .getPodcastPublishedDateFromEpoch(widget.episodeItem['datePublished']);

    final duration = _formatDuration(widget.episodeItem['duration']);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EpisodeDetail(
              episodeItem: widget.episodeItem,
              podcast: widget.podcast,
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
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Episode thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 72,
                  height: 72,
                  color: theme.cardColor,
                  child: CachedNetworkImage(
                    memCacheHeight: 144,
                    memCacheWidth: 144,
                    imageUrl: widget.episodeItem['feedImage'] ??
                        widget.podcast.imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Icon(
                      Icons.podcasts,
                      size: 32,
                      color: Colors.grey[400],
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
                    // Title
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
                    // Author and date row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.author,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (duration.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 2),
                          Text(
                            duration,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                          ),
                        ],
                        const SizedBox(width: 8),
                        Text(
                          podcastDate,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Description preview (lightweight, no Html widget)
                    if (widget.episodeItem['description'] != null)
                      _buildDescriptionPreview(
                        widget.episodeItem['description'],
                        theme,
                      ),
                    const SizedBox(height: 8),
                    // Action buttons
                    _buildActionButtons(context, ref),
                  ],
                ),
              ),
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
        fontSize: 11,
        height: 1.2,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // Play button
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              if (ref.read(audioProvider).currentEpisode !=
                  widget.episodeItem) {
                ref
                    .read(audioProvider.notifier)
                    .playerPlayButtonClicked(widget.episodeItem, context);
                ref.read(audioProvider).currentEpisode!['author'] =
                    widget.author;
              }
            },
            child: PlayButtonWidget(
              episodeItem: widget.episodeItem,
            ),
          ),
        ),
        const SizedBox(width: 4),
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
          onPressed: () => ref.watch(openAirProvider).share(),
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
    final downloadedListProvider = ref.watch(sortedDownloadsProvider);

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
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(Translations.of(context).text('confirmDeletion')),
        content: Text(
          '${Translations.of(context).text('areYouSureYouWantToRemoveDownload')} \'${widget.episodeItem['title']}\'?',
        ),
        actions: [
          TextButton(
            child: Text(Translations.of(context).text('cancel')),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(Translations.of(context).text('remove')),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await ref
                  .read(audioProvider.notifier)
                  .removeDownload(widget.episodeItem);
              ref.invalidate(sortedDownloadsProvider);
            },
          ),
        ],
      ),
    );
  }

  void _downloadEpisode(BuildContext context, WidgetRef ref) {
    ref.read(audioProvider.notifier).downloadEpisode(
          widget.episodeItem,
          widget.podcast,
          context,
        );
  }
}
