import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/scale.dart';
import 'package:openair/models/fetch_data_model.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/services/podcast_index_provider.dart';
import 'package:openair/components/no_connection.dart';
import 'package:openair/views/mobile/widgets/podcast_card.dart';

// TODO Add a button to refresh data

final AutoDisposeFutureProvider<FetchDataModel> podcastDataByTrendingProvider =
    FutureProvider.autoDispose((ref) async {
  final FetchDataModel? trendingPodcastData =
      await ref.read(hiveServiceProvider).getTrendingPodcast();

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
  final apiService = ref.read(openAirProvider);
  return await apiService.getConnectionStatus();
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
                        'Oops, an error occurred...',
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
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  cacheExtent: cacheExtent,
                  itemCount: trendingData.count,
                  itemBuilder: (context, index) {
                    return PodcastCard(
                      podcastItem: trendingData.feeds[index],
                    );
                  },
                ),
              );
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
                'Oops, an error occurred...',
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
