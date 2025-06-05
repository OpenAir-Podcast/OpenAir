import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/scale.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/providers/podcast_index_provider.dart';
import 'package:openair/components/no_connection.dart';
import 'package:openair/views/mobile/widgets/podcast_card.dart';

final podcastDataByTrendingProvider = FutureProvider((ref) async {
  final podcastIndexAPI = ref.read(podcastIndexProvider);
  return await podcastIndexAPI.getTrendingPodcasts();
});

final getConnectionStatusProvider = FutureProvider<bool>((ref) async {
  final apiService = ref.read(openAirProvider);
  return await apiService.getConnectionStatus();
});

class TrendingPage extends ConsumerStatefulWidget {
  const TrendingPage({super.key});

  @override
  ConsumerState<TrendingPage> createState() => _TrendingPageState();
}

class _TrendingPageState extends ConsumerState<TrendingPage>
    with AutomaticKeepAliveClientMixin<TrendingPage> {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context); // Important for AutomaticKeepAliveClientMixin
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
            error: (error, stackTrace) => Center(child: Text(error.toString())),
            data: (trendingData) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  cacheExtent: cacheExtent,
                  itemCount: trendingData['count'],
                  itemBuilder: (context, index) {
                    return PodcastCard(
                      podcastItem: trendingData['feeds'][index],
                    );
                  },
                ),
              );
            });
      },
      error: (error, stackTrace) => Center(child: Text(error.toString())),
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
