import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations_plus/flutter_localizations_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/config.dart';
import 'package:openair/hive_models/fetch_data_model.dart';
import 'package:openair/providers/audio_provider.dart';
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
      await ref.watch(openAirProvider).hiveService.getTopFeaturedPodcast();

  if (topFeaturedPodcastData != null) {
    return topFeaturedPodcastData;
  }

  final apiService = ref.read(podcastIndexProvider);
  final data = await apiService.getTopPodcasts();
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

  final apiService = ref.read(podcastIndexProvider);
  final data = await apiService.getEducationPodcasts();
  return FetchDataModel.fromJson(data);
});

final podcastDataByHealthProvider = FutureProvider<FetchDataModel>((ref) async {
  final FetchDataModel? healthPodcastData =
      await ref.watch(openAirProvider).hiveService.getCategoryPodcast('Health');

  if (healthPodcastData != null) {
    return healthPodcastData;
  }

  final apiService = ref.read(podcastIndexProvider);
  final data = await apiService.getHealthPodcasts();
  return FetchDataModel.fromJson(data);
});

final podcastDataByTechnologyProvider =
    FutureProvider<FetchDataModel>((ref) async {
  final FetchDataModel? tehnologyPodcastData = await ref
      .watch(openAirProvider)
      .hiveService
      .getCategoryPodcast('Technology');

  if (tehnologyPodcastData != null) {
    return tehnologyPodcastData;
  }

  final apiService = ref.read(podcastIndexProvider);
  final data = await apiService.getTechnologyPodcasts();
  return FetchDataModel.fromJson(data);
});

final podcastDataBySportsProvider = FutureProvider<FetchDataModel>((ref) async {
  final FetchDataModel? sportsPodcastData =
      await ref.watch(openAirProvider).hiveService.getCategoryPodcast('Sports');

  if (sportsPodcastData != null) {
    return sportsPodcastData;
  }

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
                title: Translations.of(context).text('topPodcasts'),
                podcastDataProvider: podcastDataByTopProvider,
              ),
              SizedBox.fromSize(size: const Size(0, 10)),
              // Education
              PodcastsCard(
                podcastDataAsyncValue: podcastDataAsyncEducationValue,
                title: Translations.of(context).text('education'),
                podcastDataProvider: podcastDataByEducationProvider,
              ),
              SizedBox.fromSize(size: const Size(0, 10)),
              // Health
              PodcastsCard(
                podcastDataAsyncValue: podcastDataAsyncHealthValue,
                title: Translations.of(context).text('health'),
                podcastDataProvider: podcastDataByHealthProvider,
              ),
              SizedBox.fromSize(size: const Size(0, 10)),
              // Technology
              PodcastsCard(
                podcastDataAsyncValue: podcastDataAsyncTechnologyValue,
                title: Translations.of(context).text('technology'),
                podcastDataProvider: podcastDataByTechnologyProvider,
              ),
              SizedBox.fromSize(size: const Size(0, 10)),
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
      loading: () => Text(''),
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
      color: Theme.of(context).cardColor,
      elevation: cardElevation ?? 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardBottomCornersRatio),
      ),
      child: podcastDataAsyncValue.when(
        loading: () => Column(
          children: [
            ListTile(
              leading: Text(title),
              trailing: Text(Translations.of(context).text('seeAll')),
            ),
            SizedBox(
              height: featuredCardHeight,
              width: double.infinity,
              child: GridView.builder(
                itemCount: mobileItemCountPortrait,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: mobileCrossAxisCount,
                  mainAxisExtent: mobileMainAxisExtent,
                ),
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                    baseColor: Theme.of(context).cardColor,
                    highlightColor: highlightColor!,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        cardSidePadding,
                        cardTopPadding,
                        cardSidePadding,
                        cardTopPadding,
                      ),
                      child: Column(
                        children: [
                          Container(
                            color: highlightColor2,
                            height: cardImageHeight - 14.0,
                            width: cardImageWidth,
                          ),
                          Container(
                            color: highlightColor,
                            height: cardLabelHeight - 14.0,
                            width: cardLabelWidth,
                          ),
                          Container(
                            color: highlightColor,
                            height: cardLabelHeight - 14.0,
                            width: cardLabelWidth,
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
              Translations.of(context).text('oopsAnErrorOccurred'),
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              Translations.of(context).text('oopsTryAgainLater'),
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
                child: Text(Translations.of(context).text('retry')),
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
                    topLeft: Radius.circular(cardTopCornersRatio),
                    topRight: Radius.circular(cardTopCornersRatio),
                  ),
                ),
                tileColor: ThemeProvider.themeOf(context).data.primaryColor,
                leading: Text(
                  title,
                ),
                trailing: Text(
                  Translations.of(context).text('seeAll'),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        if (title ==
                            Translations.of(context).text('topPodcasts')) {
                          return TopPodcastsPage();
                        } else {
                          return CategoryPage(category: title);
                        }
                      },
                    ),
                  );
                },
              ),
              SizedBox(
                height: featuredCardHeight,
                width: double.infinity,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: mobileItemCountPortrait,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: mobileCrossAxisCount,
                    mainAxisExtent: mobileMainAxisExtent,
                  ),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                        cardSidePadding,
                        cardTopPadding,
                        cardSidePadding,
                        cardTopPadding,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          ref.read(auidoProvider).currentPodcast =
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
                                    color: cardImageShadow,
                                    blurRadius: blurRadius,
                                  )
                                ],
                              ),
                              height: cardImageHeight,
                              width: cardImageWidth,
                              child: CachedNetworkImage(
                                memCacheHeight: cardImageHeight.ceil(),
                                memCacheWidth: cardImageWidth.ceil(),
                                imageUrl: snapshot.feeds[index].artwork,
                                fit: BoxFit.fill,
                                errorWidget: (context, url, error) => Icon(
                                  Icons.error,
                                  size: 120.0,
                                ),
                              ),
                            ),
                            Container(
                              height: cardLabelHeight,
                              width: cardLabelWidth,
                              decoration: BoxDecoration(
                                color: cardLabelBackground,
                                boxShadow: [
                                  BoxShadow(
                                    color: cardLabelShadow,
                                    blurRadius: blurRadius,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(cardLabelPadding),
                                child: Text(
                                  snapshot.feeds[index].title,
                                  maxLines: cardLabelMaxLines,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: cardLabelTextColor,
                                    fontSize: cardLabelFontSize,
                                    fontWeight: cardLabelFontWeight,
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
