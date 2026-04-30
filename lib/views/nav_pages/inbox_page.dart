import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/components/empty_inbox.dart';
import 'package:openair/config/config.dart';
import 'package:openair/model/hive_models/feed_model.dart';
import 'package:openair/model/hive_models/podcast_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/views/main_pages/episodes_page.dart';
import 'package:openair/views/player/banner_audio_player.dart';
import 'package:openair/views/widgets/unified_episode_card.dart';

final getInboxProvider = FutureProvider.autoDispose((ref) async {
  final Map<String, FeedModel> inboxEpisodes =
      await ref.read(hiveServiceProvider).getFeed();
  return inboxEpisodes;
});

final episodeProvider = FutureProvider.family<Map?, String>((ref, guid) async {
  return await ref.read(hiveServiceProvider).getEpisode(guid);
});

class InboxPage extends ConsumerStatefulWidget {
  const InboxPage({super.key});

  @override
  ConsumerState<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends ConsumerState<InboxPage> {
  @override
  Widget build(BuildContext context) {
    final episodesValue = ref.watch(getInboxProvider);

    return episodesValue.when(
      data: (Map<String, FeedModel> data) {
        if (data.isEmpty) {
          return const EmptyInbox();
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
          body: ListView.separated(
            padding: const EdgeInsets.all(12),
            cacheExtent: cacheExtent,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemCount: feedItems.length,
            itemBuilder: (context, index) {
              final feedItem = feedItems[index];
              final episodeFuture = ref.watch(episodeProvider(feedItem.guid));

              return episodeFuture.when(
                data: (episodeData) {
                  if (episodeData == null) {
                    return const SizedBox.shrink();
                  }

                  final podcast = PodcastModel(
                    id: episodeData['id'] ?? -1,
                    title: episodeData['title'] ?? '',
                    author: episodeData['author'] ?? '',
                    feedUrl: episodeData['feedUrl'] ?? '',
                    imageUrl: episodeData['image'] ?? '',
                    description: episodeData['description'] ?? '',
                    artwork: episodeData['image'] ?? '',
                  );

                  return GestureDetector(
                    onTap: () {
                      ref.read(audioProvider.notifier).currentPodcast = podcast;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EpisodesPage(
                            podcast: podcast,
                          ),
                        ),
                      );
                    },
                    child: UnifiedEpisodeCard(
                      episodeItem: episodeData.cast<String, dynamic>(),
                      podcast: podcast,
                      title: episodeData['title'] ?? '',
                      author: episodeData['author'] ??
                          Translations.of(context).text('unknown'),
                      showAuthor: true,
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
          bottomNavigationBar: _buildBottomBar(),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: Text(Translations.of(context).text('inbox'))),
        body: _ErrorView(error: error.toString()),
      ),
    );
  }

  Widget? _buildBottomBar() {
    final isPodcastSelected = ref.watch(
      audioProvider.select((p) => p.isPodcastSelected),
    );

    if (!isPodcastSelected) return null;

    return SizedBox(
      height: bannerAudioPlayerHeight,
      child: const BannerAudioPlayer(),
    );
  }
}

class _ErrorView extends ConsumerWidget {
  final String error;

  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            Translations.of(context).text('oopsTryAgainLater'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.invalidate(getInboxProvider),
            child: Text(Translations.of(context).text('retry')),
          ),
        ],
      ),
    );
  }
}
