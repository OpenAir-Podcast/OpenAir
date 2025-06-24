import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/models/download_model.dart';
import 'package:openair/models/queue_model.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/mobile/player/banner_audio_player.dart';
import 'package:openair/views/mobile/widgets/play_button_widget.dart';

class EpisodeDetail extends ConsumerStatefulWidget {
  const EpisodeDetail({
    super.key,
    this.episodeItem,
    this.podcast,
  });

  final Map<String, dynamic>? episodeItem;
  final Map<String, dynamic>? podcast;

  @override
  EpisodeDetailState createState() => EpisodeDetailState();
}

class EpisodeDetailState extends ConsumerState<EpisodeDetail> {
  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<QueueModel>> queueListAsync =
        ref.watch(sortedQueueListProvider);

    final AsyncValue<List<Download>> downloadedListAsync =
        ref.watch(sortedDownloadsProvider);

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
                            widget.podcast!['title'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 140.0,
                          child: Text(
                            ref
                                    .watch(openAirProvider)
                                    .currentPodcast!['author'] ??
                                'Unknown',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                        // Podcast Published Date
                        Text(
                          ref
                              .watch(openAirProvider)
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
                            .read(openAirProvider)
                            .playerPlayButtonClicked(widget.episodeItem!),
                        child: PlayButtonWidget(
                          episodeItem: widget.episodeItem!,
                        ),
                      ),
                    ),
                    // Queue Button
                    queueListAsync.when(
                      data: (list) {
                        final isQueued = list.any(
                            (item) => item.guid == widget.episodeItem!['guid']);

                        return IconButton(
                          tooltip: "Add to Queue",
                          onPressed: () {
                            isQueued
                                ? ref.read(openAirProvider).removeFromQueue(
                                    widget.episodeItem!['guid'])
                                : ref.read(openAirProvider).addToQueue(
                                      widget.episodeItem!,
                                      widget.podcast,
                                    );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isQueued
                                      ? 'Removed ${widget.episodeItem!['title']} from queue'
                                      : 'Added ${widget.episodeItem!['title']} to queue',
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
                          tooltip: "Add to Queue",
                          onPressed: () {},
                          icon: const Icon(Icons.error_outline_rounded),
                        );
                      },
                      loading: () {
                        // Handle loading by showing previous state's icon, disabled
                        final previousList = queueListAsync.valueOrNull;
                        final isQueuedPreviously = previousList?.any((item) =>
                                item.guid == widget.episodeItem!['guid']) ??
                            false;

                        return IconButton(
                          tooltip: "Add to Queue",
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

                          final isDownloading = ref.watch(openAirProvider
                              .select((p) => p.downloadingPodcasts
                                  .contains(widget.episodeItem!['guid'])));

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
                                      'Are you sure you want to remove the download for \'${widget.episodeItem!['title']}\'?'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Cancel'),
                                      onPressed: () {
                                        Navigator.of(dialogContext)
                                            .pop(); // Dismiss the dialog
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('Remove'),
                                      onPressed: () async {
                                        // Pop the dialog first
                                        Navigator.of(dialogContext).pop();

                                        // Then perform the removal
                                        await ref
                                            .read(openAirProvider.notifier)
                                            .removeDownload(
                                                widget.episodeItem!);

                                        // Show feedback
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Removed \'${widget.episodeItem!['title']}\''),
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
                          // Episode not downloaded
                          else {
                            iconData = Icons.download_rounded;
                            tooltip = 'Download Episode';

                            onPressed = () {
                              ref
                                  .read(openAirProvider.notifier)
                                  .downloadEpisode(
                                    widget.episodeItem!,
                                    widget.podcast!,
                                  );

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Downloading \'${widget.episodeItem!['title']}\''),
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
                      tooltip: "Share",
                      onPressed: () => ref.watch(openAirProvider).share(),
                      icon: const Icon(Icons.share_rounded),
                    ),
                  ],
                ),
              ),
              // Episode Description
              // TODO: Use a rich text widget to display the description
              SingleChildScrollView(
                child: Html(
                  data: widget.episodeItem!['description'],
                  style: {
                    "br": Style(
                      display: Display.block,
                      backgroundColor: Colors.black,
                    ),
                  },
                  shrinkWrap: true,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: ref.watch(openAirProvider).isPodcastSelected ? 75.0 : 0.0,
        child: ref.watch(openAirProvider).isPodcastSelected
            ? const BannerAudioPlayer()
            : const SizedBox(),
      ),
    );
  }
}
