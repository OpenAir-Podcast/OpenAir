import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/podcast_provider.dart';
import 'package:openair/views/player/episode_detail.dart';
import 'package:openair/views/widgets/play_button_widget.dart';
import 'package:podcastindex_dart/src/entity/episode.dart';

class EpisodeCard extends ConsumerStatefulWidget {
  final Episode episodeItem;

  const EpisodeCard({
    super.key,
    required this.episodeItem,
  });

  @override
  ConsumerState<EpisodeCard> createState() => _EpisodeCardState();
}

class _EpisodeCardState extends ConsumerState<EpisodeCard> {
  String podcastDate = "";

  @override
  Widget build(BuildContext context) {
    podcastDate = ref
        .watch(podcastProvider)
        .getPodcastPublishedDateFromEpoch(widget.episodeItem.datePublished);

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
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(width: 1.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          image: DecorationImage(
                            image: NetworkImage(
                              ref
                                  .watch(podcastProvider)
                                  .currentPodcast!
                                  .artwork,
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        width: 62.0,
                        height: 62.0,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 130.0,
                            // Podcast title
                            child: Text(
                              ref.watch(podcastProvider).currentPodcast!.title,
                              style: const TextStyle(
                                fontSize: 14.0,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 130.0,
                            // Podcast title
                            child: Text(
                              ref.watch(podcastProvider).currentPodcast!.author,
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
                  ],
                ),
                SizedBox(
                  height: 40.0,
                  child: Text(
                    widget.episodeItem.title,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // TODO: Use a rich text widget to display the description
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: SizedBox(
                    height: 88.0,
                    child: Text(
                      widget.episodeItem.description!,
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
                    SizedBox(
                      width: 200.0,
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
                          if (ref.read(podcastProvider).currentEpisode !=
                              widget.episodeItem) {
                            ref
                                .read(podcastProvider.notifier)
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
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.playlist_add_rounded),
                    ),
                    // Download button
                    IconButton(
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
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
