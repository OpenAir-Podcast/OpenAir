import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/api_service_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/player/banner_audio_player.dart';
import 'package:openair/views/widgets/trending_episode_card.dart';

final podcastDataByUrlProvider =
    FutureProvider.family<Map<String, dynamic>, String>(
        (ref, podcastUrl) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getPodcastsByFeedUrl(podcastUrl);
});

class TrendingEpisodesPage extends ConsumerStatefulWidget {
  const TrendingEpisodesPage({super.key});

  @override
  ConsumerState<TrendingEpisodesPage> createState() => _EpisodesPageState();
}

class _EpisodesPageState extends ConsumerState<TrendingEpisodesPage> {
  @override
  Widget build(BuildContext context) {
    final podcastUrl =
        ref.watch(openAirProvider.notifier).currentPodcast!['url'];

    final podcastDataAsyncValue =
        ref.watch(podcastDataByUrlProvider(podcastUrl));

    return Scaffold(
      appBar: AppBar(),
      body: podcastDataAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text(error.toString())),
        data: (snapshot) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: RefreshIndicator(
              onRefresh: () async =>
                  ref.invalidate(podcastDataByUrlProvider(podcastUrl)),
              child: ListView.builder(
                itemCount: snapshot['count'],
                itemBuilder: (context, index) => TrendingEpisodeCard(
                  episodeItem: snapshot['items'][index],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SizedBox(
        height: ref.watch(openAirProvider).isPodcastSelected ? 80.0 : 0.0,
        child: ref.watch(openAirProvider).isPodcastSelected
            ? const BannerAudioPlayer()
            : const SizedBox(),
      ),
    );
  }
}
