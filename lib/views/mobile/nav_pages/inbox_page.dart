import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/components/no_subscriptions.dart';
import 'package:openair/config/config.dart';
import 'package:openair/hive_models/podcast_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/openair_provider.dart';

import 'package:openair/views/mobile/player/banner_audio_player.dart';
import 'package:openair/views/mobile/widgets/feeds_episode_card%20.dart';

final getInboxProvider = FutureProvider.autoDispose((ref) async {
  // Feeds data comes from subscribed episodes in Hive.
  // This provider will be manually invalidated when subscriptions (and their episodes) change.
  return await ref.read(openAirProvider).getSubscribedEpisodes();
});

class InboxPage extends ConsumerStatefulWidget {
  const InboxPage({super.key});

  @override
  ConsumerState<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends ConsumerState<InboxPage> {
  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Map>> getEpisodesValue = ref.watch(getInboxProvider);

    return getEpisodesValue.when(
      data: (List<Map> data) {
        if (data.isEmpty) {
          return NoSubscriptions(title: 'inbox');
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(Translations.of(context).text('inbox')),
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
            height: ref.watch(auidoProvider.select((p) => p.isPodcastSelected))
                ? 80.0
                : 0.0,
            child: ref.watch(auidoProvider.select((p) => p.isPodcastSelected))
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
