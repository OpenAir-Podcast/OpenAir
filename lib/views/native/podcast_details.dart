import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/hive_models/podcast_model.dart';
import 'package:openair/services/podcast_index_service.dart';

final podcastDetailsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, title) async {
  final podcastIndexService = ref.watch(podcastIndexProvider);
  return await podcastIndexService.getPodcastDetailsByTitle(title);
});

class PodcastDetailsPage extends ConsumerWidget {
  const PodcastDetailsPage({super.key, required this.podcast});

  final PodcastModel podcast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final podcastDetailsAsyncValue =
        ref.watch(podcastDetailsProvider(podcast.title));

    return podcastDetailsAsyncValue.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(),
        body: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
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
                  color: Brightness.dark == Theme.of(context).brightness
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              Text(
                Translations.of(context).text('oopsTryAgainLater'),
                style: TextStyle(
                  fontSize: 16.0,
                  color: Brightness.dark == Theme.of(context).brightness
                      ? Colors.white
                      : Colors.black,
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
                    ref.invalidate(podcastDetailsProvider(podcast.title));
                  },
                  child: Text(
                    Translations.of(context).text('retry'),
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Brightness.dark == Theme.of(context).brightness
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      data: (snapshot) {
        final feed = snapshot['feeds'][0];

        return Scaffold(
          appBar: AppBar(
            title: Text(podcast.title),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CachedNetworkImage(
                        imageUrl: feed['image'],
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              feed['title'],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              feed['author'],
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${feed['episodeCount']} episodes',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    feed['description'],
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Website: ${feed['link']}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Language: ${feed['language']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Medium: ${feed['medium']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Categories: ${feed['categories'].values.join(', ')}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Last Update: ${DateTime.fromMillisecondsSinceEpoch(feed['lastUpdateTime'] * 1000)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
