import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/models/fetch_data_model.dart';
import 'package:openair/providers/hive_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/services/podcast_index_provider.dart';
import 'package:openair/views/mobile/main_pages/category_page.dart';
import 'package:openair/views/mobile/main_pages/episodes_page.dart';
import 'package:openair/views/mobile/main_pages/top_podcasts_page.dart';
import 'package:openair/components/no_connection.dart';
import 'package:shimmer/shimmer.dart';
import 'package:theme_provider/theme_provider.dart';

// Add a button to refresh data

final podcastDataByTopProvider = FutureProvider<FetchDataModel>((ref) async {
  final FetchDataModel? topFeaturedPodcastData =
      await ref.read(hiveServiceProvider).getTopFeaturedPodcast();

  // debugPrint(topFeaturedPodcastData.toString());

  if (topFeaturedPodcastData != null) {
    return topFeaturedPodcastData;
  }

  debugPrint('Fetching podcasts from Podcast Index');

  final apiService = ref.read(podcastIndexProvider);
  final data = await apiService.getTopPodcasts();
  return FetchDataModel.fromJson(data);
});

// Create a FutureProvider to fetch the podcast data
final podcastDataByEducationProvider =
    FutureProvider<FetchDataModel>((ref) async {
  final FetchDataModel? educationPodcastData =
      await ref.read(hiveServiceProvider).getCategoryPodcast('Education');

  if (educationPodcastData != null) {
    return educationPodcastData;
  }

  final apiService = ref.read(podcastIndexProvider);
  final data = await apiService.getEducationPodcasts();
  return FetchDataModel.fromJson(data);
});

final podcastDataByHealthProvider = FutureProvider<FetchDataModel>((ref) async {
  final FetchDataModel? healthPodcastData =
      await ref.read(hiveServiceProvider).getCategoryPodcast('Health');

  if (healthPodcastData != null) {
    return healthPodcastData;
  }

  debugPrint('Fetching podcasts from Podcast Index');

  final apiService = ref.read(podcastIndexProvider);
  final data = await apiService.getHealthPodcasts();
  return FetchDataModel.fromJson(data);
});

final podcastDataByTechnologyProvider =
    FutureProvider<FetchDataModel>((ref) async {
  final FetchDataModel? tehnologyPodcastData =
      await ref.read(hiveServiceProvider).getCategoryPodcast('Technology');

  if (tehnologyPodcastData != null) {
    return tehnologyPodcastData;
  }

  debugPrint('Fetching podcasts from Podcast Index');

  final apiService = ref.read(podcastIndexProvider);
  final data = await apiService.getTechnologyPodcasts();
  return FetchDataModel.fromJson(data);
});

final podcastDataBySportsProvider = FutureProvider<FetchDataModel>((ref) async {
  final FetchDataModel? sportsPodcastData =
      await ref.read(hiveServiceProvider).getCategoryPodcast('Sports');

  if (sportsPodcastData != null) {
    return sportsPodcastData;
  }

  debugPrint('Fetching podcasts from Podcast Index');

  final apiService = ref.read(podcastIndexProvider);
  final data = await apiService.getSportsPodcasts();
  return FetchDataModel.fromJson(data);
});

final getConnectionStatusProvider = FutureProvider<bool>((ref) async {
  final apiService = ref.read(openAirProvider);
  return await apiService.getConnectionStatus();
});

class FeaturedPage extends ConsumerStatefulWidget {
  const FeaturedPage({super.key});

  @override
  ConsumerState<FeaturedPage> createState() => _FeaturedPageState();
}

class _FeaturedPageState extends ConsumerState<FeaturedPage>
    with AutomaticKeepAliveClientMixin<FeaturedPage> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Important for AutomaticKeepAliveClientMixin
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

        if (podcastDataAsyncTopValue.hasError) {
          return Container(
            color: Colors.white,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 4.0),
          child: ListView(
            cacheExtent: 1000.0,
            children: [
              // Top Podcasts
              PodcastsCard(
                podcastDataAsyncValue: podcastDataAsyncTopValue,
                title: 'Top Podcasts',
                podcastDataProvider: podcastDataByTopProvider,
              ),
              SizedBox.fromSize(size: const Size(0, 10)),
              // Education
              PodcastsCard(
                podcastDataAsyncValue: podcastDataAsyncEducationValue,
                title: 'Education',
                podcastDataProvider: podcastDataByEducationProvider,
              ),
              SizedBox.fromSize(size: const Size(0, 10)),
              // Health
              PodcastsCard(
                podcastDataAsyncValue: podcastDataAsyncHealthValue,
                title: 'Health',
                podcastDataProvider: podcastDataByHealthProvider,
              ),
              SizedBox.fromSize(size: const Size(0, 10)),
              // Technology
              PodcastsCard(
                podcastDataAsyncValue: podcastDataAsyncTechnologyValue,
                title: 'Technology',
                podcastDataProvider: podcastDataByTechnologyProvider,
              ),
              SizedBox.fromSize(size: const Size(0, 10)),
              // Sports
              PodcastsCard(
                podcastDataAsyncValue: podcastDataAsyncSportsValue,
                title: 'Sports',
                podcastDataProvider: podcastDataBySportsProvider,
              ),
              SizedBox.fromSize(size: const Size(0, 10)),
            ],
          ),
        );
      },
      error: (error, stackTrace) => NoConnection(),
      loading: () => Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: ref.read(openAirProvider).config.cardBackgroundColor,
      elevation: ref.read(openAirProvider).config.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
            ref.read(openAirProvider).config.cardBottomCornersRatio),
      ),
      child: podcastDataAsyncValue.when(
        loading: () => Column(
          children: [
            ListTile(
              leading: Text(title),
              trailing: const Text('See All'),
            ),
            SizedBox(
              height: ref.read(openAirProvider).config.featuredCardHeight,
              width: double.infinity,
              child: GridView.builder(
                itemCount:
                    ref.read(openAirProvider).config.mobileItemCountPortrait,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      ref.read(openAirProvider).config.mobileCrossAxisCount,
                  mainAxisExtent:
                      ref.read(openAirProvider).config.mobileMainAxisExtent,
                ),
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                    baseColor:
                        ref.read(openAirProvider).config.cardBackgroundColor!,
                    highlightColor:
                        ref.read(openAirProvider).config.highlightColor!,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        ref.read(openAirProvider).config.cardSidePadding,
                        ref.read(openAirProvider).config.cardTopPadding,
                        ref.read(openAirProvider).config.cardSidePadding,
                        ref.read(openAirProvider).config.cardTopPadding,
                      ),
                      child: Column(
                        children: [
                          Container(
                            color: ref
                                .read(openAirProvider)
                                .config
                                .highlightColor2,
                            height: ref
                                    .read(openAirProvider)
                                    .config
                                    .cardImageHeight -
                                14.0,
                            width:
                                ref.read(openAirProvider).config.cardImageWidth,
                          ),
                          Container(
                            color:
                                ref.read(openAirProvider).config.highlightColor,
                            height: ref
                                    .read(openAirProvider)
                                    .config
                                    .cardLabelHeight -
                                14.0,
                            width:
                                ref.read(openAirProvider).config.cardLabelWidth,
                          ),
                          Container(
                            color:
                                ref.read(openAirProvider).config.highlightColor,
                            height: ref
                                    .read(openAirProvider)
                                    .config
                                    .cardLabelHeight -
                                14.0,
                            width:
                                ref.read(openAirProvider).config.cardLabelWidth,
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
                  ref.invalidate(podcastDataProvider);
                },
                child: const Text('Retry'),
              ),
            ),
          ],
        ),
        data: (snapshot) {
          return Column(
            children: [
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(
                        ref.read(openAirProvider).config.cardTopCornersRatio),
                    topRight: Radius.circular(
                        ref.read(openAirProvider).config.cardTopCornersRatio),
                  ),
                ),
                tileColor: ThemeProvider.themeOf(context).data.primaryColor,
                leading: Text(
                  title,
                ),
                trailing: Text(
                  'See All',
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        if (title == 'Top Podcasts') {
                          return TopPodcastsPage();
                        }

                        return CategoryPage(
                          category: title,
                        );
                      },
                    ),
                  );
                },
              ),
              SizedBox(
                height: ref.read(openAirProvider).config.featuredCardHeight,
                width: double.infinity,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount:
                      ref.read(openAirProvider).config.mobileItemCountPortrait,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        ref.read(openAirProvider).config.mobileCrossAxisCount,
                    mainAxisExtent:
                        ref.read(openAirProvider).config.mobileMainAxisExtent,
                  ),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                        ref.read(openAirProvider).config.cardSidePadding,
                        ref.read(openAirProvider).config.cardTopPadding,
                        ref.read(openAirProvider).config.cardSidePadding,
                        ref.read(openAirProvider).config.cardTopPadding,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          ref.read(openAirProvider).currentPodcast =
                              snapshot.feeds[index];

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  EpisodesPage(podcast: snapshot.feeds[index]),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: ref
                                        .read(openAirProvider)
                                        .config
                                        .cardImageShadow,
                                    blurRadius: ref
                                        .read(openAirProvider)
                                        .config
                                        .blurRadius,
                                  )
                                ],
                              ),
                              height: ref
                                  .read(openAirProvider)
                                  .config
                                  .cardImageHeight,
                              width: ref
                                  .read(openAirProvider)
                                  .config
                                  .cardImageWidth,
                              child: CachedNetworkImage(
                                memCacheHeight: ref
                                    .read(openAirProvider)
                                    .config
                                    .cardImageHeight
                                    .ceil(),
                                memCacheWidth: ref
                                    .read(openAirProvider)
                                    .config
                                    .cardImageWidth
                                    .ceil(),
                                imageUrl: snapshot.feeds[index].artwork,
                                fit: BoxFit.fill,
                                errorWidget: (context, url, error) => Icon(
                                  Icons.error,
                                  size: 120.0,
                                ),
                              ),
                            ),
                            Container(
                              height: ref
                                  .read(openAirProvider)
                                  .config
                                  .cardLabelHeight,
                              width: ref
                                  .read(openAirProvider)
                                  .config
                                  .cardLabelWidth,
                              decoration: BoxDecoration(
                                color: ref
                                    .read(openAirProvider)
                                    .config
                                    .cardLabelBackground,
                                boxShadow: [
                                  BoxShadow(
                                    color: ref
                                        .read(openAirProvider)
                                        .config
                                        .cardLabelShadow,
                                    blurRadius: ref
                                        .read(openAirProvider)
                                        .config
                                        .blurRadius,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(ref
                                    .read(openAirProvider)
                                    .config
                                    .cardLabelPadding),
                                child: Text(
                                  snapshot.feeds[index].title,
                                  maxLines: ref
                                      .read(openAirProvider)
                                      .config
                                      .cardLabelMaxLines,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: ref
                                        .read(openAirProvider)
                                        .config
                                        .cardLabelTextColor,
                                    fontSize: ref
                                        .read(openAirProvider)
                                        .config
                                        .cardLabelFontSize,
                                    fontWeight: ref
                                        .read(openAirProvider)
                                        .config
                                        .cardLabelFontWeight,
                                  ),
                                ),
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
      ),
    );
  }
}
