import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/mobile/player/banner_audio_player.dart';
import 'package:openair/views/mobile/widgets/search_card.dart';

class FyydSearchPage extends ConsumerWidget {
  const FyydSearchPage({
    super.key,
    required this.podcasts,
    required this.searchWord,
  });

  final List podcasts;
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
          itemCount: podcasts.length,
          itemBuilder: (context, index) => SearchCard(
            podcastItem: podcasts[index],
          ),
        ),
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
