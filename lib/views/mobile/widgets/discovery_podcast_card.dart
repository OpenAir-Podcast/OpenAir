import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/hive_models/podcast_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/mobile/main_pages/episodes_page.dart';
import 'package:openair/views/mobile/nav_pages/feeds_page.dart';

class DiscoveryPodcastCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> podcastItem;

  const DiscoveryPodcastCard({
    super.key,
    required this.podcastItem,
  });

  @override
  ConsumerState<DiscoveryPodcastCard> createState() =>
      _DiscoveryPodcastCardState();
}

class _DiscoveryPodcastCardState extends ConsumerState<DiscoveryPodcastCard> {
  @override
  Widget build(BuildContext context) {
    PodcastModel podcast = PodcastModel(
      id: widget.podcastItem['id'],
      feedUrl: widget.podcastItem['xmlURL'],
      title: widget.podcastItem['title'],
      description: widget.podcastItem['description'],
      author: widget.podcastItem['description'],
      imageUrl: widget.podcastItem['imgURL'],
      artwork: widget.podcastItem['imgURL'],
    );

    return GestureDetector(
      onTap: () async {
        ref.read(audioProvider).currentPodcast = podcast;

        if (context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EpisodesPage(podcast: podcast),
            ),
          );
        }
      },
      child: Card(
        color: Theme.of(context).cardColor,
        elevation: 2.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 62.0,
                height: 62.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: CachedNetworkImage(
                  memCacheHeight: 62,
                  memCacheWidth: 62,
                  imageUrl: widget.podcastItem['imgURL'],
                  fit: BoxFit.fill,
                  errorWidget: (context, url, error) => Container(
                    color: cardImageShadow,
                    child: Icon(
                      Icons.error,
                      size: 56.0,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  width: 500.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 105.0,
                          child: Text(
                            podcast.title,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                              color: Brightness.light ==
                                      Theme.of(context).brightness
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 120.0,
                          child: Text(
                            widget.podcastItem['subtitle'].isNotEmpty
                                ? widget.podcastItem['subtitle']
                                : 'Unknown',
                            maxLines: 2,
                            style: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              FutureBuilder(
                future: ref.watch(openAirProvider).isSubscribed(podcast.title),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text('...'),
                    );
                  } else if (snapshot.hasError) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text('...'),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: IconButton(
                      tooltip: snapshot.data!
                          ? Translations.of(context)
                              .text('unsubscribeToPodcast')
                          : Translations.of(context).text('subscribeToPodcast'),
                      onPressed: () async {
                        // FIXME: Doesn't subscribe/unsubscribe immediately
                        snapshot.data!
                            ? ref.read(audioProvider).unsubscribe(podcast)
                            : ref.read(audioProvider).subscribe(
                                  podcast,
                                  context,
                                );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              snapshot.data!
                                  ? '${Translations.of(context).text('unsubscribed')} ${podcast.title}'
                                  : '${Translations.of(context).text('subscribed')} ${podcast.title}',
                            ),
                          ),
                        );

                        ref.invalidate(
                            podcastDataByUrlProvider(podcast.feedUrl));
                        ref.invalidate(getFeedsProvider);
                      },
                      icon: snapshot.data!
                          ? const Icon(Icons.check)
                          : const Icon(Icons.add),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
