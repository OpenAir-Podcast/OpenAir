import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/podcast_provider.dart';
import 'package:openair/views/player/banner_audio_player.dart';
import 'package:openair/views/widgets/play_button_widget.dart';
import 'package:podcastindex_dart/src/entity/episode.dart';

class EpisodeDetail extends ConsumerStatefulWidget {
  const EpisodeDetail({
    super.key,
    this.episodeItem,
  });

  final Episode? episodeItem;

  @override
  EpisodeDetailState createState() => EpisodeDetailState();
}

class EpisodeDetailState extends ConsumerState<EpisodeDetail> {
  @override
  Widget build(BuildContext context) {
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
                            ref.watch(podcastProvider).currentPodcast!.artwork,
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      width: 92.0,
                      height: 92.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Podcast Title
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 140.0,
                          child: Text(
                            ref.watch(podcastProvider).currentPodcast!.title,
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
                            ref.watch(podcastProvider).currentPodcast!.author,
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
                              .watch(podcastProvider)
                              .getPodcastPublishedDateFromEpoch(ref
                                  .watch(podcastProvider)
                                  .currentEpisode!
                                  .datePublished),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0,
                            color: Colors.grey,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Text(
                ref.watch(podcastProvider).currentEpisode!.title,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
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
                        onPressed: () =>
                            ref.read(podcastProvider).playerPlayButtonClicked(
                                  widget.episodeItem!,
                                ),
                        child: PlayButtonWidget(
                          episodeItem: widget.episodeItem!,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.playlist_add),
                    ),
                    // FIXME: Add download button
                    // Download Button
                    // IconButton(
                    //   onPressed: () {
                    //     if (widget.episodeItem!.getDownloaded ==
                    //         DownloadStatus.notDownloaded) {
                    //       ref
                    //           .read(podcastProvider)
                    //           .playerDownloadButtonClicked(widget.episodeItem!);
                    //
                    //       ScaffoldMessenger.of(context).showSnackBar(
                    //         SnackBar(
                    //           content: Text(
                    //               'Downloading \'${widget.episodeItem!.rssItem!.title}\''),
                    //         ),
                    //       );
                    //     } else if (widget.episodeItem!.getDownloaded ==
                    //         DownloadStatus.downloaded) {
                    //       showModalBottomSheet(
                    //         context: context,
                    //         builder: (context) => SizedBox(
                    //           width: double.infinity,
                    //           height: 50.0,
                    //           child: ElevatedButton.icon(
                    //             onPressed: () {
                    //               ref
                    //                   .read(podcastProvider)
                    //                   .playerRemoveDownloadButtonClicked(
                    //                       widget.episodeItem!);
                    //
                    //               ScaffoldMessenger.of(context).showSnackBar(
                    //                 SnackBar(
                    //                   content: Text(
                    //                       'Removed \'${widget.episodeItem!.rssItem!.title}\''),
                    //                 ),
                    //               );
                    //             },
                    //             icon: const Icon(Icons.delete),
                    //             label: const Text('Remove download'),
                    //           ),
                    //         ),
                    //       );
                    //     } else {
                    // TODO: Add cancel download
                    //     }
                    //   },
                    //   icon: ref
                    //       .read(podcastProvider)
                    //       .getDownloadIcon(widget.episodeItem!.getDownloaded!),
                    // ),
                    // More Button
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert_outlined),
                    ),
                  ],
                ),
              ),
              // Episode Description
              // TODO: Use a rich text widget to display the description
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  ref.watch(podcastProvider).currentEpisode!.description!,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: ref.watch(podcastProvider).isPodcastSelected ? 75.0 : 0.0,
        child: ref.watch(podcastProvider).isPodcastSelected
            ? const BannerAudioPlayer()
            : const SizedBox(),
      ),
    );
  }
}
