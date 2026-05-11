export 'package:openair/views/main_pages/trending_page.dart'
    show trendingDataProvider;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/translations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/model/hive_models/fetch_data_model.dart';
import 'package:openair/providers/locale_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/services/podcast_index_service.dart';
import 'package:openair/components/no_connection.dart';
import 'package:openair/views/widgets/podcast_card_grid.dart';
import 'package:openair/views/widgets/podcast_card_list.dart';

final trendingDataProvider =
    FutureProvider.autoDispose<FetchDataModel>((ref) async {
  final hiveService = ref.watch(openAirProvider).hiveService;
  final cachedData = await hiveService.getTrendingPodcast();

  if (cachedData != null) {
    return cachedData;
  }

  debugPrint('Fetching trending podcasts from API');
  final podcastIndexAPI = ref.read(podcastIndexProvider);
  final data = await podcastIndexAPI.getTrendingPodcasts();
  final fetchData = FetchDataModel.fromJson(data);

  hiveService.putTrendingPodcast(data);

  return fetchData;
});

class TrendingPage extends ConsumerWidget {
  const TrendingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionAsync = ref.watch(connectionCheckProvider);

    return connectionAsync.when(
        loading: () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
        error: (_, __) => const TrendingPage(),
        data: (isConnected) {
          if (isConnected == false) {
            return const NoConnection();
          }

          ref.watch(localeProvider); // Ensure rebuild on language change
          final trendingAsync = ref.watch(trendingDataProvider);

          return trendingAsync.when(
            loading: () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stackTrace) => Scaffold(
              appBar: AppBar(
                  title: Text(Translations.of(context).text('trending'))),
              body: _ErrorView(
                error: error.toString(),
                onRetry: () => ref.invalidate(trendingDataProvider),
              ),
            ),
            data: (data) => _TrendingView(data: data),
          );
        });
  }
}

class _TrendingView extends ConsumerWidget {
  final FetchDataModel data;

  const _TrendingView({required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: data.count == 0
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.podcasts, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(Translations.of(context).text('noResults')),
                ],
              ),
            )
          : _buildPodcastList(context),
    );
  }

  Widget _buildPodcastList(BuildContext context) {
    final isWide = wideScreenMinWidth < MediaQuery.sizeOf(context).width;

    if (isWide) {
      final isDesktop = !Platform.isAndroid && !Platform.isIOS;
      final spacing = isDesktop ? 16.0 : 4.0;
      return GridView.builder(
        padding: EdgeInsets.all(isDesktop ? 24 : 8),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          childAspectRatio: 3 / 4,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
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

final connectionCheckProvider = FutureProvider.autoDispose<bool>((ref) async {
  final openAir = ref.read(openAirProvider);
  return await openAir.getConnectionStatus();
});
