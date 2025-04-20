import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/podcast_provider.dart';
import 'package:openair/views/navigation/app_bar.dart';
import 'package:openair/views/player/banner_audio_player.dart';
import 'package:openair/views/widgets/episode_card.dart';
import 'package:podcastindex_dart/src/entity/episode.dart';
import 'package:podcastindex_dart/src/service/episode_service.dart';
import 'package:podcastindex_dart/src/service/feed_service.dart';

class EpisodesPage extends ConsumerStatefulWidget {
  const EpisodesPage({Key? key}) : super(key: key);

  @override
  ConsumerState<EpisodesPage> createState() => _EpisodesPageState();
}

class _EpisodesPageState extends ConsumerState<EpisodesPage> {
  final FeedService feedService = FeedService();
  final EpisodeService episodeService = EpisodeService();
  late Future<List<Episode>> _episodeFuture;

  @override
  void initState() {
    super.initState();
    _refreshEpisodes(); // Initialize the future on startup
  }

  Future<void> _refreshEpisodes() async {
    final podcastUrl = ref.read(podcastProvider.notifier).currentPodcast?.url;
    if (podcastUrl != null) {
      setState(() {
        _episodeFuture = episodeFeed(podcastUrl); // Create a new Future
      });
    }
  }

  Future<List<Episode>> episodeFeed(String podcastUrl) async {
    List<Episode> results =
        await episodeService.findEpisodesByFeedUrl(podcastUrl);

    return results;
  }

  @override
  Widget build(BuildContext context) {
    final podcastUrl = ref.watch(podcastProvider.notifier).currentPodcast?.url;

    if (podcastUrl == null) {
      return const Scaffold(
        body: Center(
          child: Text('No podcast selected'),
        ),
      );
    }

    return Scaffold(
      appBar: appBar(ref),
      body: FutureBuilder<List<Episode>>(
        future: _episodeFuture,
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
                  await _refreshEpisodes(); // Call _refreshEpisodes here
                },
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) => EpisodeCard(
                    episodeItem: snapshot.data![index],
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
        height: ref.watch(podcastProvider).isPodcastSelected ? 80.0 : 0.0,
        child: ref.watch(podcastProvider).isPodcastSelected
            ? const BannerAudioPlayer()
            : const SizedBox(),
      ),
    );
  }
}
