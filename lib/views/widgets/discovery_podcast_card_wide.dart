import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/hive_models/podcast_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/main_pages/episodes_page.dart';
import 'package:openair/views/settings_pages/notifications_page.dart';

class DiscoveryPodcastCardWide extends ConsumerStatefulWidget {
  final Map<String, dynamic> podcastItem;

  const DiscoveryPodcastCardWide({
    super.key,
    required this.podcastItem,
  });

  @override
  ConsumerState<DiscoveryPodcastCardWide> createState() =>
      _DiscoveryPodcastCardWideState();
}

class _DiscoveryPodcastCardWideState
    extends ConsumerState<DiscoveryPodcastCardWide> {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: CachedNetworkImage(
                memCacheHeight: 300,
                imageUrl: podcast.imageUrl,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  color: cardImageShadow,
                  child: const Icon(
                    Icons.error,
                    size: 56.0,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    podcast.title,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Brightness.dark == Theme.of(context).brightness
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),
                  Text(
                    podcast.author ?? Translations.of(context).text('unknown'),
                    maxLines: 1,
                    style: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            FutureBuilder(
              future: ref.watch(openAirProvider).isSubscribed(podcast.title),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                } else if (snapshot.hasError) {
                  return const SizedBox.shrink();
                }

                return IconButton(
                  tooltip: snapshot.data!
                      ? Translations.of(context).text('unsubscribeToPodcast')
                      : Translations.of(context).text('subscribeToPodcast'),
                  onPressed: () async {
                    snapshot.data!
                        ? ref.read(audioProvider).unsubscribe(podcast)
                        : ref.read(audioProvider).subscribe(
                              podcast,
                              context,
                            );

                    if (context.mounted) {
                      if (!Platform.isAndroid && !Platform.isIOS) {
                        ref.read(notificationServiceProvider).showNotification(
                              'OpenAir ${Translations.of(context).text('notification')}',
                              snapshot.data!
                                  ? '${Translations.of(context).text('unsubscribedFrom')} ${podcast.title}'
                                  : '${Translations.of(context).text('subscribedTo')} ${podcast.title}',
                            );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              snapshot.data!
                                  ? '${Translations.of(context).text('unsubscribedFrom')} ${podcast.title}'
                                  : '${Translations.of(context).text('subscribedTo')} ${podcast.title}',
                            ),
                          ),
                        );
                      }
                    }

                    ref.invalidate(podcastDataByUrlProvider(podcast.feedUrl));

                    Future.delayed(
                      Duration(seconds: 1),
                      () {
                        if (mounted) {
                          setState(() {});
                        }
                      },
                    );
                  },
                  icon: snapshot.data!
                      ? const Icon(Icons.check)
                      : const Icon(Icons.add),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
