import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/hive_models/podcast_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/services/podcast_index_service.dart';
import 'package:openair/views/native/podcast_info.dart';
import 'package:openair/views/player/banner_audio_player.dart';
import 'package:openair/views/widgets/episode_card_grid.dart';
import 'package:openair/views/widgets/episode_card_list.dart';

final podcastDataByUrlProvider =
    FutureProvider.family<Map<String, dynamic>, String>(
        (ref, podcastUrl) async {
  final podcastIndexService = ref.watch(podcastIndexProvider);
  return await podcastIndexService.getEpisodesByFeedUrl(podcastUrl);
});

class EpisodesPage extends ConsumerWidget {
  const EpisodesPage({super.key, required this.podcast});

  final PodcastModel podcast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final podcastUrl = ref.watch(audioProvider).currentPodcast!.feedUrl;
    final podcastDataAsync = ref.watch(podcastDataByUrlProvider(podcastUrl));
    final podcastInfoAsync =
        ref.watch(getPodcastInfoByTitleProvider(podcast.title));

    return podcastDataAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: Text(podcast.title)),
        body: _ErrorView(
          error: error.toString(),
          onRetry: () => ref.invalidate(podcastDataByUrlProvider(podcastUrl)),
        ),
      ),
      data: (episodesData) => podcastInfoAsync.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => _buildEpisodesPage(context, ref, episodesData, null),
        data: (podcastInfo) =>
            _buildEpisodesPage(context, ref, episodesData, podcastInfo),
      ),
    );
  }

  Widget _buildEpisodesPage(
    BuildContext context,
    WidgetRef ref,
    Map episodesData,
    Map? podcastInfo,
  ) {
    final imageUrl = podcast.imageUrl.isNotEmpty
        ? podcast.imageUrl
        : podcastInfo?['image'] ?? '';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                podcast.title,
                style: const TextStyle(
                  fontSize: 16,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        color: Theme.of(context).primaryColor,
                        child: const Icon(Icons.podcasts, size: 64),
                      ),
                    )
                  else
                    Container(
                      color: Theme.of(context).primaryColor,
                      child: const Icon(Icons.podcasts, size: 64),
                    ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                tooltip: Translations.of(context).text('podcastDetails'),
                onPressed: () {
                  if (podcastInfo != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PodcastInfoPage(podcastInfo: podcastInfo),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.info_outline_rounded),
              ),
              _SubscribeButton(podcast: podcast),
            ],
          ),
          _buildEpisodeList(context, ref, episodesData, podcastInfo),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context, ref),
    );
  }

  Widget _buildEpisodeList(
    BuildContext context,
    WidgetRef ref,
    Map episodesData,
    Map? podcastInfo,
  ) {
    final isWide = wideScreenMinWidth < MediaQuery.sizeOf(context).width;

    if (isWide) {
      return SliverPadding(
        padding: const EdgeInsets.all(8),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 250,
            childAspectRatio: 1.2,
            mainAxisExtent: 294,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final author =
                  podcastInfo?['author'] ?? podcast.author ?? 'Unknown';
              return EpisodeCardGrid(
                title: episodesData['items'][index]['title'],
                aurthor: author,
                imageUrl: podcast.imageUrl.isNotEmpty
                    ? podcast.imageUrl
                    : podcastInfo?['image'] ?? '',
                episodeItem: episodesData['items'][index],
                podcast: podcast,
              );
            },
            childCount: episodesData['count'],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final author =
                podcastInfo?['author'] ?? podcast.author ?? 'Unknown';
            return EpisodeCardList(
              title: episodesData['items'][index]['title'],
              author: author,
              episodeItem: episodesData['items'][index],
              podcast: podcast,
            );
          },
          childCount: episodesData['count'],
        ),
      ),
    );
  }

  Widget? _buildBottomNav(BuildContext context, WidgetRef ref) {
    final isPodcastSelected =
        ref.watch(audioProvider.select((p) => p.isPodcastSelected));

    if (!isPodcastSelected) return null;

    return SizedBox(
      height: bannerAudioPlayerHeight,
      child: const BannerAudioPlayer(),
    );
  }
}

class _SubscribeButton extends ConsumerWidget {
  const _SubscribeButton({required this.podcast});

  final PodcastModel podcast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSubscribedAsync = ref.watch(_subscriptionProvider(podcast.title));

    return isSubscribedAsync.when(
      loading: () => const IconButton(
        onPressed: null,
        icon: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, __) => IconButton(
        onPressed: null,
        icon: const Icon(Icons.add),
      ),
      data: (isSubscribed) => IconButton(
        tooltip: isSubscribed
            ? Translations.of(context).text('unsubscribeToPodcast')
            : Translations.of(context).text('subscribeToPodcast'),
        onPressed: () => _toggleSubscription(context, ref, isSubscribed),
        icon: Icon(isSubscribed ? Icons.check : Icons.add),
      ),
    );
  }

  void _toggleSubscription(
      BuildContext context, WidgetRef ref, bool isSubscribed) async {
    final audioController = ref.read(audioProvider);

    if (isSubscribed) {
      audioController.unsubscribe(podcast);
    } else {
      audioController.subscribe(podcast, context);
    }

    final msg = isSubscribed
        ? '${Translations.of(context).text('unsubscribedFrom')} ${podcast.title}'
        : '${Translations.of(context).text('subscribedTo')} ${podcast.title}';

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

final _subscriptionProvider =
    FutureProvider.family<bool, String>((ref, title) async {
  return await ref.read(openAirProvider).isSubscribed(title);
});

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              Translations.of(context).text('oopsTryAgainLater'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(Translations.of(context).text('retry')),
            ),
          ],
        ),
      ),
    );
  }
}
