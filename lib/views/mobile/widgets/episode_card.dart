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

class EpisodeCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> episodeItem;
  final String title;
  final Map<String, dynamic> podcast;

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

  @override
  Widget build(BuildContext context) {
    podcastDate = ref
        .read(openAirProvider)
        .getPodcastPublishedDateFromEpoch(widget.episodeItem['datePublished']);

    final AsyncValue<List<QueueModel>> queueListAsync =
        ref.watch(sortedQueueListProvider);

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
                        imageUrl: widget.episodeItem['feedImage'],
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
                              widget.podcast['author'] ?? "Unknown",
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
                  queueListAsync.when(
                    data: (list) {
                      final isQueued = list.any(
                          (item) => item.guid == widget.episodeItem['guid']);

                      return IconButton(
                        tooltip: "Add to Queue",
                        onPressed: () {
                          isQueued
                              ? ref
                                  .read(openAirProvider)
                                  .removeFromQueue(widget.episodeItem['guid'])
                              : ref.read(openAirProvider).addToQueue(
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
                              item.guid == widget.episodeItem['guid']) ??
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
                  // Download button
                  IconButton(
                    tooltip: "Download Episode",
                    onPressed: () {
                      
                    },
                    icon: const Icon(Icons.download_rounded),
                  ),
                  IconButton(
                    tooltip: "Share",
                    onPressed: () {},
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
