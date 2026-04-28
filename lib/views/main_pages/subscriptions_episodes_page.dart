import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/hive_models/podcast_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/providers/subscription_providers.dart';
import 'package:openair/views/player/banner_audio_player.dart';
import 'package:openair/views/settings_pages/notifications_page.dart';
import 'package:openair/views/widgets/subscription_episode_card_list.dart';
import 'package:openair/views/widgets/subscription_episode_card_grid.dart';
import 'package:openair/views/native/podcast_info.dart';

class SubscriptionsEpisodesPage extends ConsumerStatefulWidget {
  const SubscriptionsEpisodesPage({
    super.key,
    required this.podcast,
    required this.id,
  });

  final PodcastModel podcast;
  final int id;

  @override
  ConsumerState<SubscriptionsEpisodesPage> createState() =>
      _SubscriptionsEpisodesPageState();
}

class _SubscriptionsEpisodesPageState
    extends ConsumerState<SubscriptionsEpisodesPage> {
  @override
  Widget build(BuildContext context) {
    final podcastUrl = widget.podcast.feedUrl;
    final podcastDataAsyncValue =
        ref.watch(podcastDataByUrlProvider(podcastUrl));
    final podcastDataInfoAsyncValue =
        ref.watch(getPodcastInfoByTitleProvider(widget.podcast.title));
    final isSubscribedAsyncValue =
        ref.watch(isSubscribedProvider(widget.podcast.title));

    return podcastDataAsyncValue.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 75, color: Colors.grey),
              const SizedBox(height: 20),
              Text(
                Translations.of(context).text('oopsTryAgainLater'),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text('$error', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              SizedBox(
                width: 180,
                height: 40,
                child: ElevatedButton(
                  onPressed: () =>
                      ref.invalidate(podcastDataByUrlProvider(podcastUrl)),
                  child: const Text('Retry'),
                ),
              ),
            ],
          ),
        ),
      ),
      data: (snapshot) {
        return podcastDataInfoAsyncValue.when(
          data: (data) {
            return isSubscribedAsyncValue.when(
              data: (isSubscribed) {
                return Scaffold(
                  appBar: AppBar(
                    title: Text(widget.podcast.title),
                    actions: [
                      IconButton(
                        tooltip:
                            Translations.of(context).text('podcastDetails'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PodcastInfoPage(podcastInfo: data),
                            ),
                          );
                        },
                        icon: const Icon(Icons.info_outline_rounded, size: 30),
                      ),
                      IconButton(
                        tooltip: isSubscribed ? 'Unsubscribe' : 'Subscribe',
                        onPressed: () async {
                          if (isSubscribed) {
                            ref.read(audioProvider).unsubscribe(widget.podcast);
                          } else {
                            ref
                                .read(audioProvider)
                                .subscribe(widget.podcast, context);
                          }

                          final msg = isSubscribed
                              ? 'Unsubscribed from ${widget.podcast.title}'
                              : 'Subscribed to ${widget.podcast.title}';

                          if (!Platform.isAndroid && !Platform.isIOS) {
                            ref
                                .read(notificationServiceProvider)
                                .showNotification(
                                  'OpenAir ${Translations.of(context).text('notification')}',
                                  msg,
                                );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(msg)),
                            );
                          }

                          ref.invalidate(podcastDataByUrlProvider(podcastUrl));
                          ref.invalidate(
                              isSubscribedProvider(widget.podcast.title));
                        },
                        icon: Icon(isSubscribed ? Icons.check : Icons.add),
                      ),
                    ],
                  ),
                  body: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RefreshIndicator(
                      onRefresh: () async =>
                          ref.invalidate(podcastDataByUrlProvider(podcastUrl)),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide =
                              wideScreenMinWidth < constraints.maxWidth;

                          if (isWide) {
                            const targetCardWidth = 250.0;
                            final crossAxisCount =
                                (constraints.maxWidth / targetCardWidth)
                                    .floor()
                                    .clamp(1, 10);

                            return GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                childAspectRatio: 1.2,
                                mainAxisExtent: 294,
                                crossAxisSpacing: 4,
                                mainAxisSpacing: 4,
                              ),
                              cacheExtent: cacheExtent,
                              itemCount: snapshot['count'] ?? 0,
                              itemBuilder: (context, index) =>
                                  SubscriptionEpisodeCardGrid(
                                title: snapshot['items'][index]['title'],
                                episodeItem: snapshot['items'][index],
                                podcast: widget.podcast,
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: snapshot['count'] ?? 0,
                            itemBuilder: (context, index) {
                              return SubscriptionEpisodeCardList(
                                title: snapshot['items'][index]['title'],
                                episodeItem: snapshot['items'][index],
                                podcast: widget.podcast,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  bottomNavigationBar: SizedBox(
                    height: ref.watch(
                            audioProvider.select((p) => p.isPodcastSelected))
                        ? bannerAudioPlayerHeight
                        : 0.0,
                    child: ref.watch(
                            audioProvider.select((p) => p.isPodcastSelected))
                        ? const BannerAudioPlayer()
                        : const SizedBox(),
                  ),
                );
              },
              loading: () => const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const Scaffold(
                body: Center(child: Text('Error loading subscription status')),
              ),
            );
          },
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (_, __) => const Scaffold(body: Center(child: Text('Error'))),
        );
      },
    );
  }
}
