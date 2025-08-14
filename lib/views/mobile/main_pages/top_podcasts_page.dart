import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/hive_models/fetch_data_model.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/services/podcast_index_provider.dart';
import 'package:openair/views/mobile/widgets/podcast_card.dart';

final AutoDisposeFutureProvider<FetchDataModel> podcastDataByTrendingProvider =
    FutureProvider.autoDispose((ref) async {
  final FetchDataModel? topFeaturedPodcastData =
      await ref.watch(openAirProvider).hiveService.getTopFeaturedPodcast();

  if (topFeaturedPodcastData != null) {
    return topFeaturedPodcastData;
  }

  debugPrint('Getting Top podcast from PodcastIndex');
  final apiService = ref.watch(podcastIndexProvider);
  final data = await apiService.getTrendingPodcasts();
  return FetchDataModel.fromJson(data);
});

class TopPodcastsPage extends ConsumerWidget {
  const TopPodcastsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final podcastDataAsyncTrendingValue =
        ref.watch(podcastDataByTrendingProvider);

    return podcastDataAsyncTrendingValue.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
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
                ),
              ),
              Text(
                Translations.of(context).text('oopsTryAgainLater'),
                style: TextStyle(fontSize: 16.0),
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
                  child: Text(Translations.of(context).text('retry')),
                ),
              ),
            ],
          ),
        ),
      ),
      data: (snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Text(Translations.of(context).text('topPodcasts')),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: snapshot.feeds.length,
              itemBuilder: (context, index) {
                return PodcastCard(podcastItem: snapshot.feeds[index]);
              },
            ),
          ),
        );
      },
    );
  }
}
