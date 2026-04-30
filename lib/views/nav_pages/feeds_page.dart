import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/components/no_subscriptions.dart';
import 'package:openair/config/config.dart';
import 'package:openair/model/hive_models/podcast_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/main_pages/episodes_page.dart';
import 'package:openair/views/widgets/unified_episode_card.dart';

final getSubscribedEpisodesProvider =
    FutureProvider.autoDispose<List<Map<dynamic, dynamic>>>((ref) async {
  final episodes = await ref.read(openAirProvider).getSubscribedEpisodes();
  return episodes;
});

class FeedsPage extends ConsumerStatefulWidget {
  const FeedsPage({super.key});

  @override
  ConsumerState<FeedsPage> createState() => _FeedsPageState();
}

class _FeedsPageState extends ConsumerState<FeedsPage> {
  @override
  Widget build(BuildContext context) {
    final episodesAsync = ref.watch(getSubscribedEpisodesProvider);

    return episodesAsync.when(
      data: (List<Map<dynamic, dynamic>> episodesDataSet) {
        if (episodesDataSet.isEmpty) {
          return const NoSubscriptions(title: 'Feeds');
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(Translations.of(context).text('feeds')),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  onPressed: () {
                    ref.invalidate(getSubscribedEpisodesProvider);
                  },
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ),
            ],
          ),
          body: ListView.separated(
            padding: const EdgeInsets.all(12),
            cacheExtent: cacheExtent,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemCount: episodesDataSet.length,
            itemBuilder: (context, index) {
              final episodeItem = episodesDataSet[index];
              final podcast = PodcastModel.fromJson(
                  (episodeItem['podcast'] as Map).cast<String, dynamic>());

              return GestureDetector(
                onTap: () {
                  ref.read(audioProvider.notifier).currentPodcast = podcast;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EpisodesPage(
                        podcast: podcast,
                      ),
                    ),
                  );
                },
                child: UnifiedEpisodeCard(
                  episodeItem: episodeItem.cast<String, dynamic>(),
                  podcast: podcast,
                  title: episodeItem['title'] ?? '',
                  author: podcast.author ??
                      Translations.of(context).text('unknown'),
                  showAuthor: true,
                ),
              );
            },
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: Text(Translations.of(context).text('feeds'))),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: Text(Translations.of(context).text('feeds'))),
        body: _ErrorView(
          error: error.toString(),
          onRetry: () {
            ref.invalidate(getSubscribedEpisodesProvider);
          },
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            Translations.of(context).text('oopsTryAgainLater'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onRetry,
            child: Text(Translations.of(context).text('retry')),
          ),
        ],
      ),
    );
  }
}
