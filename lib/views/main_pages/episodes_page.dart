import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/model/hive_models/podcast_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/subscription_providers.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/services/podcast_index_service.dart';
import 'package:openair/views/native/podcast_info.dart';
import 'package:openair/views/player/banner_audio_player.dart';
import 'package:openair/views/widgets/unified_episode_card.dart';

final podCastDataByUrlProvider =
    FutureProvider.family<Map<String, dynamic>, String>(
        (ref, podCastUrl) async {
  final podCastIndexService = ref.watch(podcastIndexProvider);
  return await podCastIndexService.getEpisodesByFeedUrl(podCastUrl);
});

class EpisodesPage extends ConsumerWidget {
  const EpisodesPage({super.key, required this.podcast});

  final PodcastModel podcast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final podCastUrl = ref.watch(audioProvider).currentPodcast!.feedUrl;
    final podCastDataAsync = ref.watch(podCastDataByUrlProvider(podCastUrl));
    final podCastInfoAsync =
        ref.watch(getPodcastInfoByTitleProvider(podcast.title));
    final isSubscribedAsync = ref.watch(isSubscribedProvider(podcast.title));

    return podCastDataAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: Text(podcast.title)),
        body: _ErrorView(
            error: error.toString(),
            onRetry: () =>
                ref.invalidate(podCastDataByUrlProvider(podCastUrl))),
      ),
      data: (snapshot) {
        return podCastInfoAsync.when(
          data: (data) {
            return isSubscribedAsync.when(
              data: (isSubscribed) {
                return Scaffold(
                  appBar: AppBar(
                    title: Text(podcast.title),
                    actions: [
                      IconButton(
                        tooltip:
                            Translations.of(context).text('podcastDetails'),
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
                        podcast: podcast,
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
            appBar: AppBar(title: Text(podcast.title)),
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
    Map? podCastInfo,
  ) {
    final episodeCount = snapshot['count'] ?? 0;

    if (episodeCount == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.podcasts, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              Translations.of(context).text('noResults'),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      cacheExtent: cacheExtent,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemCount: episodeCount,
      itemBuilder: (context, index) {
        final author = (podCastInfo?['author']?.isNotEmpty == true ||
                podcast.author?.isNotEmpty == true)
            ? (podCastInfo?['author'] ?? podcast.author!)
            : Translations.of(context).text('unknown');

        return UnifiedEpisodeCard(
          episodeItem: snapshot['items'][index],
          podcast: podcast,
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
          ? Translations.of(context).text('unsubscribeToPodcast')
          : Translations.of(context).text('subscribeToPodcast'),
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

    final msg = isSubscribed
        ? '${Translations.of(context).text('unsubscribedFrom')} ${podcast.title}'
        : '${Translations.of(context).text('subscribedTo')} ${podcast.title}';

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

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
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
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
