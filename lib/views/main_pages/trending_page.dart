import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/translations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/hive_models/fetch_data_model.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/services/podcast_index_service.dart';
import 'package:openair/components/no_connection.dart';
import 'package:openair/views/widgets/podcast_card_grid.dart';
import 'package:openair/views/widgets/podcast_card_list.dart';

final AutoDisposeFutureProvider<FetchDataModel> podcastDataByTrendingProvider =
    FutureProvider.autoDispose((ref) async {
  final FetchDataModel? trendingPodcastData =
      await ref.watch(openAirProvider).hiveService.getTrendingPodcast();

  if (trendingPodcastData != null) {
    return trendingPodcastData;
  }

  debugPrint('Fetching podcasts from Podcast Index');

  final podcastIndexAPI = ref.read(podcastIndexProvider);
  final data = await podcastIndexAPI.getTrendingPodcasts();

  return FetchDataModel.fromJson(data);
});

final getConnectionStatusProvider =
    FutureProvider.autoDispose<bool>((ref) async {
  final podcastIndexService = ref.read(openAirProvider);
  return await podcastIndexService.getConnectionStatus();
});

class TrendingPage extends ConsumerStatefulWidget {
  const TrendingPage({super.key});

  @override
  ConsumerState<TrendingPage> createState() => _TrendingPageState();
}

class _TrendingPageState extends ConsumerState<TrendingPage> {
  @override
  Widget build(BuildContext context) {
    final podcastDataAsyncTrendingValue =
        ref.watch(podcastDataByTrendingProvider);

    final getConnectionStatusValue = ref.watch(getConnectionStatusProvider);

    return getConnectionStatusValue.when(
      data: (connectionData) {
        if (connectionData == false) {
          return NoConnection();
        }

        return podcastDataAsyncTrendingValue.when(
            loading: () => const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            error: (error, stackTrace) => SizedBox(
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
                        Translations.of(context).text('oopsTryAgainLater'),
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Center(
                        child: Text(
                          '$error\n$stackTrace',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16.0),
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
                            ref.invalidate(podcastDataByTrendingProvider);
                          },
                          child: const Text('Retry'),
                        ),
                      ),
                    ],
                  ),
                ),
            data: (FetchDataModel trendingData) {
              if (wideScreenMinWidth < MediaQuery.sizeOf(context).width) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 3 / 4,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    cacheExtent: cacheExtent,
                    itemCount: trendingData.count,
                    itemBuilder: (context, index) {
                      return PodcastCardGrid(
                        podcastItem: trendingData.feeds[index],
                      );
                    },
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    cacheExtent: cacheExtent,
                    itemCount: trendingData.count,
                    itemBuilder: (context, index) {
                      return PodcastCardList(
                        podcastItem: trendingData.feeds[index],
                      );
                    },
                  ),
                );
              }
            });
      },
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
                Translations.of(context).text(']oopsAnErrorOccurred'),
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$error\n$stackTrace',
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
                    ref.invalidate(getConnectionStatusProvider);
                  },
                  child: const Text('Retry'),
                ),
              ),
            ],
          ),
        ),
      ),
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
