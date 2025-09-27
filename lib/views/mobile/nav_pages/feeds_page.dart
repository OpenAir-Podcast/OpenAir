import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/components/no_subscriptions.dart';
import 'package:openair/config/config.dart';
import 'package:openair/hive_models/podcast_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/openair_provider.dart';

import 'package:openair/views/mobile/player/banner_audio_player.dart';
import 'package:openair/views/mobile/widgets/feeds_episode_card.dart';

final getFeedsProvider = FutureProvider.autoDispose((ref) async {
  // Feeds data comes from subscribed episodes in Hive.
  // This provider will be manually invalidated when subscriptions (and their episodes) change.
  return await ref.read(openAirProvider).getSubscribedEpisodes();
});

class FeedsPage extends ConsumerStatefulWidget {
  const FeedsPage({super.key});

  @override
  ConsumerState<FeedsPage> createState() => _FeedsPageState();
}

class _FeedsPageState extends ConsumerState<FeedsPage> {
  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Map>> getEpisodesValue = ref.watch(getFeedsProvider);

    return getEpisodesValue.when(
      data: (List<Map> data) {
        if (data.isEmpty) {
          return NoSubscriptions(title: 'Feeds');
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(Translations.of(context).text('feeds')),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: Translations.of(context).text('refresh'),
                  onPressed: () async {
                    await ref
                        .read(openAirProvider)
                        .hiveService
                        .updateSubscriptions();

                    ref.invalidate(getFeedsProvider);
                  },
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(getFeedsProvider),
              child: ListView.builder(
                cacheExtent: cacheExtent,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final episodeData = data[index];

                  return FeedsEpisodeCard(
                    title: episodeData['title'],
                    episodeItem: episodeData.cast<String, dynamic>(),
                    podcast: PodcastModel(
                      id: episodeData['id'] ?? -1,
                      title: episodeData['title'],
                      description: episodeData['description'],
                      author: episodeData['author'] ??
                          Translations.of(context).text('unknown'),
                      feedUrl: episodeData['feedUrl'],
                      artwork: episodeData['image'],
                      imageUrl:
                          episodeData['feedImage'] ?? episodeData['image'],
                    ),
                  );
                },
              ),
            ),
          ),
          bottomNavigationBar: SizedBox(
            height: ref.watch(audioProvider.select((p) => p.isPodcastSelected))
                ? bannerAudioPlayerHeight
                : 0.0,
            child: ref.watch(audioProvider.select((p) => p.isPodcastSelected))
                ? const BannerAudioPlayer()
                : const SizedBox.shrink(),
          ),
        );
      },
      error: (error, stackTrace) {
        debugPrint('Error loading episodes: $error');
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
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
                      ref.invalidate(getFeedsProvider);
                    },
                    child: const Text('Retry'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Container(
        color: Brightness.dark == Theme.of(context).brightness
            ? Colors.black
            : Colors.white,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
