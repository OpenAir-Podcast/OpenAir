import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/podcast_index_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/mobile/player/banner_audio_player.dart';
import 'package:openair/views/mobile/widgets/podcast_card.dart';

// Create a FutureProvider to fetch the podcast data
final podcastDataByCategoryProvider = FutureProvider.family
    .autoDispose<Map<String, dynamic>, String>((ref, category) async {
  return await ref
      .watch(podcastIndexProvider)
      .getPodcastsByCategory(category.toLowerCase());
});

class CategoryPage extends ConsumerWidget {
  const CategoryPage({
    super.key,
    required this.category,
  });

  final String category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final podcastDataAsyncValue =
        ref.watch(podcastDataByCategoryProvider(category));

    return podcastDataAsyncValue.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(
          title: Text(category),
        ),
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
            title: Text(category),
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
          bottomNavigationBar: SizedBox(
            height: ref.watch(openAirProvider).isPodcastSelected ? 80.0 : 0.0,
            child: ref.watch(openAirProvider).isPodcastSelected
                ? const BannerAudioPlayer()
                : const SizedBox(),
          ),
        );
      },
    );
  }
}
