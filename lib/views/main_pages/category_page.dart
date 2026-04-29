import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/model/hive_models/fetch_data_model.dart';
import 'package:openair/model/hive_models/podcast_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/services/podcast_index_service.dart';
import 'package:openair/views/main_pages/episodes_page.dart';
import 'package:openair/views/widgets/podcast_card_grid.dart';

final categoryDataProvider = FutureProvider.family
    .autoDispose<FetchDataModel, String>((ref, apiKey) async {
  final hiveService = ref.read(openAirProvider).hiveService;
  final cached = await hiveService.getCategoryPodcast(apiKey);

  if (cached != null) {
    return cached;
  }

  final podcastIndexService = ref.read(podcastIndexProvider);
  final data = await podcastIndexService.getPodcastsByCategory(apiKey);
  return FetchDataModel.fromJson(data);
});

class CategoryPage extends ConsumerWidget {
  final String category;
  final String apiKey;

  const CategoryPage({
    super.key,
    required this.category,
    required this.apiKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(categoryDataProvider(apiKey));

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(categoryDataProvider(apiKey)),
          ),
        ],
      ),
      body: dataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          error: error.toString(),
          onRetry: () => ref.invalidate(categoryDataProvider(apiKey)),
        ),
        data: (data) => _buildContent(context, data),
      ),
    );
  }

  Widget _buildContent(BuildContext context, FetchDataModel data) {
    if (data.count == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.podcasts, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(Translations.of(context).text('noResults')),
          ],
        ),
      );
    }

    final isWide = wideScreenMinWidth < MediaQuery.sizeOf(context).width;

    if (isWide) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 180,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        cacheExtent: cacheExtent,
        itemCount: data.count,
        itemBuilder: (context, index) => PodcastCardGrid(
          podcastItem: data.feeds[index],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      cacheExtent: cacheExtent,
      itemCount: data.count,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _PodcastListTile(
        podcast: data.feeds[index],
        apiKey: apiKey,
      ),
    );
  }
}

class _PodcastListTile extends ConsumerWidget {
  final PodcastModel podcast;
  final String apiKey;

  const _PodcastListTile({required this.podcast, required this.apiKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          ref.read(audioProvider).currentPodcast = podcast;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EpisodesPage(podcast: podcast),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: podcast.imageUrl,
                  height: 64,
                  width: 64,
                  memCacheHeight: 128,
                  memCacheWidth: 128,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                    height: 64,
                    width: 64,
                    color: theme.cardColor,
                    child: const Icon(Icons.podcasts, size: 32),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      podcast.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  
                  ],
                ),
              ),
              FutureBuilder<bool>(
                future: ref.watch(openAirProvider).isSubscribed(podcast.title),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();

                  return IconButton(
                    icon: Icon(
                      snapshot.data!
                          ? Icons.check_circle
                          : Icons.add_circle_outline,
                      color: snapshot.data! ? theme.primaryColor : null,
                    ),
                    onPressed: () async {
                      if (snapshot.data!) {
                        ref.read(audioProvider).unsubscribe(podcast);
                      } else {
                        ref.read(audioProvider).subscribe(podcast, context);
                      }
                      ref.invalidate(categoryDataProvider(apiKey));
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              Translations.of(context).text('oopsTryAgainLater'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(Translations.of(context).text('retry')),
            ),
          ],
        ),
      ),
    );
  }
}
