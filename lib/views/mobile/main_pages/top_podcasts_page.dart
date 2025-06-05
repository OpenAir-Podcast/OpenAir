import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/podcast_index_provider.dart';
import 'package:openair/views/mobile/widgets/podcast_card.dart';

final podcastDataByTrendingProvider = FutureProvider((ref) async {
  final apiService = ref.watch(podcastIndexProvider);
  return await apiService.getTrendingPodcasts();
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
                'Oops, an error occurred...',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$error',
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
                  child: const Text('Retry'),
                ),
              ),
            ],
          ),
        ),
      ),
      data: (snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Top Podcasts'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: snapshot['count'],
              itemBuilder: (context, index) {
                return PodcastCard(
                  podcastItem: snapshot['feeds'][index],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
