import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/hive_models/podcast_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/services/fyyd_provider.dart';
import 'package:openair/views/mobile/main_pages/episodes_page.dart';
import 'package:webfeed_plus/domain/rss_feed.dart';

class FyydSearchCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> podcastItem;

  const FyydSearchCard({
    super.key,
    required this.podcastItem,
  });

  @override
  ConsumerState<FyydSearchCard> createState() => _FyydSearchCardState();
}

class _FyydSearchCardState extends ConsumerState<FyydSearchCard> {
  @override
  Widget build(BuildContext context) {
    bool isSub = false;

    return GestureDetector(
      onTap: () async {
        final xmlString = await ref
            .watch(fyydProvider)
            .getPodcastXml(widget.podcastItem['xmlURL']);

        var rssFeed = RssFeed.parse(xmlString);

        PodcastModel podcastModel = PodcastModel(
          id: widget.podcastItem['id'],
          feedUrl: widget.podcastItem['xmlURL'],
          title: rssFeed.title!,
          author: rssFeed.author ?? 'unkown',
          imageUrl: widget.podcastItem['imgURL'],
          artwork: widget.podcastItem['imgURL'],
          description: rssFeed.description!,
        );

        ref.read(auidoProvider).currentPodcast = podcastModel;

        if (context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EpisodesPage(podcast: podcastModel),
            ),
          );
        }
      },
      child: Card(
        color: Colors.blueGrey[100],
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
                            widget.podcastItem['title'],
                            maxLines: 2,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
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
                future: ref
                    .watch(openAirProvider)
                    .isSubscribed(widget.podcastItem['title']),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text('...'),
                    );
                  } else if (snapshot.hasError) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Icon(Icons.error_outline_rounded),
                    );
                  }

                  isSub = snapshot.data!;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: IconButton(
                      tooltip: snapshot.data!
                          ? 'Unsubscribe to podcast'
                          : 'Subscribe to podcast',
                      onPressed: () async {
                        final xmlString = await ref
                            .watch(fyydProvider)
                            .getPodcastXml(widget.podcastItem['xmlURL']);

                        var rssFeed = RssFeed.parse(xmlString);

                        PodcastModel podcastModel = PodcastModel(
                          id: widget.podcastItem['id'],
                          feedUrl: widget.podcastItem['xmlURL'],
                          title: rssFeed.title!,
                          author: rssFeed.author ?? 'unkown',
                          imageUrl: widget.podcastItem['imgURL'],
                          artwork: widget.podcastItem['imgURL'],
                          description: rssFeed.description!,
                        );

                        if (snapshot.data!) {
                          ref.read(auidoProvider).unsubscribe(podcastModel);
                          setState(() {
                            isSub = false;
                          });
                        } else {
                          if (context.mounted) {
                            ref.read(auidoProvider).subscribe(
                                  podcastModel,
                                  context,
                                );
                          }
                          setState(() {
                            isSub = true;
                          });
                        }

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                snapshot.data!
                                    ? 'Unsubscribed from ${podcastModel.title}'
                                    : 'Subscribed to ${podcastModel.title}',
                              ),
                            ),
                          );
                        }
                      },
                      icon: isSub
                          ? const Icon(Icons.check_rounded)
                          : const Icon(Icons.add_rounded),
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
