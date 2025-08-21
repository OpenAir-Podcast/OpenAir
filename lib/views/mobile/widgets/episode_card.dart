import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/hive_models/download_model.dart';
import 'package:openair/hive_models/podcast_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/mobile/main_pages/episode_detail.dart';
import 'package:openair/views/mobile/main_pages/episodes_page.dart';
import 'package:openair/views/mobile/widgets/play_button_widget.dart';
import 'package:styled_text/styled_text.dart';

class EpisodeCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> episodeItem;
  final String title;
  final PodcastModel podcast;

  const EpisodeCard({
    super.key,
    required this.episodeItem,
    required this.title,
    required this.podcast,
  });

  @override
  ConsumerState<EpisodeCard> createState() => _EpisodeCardState();
}

class _EpisodeCardState extends ConsumerState<EpisodeCard> {
  String podcastDate = "";
  bool cancel = false;
  late bool isQueued;

  @override
  Widget build(BuildContext context) {
    podcastDate = ref
        .read(auidoProvider)
        .getPodcastPublishedDateFromEpoch(widget.episodeItem['datePublished']);

    final AsyncValue queueListAsync = ref.watch(getQueueProvider);

    final AsyncValue<List<DownloadModel>> downloadedListProvider =
        ref.watch(sortedDownloadsProvider);

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
        color: Colors.blueGrey[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image, title, author, and date
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
                        imageUrl: widget.episodeItem['feedImage'] ??
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
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 130.0,
                            // Podcast title
                            child: Text(
                              widget.title,
                              style: const TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 2,
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 130.0,
                            // Podcast title
                            child: Text(
                              widget.podcast.author ??
                                  Translations.of(context).text('unknown'),
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
              // TODO: Use a rich text widget to display the description
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3.0),
                child: StyledText(
                  text: widget.episodeItem['description'],
                  maxLines: 4,
                  style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Row(
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
                        if (ref.read(auidoProvider).currentEpisode !=
                            widget.episodeItem) {
                          ref
                              .read(auidoProvider.notifier)
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
                      isQueued = data.containsKey(widget.episodeItem['guid']);

                      return IconButton(
                        tooltip: Translations.of(context).text('addToQueue'),
                        onPressed: () {
                          isQueued
                              ? ref
                                  .read(auidoProvider)
                                  .removeFromQueue(widget.episodeItem['guid'])
                              : ref.read(auidoProvider).addToQueue(
                                    widget.episodeItem,
                                    widget.podcast,
                                  );

                          ref.invalidate(getQueueProvider);
                          ref.invalidate(
                              podcastDataByUrlProvider(widget.podcast.feedUrl));

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isQueued
                                    ? '${Translations.of(context).text('removedFromQueue')}: ${widget.episodeItem['title']}'
                                    : '${Translations.of(context).text('addedToQueue')}: ${widget.episodeItem['title']}',
                              ),
                            ),
                          );
                        },
                        icon: isQueued
                            ? const Icon(Icons.playlist_add_check_rounded)
                            : const Icon(Icons.playlist_add_rounded),
                      );
                    },
                    error: (error, stackTrace) {
                      debugPrint(
                          'Error in queueListAsync for EpisodeCard: $error');
                      return IconButton(
                        tooltip: Translations.of(context).text('addToQueue'),
                        onPressed: () {},
                        icon: const Icon(Icons.error_outline_rounded),
                      );
                    },
                    loading: () {
                      // Handle loading by showing previous state's icon, disabled
                      final previousList = queueListAsync.valueOrNull;

                      final isQueuedPreviously = previousList
                              ?.containsKey(widget.episodeItem['guid']) ??
                          false;

                      return IconButton(
                        tooltip: Translations.of(context).text('addToQueue'),
                        onPressed: null, // Disable button while loading
                        icon: isQueuedPreviously
                            ? const Icon(Icons.playlist_add_check_rounded)
                            : const Icon(Icons.playlist_add_rounded),
                      );
                    },
                  ),
                  // Download button
                  if (!kIsWeb)
                    downloadedListProvider.when(
                      data: (downloads) {
                        final isDownloaded = downloads
                            .any((d) => d.guid == widget.episodeItem['guid']);

                        final isDownloading = ref.watch(auidoProvider.select(
                            (p) => p.downloadingPodcasts
                                .contains(widget.episodeItem['guid'])));

                        IconData iconData;
                        String tooltip;
                        VoidCallback? onPressed;

                        if (isDownloading) {
                          iconData = Icons.downloading_rounded;
                          tooltip =
                              Translations.of(context).text('downloading');
                          onPressed = null;
                        } else if (isDownloaded) {
                          iconData = Icons.download_done_rounded;
                          tooltip =
                              Translations.of(context).text('deleteDownload');

                          onPressed = () {
                            showDialog(
                              context: context,
                              builder: (BuildContext dialogContext) =>
                                  AlertDialog(
                                title: Text(Translations.of(context)
                                    .text('confirmDeletion')),
                                content: Text(
                                    '${Translations.of(context).text('areYouSureYouWantToRemoveDownload')} \'${widget.episodeItem['title']}\'?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text(Translations.of(context)
                                        .text('cancel')),
                                    onPressed: () {
                                      Navigator.of(dialogContext)
                                          .pop(); // Dismiss the dialog
                                    },
                                  ),
                                  TextButton(
                                    child: Text(Translations.of(context)
                                        .text('remove')),
                                    onPressed: () async {
                                      // Pop the dialog first
                                      Navigator.of(dialogContext).pop();

                                      // Then perform the removal
                                      await ref
                                          .read(auidoProvider.notifier)
                                          .removeDownload(widget.episodeItem);

                                      // Show feedback
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                '${Translations.of(context).text('removed')} \'${widget.episodeItem['title']}\''),
                                          ),
                                        );
                                      }

                                      ref.invalidate(sortedDownloadsProvider);
                                    },
                                  ),
                                ],
                              ),
                            );

                            ref.invalidate(sortedDownloadsProvider);
                          };
                        }
                        // Not downloaded
                        else {
                          iconData = Icons.download_rounded;
                          tooltip =
                              Translations.of(context).text('downloadEpisode');

                          onPressed = () {
                            if (kIsWeb) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Downloading is not available on the web.'),
                                  ),
                                );
                              }
                            } else {
                              ref.read(auidoProvider.notifier).downloadEpisode(
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
                            }
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
                            // child: CircularProgressIndicator(),
                            child: CircularProgressIndicator(strokeWidth: 2.0),
                          ),
                          onPressed: null),
                    ),
                  IconButton(
                    tooltip: Translations.of(context).text('share'),
                    onPressed: () => ref.watch(openAirProvider).share(),
                    icon: const Icon(Icons.share_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
