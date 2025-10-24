import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/hive_models/podcast_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/services/podcast_index_service.dart';

import 'package:openair/views/player/banner_audio_player.dart';
import 'package:openair/views/settings_pages/notifications_page.dart';
import 'package:openair/views/widgets/subscription_episode_card_narrow.dart';
import 'package:openair/views/widgets/subscription_episode_card_wide.dart';
import 'package:openair/views/native/podcast_info.dart';

final podcastDataByUrlProvider =
    FutureProvider.family<Map<String, dynamic>, String>(
        (ref, podcastUrl) async {
  final podcastIndexService = ref.watch(podcastIndexProvider);
  return await podcastIndexService.getEpisodesByFeedUrl(podcastUrl);
});

class SubscriptionsEpisodesPage extends ConsumerStatefulWidget {
  const SubscriptionsEpisodesPage(
      {super.key, required this.podcast, required this.id});
  final PodcastModel podcast;
  final int id;

  @override
  ConsumerState<SubscriptionsEpisodesPage> createState() =>
      _SubscriptionsEpisodesPageState();
}

class _SubscriptionsEpisodesPageState
    extends ConsumerState<SubscriptionsEpisodesPage> {
  Future<bool> getSub() async {
    return await ref.watch(openAirProvider).isSubscribed(widget.podcast.title);
  }

  @override
  Widget build(BuildContext context) {
    final String podcastUrl = widget.podcast.feedUrl;

    final podcastDataAsyncValue =
        ref.watch(podcastDataByUrlProvider(podcastUrl));

    bool once = false;

    return podcastDataAsyncValue.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        body: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 75.0,
                color: Colors.grey,
              ),
              const SizedBox(height: 20.0),
              Text(
                Translations.of(context).text('oopsTryAgainLater'),
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$error',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 20.0),
              SizedBox(
                width: 180.0,
                height: 40.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onPressed: () async {
                    ref.invalidate(podcastIndexProvider);
                  },
                  child: const Text('Retry'),
                ),
              ),
            ],
          ),
        ),
      ),
      data: (snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Text(ref.watch(audioProvider).currentPodcast!.title),
            actions: [
              IconButton(
                tooltip: Translations.of(context).text('podcastDetails'),
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PodcastInfoPage(
                          podcast: widget.podcast,
                        ),
                      ));
                },
                icon: Icon(
                  Icons.info_outline_rounded,
                  size: 30.0,
                ),
              ),
              FutureBuilder(
                future: ref
                    .watch(openAirProvider)
                    .isSubscribed(widget.podcast.title),
                builder: (context, snapshot) {
                  if (snapshot.hasData == false && !once) {
                    once = true;

                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text('...'),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: IconButton(
                      tooltip: snapshot.hasData
                          ? snapshot.data!
                              ? 'Unsubscribe to podcast'
                              : 'Subscribe to podcast'
                          : '...',
                      onPressed: () async {
                        snapshot.data! && snapshot.hasData
                            ? ref
                                .read(audioProvider)
                                .unsubscribe(widget.podcast)
                            : ref.read(audioProvider).subscribe(
                                  widget.podcast,
                                  context,
                                );

                        if (!Platform.isAndroid && !Platform.isIOS) {
                          ref
                              .read(notificationServiceProvider)
                              .showNotification(
                                'OpenAir ${Translations.of(context).text('notification')}',
                                snapshot.data!
                                    ? 'Unsubscribed from ${widget.podcast.title}'
                                    : 'Subscribed to ${widget.podcast.title}',
                              );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                snapshot.data!
                                    ? 'Unsubscribed from ${widget.podcast.title}'
                                    : 'Subscribed to ${widget.podcast.title}',
                              ),
                            ),
                          );
                        }

                        ref.invalidate(podcastDataByUrlProvider(podcastUrl));
                      },
                      icon: snapshot.hasData
                          ? snapshot.data!
                              ? const Icon(Icons.check)
                              : const Icon(Icons.add)
                          : const Icon(Icons.add),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: RefreshIndicator(
              onRefresh: () async =>
                  ref.invalidate(podcastDataByUrlProvider(podcastUrl)),
              child: wideScreenMinWidth < MediaQuery.sizeOf(context).width
                  ? GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: wideCrossAxisCount,
                        childAspectRatio: 1.2,
                        mainAxisExtent: 294,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                      ),
                      cacheExtent: cacheExtent,
                      itemCount: snapshot['count'],
                      itemBuilder: (context, index) =>
                          SubscriptionEpisodeCardWide(
                        title: snapshot['items'][index]['title'],
                        episodeItem: snapshot['items'][index],
                        podcast: widget.podcast,
                      ),
                    )
                  : ListView.builder(
                      itemCount: snapshot['count'],
                      itemBuilder: (context, index) {
                        return SubscriptionEpisodeCardNarrow(
                          title: snapshot['items'][index]['title'],
                          episodeItem: snapshot['items'][index],
                          podcast: widget.podcast,
                        );
                      },
                    ),
            ),
          ),
          bottomNavigationBar: SizedBox(
            height: ref.watch(audioProvider).isPodcastSelected
                ? bannerAudioPlayerHeight
                : 0.0,
            child: ref.watch(audioProvider).isPodcastSelected
                ? const BannerAudioPlayer()
                : const SizedBox(),
          ),
        );
      },
    );
  }
}
