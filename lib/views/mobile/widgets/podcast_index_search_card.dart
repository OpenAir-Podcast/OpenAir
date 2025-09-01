import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/hive_models/podcast_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/mobile/main_pages/episodes_page.dart';

class PodcastIndexSearchCard extends ConsumerStatefulWidget {
  final PodcastModel podcastItem;

  const PodcastIndexSearchCard({
    super.key,
    required this.podcastItem,
  });

  @override
  ConsumerState<PodcastIndexSearchCard> createState() =>
      _PodcastIndexSearchCardState();
}

class _PodcastIndexSearchCardState
    extends ConsumerState<PodcastIndexSearchCard> {
  @override
  Widget build(BuildContext context) {
    bool isSub = false;

    return GestureDetector(
      onTap: () async {
        ref.read(audioProvider).currentPodcast = widget.podcastItem;

        if (context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EpisodesPage(podcast: widget.podcastItem),
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
                  imageUrl: widget.podcastItem.imageUrl,
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
                            widget.podcastItem.title,
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
                            widget.podcastItem.author ??
                                Translations.of(context).text('unknown'),
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
                    .isSubscribed(widget.podcastItem.title),
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
                        if (snapshot.data!) {
                          ref
                              .read(audioProvider)
                              .unsubscribe(widget.podcastItem);
                          setState(() {
                            isSub = false;
                          });
                        } else {
                          ref.read(audioProvider).subscribe(
                                widget.podcastItem,
                                context,
                              );
                          setState(() {
                            isSub = true;
                          });
                        }

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                snapshot.data!
                                    ? 'Unsubscribed from ${widget.podcastItem.title}'
                                    : 'Subscribed to ${widget.podcastItem.title}',
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
