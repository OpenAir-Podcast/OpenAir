import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/components/empty_inbox.dart';
import 'package:openair/components/no_connection.dart';
import 'package:openair/config/config.dart';
import 'package:openair/model/hive_models/feed_model.dart';
import 'package:openair/model/hive_models/podcast_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/main_pages/episodes_page.dart';
import 'package:openair/views/player/banner_audio_player.dart';
import 'package:openair/views/widgets/episode_card_grid.dart';
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
    final getConnectionStatusValue = ref.watch(getConnectionStatusProvider);

    return getConnectionStatusValue.when(
      data: (data) {
        if (data == false) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                Translations.of(context).text('inbox'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            body: const Center(child: NoConnection()),
          );
        }

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
                        await ref
                            .read(hiveServiceProvider)
                            .updateSubscriptions();
                        ref.invalidate(getInboxProvider);
                      },
                    ),
                  ),
                ],
              ),
              body: _buildInboxList(context, feedItems),
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

  Widget _buildInboxList(BuildContext context, List<FeedModel> feedItems) {
    final isWide = !Platform.isAndroid && !Platform.isIOS ||
        wideScreenMinWidth < MediaQuery.sizeOf(context).width;

    if (isWide) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300.0,
          mainAxisExtent: 312.0,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        cacheExtent: cacheExtent,
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
                id: int.tryParse(episodeData['podcast']?['id']?.toString() ??
                        episodeData['podcastId']?.toString() ??
                        '') ??
                    -1,
                title: episodeData['podcast']?['title'] ??
                    episodeData['podcastTitle'] ??
                    episodeData['title'] ??
                    '',
                author: episodeData['podcast']?['author'] ??
                    episodeData['author'] ??
                    episodeData['feedAuthor'] ??
                    '',
                feedUrl: episodeData['podcast']?['url'] ??
                    episodeData['feedUrl'] ??
                    '',
                imageUrl: episodeData['podcast']?['image'] ??
                    episodeData['image'] ??
                    episodeData['feedImage'] ??
                    '',
                description: episodeData['podcast']?['description'] ??
                    episodeData['description'] ??
                    '',
                artwork: episodeData['podcast']?['artwork'] ??
                    episodeData['image'] ??
                    episodeData['feedImage'] ??
                    '',
              );

              return EpisodeCardGrid(
                episodeItem: episodeData.cast<String, dynamic>(),
                title: episodeData['title'] ?? '',
                author: episodeData['podcast']?['author'] ??
                    episodeData['author'] ??
                    episodeData['feedAuthor'] ??
                    Translations.of(context).text('unknown'),
                imageUrl: episodeData['podcast']?['image'] ??
                    episodeData['image'] ??
                    episodeData['feedImage'] ??
                    '',
                podcast: podcast,
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
          );
        },
      );
    }

    return ListView.separated(
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
              id: int.tryParse(episodeData['podcast']?['id']?.toString() ??
                      episodeData['podcastId']?.toString() ??
                      '') ??
                  -1,
              title: episodeData['podcast']?['title'] ??
                  episodeData['podcastTitle'] ??
                  episodeData['title'] ??
                  '',
              author: episodeData['podcast']?['author'] ??
                  episodeData['author'] ??
                  episodeData['feedAuthor'] ??
                  '',
              feedUrl: episodeData['podcast']?['url'] ??
                  episodeData['feedUrl'] ??
                  '',
              imageUrl: episodeData['podcast']?['image'] ??
                  episodeData['image'] ??
                  episodeData['feedImage'] ??
                  '',
              description: episodeData['podcast']?['description'] ??
                  episodeData['description'] ??
                  '',
              artwork: episodeData['podcast']?['artwork'] ??
                  episodeData['image'] ??
                  episodeData['feedImage'] ??
                  '',
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
                author: episodeData['podcast']?['author'] ??
                    episodeData['author'] ??
                    episodeData['feedAuthor'] ??
                    Translations.of(context).text('unknown'),
                showAuthor: true,
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
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
