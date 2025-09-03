import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/hive_models/podcast_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/services/podcast_index_provider.dart';
import 'package:openair/views/mobile/player/banner_audio_player.dart';
import 'package:openair/views/mobile/widgets/episode_card.dart';

final podcastDataByUrlProvider =
    FutureProvider.family<Map<String, dynamic>, String>(
        (ref, podcastUrl) async {
  final apiService = ref.watch(podcastIndexProvider);
  return await apiService.getEpisodesByFeedUrl(podcastUrl);
});

class EpisodesPage extends ConsumerStatefulWidget {
  const EpisodesPage({super.key, required this.podcast});
  final PodcastModel podcast;

  @override
  ConsumerState<EpisodesPage> createState() => _EpisodesPageState();
}

class _EpisodesPageState extends ConsumerState<EpisodesPage> {
  Future<bool> getSub() async {
    return await ref.watch(openAirProvider).isSubscribed(widget.podcast.title);
  }

  @override
  Widget build(BuildContext context) {
    final podcastUrl = ref.watch(audioProvider).currentPodcast!.feedUrl;

    final podcastDataAsyncValue =
        ref.watch(podcastDataByUrlProvider(podcastUrl));

    return podcastDataAsyncValue.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        body: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 75.0,
                color: Colors.grey,
              ),
              const SizedBox(height: 20.0),
              Text(
                Translations.of(context).text('oopsAnErrorOccurred'),
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Brightness.dark == Theme.of(context).brightness
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              Text(
                Translations.of(context).text('oopsTryAgainLater'),
                style: TextStyle(
                  fontSize: 16.0,
                  color: Brightness.dark == Theme.of(context).brightness
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              const SizedBox(height: 20.0),
              SizedBox(
                width: 180.0,
                height: 40.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onPressed: () async {
                    ref.invalidate(podcastIndexProvider);
                  },
                  child: Text(
                    Translations.of(context).text('retry'),
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Brightness.dark == Theme.of(context).brightness
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      data: (snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Text(ref.watch(audioProvider).currentPodcast!.title),
            actions: [
              IconButton(
                tooltip: Translations.of(context).text('podcastDetails'),
                onPressed: () async {
                  // TODO Go to a screen that shows the details of the podcast
                },
                icon: Icon(
                  Icons.info_outline_rounded,
                  size: 30.0,
                ),
              ),
              FutureBuilder(
                future: ref
                    .watch(openAirProvider)
                    .isSubscribed(widget.podcast.title),
                builder: (context, snapshot) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: IconButton(
                      tooltip: snapshot.hasData
                          ? snapshot.data!
                              ? Translations.of(context)
                                  .text('unsubscribeToPodcast')
                              : Translations.of(context)
                                  .text('subscribeToPodcast')
                          : '...',
                      onPressed: () async {
                        snapshot.data! && snapshot.hasData
                            ? ref
                                .read(audioProvider)
                                .unsubscribe(widget.podcast)
                            : ref.read(audioProvider).subscribe(
                                  widget.podcast,
                                  context,
                                );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              snapshot.data!
                                  ? '${Translations.of(context).text('unsubscribedFrom')} ${widget.podcast.title}'
                                  : '${Translations.of(context).text('subscribedTo')} ${widget.podcast.title}',
                            ),
                          ),
                        );

                        ref.invalidate(podcastDataByUrlProvider);
                      },
                      icon: snapshot.hasData
                          ? snapshot.data!
                              ? const Icon(Icons.check)
                              : const Icon(Icons.add)
                          : const Icon(Icons.add),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: RefreshIndicator(
              onRefresh: () async =>
                  ref.invalidate(podcastDataByUrlProvider(podcastUrl)),
              child: ListView.builder(
                cacheExtent: cacheExtent,
                itemCount: snapshot['count'],
                itemBuilder: (context, index) => EpisodeCard(
                  title: snapshot['items'][index]['title'],
                  episodeItem: snapshot['items'][index],
                  podcast: widget.podcast,
                ),
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
      },
    );
  }
}
