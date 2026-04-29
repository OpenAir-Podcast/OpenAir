import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/model/hive_models/podcast_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/main_pages/episodes_page.dart';
import 'package:openair/views/settings_pages/notifications_page.dart';

class PodcastCardGrid extends ConsumerStatefulWidget {
  final PodcastModel podcastItem;

  const PodcastCardGrid({
    super.key,
    required this.podcastItem,
  });

  @override
  ConsumerState<PodcastCardGrid> createState() => _PodcastCardSGridtate();
}

class _PodcastCardSGridtate extends ConsumerState<PodcastCardGrid> {
  bool once = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ref.read(audioProvider).currentPodcast = widget.podcastItem;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EpisodesPage(podcast: widget.podcastItem),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
                child: CachedNetworkImage(
                  memCacheHeight: 300,
                  imageUrl: widget.podcastItem.imageUrl,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                    color: Theme.of(context).cardColor,
                    child: const Icon(
                      Icons.error,
                      size: 56.0,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 12.0, 8.0, 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.podcastItem.title,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          (widget.podcastItem.author?.isNotEmpty == true)
                              ? widget.podcastItem.author!
                              : Translations.of(context).text('unknown'),
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  FutureBuilder<bool>(
                    future: ref
                        .watch(openAirProvider)
                        .isSubscribed(widget.podcastItem.title),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox(width: 48, height: 48); // Placeholder size for icon button
                      } else if (snapshot.hasError) {
                        return const SizedBox(width: 48, height: 48);
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
          ],
        ),
      ),
    );
  }
}
