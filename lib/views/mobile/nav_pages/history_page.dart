import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/components/no_history_episodes.dart';
import 'package:openair/config/scale.dart';
import 'package:openair/models/history_model.dart';
import 'package:openair/providers/hive_provider.dart';
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
            title: const Text('History'),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.delete_sweep_rounded),
                  tooltip: 'Clear History',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) => AlertDialog(
                        title: const Text('Clear History'),
                        content: const Text(
                            'Are you sure you want to clear your entire listening history? This action cannot be undone.'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('Clear'),
                            onPressed: () async {
                              Navigator.of(dialogContext).pop();
                              await ref
                                  .read(hiveServiceProvider)
                                  .clearHistory();
                              ref.invalidate(getHistoryProvider);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Listening history cleared.'),
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
                  return DownloadsEpisodeCard(
                    title: data[index].title,
                    episodeItem: data[index].toJson(),
                    podcast: data[index].toJson(),
                  );
                },
              ),
            ),
          ),
          bottomNavigationBar: SizedBox(
            height:
                ref.watch(openAirProvider.select((p) => p.isPodcastSelected))
                    ? 80.0
                    : 0.0,
            child: ref.watch(openAirProvider.select((p) => p.isPodcastSelected))
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
      loading: () => Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
