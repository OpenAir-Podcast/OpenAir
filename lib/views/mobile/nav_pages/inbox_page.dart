import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/components/empty_inbox.dart';
import 'package:openair/config/config.dart';
import 'package:openair/hive_models/feed_model.dart';
import 'package:openair/hive_models/podcast_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/hive_provider.dart';

import 'package:openair/views/mobile/player/banner_audio_player.dart';
import 'package:openair/views/mobile/widgets/feeds_episode_card.dart';

final getInboxProvider = FutureProvider.autoDispose((ref) async {
  final Map<String, FeedModel> inboxEpisodes =
      await ref.watch(hiveServiceProvider).getFeed();

  if (inboxEpisodes.isNotEmpty) {
    return inboxEpisodes;
  }

  await ref.read(hiveServiceProvider).updateSubscriptions();
  return await ref.watch(hiveServiceProvider).getFeed();
});

final episodeProvider =
    FutureProvider.autoDispose.family<Map?, String>((ref, guid) async {
  return await ref.watch(hiveServiceProvider).getEpisode(guid);
});

class InboxPage extends ConsumerStatefulWidget {
  const InboxPage({super.key});

  @override
  ConsumerState<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends ConsumerState<InboxPage> {
  @override
  Widget build(BuildContext context) {
    final AsyncValue<Map<String, FeedModel>> getEpisodesValue =
        ref.watch(getInboxProvider);

    return getEpisodesValue.when(
      data: (Map<String, FeedModel> data) {
        if (data.isEmpty) {
          return EmptyInbox();
        }

        final feedItems = data.values.toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(Translations.of(context).text('inbox')),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: Translations.of(context).text('refresh'),
                  onPressed: () async {
                    await ref.read(hiveServiceProvider).updateSubscriptions();
                    ref.invalidate(getInboxProvider);
                  },
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(hiveServiceProvider).updateSubscriptions();
                ref.invalidate(getInboxProvider);
              },
              child: ListView.builder(
                cacheExtent: cacheExtent,
                itemCount: feedItems.length,
                itemBuilder: (context, index) {
                  final feedItem = feedItems[index];
                  final episodeFuture =
                      ref.watch(episodeProvider(feedItem.guid));

                  return episodeFuture.when(
                    data: (episodeData) {
                      if (episodeData == null) {
                        return const SizedBox.shrink();
                      }
                      
                      PodcastModel podcastModel = PodcastModel(
                        id: episodeData['id'],
                        title: episodeData['title'],
                        author: episodeData['author'],
                        feedUrl: episodeData['feedUrl'],
                        imageUrl: episodeData['image'],
                        description: episodeData['description'],
                        artwork: episodeData['image'],
                      );

                      return FeedsEpisodeCard(
                        title: episodeData['title'],
                        episodeItem: episodeData.cast<String, dynamic>(),
                        podcast: podcastModel,
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) => const SizedBox.shrink(),
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
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
