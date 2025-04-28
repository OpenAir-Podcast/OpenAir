import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/api_service_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/player/banner_audio_player.dart';
import 'package:openair/views/widgets/trending_episode_card.dart';

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

    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
        future: ref.watch(apiServiceProvider).getPodcastsByFeedUrl(podcastUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: RefreshIndicator(
                onRefresh: () async {
                  await ref
                      .watch(apiServiceProvider)
                      .getPodcastsByFeedUrl(podcastUrl);
                },
                child: ListView.builder(
                  itemCount: snapshot.data!['count'],
                  itemBuilder: (context, index) => TrendingEpisodeCard(
                    episodeItem: snapshot.data!['items'][index],
                  ),
                ),
              ),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
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
