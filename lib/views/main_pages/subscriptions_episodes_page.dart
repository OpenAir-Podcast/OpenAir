import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/model/hive_models/podcast_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/providers/subscription_providers.dart';
import 'package:openair/services/podcast_index_service.dart';
import 'package:openair/views/native/podcast_info.dart';
import 'package:openair/views/widgets/episode_card_grid.dart';
import 'package:openair/views/widgets/toggle_banner.dart';
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
    final isSubscribed = isSubscribedAsync.asData?.value ?? false;

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
            tooltip: isSubscribed
                ? Translations.of(context).text('unsubscribeToPodCast')
                : Translations.of(context).text('subscribeToPodCast'),
            onPressed: () => _toggleSubscription(context, ref),
            icon: Icon(
              isSubscribed ? Icons.remove_circle_outline : Icons.add_circle_outline,
              color: isSubscribed
                  ? Theme.of(context).colorScheme.error
                  : null,
            ),
          ),
          IconButton(
            tooltip:
                Translations.of(context).text('podCastDetails'),
            onPressed: () {
              final data = podCastDataInfoAsync.asData?.value;
              if (data == null) return;
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
        ],
      ),
      body: podCastDataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _ErrorView(
          error: error.toString(),
          podCastFeedUrl: podCastUrl,
        ),
        data: (snapshot) {
          return podCastDataInfoAsync.when(
            data: (data) => _buildEpisodeList(context, ref, snapshot, data),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => _buildEpisodeList(context, ref, snapshot, null),
          );
        },
      ),
      bottomNavigationBar: ToggleBanner(),
    );
  }

  Widget _buildEpisodeList(
    BuildContext context,
    WidgetRef ref,
    Map snapshot,
    Map? podcastInfo,
  ) {
    final episodeCount = snapshot['count'] ?? 0;
    final isWide = !Platform.isAndroid && !Platform.isIOS ||
        wideScreenMinWidth < MediaQuery.sizeOf(context).width;

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
      scrollCacheExtent: ScrollCacheExtent.pixels(cacheExtent),
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

  void _toggleSubscription(BuildContext context, WidgetRef ref) async {
    final audioController = ref.read(audioProvider);
    final isSubscribed = ref.read(isSubscribedProvider(widget.podcast.title)).asData?.value ?? false;

    if (isSubscribed) {
      await audioController.unsubscribe(widget.podcast);
    } else {
      await audioController.subscribe(widget.podcast, context);
    }

    ref.invalidate(isSubscribedProvider(widget.podcast.title));
    ref.invalidate(subscriptionsProvider);
    ref.invalidate(subscriptionsWithCountsProvider);

    final msg = isSubscribed
        ? '${Translations.of(context).text('unsubscribedFrom')} ${widget.podcast.title}'
        : '${Translations.of(context).text('subscribedTo')} ${widget.podcast.title}';

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
