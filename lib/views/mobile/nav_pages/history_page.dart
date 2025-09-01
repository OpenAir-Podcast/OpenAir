import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/components/no_history_episodes.dart';
import 'package:openair/config/config.dart';
import 'package:openair/hive_models/history_model.dart';
import 'package:openair/hive_models/podcast_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/mobile/player/banner_audio_player.dart';
import 'package:openair/views/mobile/widgets/downloads_episode_card.dart';

final getHistoryProvider = FutureProvider.autoDispose((ref) async {
  return await ref.read(openAirProvider).getSortedHistory();
});

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState createState() => _HistoryState();
}

class _HistoryState extends ConsumerState<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<HistoryModel>> getEpisodesValue =
        ref.watch(getHistoryProvider);

    return getEpisodesValue.when(
      data: (List<HistoryModel> data) {
        if (data.isEmpty) {
          return NoHistoryEpisodes();
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(Translations.of(context).text('history')),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  tooltip: Translations.of(context).text('clearHistory'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) => AlertDialog(
                        title:
                            Text(Translations.of(context).text('clearHistory')),
                        content: Text(Translations.of(context)
                            .text('areYouSureClearHistory')),
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
                                  .watch(openAirProvider)
                                  .hiveService
                                  .clearHistory();
                              ref.invalidate(getHistoryProvider);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      Translations.of(context)
                                          .text('historyCleared'),
                                    ),
                                  ),
                                );
                              }
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
              onRefresh: () async => ref.invalidate(getHistoryProvider),
              child: ListView.builder(
                cacheExtent: cacheExtent,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  PodcastModel podcastModel = PodcastModel(
                    id: int.parse(data[index].podcastId),
                    feedUrl: data[index].feedUrl,
                    title: data[index].title,
                    author: data[index].author,
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
                ? bannerAudioPlayerHeight
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
                      ref.invalidate(getHistoryProvider);
                    },
                    child: const Text('Retry'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
