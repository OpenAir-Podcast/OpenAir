import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/model/hive_models/podcast_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/providers/subscription_providers.dart';
import 'package:openair/views/player/banner_audio_player.dart';
import 'package:openair/views/widgets/subscription_episode_card_list.dart';
import 'package:openair/views/widgets/subscription_episode_card_grid.dart';
import 'package:openair/views/native/podcast_info.dart';

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
    final podcastUrl = widget.podcast.feedUrl;
    final podcastDataAsyncValue =
        ref.watch(podcastDataByUrlProvider(podcastUrl));
    final podcastDataInfoAsyncValue =
        ref.watch(getPodcastInfoByTitleProvider(widget.podcast.title));
    final isSubscribedAsyncValue =
        ref.watch(isSubscribedProvider(widget.podcast.title));

    return podcastDataAsyncValue.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: Text(widget.podcast.title)),
        body: _ErrorView(
          error: error.toString(),
          podcastFeedUrl: widget.podcast.feedUrl,
        ),
      ),
      data: (snapshot) {
        return podcastDataInfoAsyncValue.when(
          data: (data) {
            return isSubscribedAsyncValue.when(
              data: (isSubscribed) {
                return Scaffold(
                  appBar: AppBar(
                    title: Text(widget.podcast.title),
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
                        podcast: widget.podcast,
                        isSubscribed: isSubscribed,
                      ),
                    ],
                  ),
                  body: _buildEpisodeList(context, ref, snapshot),
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
            body: _ErrorView(
              error: 'Error loading subscription status',
              podcastFeedUrl: widget.podcast.feedUrl,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEpisodeList(
    BuildContext context,
    WidgetRef ref,
    Map snapshot,
  ) {
    final isWide = wideScreenMinWidth < MediaQuery.sizeOf(context).width;
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

    if (isWide) {
      return GridView.builder(
        padding: const EdgeInsets.all(12),
        cacheExtent: cacheExtent,
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 250,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: episodeCount,
        itemBuilder: (context, index) => SubscriptionEpisodeCardGrid(
          title: snapshot['items'][index]['title'],
          episodeItem: snapshot['items'][index],
          podcast: widget.podcast,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      cacheExtent: cacheExtent,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemCount: episodeCount,
      itemBuilder: (context, index) => SubscriptionEpisodeCardList(
        title: snapshot['items'][index]['title'],
        episodeItem: snapshot['items'][index],
        podcast: widget.podcast,
      ),
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

class _ErrorView extends ConsumerWidget {
  final String error;
  final String podcastFeedUrl;

  const _ErrorView({required this.error, required this.podcastFeedUrl});

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
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
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
          Consumer(
            builder: (context, ref, _) => ElevatedButton(
              onPressed: () =>
                  ref.invalidate(podcastDataByUrlProvider(podcastFeedUrl)),
              child: Text(Translations.of(context).text('retry')),
            ),
          ),
        ],
      ),
    );
  }
}
