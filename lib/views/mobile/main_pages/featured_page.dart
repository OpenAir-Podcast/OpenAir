import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/scale.dart';
import 'package:openair/providers/podcast_index_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/mobile/main_pages/episodes_page.dart';
import 'package:openair/views/mobile/main_pages/top_podcasts_page.dart';
import 'package:openair/components/no_connection.dart';
import 'package:shimmer/shimmer.dart';

bool once = false;

final podcastDataByTopProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final apiService = ref.read(podcastIndexProvider);
  return await apiService.getTopPodcasts();
});

// Create a FutureProvider to fetch the podcast data
final podcastDataByEducationProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final apiService = ref.read(podcastIndexProvider);
  return await apiService.getEducationPodcasts();
});

final podcastDataByHealthProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final apiService = ref.read(podcastIndexProvider);
  return await apiService.getHealthPodcasts();
});

final podcastDataByTechnologyProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final apiService = ref.read(podcastIndexProvider);
  return await apiService.getTechnologyPodcasts();
});

final podcastDataBySportsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final apiService = ref.read(podcastIndexProvider);
  return await apiService.getSportsPodcasts();
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
  void initState() {
    super.initState();
    if (once == false) {
      // Initialize the provider
      ref.read(openAirProvider).initial(
            context,
          );

      once = true;
    }
  }

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

        return Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 4.0),
          child: ListView(
            cacheExtent: 1000.0,
            children: [
              // Top Podcasts
              PodcastsCard(
                  podcastDataAsyncValue: podcastDataAsyncTopValue,
                  title: 'Top Podcasts'),
              SizedBox.fromSize(size: const Size(0, 10)),
              // Education
              PodcastsCard(
                podcastDataAsyncValue: podcastDataAsyncEducationValue,
                title: 'Education',
              ),
              SizedBox.fromSize(size: const Size(0, 10)),
              // Health
              PodcastsCard(
                podcastDataAsyncValue: podcastDataAsyncHealthValue,
                title: 'Health',
              ),
              SizedBox.fromSize(size: const Size(0, 10)),
              // Technology
              PodcastsCard(
                podcastDataAsyncValue: podcastDataAsyncTechnologyValue,
                title: 'Technology',
              ),
              SizedBox.fromSize(size: const Size(0, 10)),
              // Sports
              PodcastsCard(
                podcastDataAsyncValue: podcastDataAsyncSportsValue,
                title: 'Sports',
              ),
              SizedBox.fromSize(size: const Size(0, 10)),
            ],
          ),
        );
      },
      error: (error, stackTrace) => Center(child: Text(error.toString())),
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
  });

  final AsyncValue<Map<String, dynamic>> podcastDataAsyncValue;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: cardBackgroundColor,
      elevation: cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardBottomCornersRatio),
      ),
      child: podcastDataAsyncValue.when(
        loading: () => Column(
          children: [
            ListTile(
              leading: Text(title),
              trailing: const Text('See All'),
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
                    baseColor: cardBackgroundColor!,
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
        error: (error, stackTrace) => Text('Error: $error'),
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
                tileColor: cardHeaderColor,
                leading: Text(
                  title,
                  style: TextStyle(color: cardHeaderTextColor),
                ),
                trailing: Text(
                  'See All',
                  style: TextStyle(color: cardHeaderTextColor),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TopPodcastsPage(),
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
                          ref.read(openAirProvider.notifier).currentPodcast =
                              snapshot['feeds'][index];

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EpisodesPage(
                                podcast: snapshot['feeds'][index],
                                id: snapshot['feeds'][index]['id'],
                              ),
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
                                image: DecorationImage(
                                  fit: BoxFit.fill,
                                  image: CachedNetworkImageProvider(
                                    snapshot['feeds'][index]['image'],
                                  ),
                                ),
                              ),
                              height: cardImageHeight,
                              width: cardImageWidth,
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
                                  snapshot['feeds'][index]['title'],
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
