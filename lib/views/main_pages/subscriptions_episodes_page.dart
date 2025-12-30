import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/hive_models/podcast_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/services/podcast_index_service.dart';
import 'package:openair/views/player/banner_audio_player.dart';
import 'package:openair/views/settings_pages/notifications_page.dart';
import 'package:openair/views/widgets/subscription_episode_card_list.dart';
import 'package:openair/views/widgets/subscription_episode_card_grid.dart';
import 'package:openair/views/native/podcast_info.dart';

// Ensure providers are defined as top-level variables
final podcastDataByUrlProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, podcastUrl) async {
  final podcastIndexService = ref.watch(podcastIndexProvider);
  return await podcastIndexService.getEpisodesByFeedUrl(podcastUrl);
});

class SubscriptionsEpisodesPage extends ConsumerStatefulWidget {
  const SubscriptionsEpisodesPage({
    super.key, 
    required this.podcast, 
    required this.id
  });
  
  final PodcastModel podcast;
  final int id;

  @override
  ConsumerState<SubscriptionsEpisodesPage> createState() => _SubscriptionsEpisodesPageState();
}

class _SubscriptionsEpisodesPageState extends ConsumerState<SubscriptionsEpisodesPage> {
  bool once = false;

  Future<bool> getSub() async {
    return await ref.watch(openAirProvider).isSubscribed(widget.podcast.title);
  }

  @override
  Widget build(BuildContext context) {
    final String podcastUrl = widget.podcast.feedUrl;
    final podcastDataAsyncValue = ref.watch(podcastDataByUrlProvider(podcastUrl));
    final podcastDataInfoAsyncValue = ref.watch(getPodcastInfoByTitleProvider(widget.podcast.title));

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
              const Icon(Icons.error_outline_rounded, size: 75.0, color: Colors.grey),
              const SizedBox(height: 20.0),
              Text(
                Translations.of(context).text('oopsTryAgainLater'),
                style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              Text('$error', style: const TextStyle(fontSize: 16.0)),
              const SizedBox(height: 20.0),
              SizedBox(
                width: 180.0,
                height: 40.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  onPressed: () async => ref.invalidate(podcastIndexProvider),
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
            return Scaffold(
              appBar: AppBar(
                title: Text(ref.watch(audioProvider).currentPodcast?.title ?? "Episodes"),
                actions: [
                  IconButton(
                    tooltip: Translations.of(context).text('podcastDetails'),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PodcastInfoPage(podcastInfo: data)),
                      );
                    },
                    icon: const Icon(Icons.info_outline_rounded, size: 30.0),
                  ),
                  FutureBuilder<bool>(
                    future: ref.watch(openAirProvider).isSubscribed(widget.podcast.title),
                    builder: (context, subSnapshot) {
                      if (!subSnapshot.hasData && !once) {
                        once = true;
                        return const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: Center(child: Text('...')),
                        );
                      }

                      final isSubscribed = subSnapshot.data ?? false;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: IconButton(
                          tooltip: isSubscribed ? 'Unsubscribe to podcast' : 'Subscribe to podcast',
                          onPressed: () async {
                            if (isSubscribed) {
                              ref.read(audioProvider).unsubscribe(widget.podcast);
                            } else {
                              ref.read(audioProvider).subscribe(widget.podcast, context);
                            }

                            final msg = isSubscribed
                                ? 'Unsubscribed from ${widget.podcast.title}'
                                : 'Subscribed to ${widget.podcast.title}';

                            if (!Platform.isAndroid && !Platform.isIOS) {
                              ref.read(notificationServiceProvider).showNotification(
                                'OpenAir ${Translations.of(context).text('notification')}',
                                msg,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                            }

                            ref.invalidate(podcastDataByUrlProvider(podcastUrl));
                          },
                          icon: Icon(isSubscribed ? Icons.check : Icons.add),
                        ),
                      );
                    },
                  ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: RefreshIndicator(
                  onRefresh: () async => ref.invalidate(podcastDataByUrlProvider(podcastUrl)),
                  child: wideScreenMinWidth < MediaQuery.sizeOf(context).width
                      ? LayoutBuilder(
                          builder: (context, constraints) {
                            const double targetCardWidth = 250.0;
                            int dynamicCrossAxisCount = (constraints.maxWidth / targetCardWidth).floor();
                            if (dynamicCrossAxisCount < 1) dynamicCrossAxisCount = 1;

                            return GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: dynamicCrossAxisCount,
                                childAspectRatio: 1.2,
                                mainAxisExtent: 294,
                                crossAxisSpacing: 4,
                                mainAxisSpacing: 4,
                              ),
                              cacheExtent: cacheExtent,
                              itemCount: snapshot['count'],
                              itemBuilder: (context, index) => SubscriptionEpisodeCardGrid(
                                title: snapshot['items'][index]['title'],
                                episodeItem: snapshot['items'][index],
                                podcast: widget.podcast,
                              ),
                            );
                          },
                        )
                      : ListView.builder(
                          itemCount: snapshot['count'],
                          itemBuilder: (context, index) {
                            return SubscriptionEpisodeCardList(
                              title: snapshot['items'][index]['title'],
                              episodeItem: snapshot['items'][index],
                              podcast: widget.podcast,
                            );
                          },
                        ),
                ),
              ),
              bottomNavigationBar: SizedBox(
                height: ref.watch(audioProvider).isPodcastSelected ? bannerAudioPlayerHeight : 0.0,
                child: ref.watch(audioProvider).isPodcastSelected ? const BannerAudioPlayer() : const SizedBox(),
              ),
            );
          },
          error: (error, stackTrace) => Scaffold(
            body: Center(child: Text('Error loading podcast info: $error', style: const TextStyle(fontSize: 16.0))),
          ),
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        );
      },
    );
  }
}
