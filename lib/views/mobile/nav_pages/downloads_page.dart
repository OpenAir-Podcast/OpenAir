import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/components/no_downloaded_episodes.dart';
import 'package:openair/config/config.dart';
import 'package:openair/hive_models/download_model.dart';
import 'package:openair/hive_models/podcast_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/mobile/player/banner_audio_player.dart';
import 'package:openair/views/mobile/widgets/downloads_episode_card.dart';

final getDownloadsProvider = FutureProvider.autoDispose((ref) async {
  return await ref.read(openAirProvider).getSortedDownloadedEpisodes();
});

class DownloadsPage extends ConsumerStatefulWidget {
  const DownloadsPage({super.key});

  @override
  ConsumerState createState() => _DownloadsState();
}

class _DownloadsState extends ConsumerState<DownloadsPage> {
  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<DownloadModel>> getEpisodesValue =
        ref.watch(getDownloadsProvider);

    return getEpisodesValue.when(
      data: (List<DownloadModel> data) {
        if (data.isEmpty) {
          return NoDownloadedEpisodes();
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(Translations.of(context).text('downloads')),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  tooltip: Translations.of(context).text('clearDownloads'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) => AlertDialog(
                        title: Text(
                            Translations.of(context).text('clearDownloads')),
                        content: Text(Translations.of(context)
                            .text('areYouSureClearDownloads')),
                        actions: <Widget>[
                          TextButton(
                            child:
                                Text(Translations.of(context).text('cancel')),
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                          ),
                          TextButton(
                            child: Text(Translations.of(context).text('clear')),
                            onPressed: () async {
                              Navigator.of(dialogContext).pop();

                              await ref
                                  .read(audioProvider)
                                  .removeAllDownloadedPodcasts(context);

                              ref.invalidate(getDownloadsProvider);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(getDownloadsProvider),
              child: ListView.builder(
                cacheExtent: cacheExtent,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  PodcastModel podcastModel = PodcastModel(
                    id: int.parse(data[index].podcastId),
                    title: data[index].title,
                    author: data[index].author,
                    feedUrl: data[index].feedUrl,
                    imageUrl: data[index].image,
                    description: data[index].description,
                    artwork: data[index].image,
                  );

                  return DownloadsEpisodeCard(
                    title: data[index].title,
                    episodeItem: data[index].toJson(),
                    podcast: podcastModel,
                  );
                },
              ),
            ),
          ),
          bottomNavigationBar: SizedBox(
            height: ref.watch(audioProvider.select((p) => p.isPodcastSelected))
                ? 80.0
                : 0.0,
            child: ref.watch(audioProvider.select((p) => p.isPodcastSelected))
                ? const BannerAudioPlayer()
                : const SizedBox.shrink(),
          ),
        );
      },
      error: (error, stackTrace) {
        debugPrint('Error loading episodes: $error');
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 75.0,
                  color: Colors.grey,
                ),
                const SizedBox(height: 20.0),
                Text(
                  'Oops, an error occurred...',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
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
                      ref.invalidate(getDownloadsProvider);
                    },
                    child: const Text('Retry'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
