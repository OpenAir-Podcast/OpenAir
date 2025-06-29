import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openair/config/scale.dart';
import 'package:openair/providers/openair_provider.dart';
import 'package:openair/services/fyyd_provider.dart';
import 'package:openair/views/mobile/main_pages/discovery_page.dart';
import 'package:openair/views/mobile/main_pages/episodes_page.dart';
import 'package:openair/views/mobile/player/banner_audio_player.dart';
import 'package:shimmer/shimmer.dart';
import 'package:webfeed_plus/domain/rss_feed.dart';

final podcastDataFeaturedProvider = FutureProvider<List<dynamic>>((ref) async {
  final apiService = ref.read(fyydProvider);
  return await apiService.getFeaturedPodcasts();
});

class AddPodcast extends ConsumerStatefulWidget {
  const AddPodcast({super.key});

  @override
  ConsumerState createState() => _AddPodcastState();
}

class _AddPodcastState extends ConsumerState<AddPodcast> {
  @override
  Widget build(BuildContext context) {
    final podcastDataAsyncValue = ref.watch(podcastDataFeaturedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Podcast'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              keyboardType: TextInputType.webSearch,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                icon: Icon(
                  Icons.search_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                labelText: 'Search Podcast (fyyd)',
              ),
            ),
            SizedBox(height: 15),
            podcastDataAsyncValue.when(
              loading: () {
                return SizedBox(
                  height: 336,
                  child: GridView.builder(
                    itemCount: 12,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisExtent: 100.0,
                      crossAxisSpacing: 12.0,
                      mainAxisSpacing: 12.0,
                    ),
                    itemBuilder: (context, index) {
                      return Shimmer.fromColors(
                        baseColor: cardBackgroundColor!,
                        highlightColor: highlightColor!,
                        child: Container(
                          color: highlightColor,
                        ),
                      );
                    },
                  ),
                );
              },
              error: (error, stackTrace) {
                debugPrint('$error');

                return Center(
                  child: Column(
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
                            ref.invalidate(podcastDataFeaturedProvider);
                          },
                          child: const Text('Retry'),
                        ),
                      ),
                    ],
                  ),
                );
              },
              data: (snapshot) {
                return Column(
                  children: [
                    SizedBox(
                      height: 336,
                      child: GridView.builder(
                        itemCount: 12,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisExtent: 100.0,
                          crossAxisSpacing: 12.0,
                          mainAxisSpacing: 12.0,
                        ),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () async {
                              final xmlString = await ref
                                  .watch(fyydProvider)
                                  .getPodcastXml(snapshot[index]['xmlURL']);

                              var rssFeed = RssFeed.parse(xmlString);

                              Map<String, dynamic> podcast = {
                                'id': snapshot[index]['id'],
                                'url': snapshot[index]['xmlURL'],
                                'title': rssFeed.title,
                                'description': rssFeed.description,
                                'author': rssFeed.author,
                                'image': snapshot[index]['imgURL'],
                                'artwork': snapshot[index]['imgURL'],
                                'newestItemPublishTime': rssFeed.items!.first
                                        .pubDate!.millisecondsSinceEpoch ~/
                                    1000,
                                'language': rssFeed.language,
                                'categories': {
                                  for (var category in rssFeed.categories!)
                                    category.hashCode: category
                                },
                              };

                              ref.read(openAirProvider).currentPodcast =
                                  podcast;

                              if (context.mounted) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => EpisodesPage(
                                      podcast: podcast,
                                      id: podcast['id'],
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Container(
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
                                imageUrl: snapshot[index]['imgURL'],
                                fit: BoxFit.fill,
                                errorWidget: (context, url, error) => Icon(
                                  Icons.error,
                                  size: 120.0,
                                ),
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
            Row(
              children: [
                Text(
                  'Discovery Powered by fyyd',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                const Spacer(),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Discover More',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      Icon(
                        Icons.double_arrow_rounded,
                        color: Colors.blue,
                        size: 20.0,
                      ),
                    ],
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiscoveryPage(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            ListTile(
              leading: Icon(
                Icons.rss_feed_rounded,
                size: 36.0,
              ),
              title: Text(
                'Add podcast by RSS URL',
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              onTap: () => showDialog(
                context: context,
                builder: (context) {
                  TextEditingController textInputControl =
                      TextEditingController();

                  return AlertDialog(
                    insetPadding: EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: MediaQuery.of(context).size.height * 0.2,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.sizeOf(context).width * 0.05,
                      vertical: 15.0,
                    ),
                    titlePadding: const EdgeInsets.symmetric(
                        horizontal: 100.0, vertical: 15.0),
                    title: Text(
                      'Add podcast by RSS URL',
                      textAlign: TextAlign.start,
                    ),
                    content: TextField(
                      autofocus: true,
                      controller: textInputControl,
                      keyboardType: TextInputType.url,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        icon: Icon(
                          Icons.link_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        labelText: 'RSS URL',
                      ),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextButton(
                          onPressed: () async {
                            Navigator.pop(context);

                            if (textInputControl.text.isEmpty) {
                              return;
                            }

                            ref
                                .watch(openAirProvider)
                                .addPodcastByRssUrl(textInputControl.text);
                          },
                          child: const Text(
                            'Add',
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            ListTile(
              leading: Icon(
                Icons.search_rounded,
                size: 36.0,
              ),
              title: Text(
                'Search Podcast Index',
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              onTap: () => debugPrint(
                'Add podcast by RSS URL',
              ),
            ),
            SizedBox(height: 10),
            ListTile(
              leading: Icon(
                Icons.file_download_outlined,
                size: 36.0,
              ),
              title: Text(
                'Import podcast list (OPML)',
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              onTap: () => debugPrint(
                'Add podcast by RSS URL',
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: ref.watch(openAirProvider.select((p) => p.isPodcastSelected))
            ? 80.0
            : 0.0,
        child: ref.watch(openAirProvider.select((p) => p.isPodcastSelected))
            ? const BannerAudioPlayer()
            : const SizedBox.shrink(),
      ),
    );
  }
}
