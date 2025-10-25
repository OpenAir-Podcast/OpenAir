import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/views/player/banner_audio_player.dart';
import 'package:openair/views/widgets/fyyd_search_card_grid.dart';

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
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: wideScreenMinWidth < MediaQuery.sizeOf(context).width
            ? GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 3 / 4,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                cacheExtent: cacheExtent,
                itemCount: podcasts.length,
                itemBuilder: (context, index) {
                  debugPrint(podcasts[index].toString());

                  if (podcasts[index]['imgURL'] == null) {
                    return Container();
                  }

                  return FyydSearchCardGrid(
                    podcastItem: podcasts[index],
                  );
                },
              )
            : ListView.builder(
                itemCount: podcasts.length,
                itemBuilder: (context, index) => FyydSearchCardGrid(
                  podcastItem: podcasts[index],
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
