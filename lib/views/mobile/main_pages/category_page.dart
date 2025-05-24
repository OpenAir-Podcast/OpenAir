import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/podcast_index_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/mobile/player/banner_audio_player.dart';
import 'package:openair/views/mobile/widgets/podcast_card.dart';

// Create a FutureProvider to fetch the podcast data
final podcastDataByCategoryProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, category) async {
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
      error: (error, stackTrace) => Text('Error: $error'),
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
