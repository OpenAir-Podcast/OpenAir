import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/model/hive_models/podcast_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/providers/subscription_providers.dart';
import 'package:openair/services/podcast_index_service.dart';
import 'package:openair/views/native/podcast_info.dart';
import 'package:openair/views/player/banner_audio_player.dart';
import 'package:openair/views/widgets/episode_card_grid.dart';
import 'package:openair/views/widgets/unified_episode_card.dart';

final podCastDataByUrlProvider =
    FutureProvider.family<Map<String, dynamic>, String>(
        (ref, podCastUrl) async {
  final podCastIndexService = ref.watch(podcastIndexProvider);
  return await podCastIndexService.getEpisodesByFeedUrl(podCastUrl);
});

class SubscriptionsEpisodesPage extends ConsumerStatefulWidget {
  const SubscriptionsEpisodesPage({
    super.key,
    required this.podcast,
    required this.id,
  });

  final PodcastModel podcast;
  final int id;

  @override
  ConsumerState<SubscriptionsEpisodesPage> createState() =>
      _SubscriptionsEpisodesPageState();
}

class _SubscriptionsEpisodesPageState
    extends ConsumerState<SubscriptionsEpisodesPage> {
  @override
  Widget build(BuildContext context) {
    final podCastUrl = widget.podcast.feedUrl;
    final podCastDataAsync = ref.watch(podCastDataByUrlProvider(podCastUrl));
    final podCastDataInfoAsync =
        ref.watch(getPodcastInfoByTitleProvider(widget.podcast.title));
    final isSubscribedAsync =
        ref.watch(isSubscribedProvider(widget.podcast.title));

    return podCastDataAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: Text(widget.podcast.title)),
        body: _ErrorView(
          error: error.toString(),
          podCastFeedUrl: podCastUrl,
        ),
      ),
      data: (snapshot) {
        return podCastDataInfoAsync.when(
          data: (data) {
            return isSubscribedAsync.when(
              data: (isSubscribed) {
                return Scaffold(
                  appBar: AppBar(
                    title: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.55),
                      child: Text(
                        widget.podcast.title,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    actions: [
                      IconButton(
                        tooltip:
                            Translations.of(context).text('podCastDetails'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PodcastInfoPage(podcastInfo: data),
                            ),
                          );
                        },
                        icon: const Icon(Icons.info_outline_rounded, size: 30),
                      ),
                      _SubscribeButton(
                        podcast: widget.podcast,
                        isSubscribed: isSubscribed,
                      ),
                    ],
                  ),
                  body: _buildEpisodeList(context, ref, snapshot, data),
                  bottomNavigationBar: _buildBottomBar(context, ref),
                );
              },
              loading: () => const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const Scaffold(
                body: Center(child: Text('Error loading subscription status')),
              ),
            );
          },
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => Scaffold(
            appBar: AppBar(title: Text(widget.podcast.title)),
            body: _buildEpisodeList(context, ref, snapshot, null),
          ),
        );
      },
    );
  }

  Widget _buildEpisodeList(
    BuildContext context,
    WidgetRef ref,
    Map snapshot,
    Map? podcastInfo,
  ) {
    final episodeCount = snapshot['count'] ?? 0;
    final isDesktop = !Platform.isAndroid && !Platform.isIOS;

    if (episodeCount == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.podcasts, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              Translations.of(context).text('noResults'),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    String getAuthor() {
      return (podcastInfo?['author']?.isNotEmpty == true ||
              widget.podcast.author?.isNotEmpty == true)
          ? (podcastInfo?['author'] ?? widget.podcast.author!)
          : Translations.of(context).text('unknown');
    }

    if (isDesktop) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300.0,
          mainAxisExtent: 312.0,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        cacheExtent: cacheExtent,
        itemCount: episodeCount,
        itemBuilder: (context, index) {
          final author = getAuthor();
          return EpisodeCardGrid(
            episodeItem: snapshot['items'][index],
            title: snapshot['items'][index]['title'] ?? '',
            author: author,
            imageUrl: widget.podcast.imageUrl,
            podcast: widget.podcast,
          );
        },
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      cacheExtent: cacheExtent,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemCount: episodeCount,
      itemBuilder: (context, index) {
        final author = getAuthor();

        return UnifiedEpisodeCard(
          episodeItem: snapshot['items'][index],
          podcast: widget.podcast,
          title: snapshot['items'][index]['title'],
          author: author,
          showAuthor: true,
        );
      },
    );
  }

  Widget? _buildBottomBar(BuildContext context, WidgetRef ref) {
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

class _SubscribeButton extends ConsumerWidget {
  const _SubscribeButton({
    required this.podcast,
    required this.isSubscribed,
  });

  final PodcastModel podcast;
  final bool isSubscribed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: isSubscribed
          ? Translations.of(context).text('unsubscribeToPodCast')
          : Translations.of(context).text('subscribeToPodCast'),
      onPressed: () => _toggleSubscription(context, ref),
      icon: Icon(isSubscribed ? Icons.check : Icons.add),
    );
  }

  void _toggleSubscription(BuildContext context, WidgetRef ref) async {
    final audioController = ref.read(audioProvider);

    if (isSubscribed) {
      audioController.unsubscribe(podcast);
    } else {
      audioController.subscribe(podcast, context);
    }

    // Invalidate the provider to refresh the UI
    ref.invalidate(isSubscribedProvider(podcast.title));

    final msg = isSubscribed
        ? '${Translations.of(context).text('unsubscribedFrom')} ${podcast.title}'
        : '${Translations.of(context).text('subscribedTo')} ${podcast.title}';

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _ErrorView extends ConsumerWidget {
  final String error;

  const _ErrorView({required this.error, required this.podCastFeedUrl});

  final String podCastFeedUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 64, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            Translations.of(context).text('oopsTryAgainLater'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            error,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () =>
                ref.invalidate(podCastDataByUrlProvider(podCastFeedUrl)),
            child: Text(Translations.of(context).text('retry')),
          ),
        ],
      ),
    );
  }
}
