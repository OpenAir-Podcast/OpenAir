import 'dart:io';

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
import 'package:openair/views/mobile/nav_pages/favorites_page.dart';
import 'package:openair/views/mobile/player/banner_audio_player.dart';
import 'package:openair/views/mobile/settings_pages/notifications_page.dart';
import 'package:openair/views/mobile/widgets/play_button_widget.dart';
import 'package:styled_text/widgets/styled_text.dart';

class EpisodeDetail extends ConsumerStatefulWidget {
  const EpisodeDetail({
    super.key,
    this.episodeItem,
    this.podcast,
  });

  final Map<String, dynamic>? episodeItem;
  final PodcastModel? podcast;

  @override
  EpisodeDetailState createState() => EpisodeDetailState();
}

class EpisodeDetailState extends ConsumerState<EpisodeDetail> {
  @override
  Widget build(BuildContext context) {
    final AsyncValue<Map> queueListAsync = ref.watch(getQueueProvider);

    final AsyncValue<List<DownloadModel>> downloadedListAsync =
        ref.watch(sortedDownloadsProvider);

    final AsyncValue favoriteListAsync = ref.watch(getFavoriteProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.episodeItem!['title']),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        image: DecorationImage(
                          image: NetworkImage(
                            widget.episodeItem!['feedImage'] ??
                                widget.episodeItem!['image'],
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      width: 92.0,
                      height: 92.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Podcast Title
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 140.0,
                          child: Text(
                            widget.podcast!.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0,
                              color: Brightness.dark ==
                                      Theme.of(context).brightness
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                        // SizedBox(
                        //   width: MediaQuery.of(context).size.width - 140.0,
                        //   child: Text(
                        //     ref.watch(audioProvider).currentPodcast!.author ??
                        //         Translations.of(context).text('unknown'),
                        //     style: const TextStyle(
                        //       fontWeight: FontWeight.bold,
                        //       fontSize: 14.0,
                        //       color: Colors.grey,
                        //     ),
                        //     overflow: TextOverflow.ellipsis,
                        //     maxLines: 2,
                        //   ),
                        // ),
                        // Podcast Published Date
                        Text(
                          ref
                              .watch(audioProvider)
                              .getPodcastPublishedDateFromEpoch(
                                  widget.episodeItem!['datePublished']),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Play button
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 1.0,
                          shape: const StadiumBorder(
                            side: BorderSide(
                              width: 1.0,
                            ),
                          ),
                        ),
                        onPressed: () => ref
                            .read(audioProvider)
                            .playerPlayButtonClicked(widget.episodeItem!),
                        child: PlayButtonWidget(
                          episodeItem: widget.episodeItem!,
                        ),
                      ),
                    ),
                    // Queue Button
                    queueListAsync.when(
                      data: (data) {
                        final isQueued =
                            data.containsKey(widget.episodeItem!['guid']);

                        return IconButton(
                          tooltip: Translations.of(context).text('addToQueue'),
                          onPressed: () {
                            isQueued
                                ? ref.read(audioProvider).removeFromQueue(
                                    widget.episodeItem!['guid'])
                                : ref.read(audioProvider).addToQueue(
                                      widget.episodeItem!,
                                      widget.podcast,
                                    );

                            if (!Platform.isAndroid && !Platform.isIOS) {
                              ref
                                  .read(notificationServiceProvider)
                                  .showNotification(
                                    'OpenAir ${Translations.of(context).text('notification')}',
                                    isQueued
                                        ? '${Translations.of(context).text('removedFromQueue')}: ${widget.episodeItem!['title']}'
                                        : '${Translations.of(context).text('addedToQueue')}: ${widget.episodeItem!['title']}',
                                  );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isQueued
                                        ? '${Translations.of(context).text('removedFromQueue')}: ${widget.episodeItem!['title']}'
                                        : '${Translations.of(context).text('addedToQueue')}: ${widget.episodeItem!['title']}',
                                  ),
                                ),
                              );
                            }

                            if (enqueueDownloadedConfig) {
                              ref
                                  .watch(openAirProvider)
                                  .downloadEnqueue(context);
                            }

                            ref.invalidate(getQueueProvider);
                          },
                          icon: isQueued
                              ? const Icon(Icons.playlist_add_check_rounded)
                              : const Icon(Icons.playlist_add_rounded),
                        );
                      },
                      error: (error, stackTrace) {
                        debugPrint('Error in queueListAsync: $error');
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
                                ?.containsKey(widget.episodeItem!['guid']) ??
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
                    // Download Button
                    if (!kIsWeb)
                      downloadedListAsync.when(
                        data: (downloads) {
                          final isDownloaded = downloads.any(
                              (d) => d.guid == widget.episodeItem!['guid']);

                          final isDownloading = ref.watch(audioProvider.select(
                              (p) => p.downloadingPodcasts
                                  .contains(widget.episodeItem!['guid'])));

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
                                      '${Translations.of(context).text('AreYouSureYouWantToRemoveDownload')} \'${widget.episodeItem!['title']}\'?'),
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
                                          .text('removed')),
                                      onPressed: () async {
                                        // Pop the dialog first
                                        Navigator.of(dialogContext).pop();

                                        // Then perform the removal
                                        await ref
                                            .read(audioProvider.notifier)
                                            .removeDownload(
                                                widget.episodeItem!);

                                        // Show feedback
                                        if (context.mounted) {
                                          if (!Platform.isAndroid &&
                                              !Platform.isIOS) {
                                            ref
                                                .read(
                                                    notificationServiceProvider)
                                                .showNotification(
                                                  'OpenAir ${Translations.of(context).text('notification')}',
                                                  '${Translations.of(context).text('removed')} \'${widget.episodeItem!['title']}\'',
                                                );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  '${Translations.of(context).text('removed')} \'${widget.episodeItem!['title']}\'',
                                                ),
                                              ),
                                            );
                                          }
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
                          // Episode not downloaded
                          else {
                            iconData = Icons.download_rounded;
                            tooltip =
                                Translations.of(context).text('deleteDownload');

                            onPressed = () {
                              ref.read(audioProvider.notifier).downloadEpisode(
                                    widget.episodeItem!,
                                    widget.podcast!,
                                    context,
                                  );

                              if (!Platform.isAndroid && !Platform.isIOS) {
                                ref.read(notificationServiceProvider).showNotification(
                                    'OpenAir ${Translations.of(context).text('notification')}',
                                    '${Translations.of(context).text('downloading')} \'${widget.episodeItem!['title']}\'');
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${Translations.of(context).text('downloading')} \'${widget.episodeItem!['title']}\''),
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
                            data.containsKey(widget.episodeItem!['guid']);

                        return IconButton(
                          tooltip: Translations.of(context).text('favourite'),
                          onPressed: () async {
                            setState(() {
                              if (isFavorite) {
                                ref
                                    .read(audioProvider)
                                    .removeEpisodeFromFavorite(
                                        widget.episodeItem!['guid']);

                                if (context.mounted) {
                                  if (!Platform.isAndroid && !Platform.isIOS) {
                                    ref
                                        .read(notificationServiceProvider)
                                        .showNotification(
                                            'OpenAir ${Translations.of(context).text('notification')}',
                                            '${Translations.of(context).text('removedFromFavorites')}: ${widget.episodeItem!['title']}');
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            '${Translations.of(context).text('removedFromFavorites')}: ${widget.episodeItem!['title']}'),
                                      ),
                                    );
                                  }
                                }
                              } else {
                                ref.read(audioProvider).addEpisodeToFavorite(
                                    widget.episodeItem!, widget.podcast!);

                                if (context.mounted) {
                                  if (!Platform.isAndroid && !Platform.isIOS) {
                                    ref
                                        .read(notificationServiceProvider)
                                        .showNotification(
                                          'OpenAir ${Translations.of(context).text('notification')}',
                                          '${Translations.of(context).text('addedToFavorites')}: ${widget.episodeItem!['title']}',
                                        );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${Translations.of(context).text('addedToFavorites')}: ${widget.episodeItem!['title']}',
                                        ),
                                      ),
                                    );
                                  }
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
                        tooltip: Translations.of(context).text('favourite'),
                        onPressed: null, // Disable button while loading
                        icon: const Icon(Icons
                            .favorite_border_rounded), // Or a loading indicator icon
                      ),
                      error: (error, stackTrace) {
                        debugPrint('Error checking favorite status: $error');
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
              // Episode Description
              // TODO: Use a rich text widget to display the description
              SingleChildScrollView(
                child: StyledText(
                  text: widget.episodeItem!['description'],
                  maxLines: 4,
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    color: Brightness.dark == Theme.of(context).brightness
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: ref.watch(audioProvider).isPodcastSelected ? 75.0 : 0.0,
        child: ref.watch(audioProvider).isPodcastSelected
            ? const BannerAudioPlayer()
            : const SizedBox(),
      ),
    );
  }
}
