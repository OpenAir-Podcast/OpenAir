import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/hive_models/fetch_data_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/views/mobile/player/banner_audio_player.dart';
import 'package:openair/views/mobile/widgets/podcast_index_search_card.dart';

class PodcastIndexSearchPage extends ConsumerWidget {
  const PodcastIndexSearchPage({
    super.key,
    required this.podcasts,
    required this.searchWord,
  });

  final FetchDataModel podcasts;
  final String searchWord;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search for "$searchWord"'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              tooltip: 'Refreash',
              onPressed: () {
                // TODO Implement refreash mechanic
              },
              icon: const Icon(Icons.refresh_rounded),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: podcasts.count,
          itemBuilder: (context, index) => PodcastIndexSearchCard(
            podcastItem: podcasts.feeds[index],
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: ref.watch(audioProvider).isPodcastSelected
            ? bannerAudioPlayerHeight
            : 0.0,
        child: ref.watch(audioProvider).isPodcastSelected
            ? const BannerAudioPlayer()
            : const SizedBox(),
      ),
    );
  }
}
