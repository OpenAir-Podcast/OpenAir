import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/hive_models/fetch_data_model.dart';
import 'package:openair/providers/audio_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/services/podcast_index_service.dart';
import 'package:openair/views/main_pages/category_page.dart';
import 'package:openair/views/main_pages/episodes_page.dart';
import 'package:openair/views/main_pages/top_podcasts_page.dart';
import 'package:openair/components/no_connection.dart';
import 'package:shimmer/shimmer.dart';

const _featuredApiKeys = {
  'Top Podcasts': 'top',
  'Education': 'education',
  'Health': 'health',
  'Technology': 'technology',
  'Sports': 'sports',
};

final podcastDataByTopProvider = FutureProvider<FetchDataModel>((ref) async {
  final FetchDataModel? topFeaturedPodcastData =
      await ref.watch(openAirProvider).hiveService.getTopFeaturedPodcast();

  if (topFeaturedPodcastData != null) {
    return topFeaturedPodcastData;
  }

  final podcastIndexService = ref.read(podcastIndexProvider);
  final data = await podcastIndexService.getTopPodcasts();
  return FetchDataModel.fromJson(data);
});

// Create a FutureProvider to fetch the podcast data
final podcastDataByEducationProvider =
    FutureProvider<FetchDataModel>((ref) async {
  final FetchDataModel? educationPodcastData = await ref
      .watch(openAirProvider)
      .hiveService
      .getCategoryPodcast('Education');

  if (educationPodcastData != null) {
    return educationPodcastData;
  }

  final podcastIndexService = ref.read(podcastIndexProvider);
  final data = await podcastIndexService.getEducationPodcasts();
  return FetchDataModel.fromJson(data);
});

final podcastDataByHealthProvider = FutureProvider<FetchDataModel>((ref) async {
  final FetchDataModel? healthPodcastData =
      await ref.watch(openAirProvider).hiveService.getCategoryPodcast('Health');

  if (healthPodcastData != null) {
    return healthPodcastData;
  }

  final podcastIndexService = ref.read(podcastIndexProvider);
  final data = await podcastIndexService.getHealthPodcasts();
  return FetchDataModel.fromJson(data);
});

final podcastDataByTechnologyProvider =
    FutureProvider<FetchDataModel>((ref) async {
  final FetchDataModel? technologyPodcastData = await ref
      .watch(openAirProvider)
      .hiveService
      .getCategoryPodcast('Technology');

  if (technologyPodcastData != null) {
    return technologyPodcastData;
  }

  final podcastIndexService = ref.read(podcastIndexProvider);
  final data = await podcastIndexService.getTechnologyPodcasts();
  return FetchDataModel.fromJson(data);
});

final podcastDataBySportsProvider = FutureProvider<FetchDataModel>((ref) async {
  final FetchDataModel? sportsPodcastData =
      await ref.watch(openAirProvider).hiveService.getCategoryPodcast('Sports');

  if (sportsPodcastData != null) {
    return sportsPodcastData;
  }

  final podcastIndexService = ref.read(podcastIndexProvider);
  final data = await podcastIndexService.getSportsPodcasts();
  return FetchDataModel.fromJson(data);
});

final getConnectionStatusProvider = FutureProvider<bool>((ref) async {
  final podcastIndexService = ref.read(openAirProvider);
  return await podcastIndexService.getConnectionStatus();
});

class FeaturedPage extends ConsumerStatefulWidget {
  const FeaturedPage({super.key});

  @override
  ConsumerState<FeaturedPage> createState() => _FeaturedPageState();
}

class _FeaturedPageState extends ConsumerState<FeaturedPage> {
  @override
  Widget build(BuildContext context) {
    final getConnectionStatusValue = ref.watch(getConnectionStatusProvider);

    return getConnectionStatusValue.when(
      data: (data) {
        if (data == false) {
          return NoConnection();
        }

        final podcastDataAsyncTopValue = ref.watch(podcastDataByTopProvider);

        final podcastDataAsyncEducationValue =
            ref.watch(podcastDataByEducationProvider);

        final podcastDataAsyncHealthValue =
            ref.watch(podcastDataByHealthProvider);

        final podcastDataAsyncTechnologyValue =
            ref.watch(podcastDataByTechnologyProvider);

        final podcastDataAsyncSportsValue =
            ref.watch(podcastDataBySportsProvider);

        // Show loading while any podcast data is loading
        if (podcastDataAsyncTopValue.isLoading ||
            podcastDataAsyncEducationValue.isLoading ||
            podcastDataAsyncHealthValue.isLoading ||
            podcastDataAsyncTechnologyValue.isLoading ||
            podcastDataAsyncSportsValue.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: ListView(
            cacheExtent: 1000.0,
            children: [
              // Top Podcasts
              PodcastsCard(
                podcastDataAsyncValue: podcastDataAsyncTopValue,
                title: Translations.of(context).text('topPodcasts'),
                podcastDataProvider: podcastDataByTopProvider,
              ),
              // Education
              PodcastsCard(
                podcastDataAsyncValue: podcastDataAsyncEducationValue,
                title: Translations.of(context).text('education'),
                podcastDataProvider: podcastDataByEducationProvider,
              ),
              // Health
              PodcastsCard(
                podcastDataAsyncValue: podcastDataAsyncHealthValue,
                title: Translations.of(context).text('health'),
                podcastDataProvider: podcastDataByHealthProvider,
              ),
              // Technology
              PodcastsCard(
                podcastDataAsyncValue: podcastDataAsyncTechnologyValue,
                title: Translations.of(context).text('technology'),
                podcastDataProvider: podcastDataByTechnologyProvider,
              ),
              // Sports
              PodcastsCard(
                podcastDataAsyncValue: podcastDataAsyncSportsValue,
                title: Translations.of(context).text('sports'),
                podcastDataProvider: podcastDataBySportsProvider,
              ),
              SizedBox.fromSize(size: const Size(0, 10)),
            ],
          ),
        );
      },
      error: (error, stackTrace) => NoConnection(),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class PodcastsCard extends ConsumerWidget {
  const PodcastsCard({
    super.key,
    required this.title,
    required this.podcastDataAsyncValue,
    required this.podcastDataProvider,
  });

  final AsyncValue<FetchDataModel> podcastDataAsyncValue;
  final String title;
  final FutureProvider<FetchDataModel> podcastDataProvider;

  Widget _buildSectionHeader(BuildContext context, WidgetRef ref) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
                color: onPrimary,
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      final apiKey = _featuredApiKeys[title];
                      if (apiKey == 'top') {
                        return const TopPodcastsPage();
                      } else {
                        return CategoryPage(
                          category: title,
                          apiKey: apiKey ?? title.toLowerCase(),
                        );
                      }
                    },
                  ),
                );
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Text(
                  Translations.of(context).text('seeAll'),
                  style: TextStyle(
                    fontSize: 14.0,
                    color: onPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return podcastDataAsyncValue.when(
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, ref),
          SizedBox(
            height: cardImageHeight + 50.0, // Image + spacing + text
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: 5,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                return SizedBox(
                  width: cardImageWidth,
                  child: Shimmer.fromColors(
                    baseColor: Theme.of(context).cardColor,
                    highlightColor: highlightColor ?? Colors.grey[200]!,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: cardImageHeight,
                          width: cardImageWidth,
                          decoration: BoxDecoration(
                            color: highlightColor2 ?? Colors.grey[400]!,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Container(
                          height: 14.0,
                          width: cardImageWidth * 0.8,
                          decoration: BoxDecoration(
                            color: highlightColor ?? Colors.grey[200]!,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Container(
                          height: 14.0,
                          width: cardImageWidth * 0.5,
                          decoration: BoxDecoration(
                            color: highlightColor ?? Colors.grey[200]!,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      error: (error, stackTrace) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, ref),
          SizedBox(
            height: cardImageHeight + 50.0,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 40.0,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 12.0),
                  Text(
                    Translations.of(context).text('oopsAnErrorOccurred'),
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  SizedBox(
                    height: 36.0,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      onPressed: () async {
                        ref.invalidate(podcastDataProvider);
                      },
                      child: Text(
                        Translations.of(context).text('retry'),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      data: (snapshot) {
        final itemCount = snapshot.feeds.length > 5 ? 5 : snapshot.feeds.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, ref),
            SizedBox(
              height: 16,
            ),
            SizedBox(
              height: cardImageHeight + 64.0, // Image + title + small padding
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: itemCount,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final feed = snapshot.feeds[index];
                  return GestureDetector(
                    onTap: () {
                      ref.read(audioProvider).currentPodcast = feed;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EpisodesPage(podcast: feed),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: cardImageWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: SizedBox(
                              height: cardImageHeight,
                              width: cardImageWidth,
                              child: CachedNetworkImage(
                                memCacheHeight: cardImageHeight.ceil(),
                                memCacheWidth: cardImageWidth.ceil(),
                                imageUrl: feed.artwork,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) =>
                                    LayoutBuilder(
                                  builder: (context, constraints) {
                                    return Container(
                                      color: Colors.brown,
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.error,
                                        size: (constraints.maxWidth <
                                                    constraints.maxHeight
                                                ? constraints.maxWidth
                                                : constraints.maxHeight) *
                                            0.5,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            feed.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
