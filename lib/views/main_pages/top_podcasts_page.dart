import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/hive_models/fetch_data_model.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/services/podcast_index_service.dart';
import 'package:openair/views/widgets/podcast_card_grid.dart';
import 'package:openair/views/widgets/podcast_card_list.dart';

final AutoDisposeFutureProvider<FetchDataModel> podcastDataByTrendingProvider =
    FutureProvider.autoDispose((ref) async {
  final FetchDataModel? topFeaturedPodcastData =
      await ref.watch(openAirProvider).hiveService.getTopFeaturedPodcast();

  if (topFeaturedPodcastData != null) {
    return topFeaturedPodcastData;
  }

  debugPrint('Getting Top podcast from PodcastIndex');
  final podcastIndexService = ref.watch(podcastIndexProvider);
  final data = await podcastIndexService.getTrendingPodcasts();
  return FetchDataModel.fromJson(data);
});

class TopPodcastsPage extends ConsumerStatefulWidget {
  const TopPodcastsPage({super.key});

  @override
  ConsumerState<TopPodcastsPage> createState() => _TopPodcastsPageState();
}

class _TopPodcastsPageState extends ConsumerState<TopPodcastsPage> {
  @override
  Widget build(BuildContext context) {
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
        if (MediaQuery.sizeOf(context).width > wideScreenMinWidth) {
          return Scaffold(
            appBar: AppBar(
              title: Text(Translations.of(context).text('topPodcasts')),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    tooltip: Translations.of(context).text('refresh'),
                    onPressed: () {
                      ref
                          .watch(hiveServiceProvider)
                          .removeAllTopFeaturedPodcasts();

                      ref.invalidate(podcastDataByTrendingProvider);

                      Future.delayed(const Duration(seconds: 1), () async {
                        setState(() {});
                      });
                    },
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 3 / 4,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: snapshot.feeds.length,
                itemBuilder: (context, index) {
                  return PodcastCardGrid(podcastItem: snapshot.feeds[index]);
                },
              ),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Text(Translations.of(context).text('topPodcasts')),
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: snapshot.feeds.length,
                itemBuilder: (context, index) {
                  return PodcastCardList(podcastItem: snapshot.feeds[index]);
                },
              ),
            ),
          );
        }
      },
    );
  }
}
