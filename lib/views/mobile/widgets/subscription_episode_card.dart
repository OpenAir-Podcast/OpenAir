import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/hive_models/download_model.dart';
import 'package:openair/hive_models/podcast_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/mobile/main_pages/episode_detail.dart';
import 'package:openair/views/mobile/nav_pages/favorites_page.dart';
import 'package:openair/views/mobile/widgets/play_button_widget.dart';
import 'package:styled_text/styled_text.dart';

final isEpisodeNewProvider =
    FutureProvider.family<bool, String>((ref, guid) async {
  // isEpisodeNew uses hive, doesn't depend on openAirProvider's frequent changes
  return await ref.read(openAirProvider).isEpisodeNew(guid);
});

class SubscriptionEpisodeCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> episodeItem;
  final PodcastModel podcast;
  final String title;

  const SubscriptionEpisodeCard({
    super.key,
    required this.episodeItem,
    required this.podcast,
    required this.title,
  });

  @override
  ConsumerState<SubscriptionEpisodeCard> createState() =>
      _SubscriptionEpisodeCardState();
}

class _SubscriptionEpisodeCardState
    extends ConsumerState<SubscriptionEpisodeCard> {
  String podcastDate = "";

  @override
  Widget build(BuildContext context) {
    final podcastDataAsyncValue =
        ref.watch(isEpisodeNewProvider(widget.episodeItem['guid'].toString()));

    podcastDate = ref
        .read(audioProvider)
        .getPodcastPublishedDateFromEpoch(widget.episodeItem['datePublished']);

    final AsyncValue<List<DownloadModel>> downloadedListAsync =
        ref.watch(sortedDownloadsProvider);

    final AsyncValue queueListAsync = ref.watch(getQueueProvider);

    final AsyncValue favoriteListAsync = ref.watch(getFavoriteProvider);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EpisodeDetail(
              podcast: widget.podcast,
              episodeItem: widget.episodeItem,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Card(
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            width: 62.0,
                            height: 62.0,
                            decoration: BoxDecoration(
                              color: cardImageShadow,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: CachedNetworkImage(
                              memCacheHeight: 62,
                              memCacheWidth: 62,
                              imageUrl: ref
                                      .watch(audioProvider)
                                      .currentPodcast
                                      ?.imageUrl ??
                                  widget.podcast.imageUrl,
                              fit: BoxFit.fill,
                              errorWidget: (context, url, error) => Icon(
                                Icons.error,
                                size: 56.0,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width - 130.0,
                                  // Podcast title
                                  child: Text(
                                    widget.episodeItem['title'],
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      overflow: TextOverflow.ellipsis,
                                      fontWeight: FontWeight.bold,
                                      color: Brightness.dark ==
                                              Theme.of(context).brightness
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    maxLines: 2,
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width - 130.0,
                                  // Podcast title
                                  child: Text(
                                    ref
                                            .watch(audioProvider)
                                            .currentPodcast!
                                            .author ??
                                        Translations.of(context)
                                            .text('unknown'),
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      overflow: TextOverflow.ellipsis,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                Text(
                                  podcastDate,
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    overflow: TextOverflow.ellipsis,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: SizedBox(
                        height: 88.0,
                        child: StyledText(
                          text: widget.episodeItem['description'],
                          maxLines: 4,
                          style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            color:
                                Brightness.dark == Theme.of(context).brightness
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Play button
                          Expanded(
                            // width: 200.0,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 1.0,
                                shape: const StadiumBorder(
                                  side: BorderSide(
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                if (ref.read(audioProvider).currentEpisode !=
                                    widget.episodeItem) {
                                  ref
                                      .read(audioProvider.notifier)
                                      .playerPlayButtonClicked(
                                        widget.episodeItem,
                                      );
                                }
                              },
                              child: PlayButtonWidget(
                                episodeItem: widget.episodeItem,
                              ),
                            ),
                          ),
                          // Playlist button
                          queueListAsync.when(
                            data: (data) {
                              final isQueued =
                                  data.containsKey(widget.episodeItem['guid']);

                              return IconButton(
                                tooltip: "Add to Queue",
                                onPressed: () {
                                  isQueued
                                      ? ref
                                          .watch(audioProvider)
                                          .removeFromQueue(
                                              widget.episodeItem['guid'])
                                      : ref.watch(audioProvider).addToQueue(
                                            widget.episodeItem,
                                            widget.podcast,
                                          );

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isQueued
                                            ? 'Removed ${widget.episodeItem['title']} from queue'
                                            : 'Added ${widget.episodeItem['title']} to queue',
                                      ),
                                    ),
                                  );

                                  // No need to invalidate here, sortedQueueListProvider
                                  // updates reactively via hiveServiceProvider.
                                },
                                icon: isQueued
                                    ? const Icon(
                                        Icons.playlist_add_check_rounded)
                                    : const Icon(Icons.playlist_add_rounded),
                              );
                            },
                            error: (error, stackTrace) {
                              debugPrint(
                                  'Error in queueListAsync for SubscriptionEpisodeCard: $error');
                              return IconButton(
                                tooltip: "Add to Queue",
                                onPressed: () {},
                                icon: const Icon(Icons.error_outline_rounded),
                              );
                            },
                            loading: () {
                              // Handle loading by showing previous state's icon, disabled
                              final previousList = queueListAsync.valueOrNull;
                              final isQueuedPreviously =
                                  previousList?.containsKey(
                                          widget.episodeItem['guid']) ??
                                      false;

                              return IconButton(
                                tooltip: "Add to Queue",
                                onPressed: null, // Disable button while loading
                                icon: isQueuedPreviously
                                    ? const Icon(
                                        Icons.playlist_add_check_rounded)
                                    : const Icon(Icons.playlist_add_rounded),
                              );
                            },
                          ),
                          // Download button
                          if (!kIsWeb)
                            downloadedListAsync.when(
                              data: (downloads) {
                                final isDownloaded = downloads.any((d) =>
                                    d.guid == widget.episodeItem['guid']);

                                final isDownloading = ref.watch(audioProvider
                                    .select((p) => p.downloadingPodcasts
                                        .contains(widget.episodeItem['guid'])));

                                IconData iconData;
                                String tooltip;
                                VoidCallback? onPressed;

                                if (isDownloading) {
                                  iconData = Icons.downloading_rounded;
                                  tooltip = 'Downloading...';
                                  onPressed = null; // Or implement cancel
                                } else if (isDownloaded) {
                                  iconData = Icons.download_done_rounded;
                                  tooltip = 'Delete Download';

                                  onPressed = () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext dialogContext) =>
                                          AlertDialog(
                                        title: const Text('Confirm Deletion'),
                                        content: Text(
                                            'Are you sure you want to remove the download for \'${widget.episodeItem['title']}\'?'),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('Cancel'),
                                            onPressed: () {
                                              Navigator.of(dialogContext)
                                                  .pop(); // Dismiss the dialog
                                            },
                                          ),
                                          TextButton(
                                            child: Text(
                                              Translations.of(context)
                                                  .text('remove'),
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                            onPressed: () async {
                                              // Pop the dialog first
                                              Navigator.of(dialogContext).pop();

                                              // Then perform the removal
                                              await ref
                                                  .read(audioProvider.notifier)
                                                  .removeDownload(
                                                      widget.episodeItem);

                                              // Show feedback
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'Removed \'${widget.episodeItem['title']}\''),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  };
                                }
                                // Not downloaded
                                else {
                                  iconData = Icons.download_rounded;
                                  tooltip = 'Download Episode';

                                  onPressed = () {
                                    ref
                                        .read(audioProvider.notifier)
                                        .downloadEpisode(
                                          widget.episodeItem,
                                          widget.podcast,
                                          context,
                                        );

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Downloading \'${widget.episodeItem['title']}\''),
                                      ),
                                    );
                                  };
                                }

                                return IconButton(
                                  tooltip: tooltip,
                                  onPressed: onPressed,
                                  icon: Icon(iconData),
                                );
                              },
                              error: (e, s) => const IconButton(
                                  icon: Icon(Icons.error), onPressed: null),
                              loading: () => const IconButton(
                                  icon: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.0)),
                                  onPressed: null),
                            ),
                          // Share Button
                          IconButton(
                            tooltip: Translations.of(context).text('share'),
                            onPressed: () => ref.watch(openAirProvider).share(),
                            icon: const Icon(Icons.share_rounded),
                          ),
                          favoriteListAsync.when(
                            data: (data) {
                              bool isFavorite =
                                  data.containsKey(widget.episodeItem['guid']);

                              return IconButton(
                                tooltip:
                                    Translations.of(context).text('favourite'),
                                onPressed: () async {
                                  setState(() {
                                    if (isFavorite) {
                                      ref
                                          .read(audioProvider)
                                          .removeEpisodeFromFavorite(
                                              widget.episodeItem['guid']);

                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                '${Translations.of(context).text('removedFromFavorites')}: ${widget.episodeItem['title']}'),
                                          ),
                                        );
                                      }
                                    } else {
                                      ref
                                          .read(audioProvider)
                                          .addEpisodeToFavorite(
                                              widget.episodeItem,
                                              widget.podcast);

                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                '${Translations.of(context).text('addedToFavorites')}: ${widget.episodeItem['title']}'),
                                          ),
                                        );
                                      }
                                    }
                                  });
                                },
                                icon: isFavorite
                                    ? const Icon(Icons.favorite_rounded)
                                    : const Icon(Icons.favorite_border_rounded),
                              );
                            },
                            loading: () => IconButton(
                              tooltip:
                                  Translations.of(context).text('favourite'),
                              onPressed: null, // Disable button while loading
                              icon: const Icon(Icons
                                  .favorite_border_rounded), // Or a loading indicator icon
                            ),
                            error: (error, stackTrace) {
                              debugPrint(
                                  'Error checking favorite status: $error');
                              return IconButton(
                                tooltip: Translations.of(context).text('error'),
                                onPressed: null,
                                icon: const Icon(Icons.error_outline_rounded),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            podcastDataAsyncValue.when(
              data: (data) {
                if (data) {
                  return Positioned(
                    top: 5.0,
                    right: 5.0,
                    child: Container(
                      width: 20.0,
                      color: Colors.red,
                      child: Center(
                        child: const Text(
                          '*',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return Container();
              },
              error: (error, stackTrace) => Container(),
              loading: () => Container(),
            ),
          ],
        ),
      ),
    );
  }
}
