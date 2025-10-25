import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/hive_models/podcast_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/services/fyyd_provider.dart';
import 'package:openair/views/main_pages/episodes_page.dart';
import 'package:openair/views/settings_pages/notifications_page.dart';
import 'package:webfeed_plus/domain/rss_feed.dart';

class FyydSearchCardGrid extends ConsumerStatefulWidget {
  final Map<String, dynamic> podcastItem;

  const FyydSearchCardGrid({
    super.key,
    required this.podcastItem,
  });

  @override
  ConsumerState<FyydSearchCardGrid> createState() => _FyydSearchCardGridState();
}

class _FyydSearchCardGridState extends ConsumerState<FyydSearchCardGrid> {
  late PodcastModel podcastMod;

  @override
  Widget build(BuildContext context) {
    podcastMod = PodcastModel.fromJson(widget.podcastItem);

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
          author: rssFeed.author ?? 'unknown',
          imageUrl: widget.podcastItem['imgURL'],
          artwork: widget.podcastItem['imgURL'],
          description: rssFeed.description!,
        );

        ref.read(audioProvider).currentPodcast = podcastModel;

        if (context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EpisodesPage(podcast: podcastModel),
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
                imageUrl: podcastMod.imageUrl,
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
                    podcastMod.title,
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
                    podcastMod.author ??
                        Translations.of(context).text('unknown'),
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
              future: ref.watch(openAirProvider).isSubscribed(podcastMod.title),
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
                        ? ref.read(audioProvider).unsubscribe(podcastMod)
                        : ref.read(audioProvider).subscribe(
                              podcastMod,
                              context,
                            );

                    if (context.mounted) {
                      if (!Platform.isAndroid && !Platform.isIOS) {
                        ref.read(notificationServiceProvider).showNotification(
                              'OpenAir ${Translations.of(context).text('notification')}',
                              snapshot.data!
                                  ? '${Translations.of(context).text('unsubscribedFrom')} ${podcastMod.title}'
                                  : '${Translations.of(context).text('subscribedTo')} ${podcastMod.title}',
                            );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              snapshot.data!
                                  ? '${Translations.of(context).text('unsubscribedFrom')} ${podcastMod.title}'
                                  : '${Translations.of(context).text('subscribedTo')} ${podcastMod.title}',
                            ),
                          ),
                        );
                      }
                    }

                    ref.invalidate(
                        podcastDataByUrlProvider(podcastMod.feedUrl));

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
