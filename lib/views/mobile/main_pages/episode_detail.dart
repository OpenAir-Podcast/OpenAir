import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return Scaffold(
      appBar: AppBar(),
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
                          tooltip: "Add to queue",
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
                          tooltip: "Add to queue",
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
                          tooltip: "Add to queue",
                          onPressed: null, // Disable button while loading
                          icon: isQueuedPreviously
                              ? const Icon(Icons.playlist_add_check_rounded)
                              : const Icon(Icons.playlist_add_rounded),
                        );
                      },
                    ),
                    // TODO: Add download button
                    // Download Button
                    IconButton(
                      tooltip: "Download",
                      onPressed: () {
                        // if (widget.episodeItem!.getDownloaded ==
                        //     DownloadStatus.notDownloaded) {
                        //   ref
                        //       .read(podcastProvider)
                        //       .playerDownloadButtonClicked(widget.episodeItem!);
                        //
                        //   ScaffoldMessenger.of(context).showSnackBar(
                        //     SnackBar(
                        //       content: Text(
                        //           'Downloading \'${widget.episodeItem!.rssItem!.title}\''),
                        //     ),
                        //   );
                        // } else if (widget.episodeItem!.getDownloaded ==
                        //     DownloadStatus.downloaded) {
                        //   showModalBottomSheet(
                        //     context: context,
                        //     builder: (context) => SizedBox(
                        //       width: double.infinity,
                        //       height: 50.0,
                        //       child: ElevatedButton.icon(
                        //         onPressed: () {
                        //           ref
                        //               .read(podcastProvider)
                        //               .playerRemoveDownloadButtonClicked(
                        //                   widget.episodeItem!);
                        //
                        //           ScaffoldMessenger.of(context).showSnackBar(
                        //             SnackBar(
                        //               content: Text(
                        //                   'Removed \'${widget.episodeItem!.rssItem!.title}\''),
                        //             ),
                        //           );
                        //         },
                        //         icon: const Icon(Icons.delete),
                        //         label: const Text('Remove download'),
                        //       ),
                        //     ),
                        //   );
                        // } else {}
                      },
                      icon: const Icon(Icons.download_rounded),
                    ),
                    // More Button
                    IconButton(
                      tooltip: "More",
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert_outlined),
                    ),
                  ],
                ),
              ),
              // Episode Description
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
