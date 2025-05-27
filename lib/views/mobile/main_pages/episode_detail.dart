import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/mobile/player/banner_audio_player.dart';
import 'package:openair/views/mobile/widgets/play_button_widget.dart';

class EpisodeDetail extends ConsumerStatefulWidget {
  const EpisodeDetail({
    super.key,
    this.episodeItem,
  });

  final Map<String, dynamic>? episodeItem;

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
                            ref.watch(openAirProvider).currentPodcast!['image'],
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
                            ref.watch(openAirProvider).currentPodcast!['title'],
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
              Text(
                widget.episodeItem!['title'],
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
                        onPressed: () =>
                            ref.read(openAirProvider).playerPlayButtonClicked(
                                  widget.episodeItem!,
                                ),
                        child: PlayButtonWidget(
                          episodeItem: widget.episodeItem!,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: "Add to queue",
                      onPressed: () {},
                      icon: const Icon(Icons.playlist_add),
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
                    "p.fancy": Style(
                      textAlign: TextAlign.center,
                      backgroundColor: Colors.grey,
                      margin: Margins(
                          left: Margin(50, Unit.px), right: Margin.auto()),
                      width: Width(300, Unit.px),
                      fontWeight: FontWeight.bold,
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
