import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/api_service_provider.dart';
import 'package:openair/views/widgets/podcast_card.dart';

final podcastDataByTrendingProvider = FutureProvider((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getTrendingPodcasts();
});

class TrendingPage extends ConsumerWidget {
  const TrendingPage({super.key});

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
        error: (error, stackTrace) => Center(child: Text(error.toString())),
        data: (snapshot) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: snapshot['count'],
              itemBuilder: (context, index) {
                return PodcastCard(
                  podcastItem: snapshot['feeds'][index],
                );
              },
            ),
          );
        });
  }
}
