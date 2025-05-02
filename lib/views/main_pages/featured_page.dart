import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/providers/api_service_provider.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/views/main_pages/category_page.dart';
import 'package:openair/views/main_pages/episodes_page.dart';
import 'package:openair/views/main_pages/top_podcasts_page.dart';
import 'package:shimmer/shimmer.dart';

bool once = false;

final podcastDataByTopProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getTopPodcasts();
});

// Create a FutureProvider to fetch the podcast data
final podcastDataByEducationProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getEducationPodcasts();
});

final podcastDataByHealthProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getHealthPodcasts();
});

final podcastDataByTechnologyProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getTechnologyPodcasts();
});

final podcastDataBySportsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getSportsPodcasts();
});

class FeaturedPage extends ConsumerWidget {
  const FeaturedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Run once to initialize the provider
    if (once == false) {
      // Initialize the provider
      ref.read(openAirProvider).initial(
            context,
          );
      once = true;
    }

    final podcastDataAsyncTopValue = ref.watch(podcastDataByTopProvider);

    final podcastDataAsyncEducationValue =
        ref.watch(podcastDataByEducationProvider);

    final podcastDataAsyncHealthValue = ref.watch(podcastDataByHealthProvider);

    final podcastDataAsyncTechnologyValue =
        ref.watch(podcastDataByTechnologyProvider);

    final podcastDataAsyncSportsValue = ref.watch(podcastDataBySportsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 4.0),
      child: ListView(
        children: [
          // Top Podcasts
          TopPodcastsCard(podcastDataAsyncTopValue: podcastDataAsyncTopValue),
          SizedBox.fromSize(size: const Size(0, 10)),
          // Education
          EducationCard(
              podcastDataAsyncEducationValue: podcastDataAsyncEducationValue),
          SizedBox.fromSize(size: const Size(0, 10)),
          // Health
          HealthCard(podcastDataAsyncHealthValue: podcastDataAsyncHealthValue),
          SizedBox.fromSize(size: const Size(0, 10)),
          // Technology
          TechnologyCard(
              podcastDataAsyncTechnologyValue: podcastDataAsyncTechnologyValue),
          SizedBox.fromSize(size: const Size(0, 10)),
          // Sports
          SportsCard(podcastDataAsyncSportsValue: podcastDataAsyncSportsValue),
        ],
      ),
    );
  }
}

class TopPodcastsCard extends ConsumerWidget {
  const TopPodcastsCard({
    super.key,
    required this.podcastDataAsyncTopValue,
  });

  final AsyncValue<Map<String, dynamic>> podcastDataAsyncTopValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: Colors.blueGrey[100],
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: podcastDataAsyncTopValue.when(
        loading: () => Column(
          children: [
            ListTile(
              leading: const Text('Top Podcasts'),
              trailing: const Text('See All'),
              onTap: () {},
            ),
            SizedBox(
              height: 190.0,
              width: double.infinity,
              child: GridView.builder(
                itemCount: 3,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisExtent: 180.0,
                ),
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Column(
                        children: [
                          Container(
                            color: Colors.grey[400]!,
                            height: 130.0,
                            width: 100.0,
                          ),
                          Container(
                            color: Colors.grey[100]!,
                            height: 40.0,
                            width: 100.0,
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
                    topLeft: Radius.circular(12.0),
                    topRight: Radius.circular(12.0),
                  ),
                ),
                tileColor: Colors.blue,
                leading: const Text(
                  'Top Podcasts',
                  style: TextStyle(color: Colors.white),
                ),
                trailing: const Text(
                  'See All',
                  style: TextStyle(color: Colors.white),
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
                height: 190.0,
                width: double.infinity,
                child: GridView.builder(
                  itemCount: 3,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisExtent: 180.0,
                  ),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: GestureDetector(
                        onTap: () {
                          ref.read(openAirProvider.notifier).currentPodcast =
                              snapshot['feeds'][index];

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EpisodesPage(),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 5.0, // soften the shadow
                                  )
                                ],
                                image: DecorationImage(
                                  fit: BoxFit.fill,
                                  // scale: 2,
                                  image: CachedNetworkImageProvider(
                                    snapshot['feeds'][index]['image'],
                                  ),
                                ),
                              ),
                              height: 130.0,
                              width: 100.0,
                            ),
                            Container(
                              height: 40.0,
                              width: 100.0,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 5.0,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  snapshot['feeds'][index]['title'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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

class EducationCard extends ConsumerWidget {
  const EducationCard({
    super.key,
    required this.podcastDataAsyncEducationValue,
  });

  final AsyncValue<Map<String, dynamic>> podcastDataAsyncEducationValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: Colors.blueGrey[100],
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: podcastDataAsyncEducationValue.when(
        loading: () => Column(
          children: [
            ListTile(
              leading: const Text('Education'),
              trailing: const Text('See All'),
            ),
            SizedBox(
              height: 190.0,
              width: double.infinity,
              child: GridView.builder(
                itemCount: 3,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisExtent: 180.0,
                ),
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Column(
                        children: [
                          Container(
                            color: Colors.grey[400]!,
                            height: 130.0,
                            width: 100.0,
                          ),
                          Container(
                            color: Colors.grey[100]!,
                            height: 40.0,
                            width: 100.0,
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
                    topLeft: Radius.circular(12.0),
                    topRight: Radius.circular(12.0),
                  ),
                ),
                tileColor: Colors.blue,
                leading: const Text(
                  'Education',
                  style: TextStyle(color: Colors.white),
                ),
                trailing: const Text(
                  'See All',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CategoryPage(
                        category: 'Education',
                      ),
                    ),
                  );
                },
              ),
              SizedBox(
                height: 190.0,
                width: double.infinity,
                child: GridView.builder(
                  itemCount: 3,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisExtent: 180.0,
                  ),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: GestureDetector(
                        onTap: () {
                          ref.read(openAirProvider.notifier).currentPodcast =
                              snapshot['feeds'][index];

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EpisodesPage(),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 5.0, // soften the shadow
                                  )
                                ],
                                image: DecorationImage(
                                  fit: BoxFit.fill,
                                  // scale: 2,
                                  image: CachedNetworkImageProvider(
                                    snapshot['feeds'][index]['image'],
                                  ),
                                ),
                              ),
                              height: 130.0,
                              width: 100.0,
                            ),
                            Container(
                              height: 40.0,
                              width: 100.0,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 5.0,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  snapshot['feeds'][index]['title'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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

class HealthCard extends ConsumerWidget {
  const HealthCard({
    super.key,
    required this.podcastDataAsyncHealthValue,
  });

  final AsyncValue<Map<String, dynamic>> podcastDataAsyncHealthValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: Colors.blueGrey[100],
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: podcastDataAsyncHealthValue.when(
        loading: () => Column(
          children: [
            ListTile(
              leading: const Text('Health'),
              trailing: const Text('See All'),
            ),
            SizedBox(
              height: 190.0,
              width: double.infinity,
              child: GridView.builder(
                itemCount: 3,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisExtent: 180.0,
                ),
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Column(
                        children: [
                          Container(
                            color: Colors.grey[400]!,
                            height: 130.0,
                            width: 100.0,
                          ),
                          Container(
                            color: Colors.grey[100]!,
                            height: 40.0,
                            width: 100.0,
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
                    topLeft: Radius.circular(12.0),
                    topRight: Radius.circular(12.0),
                  ),
                ),
                tileColor: Colors.blue,
                leading: const Text(
                  'Health',
                  style: TextStyle(color: Colors.white),
                ),
                trailing: const Text(
                  'See All',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CategoryPage(
                        category: 'Health',
                      ),
                    ),
                  );
                },
              ),
              SizedBox(
                height: 190.0,
                width: double.infinity,
                child: GridView.builder(
                  itemCount: 3,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisExtent: 180.0,
                  ),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: GestureDetector(
                        onTap: () {
                          ref.read(openAirProvider.notifier).currentPodcast =
                              snapshot['feeds'][index];

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EpisodesPage(),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 5.0, // soften the shadow
                                  )
                                ],
                                image: DecorationImage(
                                  fit: BoxFit.fill,
                                  // scale: 2,
                                  image: CachedNetworkImageProvider(
                                    snapshot['feeds'][index]['image'],
                                  ),
                                ),
                              ),
                              height: 130.0,
                              width: 100.0,
                            ),
                            Container(
                              height: 40.0,
                              width: 100.0,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 5.0,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  snapshot['feeds'][index]['title'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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

class TechnologyCard extends ConsumerWidget {
  const TechnologyCard({
    super.key,
    required this.podcastDataAsyncTechnologyValue,
  });

  final AsyncValue<Map<String, dynamic>> podcastDataAsyncTechnologyValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: Colors.blueGrey[100],
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: podcastDataAsyncTechnologyValue.when(
        loading: () => Column(
          children: [
            ListTile(
              leading: const Text('Technology'),
              trailing: const Text('See All'),
            ),
            SizedBox(
              height: 190.0,
              width: double.infinity,
              child: GridView.builder(
                itemCount: 3,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisExtent: 180.0,
                ),
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Column(
                        children: [
                          Container(
                            color: Colors.grey[400]!,
                            height: 130.0,
                            width: 100.0,
                          ),
                          Container(
                            color: Colors.grey[100]!,
                            height: 40.0,
                            width: 100.0,
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
                    topLeft: Radius.circular(12.0),
                    topRight: Radius.circular(12.0),
                  ),
                ),
                tileColor: Colors.blue,
                leading: const Text(
                  'Technology',
                  style: TextStyle(color: Colors.white),
                ),
                trailing: const Text(
                  'See All',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CategoryPage(
                        category: 'Technology',
                      ),
                    ),
                  );
                },
              ),
              SizedBox(
                height: 190.0,
                width: double.infinity,
                child: GridView.builder(
                  itemCount: 3,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisExtent: 180.0,
                  ),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: GestureDetector(
                        onTap: () {
                          ref.read(openAirProvider.notifier).currentPodcast =
                              snapshot['feeds'][index];

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EpisodesPage(),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 5.0, // soften the shadow
                                  )
                                ],
                                image: DecorationImage(
                                  fit: BoxFit.fill,
                                  // scale: 2,
                                  image: CachedNetworkImageProvider(
                                    snapshot['feeds'][index]['image'],
                                  ),
                                ),
                              ),
                              height: 130.0,
                              width: 100.0,
                            ),
                            Container(
                              height: 40.0,
                              width: 100.0,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 5.0,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  snapshot['feeds'][index]['title'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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

class SportsCard extends ConsumerWidget {
  const SportsCard({
    super.key,
    required this.podcastDataAsyncSportsValue,
  });

  final AsyncValue<Map<String, dynamic>> podcastDataAsyncSportsValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: Colors.blueGrey[100],
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: podcastDataAsyncSportsValue.when(
        loading: () => Column(
          children: [
            ListTile(
              leading: const Text('Sports'),
              trailing: const Text('See All'),
            ),
            SizedBox(
              height: 190.0,
              width: double.infinity,
              child: GridView.builder(
                itemCount: 3,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisExtent: 180.0,
                ),
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Column(
                        children: [
                          Container(
                            color: Colors.grey[400]!,
                            height: 130.0,
                            width: 100.0,
                          ),
                          Container(
                            color: Colors.grey[100]!,
                            height: 40.0,
                            width: 100.0,
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
                    topLeft: Radius.circular(12.0),
                    topRight: Radius.circular(12.0),
                  ),
                ),
                tileColor: Colors.blue,
                leading: const Text(
                  'Sports',
                  style: TextStyle(color: Colors.white),
                ),
                trailing: const Text(
                  'See All',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CategoryPage(
                        category: 'Sports',
                      ),
                    ),
                  );
                },
              ),
              SizedBox(
                height: 190.0,
                width: double.infinity,
                child: GridView.builder(
                  itemCount: 3,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisExtent: 180.0,
                  ),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: GestureDetector(
                        onTap: () {
                          ref.read(openAirProvider.notifier).currentPodcast =
                              snapshot['feeds'][index];

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EpisodesPage(),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 5.0, // soften the shadow
                                  )
                                ],
                                image: DecorationImage(
                                  fit: BoxFit.fill,
                                  // scale: 2,
                                  image: CachedNetworkImageProvider(
                                    snapshot['feeds'][index]['image'],
                                  ),
                                ),
                              ),
                              height: 130.0,
                              width: 100.0,
                            ),
                            Container(
                              height: 40.0,
                              width: 100.0,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 5.0,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  snapshot['feeds'][index]['title'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
