import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/scale.dart';
import 'package:openair/models/queue_model.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/mobile/main_pages/episode_detail.dart';
import 'package:openair/views/mobile/widgets/play_button_widget.dart';
import 'package:styled_text/styled_text.dart';

final isEpisodeNewProvider =
    FutureProvider.family<bool, String>((ref, guid) async {
  final apiService = ref.watch(openAirProvider);
  return await apiService.isEpisodeNew(guid);
});

class SubscriptionEpisodeCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> episodeItem;
  final Map<String, dynamic> podcast;
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
        .watch(openAirProvider)
        .getPodcastPublishedDateFromEpoch(widget.episodeItem['datePublished']);

    final AsyncValue<Map<String, QueueModel>> getQueueValue =
        ref.watch(queueProvider);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EpisodeDetail(
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
              color: Colors.blueGrey[100],
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
                                  .watch(openAirProvider)
                                  .currentPodcast!['image'],
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
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      overflow: TextOverflow.ellipsis,
                                      fontWeight: FontWeight.bold,
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
                                            .watch(openAirProvider)
                                            .currentPodcast!['author'] ??
                                        "Unknown",
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
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: SizedBox(
                        height: 88.0,
                        child: StyledText(
                          text: widget.episodeItem['description'],
                          maxLines: 4,
                          style: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                          ),
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
                              if (ref.read(openAirProvider).currentEpisode !=
                                  widget.episodeItem) {
                                ref
                                    .read(openAirProvider.notifier)
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
                        getQueueValue.when(
                          data: (data) {
                            bool isQueued = false;

                            data.containsKey(widget.episodeItem['guid'])
                                ? isQueued = true
                                : isQueued = false;

                            return IconButton(
                              tooltip: "Add to queue",
                              onPressed: () {
                                isQueued
                                    ? ref
                                        .watch(openAirProvider)
                                        .removeFromQueue(
                                            widget.episodeItem['guid'])
                                    : ref.watch(openAirProvider).addToQueue(
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

                                ref.invalidate(queueProvider);
                              },
                              icon: isQueued
                                  ? const Icon(Icons.playlist_add_check_rounded)
                                  : const Icon(Icons.playlist_add_rounded),
                            );
                          },
                          error: (error, stackTrace) {
                            return IconButton(
                              tooltip: "Add to queue",
                              onPressed: () {},
                              icon: const Icon(Icons.error_outline_rounded),
                            );
                          },
                          loading: () {
                            return IconButton(
                              tooltip: "Add to queue",
                              onPressed: () {},
                              icon: Icon(
                                  Icons.keyboard_double_arrow_down_rounded),
                            );
                          },
                        ),
                        // Download button
                        IconButton(
                          tooltip: "Download",
                          onPressed: () {
                            // TODO: Implement download button
                            // if (episodeItem.getDownloaded ==
                            //     DownloadStatus.notDownloaded) {
                            //   ref
                            //       .read(podcastProvider.notifier)
                            //       .playerDownloadButtonClicked(episodeItem);
                            //
                            //   ScaffoldMessenger.of(context).showSnackBar(
                            //     SnackBar(
                            //       content: Text(
                            //           'Downloading \'${episodeItem.rssItem!.title}\''),
                            //     ),
                            //   );
                            // } else if (episodeItem.getDownloaded ==
                            //     DownloadStatus.downloaded) {
                            //   showModalBottomSheet(
                            //     context: context,
                            //     builder: (context) => SizedBox(
                            //       width: double.infinity,
                            //       height: 50.0,
                            //       child: ElevatedButton.icon(
                            //         onPressed: () {
                            //           ref
                            //               .read(podcastProvider.notifier)
                            //               .playerRemoveDownloadButtonClicked(
                            //                   episodeItem);
                            //
                            //           ScaffoldMessenger.of(context).showSnackBar(
                            //             SnackBar(
                            //               content: Text(
                            //                   'Removed \'${episodeItem.rssItem!.title}\''),
                            //             ),
                            //           );
                            //         },
                            //         icon: const Icon(Icons.delete),
                            //         label: const Text('Remove download'),
                            //       ),
                            //     ),
                            //   );
                            // } else {
                            // TODO: Add cancel download
                            // }
                          },
                          // icon: ref
                          //     .read(podcastProvider.notifier)
                          //     .getDownloadIcon(episodeItem.getDownloaded!),

                          icon: const Icon(Icons.download_rounded),
                        ),
                        IconButton(
                          tooltip: "More",
                          onPressed: () {},
                          icon: const Icon(Icons.more_vert_rounded),
                        ),
                      ],
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
