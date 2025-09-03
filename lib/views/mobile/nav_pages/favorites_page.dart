import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/components/empty_favorites.dart';
import 'package:openair/config/config.dart';
import 'package:openair/hive_models/podcast_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/providers/openair_provider.dart';

import 'package:openair/views/mobile/player/banner_audio_player.dart';
import 'package:openair/views/mobile/widgets/feeds_episode_card%20.dart';

final isFavoriteProvider = StreamProvider.autoDispose((ref) async* {
  final hiveService = await ref.watch(hiveServiceProvider.future);
  yield* hiveService.getFavoriteEpisodes().asStream();
});

final getInboxProvider = FutureProvider.autoDispose((ref) async {
  final Map? inboxEpisodes =
      await ref.watch(openAirProvider).getInboxEpisodes();

  if (inboxEpisodes != null) {
    return inboxEpisodes;
  }

  return await ref.read(openAirProvider).fetchInboxEpisodes();
});

class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    final AsyncValue<Map> getEpisodesValue = ref.watch(getInboxProvider);

    return getEpisodesValue.when(
      data: (Map data) {
        if (data.isEmpty) {
          return EmptyFavorites();
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(Translations.of(context).text('favorites')),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: Translations.of(context).text('refresh'),
                  onPressed: () async {
                    ref.invalidate(getInboxProvider);
                  },
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(getInboxProvider),
              child: ListView.builder(
                cacheExtent: cacheExtent,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  PodcastModel podcastModel = PodcastModel(
                    id: int.parse(data[index]['podcastId']),
                    title: data[index]['title'],
                    author: data[index]['author'],
                    feedUrl: data[index]['feedUrl'],
                    imageUrl: data[index]['image'],
                    description: data[index]['description'],
                    artwork: data[index]['image'],
                  );

                  return FeedsEpisodeCard(
                    title: data[index]['title'],
                    episodeItem: data[index].cast<String, dynamic>(),
                    podcast: podcastModel,
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
                  'Oops, an error occurred...',
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
                      ref.invalidate(getInboxProvider);
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
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
