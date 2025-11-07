import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/components/no_subscriptions.dart';
import 'package:openair/config/config.dart';
import 'package:openair/hive_models/podcast_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/openair_provider.dart';

import 'package:openair/views/player/banner_audio_player.dart';
import 'package:openair/views/widgets/feeds_episode_card_list.dart';
import 'package:openair/views/widgets/feeds_episode_card_grid.dart';
import 'package:openair/views/navigation/list_drawer.dart';

final getSubscribedEpisodesProvider = FutureProvider.autoDispose((ref) async {
  return await ref.read(openAirProvider).getSubscribedEpisodes();
});

class FeedsPage extends ConsumerStatefulWidget {
  const FeedsPage({super.key});

  @override
  ConsumerState<FeedsPage> createState() => _FeedsPageState();
}

class _FeedsPageState extends ConsumerState<FeedsPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.invalidate(getSubscribedEpisodesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Map>> getEpisodesValue =
        ref.watch(getSubscribedEpisodesProvider);

    return getEpisodesValue.when(
      data: (List<Map> episodesDataSet) {
        if (episodesDataSet.isEmpty) {
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

                    ref.invalidate(inboxCountProvider);
                  },
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: RefreshIndicator(
              onRefresh: () async =>
                  ref.invalidate(getSubscribedEpisodesProvider),
              child: MediaQuery.sizeOf(context).width > 1060
                  ? GridView.builder(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 300.0,
                        mainAxisExtent: 312.0,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                      ),
                      cacheExtent: cacheExtent,
                      itemCount: episodesDataSet.length,
                      itemBuilder: (context, index) {
                        return FeedsEpisodeCardGrid(
                          title: episodesDataSet[index]['title'],
                          episodeItem:
                              episodesDataSet[index].cast<String, dynamic>(),
                          author: episodesDataSet[index]['author'] ??
                              Translations.of(context).text('unknown'),
                          podcast: PodcastModel(
                            id: episodesDataSet[index]['id'] ?? -1,
                            title: episodesDataSet[index]['title'],
                            description: episodesDataSet[index]['description'],
                            author: episodesDataSet[index]['author'],
                            feedUrl: episodesDataSet[index]['feedUrl'],
                            artwork: episodesDataSet[index]['image'],
                            imageUrl: episodesDataSet[index]['feedImage'] ??
                                episodesDataSet[index]['image'],
                          ),
                        );
                      },
                    )
                  : ListView.builder(
                      cacheExtent: cacheExtent,
                      itemCount: episodesDataSet.length,
                      itemBuilder: (context, index) {
                        return FeedsEpisodeCardList(
                          title: episodesDataSet[index]['title'],
                          episodeItem:
                              episodesDataSet[index].cast<String, dynamic>(),
                          podcast: PodcastModel(
                            id: episodesDataSet[index]['id'] ?? -1,
                            title: episodesDataSet[index]['title'],
                            description: episodesDataSet[index]['description'],
                            author: episodesDataSet[index]['author'],
                            feedUrl: episodesDataSet[index]['feedUrl'],
                            artwork: episodesDataSet[index]['image'],
                            imageUrl: episodesDataSet[index]['feedImage'] ??
                                episodesDataSet[index]['image'],
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
                      ref.invalidate(getSubscribedEpisodesProvider);
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
