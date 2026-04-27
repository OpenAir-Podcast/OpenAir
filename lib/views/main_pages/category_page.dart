import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/hive_models/fetch_data_model.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/services/podcast_index_service.dart';
import 'package:openair/views/widgets/podcast_card_grid.dart';
import 'package:openair/views/widgets/podcast_card_list.dart';

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
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          childAspectRatio: 3 / 4,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        cacheExtent: cacheExtent,
        itemCount: data.count,
        itemBuilder: (context, index) => PodcastCardGrid(
          podcastItem: data.feeds[index],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      cacheExtent: cacheExtent,
      itemCount: data.count,
      itemBuilder: (context, index) => PodcastCardList(
        podcastItem: data.feeds[index],
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
