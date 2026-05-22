import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/components/no_connection.dart';
import 'package:openair/components/no_subscriptions.dart';
import 'package:openair/config/config.dart';
import 'package:openair/model/hive_models/podcast_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/main_pages/episodes_page.dart';
import 'package:openair/views/widgets/episode_card_grid.dart';
import 'package:openair/views/widgets/toggle_banner.dart';
import 'package:openair/views/widgets/unified_episode_card.dart';

final getSubscribedEpisodesProvider =
    FutureProvider.autoDispose<List<Map<dynamic, dynamic>>>((ref) async {
  final episodes = await ref.read(openAirProvider).getSubscribedEpisodes();
  return episodes;
});

class FeedsPage extends ConsumerStatefulWidget {
  const FeedsPage({super.key});

  @override
  ConsumerState<FeedsPage> createState() => _FeedsPageState();
}

class _FeedsPageState extends ConsumerState<FeedsPage> {
  @override
  Widget build(BuildContext context) {
    final getConnectionStatusValue = ref.watch(getConnectionStatusProvider);

    return getConnectionStatusValue.when(
      data: (data) {
        if (data == false) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                Translations.of(context).text('feeds'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            body: const Center(child: NoConnection()),
            bottomNavigationBar: ToggleBanner(),
          );
        }

        final episodesAsync = ref.watch(getSubscribedEpisodesProvider);

        return episodesAsync.when(
          data: (List<Map<dynamic, dynamic>> episodesDataSet) {
            if (episodesDataSet.isEmpty) {
              return const NoSubscriptions(title: 'feeds');
            }

            return Scaffold(
              appBar: AppBar(
                title: Text(Translations.of(context).text('feeds')),
                actions: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: IconButton(
                      onPressed: () {
                        ref.invalidate(getSubscribedEpisodesProvider);
                      },
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ),
                ],
              ),
              body: _buildFeedsList(context, episodesDataSet),
              bottomNavigationBar: ToggleBanner(),
            );
          },
          loading: () => Scaffold(
            appBar: AppBar(title: Text(Translations.of(context).text('feeds'))),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => Scaffold(
            appBar: AppBar(title: Text(Translations.of(context).text('feeds'))),
            body: _ErrorView(
              error: error.toString(),
              onRetry: () {
                ref.invalidate(getSubscribedEpisodesProvider);
              },
            ),
            bottomNavigationBar: ToggleBanner(),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: Text(Translations.of(context).text('feeds'))),
        body: _ErrorView(
          error: error.toString(),
          onRetry: () {
            ref.invalidate(getSubscribedEpisodesProvider);
          },
        ),
        bottomNavigationBar: ToggleBanner(),
      ),
    );
  }

  Widget _buildFeedsList(
      BuildContext context, List<Map<dynamic, dynamic>> episodesDataSet) {
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
        scrollCacheExtent: ScrollCacheExtent.pixels(cacheExtent),
        itemCount: episodesDataSet.length,
        itemBuilder: (context, index) {
          final episodeItem = episodesDataSet[index];
          final podcastMap =
              (episodeItem['podcast'] as Map?)?.cast<String, dynamic>();
          final podcast = podcastMap != null
              ? PodcastModel.fromJson(podcastMap)
              : PodcastModel(
                  id: -1,
                  feedUrl: episodeItem['feedUrl'] ?? '',
                  title: episodeItem['podcastTitle'] ??
                      episodeItem['feedTitle'] ??
                      'Unknown',
                  author: episodeItem['author'] ??
                      episodeItem['feedAuthor'] ??
                      'Unknown Author',
                  imageUrl:
                      episodeItem['image'] ?? episodeItem['feedImage'] ?? '',
                  artwork:
                      episodeItem['image'] ?? episodeItem['feedImage'] ?? '',
                  description: '',
                );

          return EpisodeCardGrid(
            episodeItem: episodeItem.cast<String, dynamic>(),
            title: episodeItem['title'] ?? '',
            author: podcast.author ?? Translations.of(context).text('unknown'),
            imageUrl: podcast.imageUrl,
            podcast: podcast,
          );
        },
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      scrollCacheExtent: ScrollCacheExtent.pixels(cacheExtent),
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemCount: episodesDataSet.length,
      itemBuilder: (context, index) {
        final episodeItem = episodesDataSet[index];
        final podcastMap =
            (episodeItem['podcast'] as Map?)?.cast<String, dynamic>();
        final podcast = podcastMap != null
            ? PodcastModel.fromJson(podcastMap)
            : PodcastModel(
                id: -1,
                feedUrl: episodeItem['feedUrl'] ?? '',
                title: episodeItem['podcastTitle'] ??
                    episodeItem['feedTitle'] ??
                    'Unknown',
                author: episodeItem['author'] ??
                    episodeItem['feedAuthor'] ??
                    'Unknown Author',
                imageUrl:
                    episodeItem['image'] ?? episodeItem['feedImage'] ?? '',
                artwork: episodeItem['image'] ?? episodeItem['feedImage'] ?? '',
                description: '',
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
            episodeItem: episodeItem.cast<String, dynamic>(),
            podcast: podcast,
            title: episodeItem['title'] ?? '',
            author: podcast.author ?? Translations.of(context).text('unknown'),
            showAuthor: true,
          ),
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(height: 8),
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
            onPressed: onRetry,
            child: Text(Translations.of(context).text('retry')),
          ),
        ],
      ),
    );
  }
}
