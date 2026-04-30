import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/model/hive_models/podcast_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/providers/subscription_providers.dart';
import 'package:openair/views/main_pages/episodes_page.dart';
import 'package:openair/views/settings_pages/notifications_page.dart';

class PodcastCardList extends ConsumerStatefulWidget {
  final PodcastModel podcastItem;

  const PodcastCardList({
    super.key,
    required this.podcastItem,
  });

  @override
  ConsumerState<PodcastCardList> createState() => _PodcastCardListState();
}

class _PodcastCardListState extends ConsumerState<PodcastCardList> {
  bool once = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ref.read(audioProvider).currentPodcast = widget.podcastItem;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EpisodesPage(podcast: widget.podcastItem),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: CachedNetworkImage(
                memCacheHeight: 72,
                memCacheWidth: 72,
                height: 72.0,
                width: 72.0,
                imageUrl: widget.podcastItem.imageUrl,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  height: 72.0,
                  width: 72.0,
                  color: Theme.of(context).cardColor,
                  child: const Icon(Icons.error, size: 36.0),
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.podcastItem.title,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    (widget.podcastItem.author?.isNotEmpty == true)
                        ? widget.podcastItem.author!
                        : Translations.of(context).text('unknown'),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            FutureBuilder<bool>(
              future: ref
                  .watch(openAirProvider)
                  .isSubscribed(widget.podcastItem.title),
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
                        ? ref
                            .read(audioProvider)
                            .unsubscribe(widget.podcastItem)
                        : ref.read(audioProvider).subscribe(
                              widget.podcastItem,
                              context,
                            );

                    if (context.mounted) {
                      if (!Platform.isAndroid && !Platform.isIOS) {
                        ref.read(notificationServiceProvider).showNotification(
                              'OpenAir ${Translations.of(context).text('notification')}',
                              snapshot.data!
                                  ? '${Translations.of(context).text('unsubscribedFrom')} ${widget.podcastItem.title}'
                                  : '${Translations.of(context).text('subscribedTo')} ${widget.podcastItem.title}',
                            );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              snapshot.data!
                                  ? '${Translations.of(context).text('unsubscribedFrom')} ${widget.podcastItem.title}'
                                  : '${Translations.of(context).text('subscribedTo')} ${widget.podcastItem.title}',
                            ),
                          ),
                        );
                      }
                    }

                    ref.invalidate(
                        podcastDataByUrlProvider(widget.podcastItem.feedUrl));
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
