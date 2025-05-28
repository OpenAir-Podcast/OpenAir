import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/podcast_index_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/mobile/player/banner_audio_player.dart';
import 'package:openair/views/mobile/widgets/episode_card.dart';

final podcastDataByUrlProvider =
    FutureProvider.family<Map<String, dynamic>, String>(
        (ref, podcastUrl) async {
  final apiService = ref.watch(podcastIndexProvider);
  return await apiService.getPodcastsByFeedUrl(podcastUrl);
});

class EpisodesPage extends ConsumerStatefulWidget {
  const EpisodesPage({super.key, required this.podcast, required this.id});
  final Map<String, dynamic> podcast;
  final int id;

  @override
  ConsumerState<EpisodesPage> createState() => _EpisodesPageState();
}

class _EpisodesPageState extends ConsumerState<EpisodesPage> {
  @override
  Widget build(BuildContext context) {
    final podcastUrl =
        ref.watch(openAirProvider.notifier).currentPodcast!['url'];

    final podcastDataAsyncValue =
        ref.watch(podcastDataByUrlProvider(podcastUrl));

    return podcastDataAsyncValue.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Center(child: Text(error.toString())),
      data: (snapshot) {
        return FutureBuilder(
            future: ref.watch(openAirProvider).isSubscribed(widget.id),
            builder: (context, isSubscribed) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(
                      ref.watch(openAirProvider).currentPodcast!['title'] ??
                          'Unknown'),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: IconButton(
                        tooltip: !isSubscribed.hasData
                            ? 'Loading...'
                            : isSubscribed.data!
                                ? 'Unsubscribe to podcast'
                                : 'Subscribe to podcast',
                        onPressed: () {
                          if (isSubscribed.data!) {
                            // Unsubscribe
                            ref
                                .read(openAirProvider.notifier)
                                .unsubscribe(widget.podcast);
                          } else {
                            // Subscribe
                            ref
                                .read(openAirProvider.notifier)
                                .subscribe(widget.podcast);
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                !isSubscribed.hasData
                                    ? 'Loading...'
                                    : isSubscribed.data!
                                        ? 'Unsubscribed from ${widget.podcast['title']}'
                                        : 'Subscribed to ${widget.podcast['title']}',
                              ),
                            ),
                          );
                        },
                        icon: !isSubscribed.hasData
                            ? const Icon(Icons.error_outline)
                            : isSubscribed.data!
                                ? const Icon(Icons.check)
                                : const Icon(Icons.add),
                      ),
                    ),
                  ],
                ),
                body: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RefreshIndicator(
                    onRefresh: () async =>
                        ref.invalidate(podcastDataByUrlProvider(podcastUrl)),
                    child: ListView.builder(
                      itemCount: snapshot['count'],
                      itemBuilder: (context, index) => EpisodeCard(
                        title: snapshot['items'][index]['title'],
                        episodeItem: snapshot['items'][index],
                      ),
                    ),
                  ),
                ),
                bottomNavigationBar: SizedBox(
                  height:
                      ref.watch(openAirProvider).isPodcastSelected ? 80.0 : 0.0,
                  child: ref.watch(openAirProvider).isPodcastSelected
                      ? const BannerAudioPlayer()
                      : const SizedBox(),
                ),
              );
            });
      },
    );
  }
}
